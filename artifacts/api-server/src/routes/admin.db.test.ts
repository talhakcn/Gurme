// Yönetim paneli uçları: gerçek Postgres, sahte Firebase ve sahte Google ile.
// TEST_DATABASE_URL verilmezse atlanır; şema önceden uygulanmış olmalı.
import assert from "node:assert/strict";
import type { AddressInfo } from "node:net";
import { after, before, beforeEach, describe, test } from "node:test";
import { drizzle } from "drizzle-orm/node-postgres";
import pg from "pg";
import * as schema from "@workspace/db/schema";
import type { AuthConfig, AuthVerifier } from "../auth/auth";
import { createPgQuotaStore } from "../auth/quota";
import { createMemoryInsightStore } from "../search/insight-store";
import { createAnalyzer } from "../search/insights";
import { SearchService } from "../search/search-service";

const url = process.env.TEST_DATABASE_URL;
const skip = url ? false : "TEST_DATABASE_URL tanımlı değil";

const fakeVerifier: AuthVerifier = {
  async verifyIdToken(token) {
    const [, uid] = token.split(".");
    if (!uid) throw new Error("invalid");
    return { uid, email: `${uid}@ornek.test`, admin: uid.startsWith("admin") };
  },
  async verifyAppCheck() {},
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const json = async (res: Response): Promise<any> => res.json();

describe("yönetim paneli (Postgres)", { skip }, () => {
  let pool: pg.Pool;
  let db: ReturnType<typeof drizzle<typeof schema>>;
  let base: string;
  let close: () => void;
  let setAuth: (config: AuthConfig | undefined, store?: ReturnType<typeof createPgQuotaStore>) => void;
  let resetTouched: () => void;

  before(async () => {
    pool = new pg.Pool({ connectionString: url });
    db = drizzle(pool, { schema });
    process.env.DATABASE_URL = url;
    delete process.env.GOOGLE_PLACES_API_KEY;
    const runtime = await import("../auth/runtime");
    setAuth = runtime.setAuthForTesting;
    resetTouched = (await import("../lib/touch-user")).resetTouchedUsersForTesting;
    const { setSearchServiceForTesting } = await import("./search");
    setSearchServiceForTesting(
      new SearchService({
        places: {
          textSearch: async (query) => [
            { id: `p-${query}`, name: query, rating: 4.5, userRatingCount: 300, types: [], reviews: [] },
          ],
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
      "TRUNCATE search_log, list_reports, daily_usage, users, venue_reports, installations, gurme_lists CASCADE",
    );
    resetTouched();
    setAuth({ verifier: fakeVerifier, enforceAppCheck: false }, createPgQuotaStore(db));
  });

  after(async () => {
    close();
    await pool.end();
  });

  const call = (method: string, path: string, options: { uid?: string; body?: unknown } = {}) =>
    fetch(`${base}${path}`, {
      method,
      headers: {
        "Content-Type": "application/json",
        ...(options.uid ? { Authorization: `Bearer test.${options.uid}.sig` } : {}),
      },
      body: options.body === undefined ? undefined : JSON.stringify(options.body),
    });
  const search = (uid: string, query: string) =>
    call("POST", "/search", { uid, body: { city: "Kadıköy", query } });
  const admin = (path: string) => call("GET", path, { uid: "admin-semih" });

  /** Arama kaydı yanıtı bekletmeden yazılır; yazılana kadar beklenir. */
  async function waitForLog(n: number): Promise<void> {
    for (let i = 0; i < 50; i++) {
      const { rows } = await pool.query("SELECT count(*)::int AS n FROM search_log");
      if (rows[0].n >= n) return;
      await new Promise((r) => setTimeout(r, 20));
    }
    assert.fail(`arama kaydı ${n} satıra ulaşmadı`);
  }

  test("yönetim uçları yalnızca yöneticiye açık", async () => {
    for (const path of ["/admin/overview", "/admin/users", "/admin/searches", "/admin/lists"]) {
      assert.equal((await call("GET", path, { uid: "ayse" })).status, 403, path);
      assert.equal((await admin(path)).status, 200, path);
    }
    assert.equal((await call("POST", "/admin/users/ayse/bonus", { uid: "ayse", body: { count: 1 } })).status, 403);
  });

  test("genel bakış kullanıcıları, aramaları ve sayaçları gösterir", async () => {
    assert.equal((await search("ayse", "kahve")).status, 200);
    assert.equal((await search("ayse", "kahve")).status, 200, "ikincisi önbellekten");
    await call("GET", "/gurme/lists", { uid: "mehmet" }); // arama yapmadan giren hesap
    await waitForLog(2);

    const overview = await json(await admin("/admin/overview"));
    // Yöneticinin kendi kaydı yanıtı bekletmeden yazılır; sayılmış olmayabilir.
    assert.ok(overview.users.total >= 2, "ayse ve arama yapmadan giren mehmet");
    assert.ok(overview.users.activeToday >= 2);
    assert.equal(overview.days.length, 7);
    const today = overview.days.at(-1);
    assert.equal(today.day, overview.today);
    assert.equal(today.searches, 1, "önbellekten dönen sayılmaz");
    assert.deepEqual(today.outcomes, { ok: 1, cached: 1 });
    assert.equal(typeof overview.budgets.places.limit, "number");
    assert.equal(overview.server.authEnabled, true);
  });

  test("kullanıcı aranır, ayrıntısı açılır, hak verilir, arama kapatılır", async () => {
    await search("ayse", "lahmacun");
    await waitForLog(1);
    const users = await json(await admin("/admin/users?q=ayse"));
    assert.equal(users.length, 1);
    assert.equal(users[0].email, "ayse@ornek.test");
    assert.equal(users[0].searchesToday, 1);

    const detail = await json(await admin("/admin/users/ayse"));
    assert.equal(detail.today.searches, 1);
    assert.equal(detail.today.searchesLimit, 3);
    assert.equal(detail.searches[0].query, "lahmacun");
    assert.equal((await admin("/admin/users/kimse")).status, 404);

    const bonus = await call("POST", "/admin/users/ayse/bonus", { uid: "admin-semih", body: { count: 2 } });
    assert.equal((await json(bonus)).searchesLimit, 5);
    assert.equal((await call("POST", "/admin/users/ayse/bonus", { uid: "admin-semih", body: { count: 99 } })).status, 400);

    await call("POST", "/admin/users/ayse/search", { uid: "admin-semih", body: { blocked: true } });
    const blocked = await search("ayse", "pide");
    assert.equal(blocked.status, 403);
    assert.equal((await json(blocked)).code, "search_blocked");
    assert.equal((await call("GET", "/places/ChIJabcdefghij", { uid: "ayse" })).status, 403);
    assert.equal((await json(await admin("/admin/users?filter=blocked"))).length, 1);

    await call("POST", "/admin/users/ayse/search", { uid: "admin-semih", body: { blocked: false } });
    assert.equal((await search("ayse", "pide")).status, 200);
  });

  test("aramalar ve en çok arananlar", async () => {
    await search("ayse", "Kahve");
    await search("mehmet", "kahve");
    await search("mehmet", "börek");
    await waitForLog(3);
    const searches = await json(await admin("/admin/searches"));
    assert.equal(searches.recent.length, 3);
    assert.equal(searches.recent[0].email, "mehmet@ornek.test");
    assert.deepEqual(searches.topQueries[0], { value: "kahve", n: 2 });
    assert.deepEqual(searches.topCities[0], { value: "Kadıköy", n: 3 });
    // Sahte aramanın önbelleği testler arasında kalır; süzgeç yalnızca o sonucu döndürür.
    const cachedOnly = await json(await admin("/admin/searches?outcome=cached"));
    assert.ok(cachedOnly.recent.every((r: { outcome: string }) => r.outcome === "cached"));
    const ok = await json(await admin("/admin/searches?outcome=ok"));
    assert.equal(ok.recent.length + cachedOnly.recent.length, 3);
  });

  test("paylaşılan listeler sahibinin e-postasıyla; mekân bildirimleri yöneticiye açık", async () => {
    const created = await call("POST", "/gurme/lists", {
      uid: "ayse",
      body: {
        title: "Sabah rotası",
        description: "",
        authorName: "Ayşe",
        visibility: "public",
        items: [{ placeId: "p1", name: "Kahve Durağı", area: "Moda", category: "Kahve", note: "" }],
      },
    });
    assert.equal(created.status, 201);
    const lists = await json(await admin("/admin/lists"));
    assert.equal(lists.length, 1);
    assert.equal(lists[0].ownerEmail, "ayse@ornek.test");
    assert.equal(lists[0].itemCount, 1);
    assert.equal((await json(await admin("/admin/lists?filter=hidden"))).length, 0);
    assert.equal((await admin("/feedback/admin/reports")).status, 200, "yönetici hesabı mekân bildirimlerini görür");
  });
});
