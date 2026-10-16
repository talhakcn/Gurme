import { integer, pgTable, text, timestamp, uniqueIndex, index } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod/v4";
import { installationsTable } from "./installations";

export const venueReportsTable = pgTable(
  "venue_reports",
  {
    id: text("id").primaryKey(),
    installationId: text("installation_id")
      .notNull()
      .references(() => installationsTable.id, { onDelete: "cascade" }),
    userId: text("user_id"),
    placeId: text("place_id").notNull(),
    venueName: text("venue_name").notNull(),
    reportType: text("report_type", {
      enum: ["serves_alcohol", "closed", "wrong_info", "irrelevant"],
    }).notNull(),
    sourceSearchId: text("source_search_id"),
    sourceResultId: text("source_result_id"),
    status: text("status", {
      enum: ["open", "accepted", "rejected"],
    }).notNull().default("open"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    reviewedAt: timestamp("reviewed_at", { withTimezone: true }),
    reviewedBy: text("reviewed_by"),
  },
  (table) => [
    uniqueIndex("venue_reports_installation_place_type_idx").on(
      table.installationId,
      table.placeId,
      table.reportType,
    ),
    index("venue_reports_place_status_idx").on(table.placeId, table.status),
    index("venue_reports_installation_created_idx").on(table.installationId, table.createdAt),
  ],
);

export const insertVenueReportSchema = createInsertSchema(venueReportsTable).omit({
  createdAt: true,
  reviewedAt: true,
});

export type InsertVenueReport = z.infer<typeof insertVenueReportSchema>;
export type VenueReport = typeof venueReportsTable.$inferSelect;

export const venueReportReviewsTable = pgTable(
  "venue_report_reviews",
  {
    id: text("id").primaryKey(),
    placeId: text("place_id").notNull(),
    venueName: text("venue_name").notNull(),
    reportType: text("report_type", {
      enum: ["serves_alcohol", "closed", "wrong_info", "irrelevant"],
    }).notNull(),
    decision: text("decision", {
      enum: ["accepted", "rejected"],
    }).notNull(),
    reviewedBy: text("reviewed_by").notNull(),
    note: text("note"),
    affectedReportCount: integer("affected_report_count").notNull(),
    reviewedAt: timestamp("reviewed_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    index("venue_report_reviews_place_type_idx").on(
      table.placeId,
      table.reportType,
      table.reviewedAt,
    ),
  ],
);

export const insertVenueReportReviewSchema = createInsertSchema(venueReportReviewsTable).omit({
  reviewedAt: true,
});

export type InsertVenueReportReview = z.infer<typeof insertVenueReportReviewSchema>;
export type VenueReportReview = typeof venueReportReviewsTable.$inferSelect;