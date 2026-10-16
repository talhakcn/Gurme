import assert from "node:assert/strict";
import { describe, test } from "node:test";
import type { PlaceInsightFeatures } from "@workspace/db/schema";
import { effectiveFeatures, filterStatus, googleAlcoholSignal, NO_FILTERS, queryPrefix } from "./filters";
import type { GeoBias, GooglePlace, PlacesClient } from "./google-places";
import { toGooglePlace } from "./google-places";
import { createMemoryInsightStore, INSIGHT_MAX_AGE_MS } from "./insight-store";
import { buildPrompt, createAnalyzer, parseInsights, type AiProvider } from "./insights";
import { categorize, rank } from "./ranking";
import { SearchError, SearchService } from "./search-service";
import { containsAny, foldTr, lowerTr } from "./text";
import { TtlCache } from "./ttl-cache";

function place(overrides: Partial<GooglePlace> & { id: string }): GooglePlace {
  return {
    name: overrides.id,
    rating: 4.5,
    userRatingCount: 500,
    address: "Moda, Kadıköy/İstanbul",
    location: { lat: 40.98, lng: 29.03 },
    types: ["restaurant"],
    reviews: [{ text: "Lahmacunu çok iyi.", rating: 5 }],
    ...overrides,
  };
}

const unknownFeatures: PlaceInsightFeatures = {
  alcohol: "unknown",
  helal: "unknown",
  glutenFree: "unknown",
  celiacSafe: "unknown",
};

const aiItem = (overrides: Record<string, unknown> = {}) => ({
  summary: "Mahalle lahmacuncusu.",
  whyGo: ["İnce hamur", "Hızlı servis"],
  warnings: [],
  vibeTags: ["samimi", "olmayan-etiket"],
  highlights: ["lahmacun"],
  alcohol: "no",
  helal: "unknown",
  glutenFree: "unknown",
  celiacSafe: "unknown",
  ...overrides,
});

describe("text", () => {
  test("Türkçe küçük harf ve sadeleştirme", () => {
    assert.equal(lowerTr("IĞDIR İZMİR"), "ığdır izmir");
    assert.equal(foldTr("  Köfte,  KADIKÖY!! "), "kofte kadikoy");
    assert.equal(foldTr("Çiğ Köfte"), foldTr("cig kofte"));
  });

  test("kısa anahtar kelimeler tam kelime olarak eşleşir", () => {
    assert.equal(containsAny("Barbekü Evi", ["bar"]), false);
    assert.equal(containsAny("Barış Lokantası", ["bar"]), false);
    assert.equal(containsAny("Moda Bar", ["bar"]), true);
    assert.equal(containsAny("Biracı Hasan", ["bira"]), true, "uzun kelime ek alabilir");
  });
});

describe("TtlCache", () => {
  test("süresi dolan kayıt silinir, sınır aşılınca en eski atılır", () => {
    let now = 0;
    const cache = new TtlCache<number>(2, 100, () => now);
    cache.set("a", 1);
    cache.set("b", 2);
    cache.get("a"); // a artık en yeni
    cache.set("c", 3);
    assert.equal(cache.get("b"), undefined);
    assert.equal(cache.get("a"), 1);
    now = 101;
    assert.equal(cache.get("a"), undefined);
  });
});

