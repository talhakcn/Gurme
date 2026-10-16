import { randomUUID } from "node:crypto";
import { eq, lt } from "drizzle-orm";
import type { NextFunction, Request, Response } from "express";
import { db, SEARCH_LOG_RETENTION_DAYS, searchLogTable, usersTable } from "@workspace/db";
import { logger } from "./logger";

type Outcome = (typeof searchLogTable.$inferInsert)["outcome"];

let lastPrune = 0;

/**
 * Aramayı kaydeder. Kayıt yanıtı bekletmez ve hata vermez: kayıt
 * yazılamasa da arama yapılır. Günde bir kez eski kayıtlar silinir.
 */
export function logSearch(entry: {
  userId: string | undefined;
  query: string;
  city: string;
  filters: Record<string, unknown>;
  outcome: Outcome;
  resultCount?: number;
}): void {
  void (async () => {
    try {
      await db.insert(searchLogTable).values({
        id: randomUUID(),
        userId: entry.userId ?? null,
        query: entry.query.slice(0, 200),
        city: entry.city.slice(0, 200),
        filters: entry.filters,
        outcome: entry.outcome,
        resultCount: entry.resultCount ?? 0,
      });
      const now = Date.now();
      if (now - lastPrune > 24 * 60 * 60 * 1000) {
        lastPrune = now;
        const cutoff = new Date(now - SEARCH_LOG_RETENTION_DAYS * 24 * 60 * 60 * 1000);
        await db.delete(searchLogTable).where(lt(searchLogTable.createdAt, cutoff));
      }
    } catch (err) {
      logger.warn({ err }, "Arama kaydı yazılamadı");
    }
  })();
}

/** Hesabın araması yönetici tarafından kapatıldı mı? */
export async function searchBlocked(userId: string | undefined): Promise<boolean> {
  if (!userId) return false;
  const [user] = await db
    .select({ blockedAt: usersTable.searchBlockedAt })
    .from(usersTable)
    .where(eq(usersTable.id, userId));
  return Boolean(user?.blockedAt);
}

export const SEARCH_BLOCKED = {
  error: "Bu hesapla arama geçici olarak kapatıldı. Defterin ve listelerin çalışmaya devam ediyor.",
  code: "search_blocked",
};

/** Araması kapatılan hesap Google'a giden uçları kullanamaz. */
export async function requireSearchAllowed(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (await searchBlocked(req.user?.uid)) {
      res.status(403).json(SEARCH_BLOCKED);
      return;
    }
  } catch (err) {
    // Denetim yapılamazsa arama kesilmez; kota ve sayaçlar yine korur.
    logger.warn({ err }, "Arama engeli okunamadı");
  }
  next();
}
