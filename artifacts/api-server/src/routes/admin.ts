import { and, count, desc, eq, gte, ilike, inArray, isNotNull, isNull, ne, or, sql, sum } from "drizzle-orm";
import { Router, type IRouter } from "express";
import { z } from "zod/v4";
import {
  dailyUsageTable,
  db,
  gurmeListsTable,
  listReportsTable,
  searchLogTable,
  usersTable,
  venueReportsTable,
} from "@workspace/db";
import { requireAdmin } from "../auth/admin";
import { FREE_SEARCHES_PER_DAY, INSIGHTS_PER_DAY, istanbulDay } from "../auth/quota";
import { authConfig, quotaStore } from "../auth/runtime";
import { placesPhotoBudget } from "../search/place-photos";
import { placesBudget } from "../search/places-budget";

/**
 * Yönetim paneli: genel bakış, kullanıcılar, aramalar ve listeler. Her uç
 * yönetici yetkisi ister (Firebase `admin` yetkisi ya da ADMIN_API_KEY).
 */
const router: IRouter = Router();

router.use("/admin", (req, res, next) => {
  if (requireAdmin(req, res)) next();
});

/** Son [days] günün Türkiye günleri, eskiden yeniye. */
function lastDays(days: number, now = new Date()): string[] {
  return Array.from({ length: days }, (_, i) =>
    istanbulDay(new Date(now.getTime() - (days - 1 - i) * 24 * 60 * 60 * 1000)),
  );
}

/** Türkiye gününün başlangıcı (UTC+3, yaz saati yok). */
function dayStart(day: string): Date {
  return new Date(`${day}T00:00:00+03:00`);
}

router.get("/admin/overview", async (req, res): Promise<void> => {
  try {
    const now = new Date();
    const today = istanbulDay(now);
    const days = lastDays(7, now);
    const weekStart = dayStart(days[0]!);
    const todayStart = dayStart(today);

    const [users] = await db
      .select({
        total: count(),
        newToday: sql<number>`count(*) filter (where ${usersTable.createdAt} >= ${todayStart})`.mapWith(Number),
        newWeek: sql<number>`count(*) filter (where ${usersTable.createdAt} >= ${weekStart})`.mapWith(Number),
        activeToday: sql<number>`count(*) filter (where ${usersTable.lastSeenAt} >= ${todayStart})`.mapWith(Number),
        activeWeek: sql<number>`count(*) filter (where ${usersTable.lastSeenAt} >= ${weekStart})`.mapWith(Number),
        publishingBlocked: sql<number>`count(*) filter (where ${usersTable.publishingBlockedAt} is not null)`.mapWith(Number),
        searchBlocked: sql<number>`count(*) filter (where ${usersTable.searchBlockedAt} is not null)`.mapWith(Number),
      })
      .from(usersTable);

    const usage = await db
      .select({
        day: dailyUsageTable.day,
        searches: sum(dailyUsageTable.searches).mapWith(Number),
        insights: sum(dailyUsageTable.insights).mapWith(Number),
        bonus: sum(dailyUsageTable.bonusSearches).mapWith(Number),
      })
      .from(dailyUsageTable)
      .where(inArray(dailyUsageTable.day, days))
      .groupBy(dailyUsageTable.day);

    const outcomes = await db
      .select({
        day: sql<string>`to_char(${searchLogTable.createdAt} at time zone 'Europe/Istanbul', 'YYYY-MM-DD')`,
        outcome: searchLogTable.outcome,
        n: count(),
      })
      .from(searchLogTable)
      .where(gte(searchLogTable.createdAt, weekStart))
      .groupBy(sql`1`, searchLogTable.outcome);

    const signups = await db
      .select({
        day: sql<string>`to_char(${usersTable.createdAt} at time zone 'Europe/Istanbul', 'YYYY-MM-DD')`,
        n: count(),
      })
      .from(usersTable)
      .where(gte(usersTable.createdAt, weekStart))
      .groupBy(sql`1`);

    const [lists] = await db
      .select({
        total: count(),
        public: sql<number>`count(*) filter (where ${gurmeListsTable.visibility} = 'public' and ${gurmeListsTable.hiddenAt} is null)`.mapWith(Number),
        unlisted: sql<number>`count(*) filter (where ${gurmeListsTable.visibility} = 'unlisted' and ${gurmeListsTable.hiddenAt} is null)`.mapWith(Number),
        hidden: sql<number>`count(*) filter (where ${gurmeListsTable.hiddenAt} is not null)`.mapWith(Number),
        newWeek: sql<number>`count(*) filter (where ${gurmeListsTable.createdAt} >= ${weekStart})`.mapWith(Number),
      })
      .from(gurmeListsTable);

    const [openListReports] = await db
      .select({ n: sql<number>`count(distinct ${listReportsTable.listId})`.mapWith(Number) })
      .from(listReportsTable)
      .where(isNull(listReportsTable.reviewedAt));
    const [openVenueReports] = await db
      .select({ n: sql<number>`count(distinct (${venueReportsTable.placeId}, ${venueReportsTable.reportType}))`.mapWith(Number) })
      .from(venueReportsTable)
      .where(eq(venueReportsTable.status, "open"));

    const usageByDay = new Map(usage.map((u) => [u.day, u]));
    const signupsByDay = new Map(signups.map((s) => [s.day, s.n]));
    const outcomesByDay = new Map<string, Record<string, number>>();
    for (const o of outcomes) {
      const row = outcomesByDay.get(o.day) ?? {};
      row[o.outcome] = o.n;
      outcomesByDay.set(o.day, row);
    }

    const config = authConfig();
    res.json({
      today,
      users: users ?? {},
      lists: lists ?? {},
      reports: { lists: openListReports?.n ?? 0, venues: openVenueReports?.n ?? 0 },
      budgets: {
        places: placesBudget.snapshot(),
        photos: placesPhotoBudget.snapshot(),
      },
      limits: { freeSearchesPerDay: FREE_SEARCHES_PER_DAY, insightsPerDay: INSIGHTS_PER_DAY },
      days: days.map((day) => ({
        day,
        searches: usageByDay.get(day)?.searches ?? 0,
        insights: usageByDay.get(day)?.insights ?? 0,
        bonus: usageByDay.get(day)?.bonus ?? 0,
        newUsers: signupsByDay.get(day) ?? 0,
        outcomes: outcomesByDay.get(day) ?? {},
      })),
      server: {
        revision: process.env.K_REVISION ?? null,
        authEnabled: config.verifier !== null,
        appCheckEnforced: config.enforceAppCheck,
        placesConfigured: Boolean(process.env.GOOGLE_PLACES_API_KEY),
        aiProviders: ["GEMINI_API_KEY", "DEEPSEEK_API_KEY"].filter((k) => Boolean(process.env[k])).map((k) => k.split("_")[0]!.toLowerCase()),
        uptimeSeconds: Math.round(process.uptime()),
      },
    });
  } catch (error) {
    req.log.error({ err: error }, "Admin overview failed");
    res.status(500).json({ error: "Genel bakış yüklenemedi" });
  }
});

