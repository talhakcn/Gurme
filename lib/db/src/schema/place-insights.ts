import { index, integer, jsonb, pgTable, text, timestamp } from "drizzle-orm/pg-core";

/** Üç durumlu sinyal: yorumlardan ya da Google verisinden çıkarılan tahmin. */
export type Signal = "yes" | "no" | "unknown";

export type PlaceInsightFeatures = {
  /** Alkol servisi. Önce Google'ın servesBeer/Wine/Cocktails alanlarına bakılır. */
  alcohol: Signal;
  /** Helal: yalnızca yorumlardan tahmin. */
  helal: Signal;
  /** Glutensiz seçenek: yalnızca yorumlardan tahmin. */
  glutenFree: Signal;
  /** Çölyak için güvenli hazırlık (ayrı alan, çapraz bulaşma önlemi). */
  celiacSafe: Signal;
};

export type PlaceInsightSummary = {
  summary: string;
  whyGo: string[];
  warnings: string[];
  vibeTags: string[];
  /** Yorumlarda öne çıkan yiyecek ve içecekler. */
  highlights: string[];
};

/**
 * Mekân başına bir kez çıkarılan yapay zekâ özeti; bütün kullanıcılar aynı
 * kaydı kullanır. Google'ın kullanım koşulları gereği ham yorumlar
 * saklanmaz; yalnızca place_id ve kendi ürettiğimiz özet tutulur.
 */
export const placeInsightsTable = pgTable(
  "place_insights",
  {
    placeId: text("place_id").primaryKey(),
    features: jsonb("features").$type<PlaceInsightFeatures>().notNull(),
    summary: jsonb("summary").$type<PlaceInsightSummary>().notNull(),
    /** Analizde kullanılan yorum sayısı (Google en fazla 5 döndürür). */
    reviewCount: integer("review_count").notNull(),
    model: text("model").notNull(),
    analyzedAt: timestamp("analyzed_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [index("place_insights_analyzed_at_idx").on(table.analyzedAt)],
);

export type PlaceInsightRow = typeof placeInsightsTable.$inferSelect;
