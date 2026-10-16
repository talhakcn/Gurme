import { randomUUID } from "node:crypto";
import { and, desc, eq, inArray, isNull, sql } from "drizzle-orm";
import { Router, type IRouter } from "express";
import { db, gurmeListsTable, listReportsTable, usersTable } from "@workspace/db";
import {
  ListListReportsForReviewQueryParams,
  ListListReportsForReviewResponse,
  ModerateGurmeListBody,
  ModerateGurmeListParams,
  ModerateGurmeListResponse,
  ReportGurmeListBody,
  ReportGurmeListParams,
  SetUserPublishingBody,
  SetUserPublishingParams,
} from "@workspace/api-zod";
import { requireUser } from "../auth/auth";
import { adminActor, isAdmin, requireAdmin } from "../auth/admin";
import { authConfig } from "../auth/runtime";

const router: IRouter = Router();

/** İncelemede bir listenin en fazla bu kadar notu gösterilir (en yeniler). */
const NOTES_PER_LIST = 5;

/**
 * Paylaşılan bir listeyi bildirir. Hesap başına bir bildirim: aynı kişi
 * yeniden bildirirse yeni kayıt açılmaz, yine 202 döner (kötüye kullanılıp
 * sayı şişirilemez).
 */
router.post("/gurme/lists/:id/report", requireUser(authConfig), async (req, res): Promise<void> => {
  const params = ReportGurmeListParams.safeParse(req.params);
  const body = ReportGurmeListBody.safeParse(req.body);
  if (!params.success || !body.success) {
    res.status(400).json({ error: "Geçersiz bildirim" });
    return;
  }
  // Giriş sistemi kapalı geliştirme sunucusunda kullanıcı yok.
  const reporter = req.user?.uid ?? "dev";
  try {
    const [list] = await db
      .select({ id: gurmeListsTable.id, visibility: gurmeListsTable.visibility, owner: gurmeListsTable.ownerUserId })
      .from(gurmeListsTable)
      .where(eq(gurmeListsTable.id, params.data.id));
    if (!list || list.visibility === "private") {
      res.status(404).json({ error: "Liste bulunamadı" });
      return;
    }
    if (list.owner && list.owner === req.user?.uid) {
      res.status(400).json({ error: "Kendi listeni bildiremezsin", code: "own_list" });
      return;
    }
    await db
      .insert(listReportsTable)
      .values({
        id: randomUUID(),
        listId: list.id,
        reporterUserId: reporter,
        reason: body.data.reason,
        note: (body.data.note ?? "").trim(),
      })
      .onConflictDoNothing();
    res.status(202).json({ ok: true });
  } catch (error) {
    req.log.error({ err: error }, "Failed to save list report");
    res.status(500).json({ error: "Bildirim kaydedilemedi" });
  }
});

router.get("/admin/me", (req, res) => {
  res.json({ admin: isAdmin(req) });
});

/** Bildirilen listelerin özeti; liste kimlikleri verilirse yalnızca onlar. */
async function reportedLists(options: { openOnly: boolean; ids?: string[] }) {
  const rows = await db
    .select({
      listId: listReportsTable.listId,
      openReports: sql<number>`count(*) filter (where ${listReportsTable.reviewedAt} is null)`.mapWith(Number),
      totalReports: sql<number>`count(*)`.mapWith(Number),
      lastReportedAt: sql<Date>`max(${listReportsTable.createdAt})`.mapWith((v) => new Date(v)),
    })
    .from(listReportsTable)
    .where(options.ids ? inArray(listReportsTable.listId, options.ids) : undefined)
    .groupBy(listReportsTable.listId)
    .having(options.openOnly ? sql`count(*) filter (where ${listReportsTable.reviewedAt} is null) > 0` : undefined)
    .orderBy(desc(sql`max(${listReportsTable.createdAt})`));
  if (rows.length === 0) return [];
  const ids = rows.map((r) => r.listId);
  const [lists, reports] = await Promise.all([
    db
      .select({
        list: gurmeListsTable,
        ownerBlocked: sql<boolean>`${usersTable.publishingBlockedAt} is not null`.mapWith(Boolean),
      })
      .from(gurmeListsTable)
      .leftJoin(usersTable, eq(usersTable.id, gurmeListsTable.ownerUserId))
      .where(inArray(gurmeListsTable.id, ids)),
    db
      .select({
        listId: listReportsTable.listId,
        reason: listReportsTable.reason,
        note: listReportsTable.note,
        reviewedAt: listReportsTable.reviewedAt,
      })
      .from(listReportsTable)
      .where(inArray(listReportsTable.listId, ids))
      .orderBy(desc(listReportsTable.createdAt)),
  ]);
  const byId = new Map(lists.map((l) => [l.list.id, l]));
  return rows.flatMap((row) => {
    const found = byId.get(row.listId);
    if (!found) return [];
    const mine = reports.filter((r) => r.listId === row.listId);
    const reasons: Record<string, number> = {};
    for (const r of mine) reasons[r.reason] = (reasons[r.reason] ?? 0) + 1;
    return [
      {
        id: found.list.id,
        title: found.list.title,
        authorName: found.list.authorName,
        visibility: found.list.visibility,
        itemCount: found.list.items.length,
        hidden: found.list.hiddenAt !== null,
        ownerUserId: found.list.ownerUserId,
        ownerBlocked: found.ownerBlocked,
        openReports: row.openReports,
        totalReports: row.totalReports,
        reasons,
        notes: mine
          .map((r) => r.note)
          .filter((n) => n.length > 0)
          .slice(0, NOTES_PER_LIST),
        lastReportedAt: row.lastReportedAt,
      },
    ];
  });
}

