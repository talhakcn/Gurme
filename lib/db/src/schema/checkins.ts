import { pgTable, text, timestamp } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod/v4";
import { installationsTable } from "./installations";

export const checkinsTable = pgTable("checkins", {
  id: text("id").primaryKey(),
  installationId: text("installation_id")
    .notNull()
    .references(() => installationsTable.id, { onDelete: "cascade" }),
  userId: text("user_id"),
  placeId: text("place_id").notNull(),
  venueName: text("venue_name").notNull(),
  tags: text("tags").array().notNull(),
  note: text("note").notNull().default(""),
  checkedAt: timestamp("checked_at", { withTimezone: true }).notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const insertCheckinSchema = createInsertSchema(checkinsTable).omit({
  createdAt: true,
});

export type InsertCheckin = z.infer<typeof insertCheckinSchema>;
export type Checkin = typeof checkinsTable.$inferSelect;