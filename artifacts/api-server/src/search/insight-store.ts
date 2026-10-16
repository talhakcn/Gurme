import { inArray, sql } from "drizzle-orm";
import type { NodePgDatabase } from "drizzle-orm/node-postgres";
import { placeInsightsTable } from "@workspace/db/schema";
import type { PlaceInsight } from "./insights";

/** Bu süreden eski analizler yeniden yapılır (yorumlar ve mekân değişir). */
export const INSIGHT_MAX_AGE_MS = 30 * 24 * 60 * 60 * 1000;

export interface InsightStore {
  /** Güncel (en fazla 30 günlük) analizler, placeId'ye göre. */
  getMany(placeIds: string[]): Promise<Map<string, PlaceInsight>>;
  saveMany(insights: PlaceInsight[]): Promise<void>;
}

export function isFresh(insight: PlaceInsight, now: number): boolean {
  return now - insight.analyzedAt.getTime() <= INSIGHT_MAX_AGE_MS;
}

export function createPgInsightStore(
  db: NodePgDatabase<Record<string, unknown>>,
  now: () => number = Date.now,
): InsightStore {
  return {
    async getMany(placeIds) {
      if (placeIds.length === 0) return new Map();
      const rows = await db
        .select()
        .from(placeInsightsTable)
        .where(inArray(placeInsightsTable.placeId, placeIds));
      return new Map(
        rows
          .map((row): PlaceInsight => ({ ...row }))
          .filter((insight) => isFresh(insight, now()))
          .map((insight) => [insight.placeId, insight]),
      );
    },

    async saveMany(insights) {
      if (insights.length === 0) return;
      await db
        .insert(placeInsightsTable)
        .values(insights)
        .onConflictDoUpdate({
          target: placeInsightsTable.placeId,
          set: {
            features: sql`excluded.features`,
            summary: sql`excluded.summary`,
            reviewCount: sql`excluded.review_count`,
            model: sql`excluded.model`,
            analyzedAt: sql`excluded.analyzed_at`,
          },
        });
    },
  };
}

export function createMemoryInsightStore(now: () => number = Date.now): InsightStore & {
  readonly rows: Map<string, PlaceInsight>;
} {
  const rows = new Map<string, PlaceInsight>();
  return {
    rows,
    async getMany(placeIds) {
      return new Map(
        placeIds.flatMap((id) => {
          const insight = rows.get(id);
          return insight && isFresh(insight, now()) ? [[id, insight] as const] : [];
        }),
      );
    },
    async saveMany(insights) {
      for (const insight of insights) rows.set(insight.placeId, insight);
    },
  };
}
