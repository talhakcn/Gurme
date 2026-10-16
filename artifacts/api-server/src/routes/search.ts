import { Router, type IRouter, type Request, type Response } from "express";
import {
  GetVenueInsightsBody,
  GetVenueParams,
  SearchVenuesBody,
} from "@workspace/api-zod";
import { db } from "@workspace/db";
import { requireUser } from "../auth/auth";
import { istanbulDay } from "../auth/quota";
import { authConfig, quotaStore } from "../auth/runtime";
import { logger } from "../lib/logger";
import { logSearch, requireSearchAllowed, searchBlocked, SEARCH_BLOCKED } from "../lib/search-log";
import { createFlaggedPlaces } from "../search/community";
import { NO_FILTERS } from "../search/filters";
import { createGooglePlacesClient } from "../search/google-places";
import { PlacesBudgetExceeded } from "../search/places-budget";
import { createPlacePhotos, PLACE_ID_PATTERN, placesPhotoBudget } from "../search/place-photos";
import { createPgInsightStore } from "../search/insight-store";
import { createAnalyzer, providersFromEnv } from "../search/insights";
import { SearchError, SearchService } from "../search/search-service";

const router: IRouter = Router();

let service: SearchService | null | undefined;

/** Google anahtarı yoksa arama kapalıdır; AI anahtarı yoksa analizsiz çalışır. */
function searchService(): SearchService | null {
  if (service !== undefined) return service;
  const apiKey = process.env.GOOGLE_PLACES_API_KEY;
  if (!apiKey) {
    service = null;
    return service;
  }
  const providers = providersFromEnv(process.env);
  if (providers.length === 0) logger.warn("AI anahtarı yok; mekânlar analizsiz döner");
  service = new SearchService({
    places: createGooglePlacesClient(apiKey),
    store: createPgInsightStore(db),
    analyzer: createAnalyzer(providers),
    flaggedPlaces: createFlaggedPlaces(db),
  });
  return service;
}

/** Testlerde sahte bağımlılıklarla kurulan servisi kullanmak için. */
export function setSearchServiceForTesting(value: SearchService | null): void {
  service = value;
}

function unavailable(res: Response): void {
  res.status(503).json({ error: "Mekân araması bu sunucuda yapılandırılmamış." });
}

function handleError(res: Response, err: unknown): void {
  if (err instanceof PlacesBudgetExceeded && err.scope === "user") {
    res.status(429).json({
      error: "Bugünlük mekân bilgisi sınırına ulaştın. Yarın yenilenir.",
      code: "user_places_budget",
    });
    return;
  }
  if (err instanceof PlacesBudgetExceeded) {
    logger.warn("Places günlük sınırı doldu; arama durduruldu");
    res.status(503).json({
      error: "Arama bugün için yoğunluk nedeniyle durduruldu. Yarın yeniden dene.",
      code: "places_budget",
    });
    return;
  }
  if (err instanceof SearchError) {
    res.status(err.status).json({ error: err.message });
    return;
  }
  logger.error({ err }, "Arama isteği başarısız");
  res.status(500).json({ error: "Arama sırasında bir hata oluştu." });
}

router.post("/search", requireUser(authConfig), async (req, res) => {
  const body = SearchVenuesBody.safeParse(req.body);
  if (!body.success) {
    res.status(400).json({ error: "Geçersiz arama isteği", details: body.error.message });
    return;
  }
  const search = searchService();
  if (!search) return unavailable(res);
  const request = {
    city: body.data.city,
    cityPlaceId: body.data.cityPlaceId,
    query: body.data.query,
    filters: body.data.filters ?? NO_FILTERS,
  };
  // Yönetim panelindeki arama kaydı.
  const log = (outcome: Parameters<typeof logSearch>[0]["outcome"], resultCount = 0) =>
    logSearch({
      userId: req.user?.uid,
      query: request.query,
      city: request.city,
      filters: { ...request.filters },
      outcome,
      resultCount,
    });
  try {
    // Giriş kapalıysa (geliştirme) kota uygulanmaz.
    if (!req.user) {
      const result = await search.search(request);
      log(result.fromCache ? "cached" : "ok", result.venues.length);
      res.json(result);
      return;
    }
    const quota = quotaStore();
    const uid = req.user.uid;
    const day = istanbulDay(new Date());
    await quota.touchUser(req.user);
    if (await searchBlocked(uid)) {
      log("blocked");
      res.status(403).json(SEARCH_BLOCKED);
      return;
    }
    // Önbellekten dönen aramalar sayılmaz; hakkı biten kullanıcı da alır.
    const cached = await search.searchCached(request);
    if (cached) {
      log("cached", cached.venues.length);
      res.json({ ...cached, quota: await quota.status(uid, day) });
      return;
    }
    // Hak Google'a gitmeden önce düşülür: eşzamanlı istekler kotayı aşamaz.
    if (!(await quota.consumeSearch(uid, day))) {
      log("quota");
      res.status(429).json({
        error: "Bugünkü ücretsiz aramaların bitti. Yarın yenilenir.",
        code: "quota_exceeded",
        quota: await quota.status(uid, day),
      });
      return;
    }
    let result;
    try {
      result = await search.search(request);
    } catch (err) {
      await quota.refundSearch(uid, day);
      throw err;
    }
    // Aynı arama bu sırada başka bir istekle önbelleğe girdiyse hak geri verilir.
    if (result.fromCache) await quota.refundSearch(uid, day);
    log(result.fromCache ? "cached" : "ok", result.venues.length);
    res.json({ ...result, quota: await quota.status(uid, day) });
  } catch (err) {
    log(err instanceof PlacesBudgetExceeded ? "budget" : "error");
    handleError(res, err);
  }
});

