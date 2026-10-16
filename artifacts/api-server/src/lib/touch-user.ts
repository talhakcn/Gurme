import type { NextFunction, Request, Response } from "express";
import { quotaStore } from "../auth/runtime";
import { logger } from "./logger";

const TOUCH_EVERY_MS = 60 * 60 * 1000;
const lastTouch = new Map<string, number>();

/** Giriş yapan hesabın satırını açar ya da son görülme zamanını yeniler. */
export function touchSignedInUser(req: Request, _res: Response, next: NextFunction): void {
  const user = req.user;
  if (user) {
    const now = Date.now();
    if (now - (lastTouch.get(user.uid) ?? 0) > TOUCH_EVERY_MS) {
      lastTouch.set(user.uid, now);
      // Yanıtı bekletmez; yazılamasa da istek sürer.
      quotaStore()
        .touchUser(user)
        .catch((err: unknown) => logger.warn({ err }, "Kullanıcı kaydı yenilenemedi"));
    }
  }
  next();
}

/** Testlerde her istek yeniden yazsın diye. */
export function resetTouchedUsersForTesting(): void {
  lastTouch.clear();
}
