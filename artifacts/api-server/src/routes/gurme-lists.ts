import { createHash, randomBytes, randomUUID, timingSafeEqual } from "node:crypto";
import { and, desc, eq, isNull, or, type SQL } from "drizzle-orm";
import { Router, type IRouter, type Request, type Response } from "express";
import { db, gurmeListsTable } from "@workspace/db";
import {
  CreateGurmeListBody,
  DeleteGurmeListParams,
  GetGurmeListParams,
  GetGurmeListResponse,
  ListGurmeListsResponse,
  UpdateGurmeListBody,
  UpdateGurmeListParams,
  UpdateGurmeListResponse,
  ClaimGurmeListParams,
  ClaimGurmeListResponse,
  type GurmeListCreated,
} from "@workspace/api-zod";
import { bearerJwt } from "../auth/auth";
import { isAdmin } from "../auth/admin";
import { publishingBlocked } from "./moderation";

const router: IRouter = Router();
const SHARE_CONTENT_SECURITY_POLICY = [
  "default-src 'none'",
  "style-src 'unsafe-inline' https://fonts.googleapis.com",
  "font-src https://fonts.gstatic.com",
  "base-uri 'none'",
  "form-action 'none'",
  "frame-ancestors 'none'",
  "object-src 'none'",
  "connect-src 'none'",
].join("; ");

/** Herkese açık listelerin dökümünde en fazla bu kadar (en yeniler). */
const PUBLIC_LIST_LIMIT = 100;

function validOwnerKey(value: string | undefined): string | undefined {
  return value && value.length >= 32 && value.length <= 256 ? value : undefined;
}

/**
 * Liste sahibi anahtarı: X-Owner-Key başlığı ya da (eski istemciler için)
 * Authorization'daki JWT olmayan bearer değeri.
 */
function ownerKeyFromRequest(req: Request): string | undefined {
  const header = validOwnerKey(req.get("x-owner-key"));
  if (header) return header;
  const authorization = req.get("authorization");
  if (!authorization?.startsWith("Bearer ") || bearerJwt(authorization)) return undefined;
  return validOwnerKey(authorization.slice(7));
}

/**
 * Anahtar ya da giriş yapmış kullanıcı üzerinden sahiplik koşulu. Hesaba
 * bağlanmış listede anahtar tek başına yetmez: liste yalnızca o hesapla
 * düzenlenir. Anahtar, hesaba bağlanmamış (girişsiz yayınlanmış) listeler içindir.
 */
function ownedBy(req: Request): SQL | undefined {
  const ownerKey = ownerKeyFromRequest(req);
  const unboundOrMine = req.user
    ? or(isNull(gurmeListsTable.ownerUserId), eq(gurmeListsTable.ownerUserId, req.user.uid))
    : isNull(gurmeListsTable.ownerUserId);
  const conditions = [
    ...(ownerKey ? [and(eq(gurmeListsTable.ownerKeyHash, hashOwnerKey(ownerKey)), unboundOrMine)] : []),
    ...(req.user ? [eq(gurmeListsTable.ownerUserId, req.user.uid)] : []),
  ];
  return conditions.length === 0 ? undefined : or(...conditions);
}

function isOwner(req: Request, list: typeof gurmeListsTable.$inferSelect): boolean {
  if (list.ownerUserId) return Boolean(req.user && list.ownerUserId === req.user.uid);
  const ownerKey = ownerKeyFromRequest(req);
  return Boolean(ownerKey && hashesMatch(hashOwnerKey(ownerKey), list.ownerKeyHash));
}

function hashOwnerKey(ownerKey: string): string {
  return createHash("sha256").update(ownerKey).digest("hex");
}

function hashesMatch(left: string, right: string): boolean {
  const leftBytes = Buffer.from(left, "hex");
  const rightBytes = Buffer.from(right, "hex");
  return leftBytes.length === rightBytes.length && timingSafeEqual(leftBytes, rightBytes);
}

function isUniqueConstraintError(error: unknown): boolean {
  return (
    typeof error === "object" &&
    error !== null &&
    "code" in error &&
    error.code === "23505"
  );
}

function toPublicList(list: typeof gurmeListsTable.$inferSelect) {
  return {
    id: list.id,
    title: list.title,
    description: list.description,
    authorName: list.authorName,
    visibility: list.visibility,
    items: list.items,
    createdAt: list.createdAt,
    updatedAt: list.updatedAt,
  };
}

