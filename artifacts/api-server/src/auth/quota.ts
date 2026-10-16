import { and, eq, sql } from "drizzle-orm";
import type { NodePgDatabase } from "drizzle-orm/node-postgres";
import { dailyUsageTable, usersTable } from "@workspace/db/schema";
import type { AuthUser } from "./auth";

/** Giriş yapmış kullanıcıya günde ücretsiz yapay zekâ araması. */
export const FREE_SEARCHES_PER_DAY = 3;
/** Mekân analizi istekleri için günlük üst sınır (maliyet koruması). */
export const INSIGHTS_PER_DAY = 40;

export interface QuotaStatus {
  searchesUsed: number;
  searchesLimit: number;
  /** Bir sonraki gün başlangıcı (Europe/Istanbul gece yarısı), ISO. */
  resetsAt: string;
}

export interface QuotaStore {
  /** Kullanıcıyı kaydeder ya da son görülme zamanını günceller. */
  touchUser(user: AuthUser): Promise<void>;
  status(userId: string, day: string): Promise<QuotaStatus>;
  /** Hakkı varsa bir arama düşer; yoksa `false`. */
  consumeSearch(userId: string, day: string): Promise<boolean>;
  /** Düşülen aramayı geri verir (arama başarısız oldu ya da önbellekten geldi). */
  refundSearch(userId: string, day: string): Promise<void>;
  /** Hakkı varsa bir analiz isteği düşer; yoksa `false`. */
  consumeInsight(userId: string, day: string): Promise<boolean>;
  /** Ödüllü reklam: gün için ek arama hakkı. */
  addBonusSearch(userId: string, day: string): Promise<void>;
}

const dayFormat = new Intl.DateTimeFormat("en-CA", {
  timeZone: "Europe/Istanbul",
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
});

/** Türkiye saatine göre gün: "2026-10-07". */
export function istanbulDay(now: Date): string {
  return dayFormat.format(now);
}

/** Türkiye 2016'dan beri yaz saati uygulamıyor: sabit UTC+3. */
export function nextResetAt(day: string): string {
  const midnight = new Date(`${day}T00:00:00+03:00`);
  return new Date(midnight.getTime() + 24 * 60 * 60 * 1000).toISOString();
}

export function createPgQuotaStore(
  db: NodePgDatabase<Record<string, unknown>>,
  freeSearches = FREE_SEARCHES_PER_DAY,
): QuotaStore {
  return {
    async touchUser(user) {
      await db
        .insert(usersTable)
        .values({ id: user.uid, email: user.email ?? null })
        .onConflictDoUpdate({
          target: usersTable.id,
          set: { email: user.email ?? null, lastSeenAt: new Date() },
        });
    },

    async status(userId, day) {
      const [row] = await db
        .select()
        .from(dailyUsageTable)
        .where(and(eq(dailyUsageTable.userId, userId), eq(dailyUsageTable.day, day)));
      return {
        searchesUsed: row?.searches ?? 0,
        searchesLimit: freeSearches + (row?.bonusSearches ?? 0),
        resetsAt: nextResetAt(day),
      };
    },

    async consumeSearch(userId, day) {
      if (freeSearches < 1) {
        const status = await this.status(userId, day);
        if (status.searchesUsed >= status.searchesLimit) return false;
      }
      // Tek ifade: eşzamanlı isteklerde de sınır aşılmaz.
      const rows = await db
        .insert(dailyUsageTable)
        .values({ userId, day, searches: 1 })
        .onConflictDoUpdate({
          target: [dailyUsageTable.userId, dailyUsageTable.day],
          set: { searches: sql`${dailyUsageTable.searches} + 1` },
          setWhere: sql`${dailyUsageTable.searches} < ${freeSearches} + ${dailyUsageTable.bonusSearches}`,
        })
        .returning({ searches: dailyUsageTable.searches });
      return rows.length > 0;
    },

    async refundSearch(userId, day) {
      await db
        .update(dailyUsageTable)
        .set({ searches: sql`${dailyUsageTable.searches} - 1` })
        .where(
          and(
            eq(dailyUsageTable.userId, userId),
            eq(dailyUsageTable.day, day),
            sql`${dailyUsageTable.searches} > 0`,
          ),
        );
    },

    async consumeInsight(userId, day) {
      const rows = await db
        .insert(dailyUsageTable)
        .values({ userId, day, insights: 1 })
        .onConflictDoUpdate({
          target: [dailyUsageTable.userId, dailyUsageTable.day],
          set: { insights: sql`${dailyUsageTable.insights} + 1` },
          setWhere: sql`${dailyUsageTable.insights} < ${INSIGHTS_PER_DAY}`,
        })
        .returning({ insights: dailyUsageTable.insights });
      return rows.length > 0;
    },

    async addBonusSearch(userId, day) {
      await db
        .insert(dailyUsageTable)
        .values({ userId, day, bonusSearches: 1 })
        .onConflictDoUpdate({
          target: [dailyUsageTable.userId, dailyUsageTable.day],
          set: { bonusSearches: sql`${dailyUsageTable.bonusSearches} + 1` },
        });
    },
  };
}

/** Testler için bellekte çalışan kota. */
export function createMemoryQuotaStore(freeSearches = FREE_SEARCHES_PER_DAY): QuotaStore & {
  readonly users: Set<string>;
} {
  const users = new Set<string>();
  const rows = new Map<string, { searches: number; bonus: number; insights: number }>();
  const row = (userId: string, day: string) => {
    const key = `${userId}|${day}`;
    let r = rows.get(key);
    if (!r) rows.set(key, (r = { searches: 0, bonus: 0, insights: 0 }));
    return r;
  };
  return {
    users,
    async touchUser(user) {
      users.add(user.uid);
    },
    async status(userId, day) {
      const r = row(userId, day);
      return { searchesUsed: r.searches, searchesLimit: freeSearches + r.bonus, resetsAt: nextResetAt(day) };
    },
    async consumeSearch(userId, day) {
      const r = row(userId, day);
      if (r.searches >= freeSearches + r.bonus) return false;
      r.searches++;
      return true;
    },
    async refundSearch(userId, day) {
      const r = row(userId, day);
      if (r.searches > 0) r.searches--;
    },
    async consumeInsight(userId, day) {
      const r = row(userId, day);
      if (r.insights >= INSIGHTS_PER_DAY) return false;
      r.insights++;
      return true;
    },
    async addBonusSearch(userId, day) {
      row(userId, day).bonus++;
    },
  };
}