const UsersQuery = z.object({
  q: z.string().trim().max(100).optional(),
  filter: z.enum(["all", "blocked", "active"]).optional(),
  limit: z.coerce.number().int().min(1).max(200).optional(),
});

router.get("/admin/users", async (req, res): Promise<void> => {
  const query = UsersQuery.safeParse(req.query);
  if (!query.success) {
    res.status(400).json({ error: "Geçersiz süzgeç" });
    return;
  }
  const { q, filter = "all", limit = 50 } = query.data;
  const today = istanbulDay(new Date());
  try {
    const conditions = [
      q ? or(ilike(usersTable.email, `%${q}%`), eq(usersTable.id, q)) : undefined,
      filter === "blocked"
        ? or(isNotNull(usersTable.publishingBlockedAt), isNotNull(usersTable.searchBlockedAt))
        : undefined,
      filter === "active" ? gte(usersTable.lastSeenAt, dayStart(today)) : undefined,
    ].filter(Boolean);
    const rows = await db
      .select({
        id: usersTable.id,
        email: usersTable.email,
        createdAt: usersTable.createdAt,
        lastSeenAt: usersTable.lastSeenAt,
        publishingBlocked: sql<boolean>`${usersTable.publishingBlockedAt} is not null`.mapWith(Boolean),
        searchBlocked: sql<boolean>`${usersTable.searchBlockedAt} is not null`.mapWith(Boolean),
        searchesToday: sql<number>`coalesce((select ${dailyUsageTable.searches} from ${dailyUsageTable} where ${dailyUsageTable.userId} = ${usersTable.id} and ${dailyUsageTable.day} = ${today}), 0)`.mapWith(Number),
        searchesTotal: sql<number>`coalesce((select sum(${dailyUsageTable.searches}) from ${dailyUsageTable} where ${dailyUsageTable.userId} = ${usersTable.id}), 0)`.mapWith(Number),
        lists: sql<number>`(select count(*) from ${gurmeListsTable} where ${gurmeListsTable.ownerUserId} = ${usersTable.id})`.mapWith(Number),
      })
      .from(usersTable)
      .where(conditions.length ? and(...conditions) : undefined)
      .orderBy(desc(usersTable.lastSeenAt))
      .limit(limit);
    res.json(rows);
  } catch (error) {
    req.log.error({ err: error }, "Admin users failed");
    res.status(500).json({ error: "Kullanıcılar yüklenemedi" });
  }
});