function escapeHtml(value: string): string {
  const entities: Record<string, string> = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  };
  return value.replace(/[&<>"']/g, (character) => entities[character] ?? character);
}

function setSharePageHeaders(res: Response): void {
  res.set({
    "Content-Security-Policy": SHARE_CONTENT_SECURITY_POLICY,
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "Referrer-Policy": "no-referrer",
    "Cache-Control": "no-store",
  });
}

function shareErrorPage(title: string, message: string): string {
  return `<!doctype html>
<html lang="tr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(title)} · GURME</title>
</head>
<body style="margin:0;background:#F2F0EF;color:#20373B;font-family:'Plus Jakarta Sans',sans-serif">
  <main style="max-width:680px;margin:12vh auto;padding:32px 24px">
    <p style="font-family:'Plus Jakarta Sans',sans-serif;color:#519CAB;letter-spacing:.18em;font-size:11px">GURME · KİŞİSEL KÜRATÖR DEFTERİ</p>
    <h1 style="font-family:'Bodoni Moda',Georgia,serif;font-weight:400;font-size:42px">${escapeHtml(title)}</h1>
    <p style="line-height:1.8">${escapeHtml(message)}</p>
  </main>
</body>
</html>`;
}

function renderSharePage(list: typeof gurmeListsTable.$inferSelect): string {
  const itemsMarkup = list.items
    .map((item, index) => `<li class="place">
      <span class="number">${String(index + 1).padStart(2, "0")}</span>
      <div class="place-copy">
        <h2>${escapeHtml(item.name)}</h2>
        <p class="area">${escapeHtml(item.area)}${item.category ? ` · ${escapeHtml(item.category)}` : ""}</p>
        <p class="note">${escapeHtml(item.note)}</p>
      </div>
    </li>`)
    .join("\n");

  return `<!doctype html>
<html lang="tr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#F2F0EF">
  <title>${escapeHtml(list.title)} · GURME</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bodoni+Moda:ital,opsz,wght@0,6..96,400;1,6..96,400&family=Plus+Jakarta+Sans:wght@400;600&display=swap" rel="stylesheet">
  <style>
    :root { color-scheme: light; --paper:#F2F0EF; --ink:#20373B; --teal:#519CAB; --line:#A9C8CC; --gold:#FFC64F; --muted:#687B7E; --wash:#E7E9E7; }
    * { box-sizing:border-box; }
    body { margin:0; background:var(--paper); color:var(--ink); font-family:'Plus Jakarta Sans',sans-serif; }
    main { width:min(100% - 40px, 760px); margin:0 auto; padding:0 0 80px; }
    header { min-height:88px; border-bottom:1px solid var(--line); display:flex; align-items:center; justify-content:center; }
    .masthead { margin:0; font-family:'Bodoni Moda',Georgia,serif; font-size:25px; font-weight:400; letter-spacing:.18em; }
    .intro { padding:54px 0 35px; }
    .eyebrow { color:var(--teal); font-size:10px; font-weight:600; letter-spacing:.15em; text-transform:uppercase; }
    h1 { margin:14px 0 10px; font-family:'Bodoni Moda',Georgia,serif; font-size:clamp(38px,8vw,58px); line-height:1.08; font-weight:400; }
    .description { color:var(--ink); font-family:'Bodoni Moda',Georgia,serif; font-size:20px; line-height:1.55; white-space:pre-wrap; }
    .author { margin-top:22px; color:var(--muted); font-size:12px; }
    .gold-rule { width:36px; height:2px; margin-top:24px; background:var(--gold); }
    ol { margin:0; padding:0; list-style:none; border-top:1px solid var(--line); }
    .place { display:grid; grid-template-columns:46px 1fr; gap:12px; padding:23px 0; border-bottom:1px solid var(--line); }
    .number { color:var(--teal); font-family:'Bodoni Moda',Georgia,serif; font-size:24px; }
    h2 { margin:0; font-family:'Bodoni Moda',Georgia,serif; font-size:28px; line-height:1.25; font-weight:400; }
    .area { margin:7px 0 0; color:var(--teal); font-size:10px; font-weight:600; letter-spacing:.09em; text-transform:uppercase; }
    .note { margin:12px 0 0; color:var(--muted); font-size:13px; line-height:1.8; white-space:pre-wrap; }
    footer { margin-top:42px; color:var(--teal); text-align:center; font-size:10px; font-weight:600; letter-spacing:.12em; text-transform:uppercase; }
    @media (max-width:480px) { main { width:min(100% - 32px, 760px); } .intro { padding-top:38px; } }
  </style>
</head>
<body>
  <header><p class="masthead">GURME</p></header>
  <main>
    <section class="intro">
      <p class="eyebrow">Kişisel küratör defteri</p>
      <h1>${escapeHtml(list.title)}</h1>
      <p class="description">${escapeHtml(list.description)}</p>
      <p class="author">Küratör · ${escapeHtml(list.authorName)}</p>
      <div class="gold-rule"></div>
    </section>
    <ol>${itemsMarkup}</ol>
    <footer>GURME · Bir liste, bir şehrin başka bir okuması.</footer>
  </main>
</body>
</html>`;
}

router.get("/gurme/lists", async (req, res): Promise<void> => {
  try {
    const owner = ownedBy(req);
    const lists = owner
      ? await db
          .select()
          .from(gurmeListsTable)
          .where(owner)
          .orderBy(desc(gurmeListsTable.createdAt))
      : await db
          .select()
          .from(gurmeListsTable)
          // Yöneticinin kaldırdığı liste keşifte görünmez.
          .where(and(eq(gurmeListsTable.visibility, "public"), isNull(gurmeListsTable.hiddenAt)))
          .orderBy(desc(gurmeListsTable.createdAt))
          .limit(PUBLIC_LIST_LIMIT);

    res.json(ListGurmeListsResponse.parse(lists.map(toPublicList)));
  } catch (error) {
    req.log.error({ err: error }, "Failed to load Gurme lists");
    res.status(500).json({ error: "Gurme listeleri veritabanından yüklenemedi" });
  }
});

const PUBLISHING_BLOCKED = {
  error: "Bu hesapla liste paylaşımı kapatıldı. Listelerin cihazında duruyor.",
  code: "publishing_blocked",
};

router.post("/gurme/lists", async (req, res): Promise<void> => {
  const parsed = CreateGurmeListBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: "Geçersiz Gurme listesi", details: parsed.error.message });
    return;
  }
  if (parsed.data.visibility !== "private" && (await publishingBlocked(req.user?.uid))) {
    res.status(403).json(PUBLISHING_BLOCKED);
    return;
  }

  try {
    const ownerKey = randomBytes(32).toString("hex");
    const fields = parsed.data;
    const [list] = await db
      .insert(gurmeListsTable)
      .values({
        id: randomUUID(),
        ownerKeyHash: hashOwnerKey(ownerKey),
        ownerUserId: req.user?.uid ?? null,
        ...fields,
      })
      .returning();

    if (!list) {
      req.log.error("Gurme list insert returned no row");
      res.status(500).json({ error: "Gurme listesi oluşturuldu ancak kaydı alınamadı" });
      return;
    }

    const createdList: GurmeListCreated = {
      ...GetGurmeListResponse.parse(toPublicList(list)),
      ownerKey,
    };
    res.status(201).json(createdList);
  } catch (error) {
    req.log.error({ err: error }, "Failed to create Gurme list");
    if (isUniqueConstraintError(error)) {
      res.status(409).json({ error: "Gurme listesi kimliği çakıştı; tekrar deneyin" });
      return;
    }
    res.status(500).json({ error: "Gurme listesi veritabanına kaydedilemedi" });
  }
});

