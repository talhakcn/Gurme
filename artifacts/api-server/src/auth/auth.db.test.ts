// Hesap sistemi, kota ve sahiplik: gerçek Postgres ve sahte Firebase ile.
// TEST_DATABASE_URL verilmezse atlanır; şema önceden uygulanmış olmalı.
import assert from "node:assert/strict";
import type { AddressInfo } from "node:net";
import { after, before, beforeEach, describe, test } from "node:test";
import { drizzle } from "drizzle-orm/node-postgres";
import pg from "pg";
import * as schema from "@workspace/db/schema";
import { createMemoryInsightStore } from "../search/insight-store";
import { createAnalyzer } from "../search/insights";
import { SearchService } from "../search/search-service";
import type { AuthConfig, AuthVerifier } from "./auth";
import { createPgQuotaStore, FREE_SEARCHES_PER_DAY, istanbulDay } from "./quota";

const url = process.env.TEST_DATABASE_URL;
const skip = url ? false : "TEST_DATABASE_URL tanımlı değil";

/** "test.<uid>.sig" biçimindeki token'ı kabul eden sahte Firebase. */
const fakeVerifier: AuthVerifier = {
  async verifyIdToken(token) {
    const [, uid] = token.split(".");
    if (!uid || uid === "expired") throw new Error("invalid");
    return { uid, email: `${uid}@ornek.test` };
  },
  async verifyAppCheck(token) {
    if (token !== "app-ok") throw new Error("invalid");
  },
};

const tokenFor = (uid: string) => `test.${uid}.sig`;

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const json = async (res: Response): Promise<any> => res.json();