router.get("/admin/users/:userId", async (req, res): Promise<void> => {
  const userId = String(req.params.userId ?? "");
  const today = istanbulDay(new Date());
  try {
    const [user] = await db.select().from(usersTable).where(eq(usersTable.id, userId));
    if (!user) {
      res.status(404).json({ error: "Kullanıcı bulunamadı" });
      return;
    }
    const [usage, searches, lists, reportsMade] = await Promise.all([
      db
        .select()
        .from(dailyUsageTable)
        .where(eq(dailyUsageTable.userId, userId))
        .orderBy(desc(dailyUsageTable.day))
        .limit(14),
      db
        .select()
        .from(searchLogTable)
        .where(eq(searchLogTable.userId, userId))
        .orderBy(desc(searchLogTable.createdAt))
        .limit(30),
      db
        .select({
          id: gurmeListsTable.id,
          title: gurmeListsTable.title,
          visibility: gurmeListsTable.visibility,
          hidden: sql<boolean>`${gurmeListsTable.hiddenAt} is not null`.mapWith(Boolean),
          itemCount: sql<number>`jsonb_array_length(${gurmeListsTable.items})`.mapWith(Number),
          updatedAt: gurmeListsTable.updatedAt,
        })
        .from(gurmeListsTable)
        .where(eq(gurmeListsTable.ownerUserId, userId))
        .orderBy(desc(gurmeListsTable.updatedAt)),
      db.select({ n: count() }).from(listReportsTable).where(eq(listReportsTable.reporterUserId, userId)),
    ]);
    const todayUsage = usage.find((u) => u.day === today);
    res.json({
      id: user.id,
      email: user.email,
      createdAt: user.createdAt,
      lastSeenAt: user.lastSeenAt,
      publishingBlocked: user.publishingBlockedAt !== null,
      searchBlocked: user.searchBlockedAt !== null,
      today: {
        searches: todayUsage?.searches ?? 0,
        searchesLimit: FREE_SEARCHES_PER_DAY + (todayUsage?.bonusSearches ?? 0),
        insights: todayUsage?.insights ?? 0,
        placesUsed: placesBudget.snapshot(1000).topUsers.find((t) => t.userId === userId)?.used ?? 0,
      },
      usage: usage.map((u) => ({ day: u.day, searches: u.searches, bonus: u.bonusSearches, insights: u.insights })),
      searches: searches.map((s) => ({
        query: s.query,
        city: s.city,
        outcome: s.outcome,
        resultCount: s.resultCount,
        createdAt: s.createdAt,
      })),
      lists,
      reportsMade: reportsMade[0]?.n ?? 0,
    });
  } catch (error) {
    req.log.error({ err: error }, "Admin user detail failed");
    res.status(500).json({ error: "Kullanıcı yüklenemedi" });
  }
});

const BonusBody = z.object({ count: z.number().int().min(1).max(20) });

/** Bugün için ek arama hakkı verir (ödüllü reklamla aynı alan). */
router.post("/admin/users/:userId/bonus", async (req, res): Promise<void> => {
  const userId = String(req.params.userId ?? "");
  const body = BonusBody.safeParse(req.body);
  if (!body.success) {
    res.status(400).json({ error: "Geçersiz sayı (1–20)" });
    return;
  }
  try {
    const [user] = await db.select({ id: usersTable.id }).from(usersTable).where(eq(usersTable.id, userId));
    if (!user) {
      res.status(404).json({ error: "Kullanıcı bulunamadı" });
      return;
    }
    const day = istanbulDay(new Date());
    await db
      .insert(dailyUsageTable)
      .values({ userId, day, bonusSearches: body.data.count })
      .onConflictDoUpdate({
        target: [dailyUsageTable.userId, dailyUsageTable.day],
        set: { bonusSearches: sql`${dailyUsageTable.bonusSearches} + ${body.data.count}` },
      });
    res.json(await quotaStore().status(userId, day));
  } catch (error) {
    req.log.error({ err: error }, "Admin bonus failed");
    res.status(500).json({ error: "Hak eklenemedi" });
  }
});

const BlockBody = z.object({ blocked: z.boolean() });

/** Hesabın aramasını kapatır ya da açar. */
router.post("/admin/users/:userId/search", async (req, res): Promise<void> => {
  const userId = String(req.params.userId ?? "");
  const body = BlockBody.safeParse(req.body);
  if (!body.success) {
    res.status(400).json({ error: "Geçersiz işlem" });
    return;
  }
  try {
    const [user] = await db
      .update(usersTable)
      .set({ searchBlockedAt: body.data.blocked ? new Date() : null })
      .where(eq(usersTable.id, userId))
      .returning({ id: usersTable.id });
    if (!user) {
      res.status(404).json({ error: "Kullanıcı bulunamadı" });
      return;
    }
    res.json({ blocked: body.data.blocked });
  } catch (error) {
    req.log.error({ err: error }, "Admin search block failed");
    res.status(500).json({ error: "İşlem yapılamadı" });
  }
});

