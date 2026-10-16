import type { NextFunction, Request, RequestHandler, Response } from "express";
import { logger } from "../lib/logger";
import { createFirebaseVerifier } from "./firebase";

export interface AuthUser {
  uid: string;
  email?: string;
  /** Firebase özel yetkisi `admin: true`; yönetim uçlarını açar. */
  admin?: boolean;
}

/** Firebase'i sarmalar; testlerde sahte sürümü kullanılır. */
export interface AuthVerifier {
  /** Geçersiz ya da süresi dolmuş token için hata fırlatır. */
  verifyIdToken(token: string): Promise<AuthUser>;
  /** Geçersiz App Check token'ı için hata fırlatır. */
  verifyAppCheck(token: string): Promise<void>;
}

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      /** Geçerli bir Firebase ID token'ı geldiyse giriş yapmış kullanıcı. */
      user?: AuthUser;
    }
  }
}

export interface AuthConfig {
  /** `null`: Firebase yapılandırılmamış; giriş ve kota uygulanmaz (geliştirme). */
  verifier: AuthVerifier | null;
  /** App Check token'ı zorunlu mu (APP_CHECK_ENFORCE=true). */
  enforceAppCheck: boolean;
}

const BEARER = /^Bearer\s+(.+)$/i;

/** JWT üç noktalı parçadan oluşur; liste anahtarları (64 hex) oluşmaz. */
export function bearerJwt(authorization: string | undefined): string | undefined {
  const token = authorization?.match(BEARER)?.[1]?.trim();
  return token && token.split(".").length === 3 ? token : undefined;
}

/**
 * Authorization başlığında Firebase ID token'ı varsa doğrular ve
 * `req.user`'ı doldurur. Token yoksa istek anonim devam eder; geçersizse 401.
 */
export function authenticate(getConfig: () => AuthConfig): RequestHandler {
  return async (req: Request, res: Response, next: NextFunction) => {
    const config = getConfig();
    const token = bearerJwt(req.get("authorization"));
    if (!token || !config.verifier) return next();
    try {
      req.user = await config.verifier.verifyIdToken(token);
      next();
    } catch (err) {
      logger.info({ err: String(err) }, "Geçersiz ID token");
      res.status(401).json({ error: "Oturumun geçersiz ya da süresi dolmuş. Yeniden giriş yap.", code: "auth_invalid" });
    }
  };
}

/** Firebase yapılandırılmışsa giriş zorunlu; değilse (geliştirme) serbest. */
export function requireUser(getConfig: () => AuthConfig): RequestHandler {
  return (req, res, next) => {
    if (!getConfig().verifier || req.user) return next();
    res.status(401).json({ error: "Bu işlem için giriş yapmalısın.", code: "auth_required" });
  };
}

/**
 * Yalnızca gerçek uygulamanın çağırabilmesi için Firebase App Check.
 * Zorunlu değilse gelen token yine doğrulanır, eksikliği hata sayılmaz.
 */
export function requireAppCheck(getConfig: () => AuthConfig): RequestHandler {
  return async (req, res, next) => {
    const config = getConfig();
    const token = req.get("x-firebase-appcheck");
    if (!config.verifier || (!token && !config.enforceAppCheck)) return next();
    if (!token) {
      res.status(401).json({ error: "Uygulama doğrulanamadı.", code: "app_check_required" });
      return;
    }
    try {
      await config.verifier.verifyAppCheck(token);
      next();
    } catch (err) {
      logger.info({ err: String(err) }, "Geçersiz App Check token");
      res.status(401).json({ error: "Uygulama doğrulanamadı.", code: "app_check_invalid" });
    }
  };
}

/**
 * Ortam değişkenlerinden yapılandırma. FIREBASE_PROJECT_ID yoksa giriş
 * kapalıdır. Cloud Run'da kimlik bilgisi Application Default Credentials
 * ile gelir; ID token doğrulaması için ayrıca anahtar gerekmez.
 */
export function authConfigFromEnv(env: NodeJS.ProcessEnv): AuthConfig {
  const projectId = env.FIREBASE_PROJECT_ID;
  if (!projectId) {
    if (env.NODE_ENV === "production") {
      logger.warn("FIREBASE_PROJECT_ID yok: giriş ve kota KAPALI");
    }
    return { verifier: null, enforceAppCheck: false };
  }
  return {
    verifier: createFirebaseVerifier(projectId),
    enforceAppCheck: env.APP_CHECK_ENFORCE === "true",
  };
}
