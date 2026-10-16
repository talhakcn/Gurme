import { Router, type IRouter, type Request, type Response } from "express";
import { createHash, timingSafeEqual } from "node:crypto";
import { and, count, countDistinct, desc, eq, gte, inArray, sql } from "drizzle-orm";
import {
  db,
  checkinsTable,
  installationsTable,
  venueReportReviewsTable,
  venueReportsTable,
  venueReactionsTable,
} from "@workspace/db";
import {
  GetAnonymousFeedbackParams,
  GetAnonymousFeedbackResponse,
  ListVenueReportsForReviewQueryParams,
  ListVenueReportsForReviewResponse,
  ReviewVenueReportsBody,
  ReviewVenueReportsResponse,
  SaveCheckinBody,
  ReportVenueBody,
  ReportVenueResponse,
  SaveVenueReactionBody,
  SaveVenueReactionResponse,
} from "@workspace/api-zod";
import { requireUser } from "../auth/auth";
import { authConfig } from "../auth/runtime";
import { reporterKey } from "../search/community";

const router: IRouter = Router();
const REPORTS_PER_HOUR_LIMIT = 10;
const VERIFICATION_REPORT_THRESHOLD = 3;

function hasValidAdminToken(authorization: string | undefined, expectedToken: string): boolean {
  if (!authorization?.startsWith("Bearer ")) return false;
  const receivedDigest = createHash("sha256").update(authorization.slice(7)).digest();
  const expectedDigest = createHash("sha256").update(expectedToken).digest();
  return timingSafeEqual(receivedDigest, expectedDigest);
}

function requireAdmin(req: Request, res: Response): boolean {
  // Yönetici hesabı (Firebase admin yetkisi) da inceleyebilir.
  if (req.user?.admin) return true;
  const adminApiKey = process.env.ADMIN_API_KEY;
  if (!adminApiKey) {
    req.log.error("ADMIN_API_KEY is not configured");
    res.status(503).json({ error: "Yönetici erişimi yapılandırılmamış" });
    return false;
  }
  if (!hasValidAdminToken(req.get("authorization"), adminApiKey)) {
    res.status(401).json({ error: "Yönetici yetkisi gerekli" });
    return false;
  }
  return true;
}

/**
 * Kurulumu kaydeder ve giriş yapmış kullanıcıya bağlar. Kurulum başka bir
 * hesaba bağlıysa `false`: başkasının kurulum kimliğiyle yazılamaz.
 */
async function claimInstallation(installationId: string, userId: string | undefined): Promise<boolean> {
  await db
    .insert(installationsTable)
    .values({ id: installationId, userId: userId ?? null })
    .onConflictDoUpdate({
      target: installationsTable.id,
      set: { userId: sql`coalesce(${installationsTable.userId}, excluded.user_id)` },
    });
  if (!userId) return true;
  const [row] = await db
    .select({ userId: installationsTable.userId })
    .from(installationsTable)
    .where(eq(installationsTable.id, installationId));
  return row?.userId === userId;
}

function forbidden(res: Response): void {
  res.status(403).json({ error: "Bu kurulum başka bir hesaba bağlı." });
}

router.get("/feedback/:installationId", requireUser(authConfig), async (req, res) => {
  const parsed = GetAnonymousFeedbackParams.safeParse(req.params);
  if (!parsed.success) {
    res.status(400).json({ error: "Geçersiz kurulum kimliği" });
    return;
  }

  try {
    const installationId = parsed.data.installationId;
    // Hesap sistemi açıkken kayıtlar yalnızca kurulumun sahibine gösterilir.
    if (req.user) {
      const [owner] = await db
        .select({ userId: installationsTable.userId })
        .from(installationsTable)
        .where(eq(installationsTable.id, installationId));
      if (owner?.userId !== req.user.uid) {
        res.status(404).json({ error: "Kayıt bulunamadı" });
        return;
      }
    }
    const [storedReactions, storedCheckins] = await Promise.all([
      db
        .select({
          placeId: venueReactionsTable.placeId,
          reaction: venueReactionsTable.reaction,
        })
        .from(venueReactionsTable)
        .where(eq(venueReactionsTable.installationId, installationId)),
      db
        .select()
        .from(checkinsTable)
        .where(eq(checkinsTable.installationId, installationId))
        .orderBy(desc(checkinsTable.checkedAt))
        .limit(500),
    ]);

    const reactions = Object.fromEntries(
      storedReactions.map(({ placeId, reaction }) => [placeId, reaction]),
    );
    const checkins = storedCheckins.map((checkin) => ({
      id: checkin.id,
      installationId: checkin.installationId,
      placeId: checkin.placeId,
      venueName: checkin.venueName,
      tags: checkin.tags,
      note: checkin.note,
      checkedAt: checkin.checkedAt.toISOString(),
    }));

    res.json(GetAnonymousFeedbackResponse.parse({ reactions, checkins }));
  } catch (error) {
    req.log.error({ err: error }, "Failed to load anonymous feedback");
    res.status(500).json({ error: "Kayıtlar yüklenemedi" });
  }
});