describe("filters", () => {
  test("Google alkol sinyali", () => {
    assert.equal(googleAlcoholSignal(place({ id: "a", servesBeer: true, servesWine: true })), "yes");
    assert.equal(googleAlcoholSignal(place({ id: "b", servesBeer: true })), "unknown", "tek alan yetmez");
    assert.equal(
      googleAlcoholSignal(place({ id: "c", servesBeer: false, servesWine: false, servesCocktails: false })),
      "no",
    );
    assert.equal(googleAlcoholSignal(place({ id: "d", types: ["bar"] })), "yes");
    assert.equal(googleAlcoholSignal(place({ id: "Halal Grill", name: "Halal Grill", types: ["bar"] })), "unknown");
  });

  test("Google'ın kesin verisi yapay zekâ tahmininden önce gelir", () => {
    const dry = place({ id: "a", servesBeer: false, servesWine: false, servesCocktails: false });
    assert.equal(effectiveFeatures(dry, { ...unknownFeatures, alcohol: "yes" }).alcohol, "no");
    const unknown = place({ id: "b" });
    assert.equal(effectiveFeatures(unknown, { ...unknownFeatures, alcohol: "yes" }).alcohol, "yes");
    assert.equal(effectiveFeatures(place({ id: "c", name: "Moda Meyhanesi" }), null).alcohol, "yes");
  });

  test("filtre uyumu", () => {
    const f = { ...NO_FILTERS, glutenFree: true };
    assert.equal(filterStatus(NO_FILTERS, unknownFeatures), "none");
    assert.equal(filterStatus(f, unknownFeatures), "unverified");
    assert.equal(filterStatus(f, { ...unknownFeatures, glutenFree: "yes" }), "likely");
    assert.equal(filterStatus(f, { ...unknownFeatures, glutenFree: "no" }), null);
    // Helal, alkolsüz olmayı da gerektirir.
    const helal = { ...NO_FILTERS, helal: true };
    assert.equal(filterStatus(helal, { ...unknownFeatures, helal: "yes", alcohol: "yes" }), null);
    assert.equal(filterStatus(helal, { ...unknownFeatures, helal: "yes", alcohol: "no" }), "likely");
    assert.equal(queryPrefix({ ...NO_FILTERS, celiac: true, helal: true }), "çölyak dostu glutensiz");
  });
});

describe("ranking", () => {
  test("kalite eşiği ve gevşetme", () => {
    const strong = [place({ id: "a" }), place({ id: "b", rating: 4.8 }), place({ id: "c", rating: 3.0 })];
    const ranked = rank(strong, "lahmacun", null, 10);
    assert.deepEqual(ranked.places.map((p) => p.id), ["b", "a"]);
    assert.equal(ranked.limited, false);

    const weak = [place({ id: "a" }), place({ id: "b", rating: 3.5 }), place({ id: "c", userRatingCount: 5 })];
    const relaxed = rank(weak, "lahmacun", null, 10);
    assert.equal(relaxed.limited, true);
    assert.equal(relaxed.places[0]!.id, "a");
  });

  test("adında aranan kelime geçen mekân öne çıkar", () => {
    const ranked = rank(
      [place({ id: "big", userRatingCount: 900 }), place({ id: "Lahmacun Durağı", name: "Lahmacun Durağı", userRatingCount: 300 })],
      "lahmacun",
      null,
      10,
    );
    assert.equal(ranked.places[0]!.id, "Lahmacun Durağı");
  });

  test("gözde ve gizli keşif", () => {
    const categories = categorize([
      place({ id: "classic", rating: 4.5, userRatingCount: 5000 }),
      place({ id: "hidden", rating: 4.8, userRatingCount: 80 }),
      place({ id: "other", rating: 4.0, userRatingCount: 400 }),
    ]);
    assert.equal(categories.get("classic"), "classic");
    assert.equal(categories.get("hidden"), "discovery");
    assert.equal(categories.get("other"), "option");
  });
});

