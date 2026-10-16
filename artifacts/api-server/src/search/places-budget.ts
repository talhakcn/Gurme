import { AsyncLocalStorage } from "node:async_hooks";
import { istanbulDay } from "../auth/quota";

/**
 * Google Places'e günde gönderilebilecek en fazla istek. Google konsolunda
 * deneme hesabında kota düzenlenemediği için fatura koruması sunucuda.
 * `PLACES_DAILY_LIMIT` ile değiştirilir.
 *
 * Sayaç her sunucu örneğinin belleğindedir: Cloud Run birden çok örnek
 * açarsa toplam sınır örnek sayısıyla çarpılır. Bu yüzden hizmet
 * `--max-instances=1` ile çalıştırılmalıdır.
 */
export const DEFAULT_PLACES_DAILY_LIMIT = 100;

/**
 * Tek bir kullanıcının ortak sayaçtan günde harcayabileceği en fazla istek.
 * Böylece tek hesap ortak sınırı bitirip aramayı herkes için durduramaz.
 * `PLACES_USER_DAILY_LIMIT` ile değiştirilir.
 */
export const DEFAULT_PLACES_USER_DAILY_LIMIT = 30;

/**
 * İsteği yapan kullanıcı; `app.ts` her isteği bunun içinde çalıştırır.
 * Google'a giden çağrılar sayaçta bu kullanıcıya yazılır.
 */
export const budgetUser = new AsyncLocalStorage<string | undefined>();

export type BudgetScope = "global" | "user";

export class PlacesBudgetExceeded extends Error {
  constructor(readonly scope: BudgetScope = "global") {
    super(
      scope === "user"
        ? "Kullanıcının günlük Google Places sınırı doldu."
        : "Google Places günlük istek sınırı doldu.",
    );
    this.name = "PlacesBudgetExceeded";
  }
}

export class PlacesBudget {
  private day = "";
  private used = 0;
  private readonly usedByUser = new Map<string, number>();

  constructor(
    readonly limit: number,
    private readonly now: () => Date = () => new Date(),
    readonly userLimit: number = Number.POSITIVE_INFINITY,
  ) {}

  /**
   * Bir istek hakkı düşer. Gün Türkiye saatine göre. Kullanıcı [user] ya da
   * [budgetUser] ile bilinir; girişsiz istekler yalnızca ortak sayaca yazılır.
   * Hak yoksa hiçbir sayaç değişmez ve dolan sayaç döner.
   */
  check(user: string | undefined = budgetUser.getStore()): BudgetScope | null {
    const today = istanbulDay(this.now());
    if (today !== this.day) {
      this.day = today;
      this.used = 0;
      this.usedByUser.clear();
    }
    const mine = user ? (this.usedByUser.get(user) ?? 0) : 0;
    if (user && mine >= this.userLimit) return "user";
    if (this.used >= this.limit) return "global";
    this.used++;
    if (user) this.usedByUser.set(user, mine + 1);
    return null;
  }

  /**
   * Bugünkü kullanım (yönetim paneli). Gün değiştiyse sıfır. En çok
   * harcayan kullanıcılar azalan sırayla.
   */
  snapshot(top = 5): {
    day: string;
    used: number;
    limit: number;
    userLimit: number | null;
    topUsers: Array<{ userId: string; used: number }>;
  } {
    const today = istanbulDay(this.now());
    const fresh = today === this.day;
    return {
      day: today,
      used: fresh ? this.used : 0,
      limit: this.limit,
      userLimit: Number.isFinite(this.userLimit) ? this.userLimit : null,
      topUsers: fresh
        ? [...this.usedByUser.entries()]
            .map(([userId, used]) => ({ userId, used }))
            .sort((a, b) => b.used - a.used)
            .slice(0, top)
        : [],
    };
  }

  /** Bir istek hakkı düşer; sınır doluysa `false`. */
  take(user?: string): boolean {
    return this.check(user) === null;
  }

  /** Hak yoksa [PlacesBudgetExceeded] fırlatır. */
  spend(): void {
    const full = this.check();
    if (full) throw new PlacesBudgetExceeded(full);
  }
}

/** Negatif olmayan tam sayı; geçersizse [fallback]. */
export function intFromEnv(value: string | undefined, fallback: number): number {
  const parsed = Number.parseInt(value ?? "", 10);
  return Number.isFinite(parsed) && parsed >= 0 ? parsed : fallback;
}

export function budgetFromEnv(env: NodeJS.ProcessEnv): PlacesBudget {
  return new PlacesBudget(
    intFromEnv(env.PLACES_DAILY_LIMIT, DEFAULT_PLACES_DAILY_LIMIT),
    undefined,
    intFromEnv(env.PLACES_USER_DAILY_LIMIT, DEFAULT_PLACES_USER_DAILY_LIMIT),
  );
}

/** Arama ve otomatik tamamlamanın paylaştığı sayaç. */
export const placesBudget = budgetFromEnv(process.env);
