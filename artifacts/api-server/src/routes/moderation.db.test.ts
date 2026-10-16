// Liste bildirme ve yönetim: gerçek Postgres ve sahte Firebase ile.
// TEST_DATABASE_URL verilmezse atlanır; şema önceden uygulanmış olmalı.
import assert from "node:assert/strict";
import type { AddressInfo } from "node:net";
import { after, before, beforeEach, describe, test } from "node:test";
import pg from "pg";
import type { AuthConfig, AuthVerifier } from "../auth/auth";

const url = process.env.TEST_DATABASE_URL;
const skip = url ? false : "TEST_DATABASE_URL tanımlı değil";

/** "test.<uid>.sig"; adı "admin" ile başlayan hesap yöneticidir. */
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

describe("liste bildirme ve yönetim (Postgres)", { skip }, () => {
  let pool: pg.Pool;
  let base: string;
  let close: () => void;
  let setAuth: (config: AuthConfig | undefined) => void;

  before(async () => {
    pool = new pg.Pool({ connectionString: url });
    process.env.DATABASE_URL = url;
    process.env.ADMIN_API_KEY = "acil-durum-anahtari-en-az-32-karakter";
    const runtime = await import("../auth/runtime");
    setAuth = runtime.setAuthForTesting;
    const { default: app } = await import("../app");
    const server = app.listen(0);
    await new Promise((r) => server.once("listening", r));
    base = `http://127.0.0.1:${(server.address() as AddressInfo).port}/api`;
    close = () => server.close();
  });

  beforeEach(async () => {
    await pool.query("TRUNCATE list_reports, users, gurme_lists CASCADE");
    setAuth({ verifier: fakeVerifier, enforceAppCheck: false });
  });

  after(async () => {
    close();
    await pool.end();
  });

  const call = (method: string, path: string, options: { uid?: string; body?: unknown; bearer?: string } = {}) =>
    fetch(`${base}${path}`, {
      method,
      headers: {
        "Content-Type": "application/json",
        ...(options.uid ? { Authorization: `Bearer test.${options.uid}.sig` } : {}),
        ...(options.bearer ? { Authorization: `Bearer ${options.bearer}` } : {}),
      },
      body: options.body === undefined ? undefined : JSON.stringify(options.body),
    });

  const listBody = (visibility: "private" | "unlisted" | "public") => ({
    title: "Sabah rotası",
    description: "Kadıköy'de kahve",
    authorName: "Ayşe",
    visibility,
    items: [{ placeId: "p1", name: "Kahve Durağı", area: "Moda", category: "Kahve", note: "" }],
  });

  async function publish(uid: string, visibility: "private" | "unlisted" | "public" = "public") {
    const res = await call("POST", "/gurme/lists", { uid, body: listBody(visibility) });
    assert.equal(res.status, 201);
    return (await json(res)).id as string;
  }

  const report = (uid: string | undefined, id: string, reason = "spam", note = "") =>
    call("POST", `/gurme/lists/${id}/report`, { uid, body: { reason, note } });

  test("bildirim giriş ister; hesap başına bir kez; kendi listesi bildirilemez", async () => {
    const id = await publish("ayse");
    assert.equal((await report(undefined, id)).status, 401);
    assert.equal((await report("mehmet", id, "spam", "Reklam")).status, 202);
    assert.equal((await report("mehmet", id, "offensive")).status, 202, "yinelenen bildirim sessizce yok sayılır");
    const own = await report("ayse", id);
    assert.equal(own.status, 400);
    assert.equal((await json(own)).code, "own_list");
    const { rows } = await pool.query("SELECT count(*)::int AS n FROM list_reports");
    assert.equal(rows[0].n, 1);

    // Özel liste bildirilemez (bağlantısı da yok).
    const hidden = await publish("ayse", "private");
    assert.equal((await report("mehmet", hidden)).status, 404);
  });

  test("yönetim uçları yöneticiye açık; acil durum anahtarı da geçer", async () => {
    assert.equal((await json(await call("GET", "/admin/me", { uid: "mehmet" }))).admin, false);
    assert.equal((await json(await call("GET", "/admin/me", { uid: "admin-semih" }))).admin, true);
    const denied = await call("GET", "/admin/list-reports", { uid: "mehmet" });
    assert.equal(denied.status, 403);
    assert.equal((await json(denied)).code, "admin_required");
    assert.equal((await call("GET", "/admin/list-reports")).status, 403);
    const byKey = await call("GET", "/admin/list-reports", { bearer: "acil-durum-anahtari-en-az-32-karakter" });
    assert.equal(byKey.status, 200);
  });

  test("bildirilen liste incelenir, kaldırılır ve geri açılır", async () => {
    const id = await publish("ayse");
    await report("mehmet", id, "spam", "Reklam dolu");
    await report("zeynep", id, "offensive");

    const queue = await json(await call("GET", "/admin/list-reports", { uid: "admin-semih" }));
    assert.equal(queue.length, 1);
    assert.equal(queue[0].id, id);
    assert.equal(queue[0].openReports, 2);
    assert.deepEqual(queue[0].reasons, { spam: 1, offensive: 1 });
    assert.deepEqual(queue[0].notes, ["Reklam dolu"]);
    assert.equal(queue[0].ownerUserId, "ayse");
    assert.equal(queue[0].hidden, false);

    // Yönetici olmayan kaldıramaz.
    assert.equal((await call("POST", `/admin/lists/${id}/moderation`, { uid: "mehmet", body: { action: "hide" } })).status, 403);

    const hidden = await call("POST", `/admin/lists/${id}/moderation`, { uid: "admin-semih", body: { action: "hide" } });
    assert.equal(hidden.status, 200);
    const state = await json(hidden);
    assert.equal(state.hidden, true);
    assert.equal(state.openReports, 0, "açık bildirimler kapandı");

    // Keşifte yok, paylaşım sayfası "kaldırıldı", başkası açamıyor; sahibi görüyor.
    const discover = await json(await call("GET", "/gurme/lists"));
    assert.equal(discover.some((l: { id: string }) => l.id === id), false);
    const share = await fetch(`${base}/gurme/share/${id}`);
    assert.equal(share.status, 410);
    assert.match(await share.text(), /kaldırıldı/);
    assert.equal((await call("GET", `/gurme/lists/${id}`, { uid: "mehmet" })).status, 404);
    assert.equal((await call("GET", `/gurme/lists/${id}`, { uid: "ayse" })).status, 200);
    assert.equal((await call("GET", `/gurme/lists/${id}`, { uid: "admin-semih" })).status, 200, "yönetici inceler");
    assert.equal((await json(await call("GET", "/admin/list-reports", { uid: "admin-semih" }))).length, 0, "açık kuyruk boş");
    assert.equal(
      (await json(await call("GET", "/admin/list-reports?status=all", { uid: "admin-semih" })))[0].totalReports,
      2,
    );

    // Sahibi düzenleyince kaldırma kalkmaz.
    assert.equal((await call("PUT", `/gurme/lists/${id}`, { uid: "ayse", body: listBody("public") })).status, 200);
    assert.equal((await fetch(`${base}/gurme/share/${id}`)).status, 410);

    const restored = await call("POST", `/admin/lists/${id}/moderation`, { uid: "admin-semih", body: { action: "restore" } });
    assert.equal((await json(restored)).hidden, false);
    assert.equal((await fetch(`${base}/gurme/share/${id}`)).status, 200);
  });

  test("bildirim yerinde bırakılabilir", async () => {
    const id = await publish("ayse");
    await report("mehmet", id, "misleading");
    const kept = await json(
      await call("POST", `/admin/lists/${id}/moderation`, { uid: "admin-semih", body: { action: "dismiss" } }),
    );
    assert.equal(kept.hidden, false);
    assert.equal(kept.openReports, 0);
    assert.equal((await fetch(`${base}/gurme/share/${id}`)).status, 200);
  });

  test("yayını kapatılan hesap yalnızca özel liste tutar", async () => {
    const id = await publish("ayse");
    const blocked = await call("POST", "/admin/users/ayse/publishing", { uid: "admin-semih", body: { blocked: true } });
    assert.equal(blocked.status, 200);
    assert.equal((await call("POST", "/admin/users/kimse/publishing", { uid: "admin-semih", body: { blocked: true } })).status, 404);

    const denied = await call("POST", "/gurme/lists", { uid: "ayse", body: listBody("public") });
    assert.equal(denied.status, 403);
    assert.equal((await json(denied)).code, "publishing_blocked");
    assert.equal((await call("PUT", `/gurme/lists/${id}`, { uid: "ayse", body: listBody("unlisted") })).status, 403);
    assert.equal((await call("PUT", `/gurme/lists/${id}`, { uid: "ayse", body: listBody("private") })).status, 200);
    assert.equal((await call("POST", "/gurme/lists", { uid: "ayse", body: listBody("private") })).status, 201);

    // Engel listede görünür, kalkınca yayın yeniden açılır.
    await report("mehmet", await publish("zeynep"));
    await call("POST", "/admin/users/ayse/publishing", { uid: "admin-semih", body: { blocked: false } });
    assert.equal((await call("POST", "/gurme/lists", { uid: "ayse", body: listBody("public") })).status, 201);
  });
});