const SearchesQuery = z.object({
  outcome: z.enum(["ok", "cached", "quota", "budget", "blocked", "error"]).optional(),
  limit: z.coerce.number().int().min(1).max(200).optional(),
});

/** Son aramalar ve en çok aranan kelimeler (son 7 gün). */
router.get("/admin/searches", async (req, res): Promise<void> => {
  const query = SearchesQuery.safeParse(req.query);
  if (!query.success) {
    res.status(400).json({ error: "Geçersiz süzgeç" });
    return;
  }
  const { outcome, limit = 50 } = query.data;
  try {
    const weekStart = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const [recent, topQueries, topCities] = await Promise.all([
      db
        .select({
          query: searchLogTable.query,
          city: searchLogTable.city,
          outcome: searchLogTable.outcome,
          resultCount: searchLogTable.resultCount,
          createdAt: searchLogTable.createdAt,
          userId: searchLogTable.userId,
          email: usersTable.email,
        })
        .from(searchLogTable)
        .leftJoin(usersTable, eq(usersTable.id, searchLogTable.userId))
        .where(outcome ? eq(searchLogTable.outcome, outcome) : undefined)
        .orderBy(desc(searchLogTable.createdAt))
        .limit(limit),
      db
        .select({ value: sql<string>`lower(${searchLogTable.query})`, n: count() })
        .from(searchLogTable)
        .where(gte(searchLogTable.createdAt, weekStart))
        .groupBy(sql`1`)
        .orderBy(desc(count()))
        .limit(10),
      db
        .select({ value: searchLogTable.city, n: count() })
        .from(searchLogTable)
        .where(and(gte(searchLogTable.createdAt, weekStart), ne(searchLogTable.city, "")))
        .groupBy(searchLogTable.city)
        .orderBy(desc(count()))
        .limit(10),
    ]);
    res.json({ recent, topQueries, topCities });
  } catch (error) {
    req.log.error({ err: error }, "Admin searches failed");
    res.status(500).json({ error: "Aramalar yüklenemedi" });
  }
});

const ListsQuery = z.object({
  filter: z.enum(["shared", "public", "unlisted", "hidden", "all"]).optional(),
  q: z.string().trim().max(100).optional(),
  limit: z.coerce.number().int().min(1).max(200).optional(),
});

/** Paylaşılan listeler (varsayılan: herkese açık ve bağlantıyla). */
router.get("/admin/lists", async (req, res): Promise<void> => {
  const query = ListsQuery.safeParse(req.query);
  if (!query.success) {
    res.status(400).json({ error: "Geçersiz süzgeç" });
    return;
  }
  const { filter = "shared", q, limit = 50 } = query.data;
  try {
    const conditions = [
      filter === "shared" ? ne(gurmeListsTable.visibility, "private") : undefined,
      filter === "public" ? eq(gurmeListsTable.visibility, "public") : undefined,
      filter === "unlisted" ? eq(gurmeListsTable.visibility, "unlisted") : undefined,
      filter === "hidden" ? isNotNull(gurmeListsTable.hiddenAt) : undefined,
      q ? or(ilike(gurmeListsTable.title, `%${q}%`), ilike(gurmeListsTable.authorName, `%${q}%`)) : undefined,
    ].filter(Boolean);
    const rows = await db
      .select({
        id: gurmeListsTable.id,
        title: gurmeListsTable.title,
        authorName: gurmeListsTable.authorName,
        visibility: gurmeListsTable.visibility,
        hidden: sql<boolean>`${gurmeListsTable.hiddenAt} is not null`.mapWith(Boolean),
        itemCount: sql<number>`jsonb_array_length(${gurmeListsTable.items})`.mapWith(Number),
        ownerUserId: gurmeListsTable.ownerUserId,
        ownerEmail: usersTable.email,
        reports: sql<number>`(select count(*) from ${listReportsTable} where ${listReportsTable.listId} = ${gurmeListsTable.id})`.mapWith(Number),
        createdAt: gurmeListsTable.createdAt,
        updatedAt: gurmeListsTable.updatedAt,
      })
      .from(gurmeListsTable)
      .leftJoin(usersTable, eq(usersTable.id, gurmeListsTable.ownerUserId))
      .where(conditions.length ? and(...conditions) : undefined)
      .orderBy(desc(gurmeListsTable.updatedAt))
      .limit(limit);
    res.json(rows);
  } catch (error) {
    req.log.error({ err: error }, "Admin lists failed");
    res.status(500).json({ error: "Listeler yüklenemedi" });
  }
});

export default router;