describe("insights", () => {
  test("model yanıtı ayrıştırılır ve sınırlar uygulanır", () => {
    const text = "Tabii:\n```json\n" + JSON.stringify([aiItem({ helal: "belki" }), { whyGo: [] }]) + "\n```";
    const [first, second] = parseInsights(text, 2);
    assert.equal(first?.helal, "unknown", "geçersiz değer bilinmiyor sayılır");
    assert.deepEqual(first?.vibeTags, ["samimi"], "listede olmayan etiket atılır");
    assert.equal(second, null, "boş whyGo analiz sayılmaz");
    assert.throws(() => parseInsights("JSON yok", 1));
  });

  test("istem yalnızca yorumları ve kuralları içerir", () => {
    const prompt = buildPrompt([place({ id: "a", name: "Lahmacun Durağı" })]);
    assert.match(prompt, /Lahmacun Durağı/);
    assert.match(prompt, /Lahmacunu çok iyi/);
    assert.match(prompt, /1 elemanlı/);
  });

  test("ilk sağlayıcı başarısız olursa sonrakine geçilir; yorumsuz mekân analiz edilmez", async () => {
    const calls: string[] = [];
    const failing: AiProvider = { model: "a", complete: async () => { calls.push("a"); throw new Error("down"); } };
    const working: AiProvider = { model: "b", complete: async () => { calls.push("b"); return JSON.stringify([aiItem()]); } };
    const analyzer = createAnalyzer([failing, working], () => new Date("2026-10-07T00:00:00Z"));
    const result = await analyzer.analyze([place({ id: "x" }), place({ id: "y", reviews: [] })]);
    assert.deepEqual(calls, ["a", "b"]);
    assert.equal(result.length, 1);
    assert.equal(result[0]!.placeId, "x");
    assert.equal(result[0]!.model, "b");
    assert.equal(result[0]!.features.alcohol, "no");
  });
});

/** Google ve yapay zekâ yerine geçen sahte bağımlılıklar. */
function harness(found: GooglePlace[], aiResponse: (prompt: string) => string = () => JSON.stringify(found.map(() => aiItem()))) {
  const counts = { textSearch: 0, details: 0, geocode: 0, ai: 0 };
  const queries: string[] = [];
  let now = Date.parse("2026-10-07T12:00:00Z");
  const bias: GeoBias = { lat: 40.98, lng: 29.03, radiusKm: 5 };
  const places: PlacesClient = {
    async textSearch(query) {
      counts.textSearch++;
      queries.push(query);
      return found;
    },
    async placeDetails(placeId) {
      counts.details++;
      return place({ id: placeId, name: "Detaydan gelen" });
    },
    async locatePlace() {
      return bias;
    },
    async geocode() {
      counts.geocode++;
      return bias;
    },
  };
  const store = createMemoryInsightStore(() => now);
  const analyzer = createAnalyzer([
    { model: "fake", complete: async (prompt) => { counts.ai++; return aiResponse(prompt); } },
  ], () => new Date(now));
  const service = new SearchService({
    places,
    store,
    analyzer,
    flaggedPlaces: async (ids) => new Set(ids.filter((id) => id === "flagged")),
    now: () => now,
  });
  return { service, counts, queries, store, advance: (ms: number) => { now += ms; } };
}

const request = { city: "Kadıköy, İstanbul", query: "lahmacun", filters: NO_FILTERS };

