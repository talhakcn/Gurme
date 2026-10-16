import assert from "node:assert/strict";
import { describe, test } from "node:test";
import { bearerJwt } from "./auth";
import { createMemoryQuotaStore, FREE_SEARCHES_PER_DAY, istanbulDay, nextResetAt } from "./quota";

describe("auth", () => {
  test("JWT ile liste anahtarı ayırt edilir", () => {
    assert.equal(bearerJwt("Bearer aaa.bbb.ccc"), "aaa.bbb.ccc");
    assert.equal(bearerJwt(`Bearer ${"f".repeat(64)}`), undefined, "64 hex liste anahtarı");
    assert.equal(bearerJwt(undefined), undefined);
  });
});

describe("quota", () => {
  test("gün Türkiye saatine göre", () => {
    assert.equal(istanbulDay(new Date("2026-10-06T20:59:00Z")), "2026-10-06");
    assert.equal(istanbulDay(new Date("2026-10-06T21:00:00Z")), "2026-10-07", "UTC+3 gece yarısı");
    assert.equal(nextResetAt("2026-10-07"), "2026-10-07T21:00:00.000Z");
  });

  test("günlük hak ve ödüllü ek hak", async () => {
    const quota = createMemoryQuotaStore();
    const day = "2026-10-07";
    for (let i = 0; i < FREE_SEARCHES_PER_DAY; i++) {
      assert.equal(await quota.consumeSearch("u", day), true);
    }
    assert.equal(await quota.consumeSearch("u", day), false);
    await quota.addBonusSearch("u", day);
    assert.equal(await quota.consumeSearch("u", day), true);
    assert.deepEqual(await quota.status("u", day), {
      searchesUsed: 4,
      searchesLimit: 4,
      resetsAt: "2026-10-07T21:00:00.000Z",
    });
    assert.equal(await quota.consumeSearch("u", "2026-10-08"), true, "ertesi gün sıfırlanır");
  });
});
