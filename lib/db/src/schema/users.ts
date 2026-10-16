import { date, integer, pgTable, primaryKey, text, timestamp } from "drizzle-orm/pg-core";

/** Firebase Auth ile giriş yapmış kullanıcı. `id` Firebase uid'idir. */
export const usersTable = pgTable("users", {
  id: text("id").primaryKey(),
  email: text("email"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  lastSeenAt: timestamp("last_seen_at", { withTimezone: true }).notNull().defaultNow(),
  /** Yönetici, kötüye kullanım nedeniyle liste yayınlamayı kapattıysa. */
  publishingBlockedAt: timestamp("publishing_blocked_at", { withTimezone: true }),
  /** Yönetici aramayı kapattıysa: yapay zekâ araması ve mekân ayrıntısı yok. */
  searchBlockedAt: timestamp("search_blocked_at", { withTimezone: true }),
});

/**
 * Kullanıcının bir gündeki (Europe/Istanbul) kullanımı. Önbellekten dönen
 * aramalar sayılmaz; ödüllü reklamla kazanılan haklar `bonusSearches`'a eklenir.
 */
export const dailyUsageTable = pgTable(
  "daily_usage",
  {
    userId: text("user_id")
      .notNull()
      .references(() => usersTable.id, { onDelete: "cascade" }),
    day: date("day").notNull(),
    searches: integer("searches").notNull().default(0),
    bonusSearches: integer("bonus_searches").notNull().default(0),
    insights: integer("insights").notNull().default(0),
  },
  (table) => [primaryKey({ columns: [table.userId, table.day] })],
);

export type User = typeof usersTable.$inferSelect;
export type DailyUsage = typeof dailyUsageTable.$inferSelect;