router.put("/feedback/reaction", requireUser(authConfig), async (req, res) => {
  const parsed = SaveVenueReactionBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: "Geçersiz değerlendirme", details: parsed.error.message });
    return;
  }

  try {
    const data = parsed.data;
    if (!(await claimInstallation(data.installationId, req.user?.uid))) return forbidden(res);

    if (data.reaction == null) {
      await db
        .delete(venueReactionsTable)
        .where(
          and(
            eq(venueReactionsTable.installationId, data.installationId),
            eq(venueReactionsTable.placeId, data.placeId),
          ),
        );
    } else {
      await db
        .insert(venueReactionsTable)
        .values({
          id: `${data.installationId}:${data.placeId}`,
          installationId: data.installationId,
          placeId: data.placeId,
          venueName: data.venueName,
          reaction: data.reaction,
        })
        .onConflictDoUpdate({
          target: [venueReactionsTable.installationId, venueReactionsTable.placeId],
          set: {
            venueName: data.venueName,
            reaction: data.reaction,
            updatedAt: new Date(),
          },
        });
    }

    res.json(SaveVenueReactionResponse.parse({ success: true }));
  } catch (error) {
    req.log.error({ err: error }, "Failed to save venue reaction");
    res.status(500).json({ error: "Değerlendirme kaydedilemedi" });
  }
});

router.post("/feedback/checkins", requireUser(authConfig), async (req, res) => {
  const parsed = SaveCheckinBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: "Geçersiz deneyim kaydı", details: parsed.error.message });
    return;
  }

  try {
    const data = parsed.data;
    if (!(await claimInstallation(data.installationId, req.user?.uid))) return forbidden(res);
    await db
      .insert(checkinsTable)
      .values({
        id: data.id,
        installationId: data.installationId,
        placeId: data.placeId,
        venueName: data.venueName,
        tags: data.tags,
        note: data.note,
        checkedAt: new Date(data.checkedAt),
      })
      .onConflictDoNothing({ target: checkinsTable.id });

    res.status(201).json(SaveVenueReactionResponse.parse({ success: true }));
  } catch (error) {
    req.log.error({ err: error }, "Failed to save check-in");
    res.status(500).json({ error: "Deneyim kaydedilemedi" });
  }
});

router.post("/feedback/reports", requireUser(authConfig), async (req, res) => {
  const parsed = ReportVenueBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: "Geçersiz mekan bildirimi", details: parsed.error.message });
    return;
  }

  try {
    const data = parsed.data;
    const userId = req.user?.uid;
    if (!(await claimInstallation(data.installationId, userId))) return forbidden(res);

    const [existing] = await db
      .select({ id: venueReportsTable.id })
      .from(venueReportsTable)
      .where(
        and(
          eq(venueReportsTable.installationId, data.installationId),
          eq(venueReportsTable.placeId, data.placeId),
          eq(venueReportsTable.reportType, data.reportType),
        ),
      )
      .limit(1);

    if (!existing) {
      const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
      const [recent] = await db
        .select({ value: count() })
        .from(venueReportsTable)
        .where(
          and(
            userId
              ? eq(venueReportsTable.userId, userId)
              : eq(venueReportsTable.installationId, data.installationId),
            gte(venueReportsTable.createdAt, oneHourAgo),
          ),
        );

      if ((recent?.value ?? 0) >= REPORTS_PER_HOUR_LIMIT) {
        res.status(429).json({ error: "Çok fazla bildirim gönderdiniz. Lütfen daha sonra tekrar deneyin." });
        return;
      }

      await db
        .insert(venueReportsTable)
        .values({
          id: `report_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 12)}`,
          installationId: data.installationId,
          userId: userId ?? null,
          placeId: data.placeId,
          venueName: data.venueName,
          reportType: data.reportType,
          sourceSearchId: data.sourceSearchId ?? null,
          sourceResultId: data.sourceResultId ?? null,
        })
        .onConflictDoNothing({
          target: [
            venueReportsTable.installationId,
            venueReportsTable.placeId,
            venueReportsTable.reportType,
          ],
        });
    }

    // Aynı kişinin birden çok kurulumu tek bildirim sayılır.
    const [total] = await db
      .select({ value: countDistinct(reporterKey) })
      .from(venueReportsTable)
      .where(
        and(
          eq(venueReportsTable.placeId, data.placeId),
          eq(venueReportsTable.reportType, data.reportType),
          inArray(venueReportsTable.status, ["open", "accepted"]),
        ),
      );
    const reportCount = total?.value ?? 0;

    res.json(
      ReportVenueResponse.parse({
        success: true,
        alreadyReported: Boolean(existing),
        reportCount,
        verificationRequired: reportCount >= VERIFICATION_REPORT_THRESHOLD,
      }),
    );
  } catch (error) {
    req.log.error({ err: error }, "Failed to save venue report");
    res.status(500).json({ error: "Mekan bildirimi kaydedilemedi" });
  }
});

