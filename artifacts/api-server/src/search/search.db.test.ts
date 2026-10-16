// Gerçek Postgres gerektiren testler. TEST_DATABASE_URL verilmezse atlanır.
// Şema önceden uygulanmış olmalı: DATABASE_URL=... pnpm --filter @workspace/db run push-force
import assert from "node:assert/strict";
import type { AddressInfo } from "node:net";
import { after, before, describe, test } from "node:test";
import { drizzle } from "drizzle-orm/node-postgres";
import pg from "pg";
import * as schema from "@workspace/db/schema";
import { createFlaggedPlaces } from "./community";
import { NO_FILTERS } from "./filters";
import { createPgInsightStore, INSIGHT_MAX_AGE_MS } from "./insight-store";
import type { PlaceInsight } from "./insights";
import { SearchService } from "./search-service";
import { createAnalyzer } from "./insights";

const url = process.env.TEST_DATABASE_URL;
const skip = url ? false : "TEST_DATABASE_URL tanımlı değil";

const insight = (placeId: string, analyzedAt: Date, summary = "Özet"): PlaceInsight => ({
  placeId,
  features: { alcohol: "no", helal: "unknown", glutenFree: "yes", celiacSafe: "unknown" },
  summary: { summary, whyGo: ["a", "b"], warnings: [], vibeTags: ["samimi"], highlights: [] },
  reviewCount: 5,
  model: "test",
  analyzedAt,
});

describe("Postgres", { skip }, () => {
  let pool: pg.Pool;
  let db: ReturnType<typeof drizzle<typeof schema>>;

  before(async () => {
    pool = new pg.Pool({ connectionString: url });
    db = drizzle(pool, { schema });
    await pool.query("TRUNCATE place_insights, venue_reports, installations CASCADE");
  });

  after(async () => {
    await pool.end();
  });

  test("analiz kaydı üzerine yazılır ve eskiyenler okunmaz", async () => {
    const now = Date.parse("2026-10-07T12:00:00Z");
    const store = createPgInsightStore(db, () => now);
    await store.saveMany([insight("p1", new Date(now - 1000)), insight("old", new Date(now - INSIGHT_MAX_AGE_MS - 1))]);
    await store.saveMany([insight("p1", new Date(now), "Yeni özet")]);

    const found = await store.getMany(["p1", "old", "none"]);
    assert.deepEqual([...found.keys()], ["p1"]);
    assert.equal(found.get("p1")!.summary.summary, "Yeni özet");
    assert.equal(found.get("p1")!.features.glutenFree, "yes");
    const { rows } = await pool.query("SELECT count(*)::int AS n FROM place_insights");
    assert.equal(rows[0].n, 2);
  });

  test("üç farklı kişinin açık bildirimi mekânı işaretler", async () => {
    for (const id of ["i1", "i2", "i3", "i4"]) {
      await db.insert(schema.installationsTable).values({ id });
    }
    const report = (installationId: string, placeId: string, status: "open" | "rejected" = "open") =>
      db.insert(schema.venueReportsTable).values({
        id: `${installationId}-${placeId}`,
        installationId,
        placeId,
        venueName: placeId,
        reportType: "closed",
        status,
      });
    await report("i1", "many");
    await report("i2", "many");
    await report("i3", "many");
    await report("i1", "few");
    await report("i2", "few");
    await report("i3", "few", "rejected");

    const flagged = await createFlaggedPlaces(db)(["many", "few", "none"]);
    assert.deepEqual([...flagged], ["many"]);
  });

  describe("HTTP", () => {
    let base: string;
    let close: () => void;

    before(async () => {
      process.env.DATABASE_URL = url;
      delete process.env.GOOGLE_PLACES_API_KEY;
      const { default: app } = await import("../app");
      const server = app.listen(0);
      await new Promise((r) => server.once("listening", r));
      base = `http://127.0.0.1:${(server.address() as AddressInfo).port}/api`;
      close = () => server.close();
    });

    after(() => close());

    /** Üretilen zod şemaları date-time alanlarını Date olarak bekler. */
    const json = async (res: Response) =>
      JSON.parse(await res.text(), (key, value) =>
        key === "analyzedAt" && typeof value === "string" ? new Date(value) : value,
      );

    const post = (path: string, body: unknown) =>
      fetch(`${base}${path}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });

    test("geçersiz istek 400, yapılandırılmamış arama 503", async () => {
      const { setSearchServiceForTesting } = await import("../routes/search");
      setSearchServiceForTesting(null);
      assert.equal((await post("/search", { city: "", query: "x" })).status, 400);
      assert.equal((await post("/search/insights", { placeIds: [] })).status, 400);
      assert.equal((await post("/search/insights", { placeIds: ["a", "b", "c", "d", "e", "f"] })).status, 400);
      assert.equal((await post("/search", { city: "İstanbul", query: "kahve" })).status, 503);
    });

    test("iki aşamalı akış sözleşmeye uyar", async () => {
      const { setSearchServiceForTesting } = await import("../routes/search");
      const { GetVenueInsightsResponse, SearchVenuesResponse, GetVenueResponse } = await import("@workspace/api-zod");
      const google = {
        id: "g1",
        name: "Kahve Durağı",
        rating: 4.6,
        userRatingCount: 320,
        types: ["cafe"],
        reviews: [{ text: "Filtre kahvesi çok iyi", rating: 5 }],
      };
      setSearchServiceForTesting(
        new SearchService({
          places: {
            textSearch: async () => [google, { ...google, id: "g2", name: "Fırın", servesBeer: true, servesWine: true }],
            placeDetails: async (id) => ({ ...google, id }),
            locatePlace: async () => null,
            geocode: async () => null,
          },
          store: createPgInsightStore(db),
          analyzer: createAnalyzer([
            {
              model: "fake",
              complete: async () =>
                JSON.stringify([
                  {
                    summary: "Üçüncü dalga kahveci.",
                    whyGo: ["Filtre kahve", "Sakin"],
                    warnings: [],
                    vibeTags: ["sakin"],
                    highlights: ["filtre kahve"],
                    alcohol: "no",
                    helal: "unknown",
                    glutenFree: "no",
                    celiacSafe: "unknown",
                  },
                ]),
            },
          ]),
          flaggedPlaces: createFlaggedPlaces(db),
        }),
      );

      const first = await post("/search", { city: "Kadıköy", query: "kahve", filters: { ...NO_FILTERS, alcoholFree: true } });
      assert.equal(first.status, 200);
      const result = SearchVenuesResponse.parse(await json(first));
      assert.deepEqual(result.venues.map((v) => v.placeId), ["g1"], "Google'a göre alkollü olan çıkarıldı");
      assert.deepEqual(result.pendingInsights, ["g1"]);

      const second = await post("/search/insights", { placeIds: ["g1"], filters: { ...NO_FILTERS, glutenFree: true } });
      const insights = GetVenueInsightsResponse.parse(await json(second));
      assert.deepEqual(insights.excludedPlaceIds, ["g1"], "glutensiz değil");

      const third = await post("/search/insights", { placeIds: ["g1"] });
      const venue = GetVenueInsightsResponse.parse(await json(third)).venues[0]!;
      assert.equal(venue.insight?.summary, "Üçüncü dalga kahveci.");

      const page = await fetch(`${base}/places/g1`);
      assert.equal(GetVenueResponse.parse(await json(page)).filterStatus, "none");
      setSearchServiceForTesting(undefined as never);
    });
  });
});
