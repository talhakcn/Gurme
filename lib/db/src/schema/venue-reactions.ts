import { pgTable, text, timestamp, uniqueIndex } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod/v4";
import { installationsTable } from "./installations";

export const venueReactionsTable = pgTable(
  "venue_reactions",
  {
    id: text("id").primaryKey(),
    installationId: text("installation_id")
      .notNull()
      .references(() => installationsTable.id, { onDelete: "cascade" }),
    userId: text("user_id"),
    placeId: text("place_id").notNull(),
    venueName: text("venue_name").notNull(),
    reaction: text("reaction", { enum: ["liked", "disliked"] }).notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow().$onUpdate(() => new Date()),
  },
  (table) => [uniqueIndex("venue_reactions_installation_place_idx").on(table.installationId, table.placeId)],
);

export const insertVenueReactionSchema = createInsertSchema(venueReactionsTable).omit({
  createdAt: true,
  updatedAt: true,
});

export type InsertVenueReaction = z.infer<typeof insertVenueReactionSchema>;
export type VenueReaction = typeof venueReactionsTable.$inferSelect;