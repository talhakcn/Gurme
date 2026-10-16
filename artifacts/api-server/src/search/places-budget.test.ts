import assert from "node:assert/strict";
import { describe, test } from "node:test";
import { createGooglePlacesClient } from "./google-places";
import {
  budgetFromEnv,
  budgetUser,
  DEFAULT_PLACES_DAILY_LIMIT,
  DEFAULT_PLACES_USER_DAILY_LIMIT,
  PlacesBudget,
  PlacesBudgetExceeded,
} from "./places-budget";

describe("PlacesBudget", () => {
  test("günlük sınırda durur, Türkiye saatiyle ertesi gün sıfırlanır", () => {
    let now = new Date("2026-10-14T10:00:00+03:00");
    const budget = new PlacesBudget(2, () => now);
    assert.equal(budget.take(), true);
    assert.equal(budget.take(), true);
    assert.equal(budget.take(), false);
    assert.throws(() => budget.spend(), PlacesBudgetExceeded);

    // UTC'de hâlâ 14 Ekim ama İstanbul'da 15 Ekim: yeni gün.
    now = new Date("2026-10-14T21:30:00Z");
    assert.equal(budget.take(), true);
  });

  test("sınır ortam değişkeninden okunur; geçersizse varsayılan", () => {
    assert.equal(budgetFromEnv({ PLACES_DAILY_LIMIT: "250" }).limit, 250);
    assert.equal(budgetFromEnv({}).limit, DEFAULT_PLACES_DAILY_LIMIT);
    assert.equal(budgetFromEnv({ PLACES_DAILY_LIMIT: "abc" }).limit, DEFAULT_PLACES_DAILY_LIMIT);
    assert.equal(budgetFromEnv({ PLACES_DAILY_LIMIT: "0" }).limit, 0);
  });

  test("tek kullanıcı ortak sınırın yalnızca kendi payını harcar", () => {
    const now = new Date("2026-10-14T10:00:00+03:00");
    const budget = new PlacesBudget(5, () => now, 2);
    assert.equal(budget.take("ayse"), true);
    assert.equal(budget.take("ayse"), true);
    assert.equal(budget.check("ayse"), "user", "kendi payı bitti");
    assert.equal(budget.take("mehmet"), true, "başkası etkilenmez");
    assert.equal(budget.take("mehmet"), true);
    assert.equal(budget.take(), true, "girişsiz istek yalnızca ortak sayaca yazılır");
    assert.equal(budget.check("zeynep"), "global", "ortak sınır doldu");
    assert.throws(
      () => budgetUser.run("ayse", () => budget.spend()),
      (err: unknown) => err instanceof PlacesBudgetExceeded && err.scope === "user",
    );
  });

  test("kullanıcı payı ortam değişkeninden okunur", () => {
    assert.equal(budgetFromEnv({ PLACES_USER_DAILY_LIMIT: "7" }).userLimit, 7);
    assert.equal(budgetFromEnv({}).userLimit, DEFAULT_PLACES_USER_DAILY_LIMIT);
  });

  test("sınır doluysa Google'a istek gitmeden hata döner", async () => {
    // Sınır 0: istek ağdan önce durdurulur (geçersiz anahtar fark etmez).
    const client = createGooglePlacesClient("gecersiz", new PlacesBudget(0));
    await assert.rejects(client.textSearch("lahmacun", null), PlacesBudgetExceeded);
    await assert.rejects(client.geocode("Moda"), PlacesBudgetExceeded);
  });
});
