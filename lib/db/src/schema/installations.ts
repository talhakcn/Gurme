import { pgTable, text, timestamp } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod/v4";

export const installationsTable = pgTable("installations", {
  id: text("id").primaryKey(),
  userId: text("user_id"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow().$onUpdate(() => new Date()),
});

export const insertInstallationSchema = createInsertSchema(installationsTable).omit({
  createdAt: true,
  updatedAt: true,
});

export type InsertInstallation = z.infer<typeof insertInstallationSchema>;
export type Installation = typeof installationsTable.$inferSelect;