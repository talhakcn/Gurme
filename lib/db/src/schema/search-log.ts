import { index, integer, jsonb, pgTable, text, timestamp } from "drizzle-orm/pg-core";

/**
 * Yapılan aramaların kaydı: yönetim panelinde ne arandığını ve aramanın
 * nasıl sonuçlandığını görmek için. 90 günden eski kayıtlar silinir
 * (`SEARCH_LOG_RETENTION_DAYS`). Girişsiz aramada `userId` boş.
 */
export const searchLogTable = pgTable(
  "search_log",
  {
    id: text("id").primaryKey(),
    userId: text("user_id"),
    query: text("query").notNull(),
    city: text("city").notNull(),
    filters: jsonb("filters").$type<Record<string, unknown>>().notNull().default({}),
    /** ok: sonuç döndü; cached: önbellekten; quota, budget, blocked, error. */
    outcome: text("outcome", {
      enum: ["ok", "cached", "quota", "budget", "blocked", "error"],
    }).notNull(),
    resultCount: integer("result_count").notNull().default(0),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    index("search_log_created_idx").on(table.createdAt),
    index("search_log_user_created_idx").on(table.userId, table.createdAt),
  ],
);

export const SEARCH_LOG_RETENTION_DAYS = 90;

export type SearchLogEntry = typeof searchLogTable.$inferSelect;