router.get("/gurme/share/:id", async (req, res): Promise<void> => {
  const params = GetGurmeListParams.safeParse(req.params);
  setSharePageHeaders(res);
  if (!params.success) {
    res.status(404).type("html").send(shareErrorPage("Liste bulunamadı", "Bu listeye ulaşılamıyor."));
    return;
  }

  try {
    const [list] = await db
      .select()
      .from(gurmeListsTable)
      .where(eq(gurmeListsTable.id, params.data.id));

    if (!list || list.visibility === "private") {
      res.status(404).type("html").send(shareErrorPage("Liste bulunamadı", "Bu listeye ulaşılamıyor."));
      return;
    }
    if (list.hiddenAt) {
      res
        .status(410)
        .type("html")
        .send(shareErrorPage("Liste kaldırıldı", "Bu liste kurallara uymadığı için yayından kaldırıldı."));
      return;
    }

    res.status(200).type("html").send(renderSharePage(list));
  } catch (error) {
    req.log.error({ err: error }, "Failed to render Gurme share page");
    res
      .status(500)
      .type("html")
      .send(shareErrorPage("Liste açılamadı", "Liste veritabanından yüklenemedi."));
  }
});

router.get("/gurme/lists/:id", async (req, res): Promise<void> => {
  const params = GetGurmeListParams.safeParse(req.params);
  if (!params.success) {
    res.status(400).json({ error: "Geçersiz Gurme listesi kimliği", details: params.error.message });
    return;
  }

  try {
    const [list] = await db
      .select()
      .from(gurmeListsTable)
      .where(eq(gurmeListsTable.id, params.data.id));

    if (!list) {
      res.status(404).json({ error: "Gurme listesi bulunamadı" });
      return;
    }

    // Özel listeyi yalnızca sahibi, kaldırılmış listeyi sahibi ve yönetici görür.
    const allowed =
      isOwner(req, list) || (list.visibility !== "private" && (!list.hiddenAt || isAdmin(req)));
    if (!allowed) {
      res.status(404).json({ error: "Gurme listesi bulunamadı veya görüntülenemiyor" });
      return;
    }

    res.json(GetGurmeListResponse.parse(toPublicList(list)));
  } catch (error) {
    req.log.error({ err: error }, "Failed to load Gurme list");
    res.status(500).json({ error: "Gurme listesi veritabanından yüklenemedi" });
  }
});