describe("hesap ve kota (Postgres)", { skip }, () => {
  let pool: pg.Pool;
  let db: ReturnType<typeof drizzle<typeof schema>>;
  let base: string;
  let close: () => void;
  let setAuth: (config: AuthConfig | undefined, store?: ReturnType<typeof createPgQuotaStore>) => void;
  let textSearches = 0;

  before(async () => {
    pool = new pg.Pool({ connectionString: url });
    db = drizzle(pool, { schema });
    process.env.DATABASE_URL = url;
    delete process.env.GOOGLE_PLACES_API_KEY;
    const runtime = await import("./runtime");
    setAuth = runtime.setAuthForTesting;
    const { setSearchServiceForTesting } = await import("../routes/search");
    setSearchServiceForTesting(
      new SearchService({
        places: {
          textSearch: async (query) => {
            textSearches++;
            return [{ id: `p-${query}`, name: query, rating: 4.5, userRatingCount: 300, types: [], reviews: [] }];
          },
          placeDetails: async (id) => ({ id, name: id, types: [], reviews: [] }),
          locatePlace: async () => null,
          geocode: async () => null,
        },
        store: createMemoryInsightStore(),
        analyzer: createAnalyzer([]),
        flaggedPlaces: async () => new Set(),
      }),
    );
    const { default: app } = await import("../app");
    const server = app.listen(0);
    await new Promise((r) => server.once("listening", r));
    base = `http://127.0.0.1:${(server.address() as AddressInfo).port}/api`;
    close = () => server.close();
  });

  beforeEach(async () => {
    await pool.query(
      "TRUNCATE daily_usage, users, checkins, venue_reactions, venue_reports, installations, gurme_lists CASCADE",
    );
    setAuth({ verifier: fakeVerifier, enforceAppCheck: false }, createPgQuotaStore(db));
  });

  after(async () => {
    close();
    await pool.end();
  });

  const call = (method: string, path: string, options: { uid?: string; body?: unknown; headers?: Record<string, string> } = {}) =>
    fetch(`${base}${path}`, {
      method,
      headers: {
        "Content-Type": "application/json",
        ...(options.uid ? { Authorization: `Bearer ${tokenFor(options.uid)}` } : {}),
        ...options.headers,
      },
      body: options.body === undefined ? undefined : JSON.stringify(options.body),
    });

  const search = (uid: string | undefined, query: string) =>
    call("POST", "/search", { uid, body: { city: "Kadıköy", query } });

  test("arama giriş ister; geçersiz token 401", async () => {
    const anonymous = await search(undefined, "kahve");
    assert.equal(anonymous.status, 401);
    assert.equal((await json(anonymous)).code, "auth_required");
    assert.equal((await search("expired", "kahve")).status, 401);
  });

  test("günde 3 yeni arama; önbellekten dönen aramalar sayılmaz", async () => {
    for (let i = 0; i < FREE_SEARCHES_PER_DAY; i++) {
      const res = await search("ayse", `sorgu-${i}`);
      assert.equal(res.status, 200);
      const body = await json(res);
      assert.equal(body.quota.searchesUsed, i + 1);
    }
    const denied = await search("ayse", "yeni-sorgu");
    assert.equal(denied.status, 429);
    const deniedBody = await json(denied);
    assert.equal(deniedBody.code, "quota_exceeded");
    assert.equal(deniedBody.quota.searchesLimit, FREE_SEARCHES_PER_DAY);

    const before = textSearches;
    const cached = await search("ayse", "sorgu-0");
    assert.equal(cached.status, 200, "hak bitse de önbellekteki sonuç döner");
    assert.equal((await json(cached)).fromCache, true);
    assert.equal(textSearches, before, "Google'a gidilmedi");

    // Başka kullanıcının hakkı ayrı.
    assert.equal((await search("mehmet", "yeni-sorgu")).status, 200);

    const quota = await call("GET", "/me/quota", { uid: "ayse" });
    assert.equal((await json(quota)).searchesUsed, FREE_SEARCHES_PER_DAY);
  });

  test("kota eşzamanlı isteklerde aşılmaz", async () => {
    const store = createPgQuotaStore(db);
    await store.touchUser({ uid: "yaris" });
    const day = istanbulDay(new Date());
    const results = await Promise.all(Array.from({ length: 10 }, () => store.consumeSearch("yaris", day)));
    assert.equal(results.filter(Boolean).length, FREE_SEARCHES_PER_DAY);
  });

  test("aynı anda gönderilen aramalar Google'a kotadan fazla gitmez", async () => {
    const before = textSearches;
    const responses = await Promise.all(
      Array.from({ length: 10 }, (_, i) => search("eszamanli", `ayni-anda-${i}`)),
    );
    const statuses = responses.map((r) => r.status);
    assert.equal(statuses.filter((s) => s === 200).length, FREE_SEARCHES_PER_DAY);
    assert.equal(statuses.filter((s) => s === 429).length, 10 - FREE_SEARCHES_PER_DAY);
    assert.equal(textSearches - before, FREE_SEARCHES_PER_DAY, "reddedilen arama Google'a gitmedi");
  });

  test("App Check zorunluysa uygulama doğrulanmadan arama yapılamaz", async () => {
    setAuth({ verifier: fakeVerifier, enforceAppCheck: true }, createPgQuotaStore(db));
    assert.equal((await search("ayse", "kahve")).status, 401);
    const ok = await call("POST", "/search", {
      uid: "ayse",
      body: { city: "Kadıköy", query: "kahve" },
      headers: { "X-Firebase-AppCheck": "app-ok" },
    });
    assert.equal(ok.status, 200);
  });

  test("kişisel notlar yalnızca kurulumun sahibine görünür", async () => {
    const installationId = "kurulum-ayse-0001";
    const checkin = {
      id: "checkin-0000000001",
      installationId,
      placeId: "p1",
      venueName: "Kahve Durağı",
      tags: [],
      note: "Gizli not",
      checkedAt: "2026-10-07T10:00:00.000Z",
    };
    assert.equal((await call("POST", "/feedback/checkins", { body: checkin })).status, 401);
    assert.equal((await call("POST", "/feedback/checkins", { uid: "ayse", body: checkin })).status, 201);

    const stranger = await call("GET", `/feedback/${installationId}`, { uid: "mehmet" });
    assert.equal(stranger.status, 404, "başkası okuyamaz");
    const hijack = await call("POST", "/feedback/checkins", {
      uid: "mehmet",
      body: { ...checkin, id: "checkin-0000000002" },
    });
    assert.equal(hijack.status, 403, "başkasının kurulumuna yazılamaz");

    const own = await call("GET", `/feedback/${installationId}`, { uid: "ayse" });
    assert.equal(own.status, 200);
    assert.equal((await json(own)).checkins[0].note, "Gizli not");
  });

  test("aynı kişinin farklı kurulumlardan bildirimi tek sayılır", async () => {
    const report = (uid: string, installationId: string) =>
      call("POST", "/feedback/reports", {
        uid,
        body: { installationId, placeId: "p9", venueName: "Mekân", reportType: "closed" },
      });
    await report("ayse", "kurulum-ayse-0001");
    await report("ayse", "kurulum-ayse-0002");
    const third = await report("ayse", "kurulum-ayse-0003");
    const body = await json(third);
    assert.equal(body.reportCount, 1);
    assert.equal(body.verificationRequired, false);
  });

  test("liste hesaba bağlanır; anahtarsız düzenlenir, başkası düzenleyemez", async () => {
    const list = {
      title: "Sabah rotası",
      description: "",
      authorName: "Ayşe",
      visibility: "public",
      items: [],
    };
    const created = await json(await call("POST", "/gurme/lists", { uid: "ayse", body: list }));
    const update = (uid: string) =>
      call("PUT", `/gurme/lists/${created.id}`, { uid, body: { ...list, title: "Yeni ad" } });
    assert.equal((await update("mehmet")).status, 404);
    assert.equal((await update("ayse")).status, 200);

    // Anonim (cihaz anahtarıyla) oluşturulan liste sonradan hesaba bağlanır.
    const legacy = await json(await call("POST", "/gurme/lists", { body: list }));
    assert.equal((await call("PUT", `/gurme/lists/${legacy.id}`, { uid: "ayse", body: list })).status, 404);
    // Eski istemci: anahtar Authorization başlığında; bağlanmamış listede geçer.
    const oldClientUpdate = await fetch(`${base}/gurme/lists/${legacy.id}`, {
      method: "PUT",
      headers: { Authorization: `Bearer ${legacy.ownerKey}`, "Content-Type": "application/json" },
      body: JSON.stringify(list),
    });
    assert.equal(oldClientUpdate.status, 200);
    const claim = await call("POST", `/gurme/lists/${legacy.id}/claim`, {
      uid: "ayse",
      headers: { "X-Owner-Key": legacy.ownerKey },
    });
    assert.equal(claim.status, 200);
    assert.equal((await call("PUT", `/gurme/lists/${legacy.id}`, { uid: "ayse", body: list })).status, 200);

    // Hesaba bağlanan liste başka hesaba geçmez; anahtar bilinse de.
    const steal = await call("POST", `/gurme/lists/${legacy.id}/claim`, {
      uid: "mehmet",
      headers: { "X-Owner-Key": legacy.ownerKey },
    });
    assert.equal(steal.status, 404);
    const withKey = await call("PUT", `/gurme/lists/${legacy.id}`, {
      uid: "mehmet",
      body: list,
      headers: { "X-Owner-Key": legacy.ownerKey },
    });
    assert.equal(withKey.status, 404);
    const anonymous = await fetch(`${base}/gurme/lists/${legacy.id}`, {
      method: "DELETE",
      headers: { Authorization: `Bearer ${legacy.ownerKey}` },
    });
    assert.equal(anonymous.status, 404, "hesaba bağlı liste yalnızca o hesapla silinir");
    assert.equal((await call("DELETE", `/gurme/lists/${legacy.id}`, { uid: "ayse" })).status, 204);

    const mine = await json(await call("GET", "/gurme/lists", { uid: "ayse" }));
    assert.deepEqual(mine.map((l: { id: string }) => l.id), [created.id]);
  });
});
