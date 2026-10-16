import { createInsertSchema } from "drizzle-zod";
import { index, jsonb, pgTable, text, timestamp } from "drizzle-orm/pg-core";
import { z } from "zod/v4";

export type GurmeListItem = {
  placeId: string;
  name: string;
  area: string;
  category: string;
  note: string;
};

export const gurmeListsTable = pgTable(
  "gurme_lists",
  {
    id: text("id").primaryKey(),
    ownerKeyHash: text("owner_key_hash").notNull(),
    /** Hesap sistemiyle listenin sahibi (Firebase uid). Eski listelerde boş. */
    ownerUserId: text("owner_user_id"),
    title: text("title").notNull(),
    description: text("description").notNull(),
    authorName: text("author_name").notNull(),
    visibility: text("visibility", {
      enum: ["private", "unlisted", "public"],
    }).notNull(),
    items: jsonb("items").$type<GurmeListItem[]>().notNull(),
    /**
     * Yönetici yayından kaldırdıysa: keşifte ve paylaşım sayfasında görünmez.
     * Sahibi listeyi düzenleyebilir, ama kaldırma yöneticide kalır.
     */
    hiddenAt: timestamp("hidden_at", { withTimezone: true }),
    hiddenBy: text("hidden_by"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true })
      .notNull()
      .defaultNow()
      .$onUpdate(() => new Date()),
  },
  (table) => [
    index("gurme_lists_owner_key_hash_idx").on(table.ownerKeyHash),
    index("gurme_lists_owner_user_idx").on(table.ownerUserId),
    index("gurme_lists_visibility_created_idx").on(table.visibility, table.createdAt),
  ],
);

export const insertGurmeListSchema = createInsertSchema(gurmeListsTable).omit({
  createdAt: true,
  updatedAt: true,
});
export type InsertGurmeList = z.infer<typeof insertGurmeListSchema>;
export type GurmeList = typeof gurmeListsTable.$inferSelect;