describe("SearchService", () => {
  test("birinci aşama yapay zekâ çağırmaz; ilk 3 analiz bekler", async () => {
    const h = harness([1, 2, 3, 4].map((i) => place({ id: `p${i}` })));
    const result = await h.service.search(request);
    assert.equal(h.counts.textSearch, 1);
    assert.equal(h.counts.ai, 0);
    assert.equal(result.venues.length, 4);
    assert.equal(result.pendingInsights.length, 3);
    assert.ok(result.venues.every((v) => v.insight === null));
    assert.equal(h.queries[0], "lahmacun Kadıköy, İstanbul");
  });

  test("ikinci aşama tek analizde birden çok mekânı işler ve kaydeder", async () => {
    const h = harness([place({ id: "p1" }), place({ id: "p2" })]);
    await h.service.search(request);
    const venues = await h.service.insights(["p1", "p2"], NO_FILTERS);
    assert.equal(h.counts.ai, 1);
    assert.equal(h.counts.details, 0, "yorumlar ilk aşamadan bellekte");
    assert.ok(venues.every((v) => v.insight?.summary === "Mahalle lahmacuncusu."));
    assert.equal(h.store.rows.size, 2);

    // Sonraki arama kayıtlı analizi doğrudan döndürür.
    const again = await h.service.search({ ...request, query: "Lahmacun " });
    assert.equal(again.fromCache, true, "aynı sorgu (büyük/küçük harf, boşluk) önbellekten");
    assert.equal(h.counts.textSearch, 1);
    assert.deepEqual(again.pendingInsights, []);
    assert.ok(again.venues.every((v) => v.insight !== null));
  });

  test("eşzamanlı analiz istekleri tek çağrıyı paylaşır", async () => {
    const h = harness([place({ id: "p1" })]);
    await h.service.search(request);
    await Promise.all([h.service.insights(["p1"], NO_FILTERS), h.service.insights(["p1"], NO_FILTERS)]);
    assert.equal(h.counts.ai, 1);
  });

  test("aramada görünmeyen mekân Place Details ile analiz edilir", async () => {
    const h = harness([], () => JSON.stringify([aiItem()]));
    const [venue] = await h.service.insights(["elsewhere"], NO_FILTERS);
    assert.equal(h.counts.details, 1);
    assert.equal(venue!.name, "Detaydan gelen");
    assert.notEqual(venue!.insight, null);
  });

  test("alkolsüz aramada Google'ın kesin alkollü bulduğu mekân listelenmez", async () => {
    const h = harness([
      place({ id: "dry" }),
      place({ id: "wet", servesBeer: true, servesWine: true }),
      place({ id: "pub", types: ["pub"] }),
    ]);
    const result = await h.service.search({ ...request, filters: { ...NO_FILTERS, alcoholFree: true } });
    assert.deepEqual(result.venues.map((v) => v.placeId), ["dry"]);
    assert.equal(result.venues[0]!.filterStatus, "unverified");
  });

  test("analiz filtreye uymadığını gösterirse ikinci aşamada çıkarılır", async () => {
    const h = harness([place({ id: "p1" })], () => JSON.stringify([aiItem({ glutenFree: "no" })]));
    const filters = { ...NO_FILTERS, glutenFree: true };
    const result = await h.service.search({ ...request, filters });
    assert.equal(h.queries[0], "glutensiz lahmacun Kadıköy, İstanbul");
    assert.equal(result.venues[0]!.filterStatus, "unverified");
    const [venue] = await h.service.insights(["p1"], filters);
    assert.equal(venue!.filterStatus, null);
  });

  test("topluluk bildirimi işareti", async () => {
    const h = harness([place({ id: "flagged" }), place({ id: "ok" })]);
    const result = await h.service.search(request);
    assert.equal(result.venues.find((v) => v.placeId === "flagged")?.needsVerification, true);
    assert.equal(result.venues.find((v) => v.placeId === "ok")?.needsVerification, false);
  });

  test("30 günden eski analiz yeniden yapılır", async () => {
    const h = harness([place({ id: "p1" })]);
    await h.service.search(request);
    await h.service.insights(["p1"], NO_FILTERS);
    h.advance(INSIGHT_MAX_AGE_MS + 1);
    await h.service.insights(["p1"], NO_FILTERS);
    assert.equal(h.counts.ai, 2);
  });

  test("Google hatası kullanıcıya anlaşılır bir hata olarak döner", async () => {
    const h = harness([]);
    const failing = new SearchService({
      places: { ...h.service["deps"].places, textSearch: async () => { throw new Error("quota"); } },
      store: createMemoryInsightStore(),
      analyzer: createAnalyzer([]),
      flaggedPlaces: async () => new Set(),
    });
    await assert.rejects(failing.search(request), (err) => err instanceof SearchError && err.status === 503);
  });
});

test("Google yanıtı dönüştürülür", () => {
  const p = toGooglePlace({
    id: "abc",
    displayName: { text: "Kahve Durağı" },
    location: { latitude: 41, longitude: 29 },
    reviews: [{ originalText: { text: " Harika " }, text: { text: "Great" }, rating: 5 }, { text: { text: "" } }],
  });
  assert.equal(p.name, "Kahve Durağı");
  assert.deepEqual(p.location, { lat: 41, lng: 29 });
  assert.deepEqual(p.reviews, [{ text: "Harika", rating: 5 }]);
  assert.deepEqual(p.types, []);
});

