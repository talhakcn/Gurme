import type { RequestHandler } from "express";
import { rateLimit } from "express-rate-limit";

const MINUTE_MS = 60 * 1000;
const HOUR_MS = 60 * MINUTE_MS;

function limiter(windowMs: number, limit: number, message: string): RequestHandler {
  return rateLimit({
    windowMs,
    limit,
    standardHeaders: "draft-8",
    legacyHeaders: false,
    message: { error: message },
  });
}

// Tüm API için genel koruma
export const apiLimiter = limiter(15 * MINUTE_MS, 300, "Çok fazla istek gönderdiniz. Lütfen biraz sonra tekrar deneyin.");

// Her arama bir Google Text Search çağrısı yapar; maliyeti sınırlamak için sıkı tutulur.
// Kullanıcı bazlı günlük kota hesap sistemi eklendiğinde bunun üzerine gelecek.
const searchListLimiter = limiter(HOUR_MS, 20, "Saatlik arama sınırına ulaştınız. Lütfen daha sonra tekrar deneyin.");

// İkinci aşama (mekân analizi) ve mekân sayfası: yapay zekâ ve gerekirse
// Place Details çağrısı yapar. Her aramayı 1-2 analiz isteği izler.
export const insightLimiter = limiter(HOUR_MS, 60, "Saatlik mekân analizi sınırına ulaştınız. Lütfen daha sonra tekrar deneyin.");

/** `/api/search` ve alt yolu `/api/search/insights` ayrı sınırlanır. */
export const searchLimiter: RequestHandler = (req, res, next) =>
  req.path === "/" ? searchListLimiter(req, res, next) : insightLimiter(req, res, next);

export const autocompleteLimiter = limiter(MINUTE_MS, 60, "Çok fazla öneri isteği gönderdiniz. Lütfen biraz bekleyin.");

const listCreateLimiter = limiter(HOUR_MS, 20, "Saatlik liste oluşturma sınırına ulaştınız.");

export const listWriteLimiter: RequestHandler = (req, res, next) =>
  req.method === "POST" ? listCreateLimiter(req, res, next) : next();