router.put("/gurme/lists/:id", async (req, res): Promise<void> => {
  const params = UpdateGurmeListParams.safeParse(req.params);
  if (!params.success) {
    res.status(400).json({ error: "Geçersiz Gurme listesi kimliği", details: params.error.message });
    return;
  }

  const parsed = UpdateGurmeListBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: "Geçersiz Gurme listesi", details: parsed.error.message });
    return;
  }

  const owner = ownedBy(req);
  if (!owner) {
    res.status(401).json({ error: "Liste sahibi anahtarı ya da giriş gerekli" });
    return;
  }
  // Yayını kapatılan hesap listesini düzenleyebilir, ama yalnızca özel tutar.
  if (
    parsed.data.visibility !== undefined &&
    parsed.data.visibility !== "private" &&
    (await publishingBlocked(req.user?.uid))
  ) {
    res.status(403).json(PUBLISHING_BLOCKED);
    return;
  }

  try {
    const [list] = await db
      .update(gurmeListsTable)
      .set(parsed.data)
      .where(
        and(
          eq(gurmeListsTable.id, params.data.id),
          owner,
        ),
      )
      .returning();

    if (!list) {
      res.status(404).json({ error: "Gurme listesi bulunamadı veya liste sahibi değilsiniz" });
      return;
    }

    res.json(UpdateGurmeListResponse.parse(toPublicList(list)));
  } catch (error) {
    req.log.error({ err: error }, "Failed to update Gurme list");
    res.status(500).json({ error: "Gurme listesi veritabanında güncellenemedi" });
  }
});

router.delete("/gurme/lists/:id", async (req, res): Promise<void> => {
  const params = DeleteGurmeListParams.safeParse(req.params);
  if (!params.success) {
    res.status(400).json({ error: "Geçersiz Gurme listesi kimliği", details: params.error.message });
    return;
  }

  const owner = ownedBy(req);
  if (!owner) {
    res.status(401).json({ error: "Liste sahibi anahtarı ya da giriş gerekli" });
    return;
  }

  try {
    const [deleted] = await db
      .delete(gurmeListsTable)
      .where(
        and(
          eq(gurmeListsTable.id, params.data.id),
          owner,
        ),
      )
      .returning({ id: gurmeListsTable.id });

    if (!deleted) {
      res.status(404).json({ error: "Gurme listesi bulunamadı veya liste sahibi değilsiniz" });
      return;
    }

    res.status(204).send();
  } catch (error) {
    req.log.error({ err: error }, "Failed to delete Gurme list");
    res.status(500).json({ error: "Gurme listesi veritabanından silinemedi" });
  }
});

/** Cihaz anahtarıyla oluşturulmuş listeyi giriş yapmış hesaba bağlar. */
router.post("/gurme/lists/:id/claim", async (req, res): Promise<void> => {
  const params = ClaimGurmeListParams.safeParse(req.params);
  if (!params.success) {
    res.status(400).json({ error: "Geçersiz Gurme listesi kimliği" });
    return;
  }
  const ownerKey = ownerKeyFromRequest(req);
  if (!req.user || !ownerKey) {
    res.status(401).json({ error: "Giriş ve liste sahibi anahtarı gerekli", code: "auth_required" });
    return;
  }
  try {
    const [list] = await db
      .update(gurmeListsTable)
      .set({ ownerUserId: req.user.uid })
      .where(
        and(
          eq(gurmeListsTable.id, params.data.id),
          eq(gurmeListsTable.ownerKeyHash, hashOwnerKey(ownerKey)),
          // Başka bir hesaba bağlanmış liste, anahtar bilinse de devralınamaz.
          or(isNull(gurmeListsTable.ownerUserId), eq(gurmeListsTable.ownerUserId, req.user.uid)),
        ),
      )
      .returning();
    if (!list) {
      res.status(404).json({ error: "Gurme listesi bulunamadı, anahtar eşleşmiyor ya da liste başka bir hesaba bağlı" });
      return;
    }
    res.json(ClaimGurmeListResponse.parse(toPublicList(list)));
  } catch (error) {
    req.log.error({ err: error }, "Failed to claim Gurme list");
    res.status(500).json({ error: "Liste hesaba bağlanamadı" });
  }
});

export default router;