router.get("/admin/list-reports", async (req, res): Promise<void> => {
  if (!requireAdmin(req, res)) return;
  const query = ListListReportsForReviewQueryParams.safeParse(req.query);
  if (!query.success) {
    res.status(400).json({ error: "Geçersiz süzgeç" });
    return;
  }
  try {
    const lists = await reportedLists({ openOnly: (query.data.status ?? "open") === "open" });
    res.json(ListListReportsForReviewResponse.parse(lists));
  } catch (error) {
    req.log.error({ err: error }, "Failed to load list reports");
    res.status(500).json({ error: "Bildirimler yüklenemedi" });
  }
});

/**
 * hide: liste keşiften ve paylaşım sayfasından kalkar, açık bildirimler
 * "kaldırıldı" diye kapanır. restore: liste geri gelir. dismiss: liste
 * yerinde kalır, açık bildirimler "bırakıldı" diye kapanır.
 */
router.post("/admin/lists/:id/moderation", async (req, res): Promise<void> => {
  if (!requireAdmin(req, res)) return;
  const params = ModerateGurmeListParams.safeParse(req.params);
  const body = ModerateGurmeListBody.safeParse(req.body);
  if (!params.success || !body.success) {
    res.status(400).json({ error: "Geçersiz işlem" });
    return;
  }
  const actor = adminActor(req);
  const now = new Date();
  try {
    const found = await db.transaction(async (tx) => {
      const [list] = await tx
        .select({ id: gurmeListsTable.id })
        .from(gurmeListsTable)
        .where(eq(gurmeListsTable.id, params.data.id));
      if (!list) return false;
      const action = body.data.action;
      if (action !== "dismiss") {
        await tx
          .update(gurmeListsTable)
          .set(
            action === "hide"
              ? { hiddenAt: now, hiddenBy: actor }
              : { hiddenAt: null, hiddenBy: null },
          )
          .where(eq(gurmeListsTable.id, list.id));
      }
      if (action !== "restore") {
        await tx
          .update(listReportsTable)
          .set({ reviewedAt: now, reviewedBy: actor, resolution: action === "hide" ? "hidden" : "kept" })
          .where(and(eq(listReportsTable.listId, list.id), isNull(listReportsTable.reviewedAt)));
      }
      return true;
    });
    if (!found) {
      res.status(404).json({ error: "Liste bulunamadı" });
      return;
    }
    const [state] = await reportedLists({ openOnly: false, ids: [params.data.id] });
    if (!state) {
      // Bildirimi olmayan liste de gizlenebilir; özeti boş döner.
      const [list] = await db.select().from(gurmeListsTable).where(eq(gurmeListsTable.id, params.data.id));
      res.json(
        ModerateGurmeListResponse.parse({
          id: list!.id,
          title: list!.title,
          authorName: list!.authorName,
          visibility: list!.visibility,
          itemCount: list!.items.length,
          hidden: list!.hiddenAt !== null,
          ownerUserId: list!.ownerUserId,
          ownerBlocked: false,
          openReports: 0,
          totalReports: 0,
          reasons: {},
          notes: [],
          lastReportedAt: now,
        }),
      );
      return;
    }
    res.json(ModerateGurmeListResponse.parse(state));
  } catch (error) {
    req.log.error({ err: error }, "Failed to moderate list");
    res.status(500).json({ error: "İşlem yapılamadı" });
  }
});

/** Kullanıcının liste yayınlamasını kapatır ya da açar. */
router.post("/admin/users/:userId/publishing", async (req, res): Promise<void> => {
  if (!requireAdmin(req, res)) return;
  const params = SetUserPublishingParams.safeParse(req.params);
  const body = SetUserPublishingBody.safeParse(req.body);
  if (!params.success || !body.success) {
    res.status(400).json({ error: "Geçersiz işlem" });
    return;
  }
  try {
    // Hesap yalnızca liste yayınlamış, hiç arama yapmamış olabilir: kullanıcı
    // satırı yoksa açılır. Yalnızca bir listenin sahibi olan hesap engellenir.
    const [owns] = await db
      .select({ id: gurmeListsTable.id })
      .from(gurmeListsTable)
      .where(eq(gurmeListsTable.ownerUserId, params.data.userId))
      .limit(1);
    const blockedAt = body.data.blocked ? new Date() : null;
    const [user] = owns
      ? await db
          .insert(usersTable)
          .values({ id: params.data.userId, publishingBlockedAt: blockedAt })
          .onConflictDoUpdate({ target: usersTable.id, set: { publishingBlockedAt: blockedAt } })
          .returning({ id: usersTable.id })
      : await db
          .update(usersTable)
          .set({ publishingBlockedAt: blockedAt })
          .where(eq(usersTable.id, params.data.userId))
          .returning({ id: usersTable.id });
    if (!user) {
      res.status(404).json({ error: "Kullanıcı bulunamadı" });
      return;
    }
    res.json({ blocked: body.data.blocked });
  } catch (error) {
    req.log.error({ err: error }, "Failed to set publishing");
    res.status(500).json({ error: "İşlem yapılamadı" });
  }
});

/** Hesabın yayın yapması kapatılmış mı? Girişsiz istekte `false`. */
export async function publishingBlocked(userId: string | undefined): Promise<boolean> {
  if (!userId) return false;
  const [user] = await db
    .select({ blockedAt: usersTable.publishingBlockedAt })
    .from(usersTable)
    .where(eq(usersTable.id, userId));
  return Boolean(user?.blockedAt);
}

export default router;