router.get("/feedback/admin/reports", async (req, res) => {
  if (!requireAdmin(req, res)) return;

  const parsed = ListVenueReportsForReviewQueryParams.safeParse(req.query);
  if (!parsed.success) {
    res.status(400).json({ error: "Geçersiz inceleme filtresi", details: parsed.error.message });
    return;
  }

  try {
    const filters = [eq(venueReportsTable.status, "open")];
    if (parsed.data.placeId) filters.push(eq(venueReportsTable.placeId, parsed.data.placeId));
    if (parsed.data.reportType) {
      filters.push(eq(venueReportsTable.reportType, parsed.data.reportType));
    }

    const reports = await db
      .select()
      .from(venueReportsTable)
      .where(and(...filters))
      .orderBy(desc(venueReportsTable.createdAt));

    const grouped = new Map<string, {
      placeId: string;
      venueName: string;
      reportType: typeof reports[number]["reportType"];
      reportCount: number;
      firstReportedAt: Date;
      lastReportedAt: Date;
      reports: Array<{ id: string; installationId: string; createdAt: Date }>;
    }>();

    for (const report of reports) {
      const key = `${report.placeId}\u0000${report.reportType}`;
      const existing = grouped.get(key);
      if (existing) {
        existing.reportCount += 1;
        existing.firstReportedAt = report.createdAt < existing.firstReportedAt
          ? report.createdAt
          : existing.firstReportedAt;
        existing.lastReportedAt = report.createdAt > existing.lastReportedAt
          ? report.createdAt
          : existing.lastReportedAt;
        existing.reports.push({
          id: report.id,
          installationId: report.installationId,
          createdAt: report.createdAt,
        });
      } else {
        grouped.set(key, {
          placeId: report.placeId,
          venueName: report.venueName,
          reportType: report.reportType,
          reportCount: 1,
          firstReportedAt: report.createdAt,
          lastReportedAt: report.createdAt,
          reports: [{
            id: report.id,
            installationId: report.installationId,
            createdAt: report.createdAt,
          }],
        });
      }
    }

    res.json(ListVenueReportsForReviewResponse.parse({ groups: [...grouped.values()] }));
  } catch (error) {
    req.log.error({ err: error }, "Failed to list venue reports for review");
    res.status(500).json({ error: "Bildirimler yüklenemedi" });
  }
});

router.post("/feedback/admin/reports/review", async (req, res) => {
  if (!requireAdmin(req, res)) return;

  const parsed = ReviewVenueReportsBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: "Geçersiz inceleme kararı", details: parsed.error.message });
    return;
  }

  try {
    const data = parsed.data;
    const reviewedAt = new Date();
    const result = await db.transaction(async (tx) => {
      const reviewed = await tx
        .update(venueReportsTable)
        .set({
          status: data.decision,
          reviewedAt,
          reviewedBy: data.reviewedBy,
        })
        .where(
          and(
            eq(venueReportsTable.placeId, data.placeId),
            eq(venueReportsTable.reportType, data.reportType),
            eq(venueReportsTable.status, "open"),
          ),
        )
        .returning({ venueName: venueReportsTable.venueName });

      if (reviewed.length === 0) return null;

      await tx.insert(venueReportReviewsTable).values({
        id: `review_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 12)}`,
        placeId: data.placeId,
        venueName: reviewed[0].venueName,
        reportType: data.reportType,
        decision: data.decision,
        reviewedBy: data.reviewedBy,
        note: data.note ?? null,
        affectedReportCount: reviewed.length,
        reviewedAt,
      });

      return reviewed.length;
    });

    if (result === null) {
      res.status(404).json({ error: "İncelenecek açık bildirim bulunamadı" });
      return;
    }

    res.json(
      ReviewVenueReportsResponse.parse({
        success: true,
        affectedReportCount: result,
        reviewedAt,
      }),
    );
  } catch (error) {
    req.log.error({ err: error }, "Failed to review venue reports");
    res.status(500).json({ error: "İnceleme kararı kaydedilemedi" });
  }
});

export default router;