/** Mekân analizi isteklerinin günlük sınırı; aşıldıysa yanıtı yazar. */
async function insightAllowed(req: Request, res: Response): Promise<boolean> {
  if (!req.user) return true;
  const allowed = await quotaStore().consumeInsight(req.user.uid, istanbulDay(new Date()));
  if (!allowed) {
    res.status(429).json({
      error: "Bugünkü mekân analizi sınırına ulaştın. Yarın yenilenir.",
      code: "insight_quota_exceeded",
    });
  }
  return allowed;
}

router.post("/search/insights", requireUser(authConfig), requireSearchAllowed, async (req, res) => {
  const body = GetVenueInsightsBody.safeParse(req.body);
  if (!body.success) {
    res.status(400).json({ error: "Geçersiz istek", details: body.error.message });
    return;
  }
  const search = searchService();
  if (!search) return unavailable(res);
  try {
    if (!(await insightAllowed(req, res))) return;
    const results = await search.insights(body.data.placeIds, body.data.filters ?? NO_FILTERS);
    res.json({
      venues: results.flatMap((v) => (v.filterStatus === null ? [] : [{ ...v, filterStatus: v.filterStatus }])),
      excludedPlaceIds: results.filter((v) => v.filterStatus === null).map((v) => v.placeId),
    });
  } catch (err) {
    handleError(res, err);
  }
});

router.get("/places/:placeId", requireUser(authConfig), requireSearchAllowed, async (req, res) => {
  const params = GetVenueParams.safeParse(req.params);
  if (!params.success) {
    res.status(400).json({ error: "Geçersiz mekân kimliği" });
    return;
  }
  const search = searchService();
  if (!search) return unavailable(res);
  try {
    if (!(await insightAllowed(req, res))) return;
    const [venue] = await search.insights([params.data.placeId], NO_FILTERS);
    res.json({ ...venue, filterStatus: "none" });
  } catch (err) {
    handleError(res, err);
  }
});

let photos: ReturnType<typeof createPlacePhotos> | null | undefined;

function placePhotos() {
  if (photos !== undefined) return photos;
  const apiKey = process.env.GOOGLE_PLACES_API_KEY;
  photos = apiKey ? createPlacePhotos(apiKey, placesPhotoBudget) : null;
  return photos;
}

/**
 * Mekânın Google fotoğrafı. Adres kısa ömürlüdür; uygulama saklamaz, yalnızca
 * bellekte tutar. Fotoğrafı çekenin adı Google'ın koşulu gereği gösterilir.
 */
router.get("/places/:placeId/photo", requireUser(authConfig), requireSearchAllowed, async (req, res) => {
  const placeId = String(req.params.placeId ?? "");
  if (!PLACE_ID_PATTERN.test(placeId)) {
    res.status(400).json({ error: "Geçersiz mekân kimliği" });
    return;
  }
  const service = placePhotos();
  if (!service) {
    res.status(404).json({ error: "Fotoğraf yok", code: "no_photo" });
    return;
  }
  try {
    const photo = await service.photo(placeId);
    if (!photo) {
      res.status(404).json({ error: "Fotoğraf yok", code: "no_photo" });
      return;
    }
    res.json(photo);
  } catch (err) {
    if (err instanceof PlacesBudgetExceeded) {
      res
        .status(err.scope === "user" ? 429 : 503)
        .json({
          error: "Fotoğraflar bugünlük durdu.",
          code: err.scope === "user" ? "user_places_budget" : "places_budget",
        });
      return;
    }
    logger.warn({ err }, "mekân fotoğrafı alınamadı");
    res.status(502).json({ error: "Fotoğraf alınamadı", code: "photo_failed" });
  }
});

export default router;
