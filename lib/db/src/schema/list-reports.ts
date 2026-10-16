import { index, pgTable, text, timestamp, uniqueIndex } from "drizzle-orm/pg-core";
import { gurmeListsTable } from "./gurme-lists";

export const LIST_REPORT_REASONS = ["spam", "offensive", "misleading", "other"] as const;
export type ListReportReason = (typeof LIST_REPORT_REASONS)[number];

/**
 * Herkese açık ya da bağlantıyla paylaşılan bir listenin bildirimi. Bir hesap
 * bir listeyi bir kez bildirir; yönetici inceleyince `reviewedAt` dolar.
 */
export const listReportsTable = pgTable(
  "list_reports",
  {
    id: text("id").primaryKey(),
    listId: text("list_id")
      .notNull()
      .references(() => gurmeListsTable.id, { onDelete: "cascade" }),
    reporterUserId: text("reporter_user_id").notNull(),
    reason: text("reason", { enum: LIST_REPORT_REASONS }).notNull(),
    note: text("note").notNull().default(""),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    reviewedAt: timestamp("reviewed_at", { withTimezone: true }),
    reviewedBy: text("reviewed_by"),
    /** İnceleme sonucu: liste kaldırıldı ya da yerinde bırakıldı. */
    resolution: text("resolution", { enum: ["hidden", "kept"] }),
  },
  (table) => [
    uniqueIndex("list_reports_list_reporter_idx").on(table.listId, table.reporterUserId),
    index("list_reports_open_idx").on(table.reviewedAt, table.createdAt),
  ],
);

export type ListReport = typeof listReportsTable.$inferSelect;
