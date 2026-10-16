import { createHash, timingSafeEqual } from "node:crypto";
import type { Request, Response } from "express";

/** Acil durum anahtarı (ADMIN_API_KEY) Authorization başlığında mı? */
export function hasValidAdminToken(authorization: string | undefined, expectedToken: string): boolean {
  if (!authorization?.startsWith("Bearer ")) return false;
  const receivedDigest = createHash("sha256").update(authorization.slice(7)).digest();
  const expectedDigest = createHash("sha256").update(expectedToken).digest();
  return timingSafeEqual(receivedDigest, expectedDigest);
}

/**
 * Yönetici: Firebase hesabında `admin: true` özel yetkisi (custom claim)
 * olan kullanıcı. Yetki `scripts/set-admin.ts` ile verilir. ADMIN_API_KEY
 * yalnızca acil durum içindir (terminalden).
 */
export function isAdmin(req: Request): boolean {
  if (req.user?.admin) return true;
  const key = process.env.ADMIN_API_KEY;
  return Boolean(key && hasValidAdminToken(req.get("authorization"), key));
}

/** Kim inceledi: yöneticinin hesabı ya da acil durum anahtarı. */
export function adminActor(req: Request): string {
  return req.user?.admin ? req.user.uid : "admin-key";
}

/** Yönetici değilse 403 yazar ve `false` döner. */
export function requireAdmin(req: Request, res: Response): boolean {
  if (isAdmin(req)) return true;
  res.status(403).json({ error: "Yönetici yetkisi gerekli", code: "admin_required" });
  return false;
}
