import type { PlaceInsightFeatures } from "@workspace/db/schema";
import { logger } from "../lib/logger";
import {
  effectiveFeatures,
  filterStatus,
  googleAlcoholSignal,
  queryPrefix,
  type FilterStatus,
  type SearchFilters,
} from "./filters";
import type { GeoBias, GooglePlace, PlacesClient } from "./google-places";
import type { InsightStore } from "./insight-store";
import type { InsightAnalyzer, PlaceInsight } from "./insights";
import { categorize, rank, withinArea, type VenueCategory } from "./ranking";
import { cleanQuery, foldTr } from "./text";
import { TtlCache } from "./ttl-cache";
import { PlacesBudgetExceeded } from "./places-budget";

export interface SearchRequest {
  city: string;
  /** Otomatik tamamlamadan seçilen bölgenin Google place_id'si. */
  cityPlaceId?: string;
  query: string;
  filters: SearchFilters;
}

export interface InsightView {
  summary: string;
  whyGo: string[];
  warnings: string[];
  vibeTags: string[];
  highlights: string[];
  analyzedAt: string;
}

export interface VenueResult {
  placeId: string;
  name: string;
  address: string;
  rating: number;
  totalRatings: number;
  location?: { lat: number; lng: number };
  googleMapsUri?: string;
  category?: VenueCategory;
  features: PlaceInsightFeatures;
  filterStatus: FilterStatus;
  /** Henüz analiz edilmediyse `null`; istemci ikinci aşamada ister. */
  insight: InsightView | null;
  /** Topluluk bildirimleri nedeniyle doğrulanması gereken mekân. */
  needsVerification: boolean;
}

export interface SearchResult {
  city: string;
  query: string;
  filters: SearchFilters;
  venues: VenueResult[];
  limitedResults: boolean;
  categorized: boolean;
  /** Önbellekten döndüyse Google'a istek yapılmadı (kotadan düşülmez). */
  fromCache: boolean;
  /** İkinci aşamada analiz istenecek mekânlar (en fazla 3). */
  pendingInsights: string[];
}

/** Kullanıcıya gösterilebilecek arama hatası. */
export class SearchError extends Error {
  constructor(
    message: string,
    readonly status: number,
  ) {
    super(message);
  }
}

export interface SearchDeps {
  places: PlacesClient;
  store: InsightStore;
  analyzer: InsightAnalyzer;
  /** Topluluk bildirimiyle işaretlenmiş mekânlar. */
  flaggedPlaces: (placeIds: string[]) => Promise<Set<string>>;
  now?: () => number;
}

const MAX_VENUES = 8;
const FIRST_STAGE_INSIGHTS = 3;
export const MAX_INSIGHTS_PER_REQUEST = 5;

type CachedSearch = { places: GooglePlace[]; limited: boolean };

export class SearchService {
  // Google içeriği (ad, puan, yorum) yalnızca kısa süre bellekte tutulur.
  private readonly searches: TtlCache<CachedSearch>;
  private readonly placeBuffer: TtlCache<GooglePlace>;
  // Koordinatların 30 güne kadar saklanmasına izin veriliyor.
  private readonly geo: TtlCache<GeoBias>;
  private readonly inflight = new Map<string, Promise<PlaceInsight | undefined>>();

  constructor(private readonly deps: SearchDeps) {
    const now = deps.now ?? Date.now;
    this.searches = new TtlCache(500, 60 * 60 * 1000, now);
    this.placeBuffer = new TtlCache(3000, 60 * 60 * 1000, now);
    this.geo = new TtlCache(1000, 30 * 24 * 60 * 60 * 1000, now);
  }

  /** Birinci aşama: tek Text Search, analizsiz hızlı liste. */
  async search(request: SearchRequest): Promise<SearchResult> {
    return (await this.run(request, false))!;
  }

  /**
   * Yalnızca önbellekteki sonucu döndürür; Google'a gitmez. Önbellekte yoksa
   * `null` (günlük hakkı biten kullanıcı için).
   */
  async searchCached(request: SearchRequest): Promise<SearchResult | null> {
    return this.run(request, true);
  }

  private async run(request: SearchRequest, cacheOnly: boolean): Promise<SearchResult | null> {
    const city = cleanQuery(request.city);
    const query = cleanQuery(request.query);
    const { filters } = request;
    const key = [
      foldTr(city),
      request.cityPlaceId ?? "",
      foldTr(query),
      Number(filters.alcoholFree || filters.helal),
      Number(filters.helal),
      Number(filters.glutenFree),
      Number(filters.celiac),
    ].join("|");

    let cached = this.searches.get(key);
    const fromCache = cached !== undefined;
    if (!cached && cacheOnly) return null;
    if (!cached) {
      cached = await this.fetchPlaces(city, request.cityPlaceId, query, filters);
      this.searches.set(key, cached);
    }

    const venues = await this.toVenues(cached.places, filters);
    const visible = venues.slice(0, MAX_VENUES);
    const categories = cached.limited ? null : categorize(cached.places.filter((p) => visible.some((v) => v.placeId === p.id)));
    if (categories) for (const v of visible) v.category = categories.get(v.placeId);

    return {
      city,
      query,
      filters,
      venues: visible,
      limitedResults: cached.limited,
      categorized: categories !== null && visible.length >= 2,
      fromCache,
      pendingInsights: visible
        .filter((v) => v.insight === null)
        .slice(0, FIRST_STAGE_INSIGHTS)
        .map((v) => v.placeId),
    };
  }

  /**
   * İkinci aşama: verilen mekânların analizi. Kayıtlı analiz yoksa yorumlar
   * birinci aşamadan bellekte duruyorsa onlar, yoksa Place Details kullanılır.
   * Filtreye uymadığı anlaşılan mekânlar `filterStatus: null` ile döner.
   */
  async insights(
    placeIds: string[],
    filters: SearchFilters,
  ): Promise<Array<Omit<VenueResult, "filterStatus"> & { filterStatus: FilterStatus | null }>> {
    const ids = [...new Set(placeIds)].slice(0, MAX_INSIGHTS_PER_REQUEST);
    const places = await Promise.all(ids.map((id) => this.place(id)));
    const stored = await this.deps.store.getMany(ids);
    const missing = places.filter((p) => !stored.has(p.id));
    const fresh = await this.analyze(missing);
    const flagged = await this.deps.flaggedPlaces(ids);
    return places.map((p) => {
      const insight = stored.get(p.id) ?? fresh.get(p.id) ?? null;
      const features = effectiveFeatures(p, insight?.features ?? null);
      return this.venue(p, features, filterStatus(filters, features), insight, flagged.has(p.id));
    });
  }

  private async fetchPlaces(
    city: string,
    cityPlaceId: string | undefined,
    query: string,
    filters: SearchFilters,
  ): Promise<CachedSearch> {
    const bias = await this.locate(city, cityPlaceId);
    const textQuery = [queryPrefix(filters), query, city].filter(Boolean).join(" ");
    let found: GooglePlace[];
    try {
      found = await this.deps.places.textSearch(textQuery, bias);
    } catch (err) {
      // Günlük sınır kendi mesajıyla kullanıcıya ulaşır.
      if (err instanceof PlacesBudgetExceeded) throw err;
      logger.error({ err: String(err), textQuery }, "Text Search başarısız");
      throw new SearchError("Mekân araması şu anda yapılamıyor. Biraz sonra tekrar dene.", 503);
    }
    let candidates = withinArea(found, bias);
    // Google'ın kesin alkol verisi olan mekânlar sıralamada yer kaplamasın.
    if (filters.alcoholFree || filters.helal) {
      candidates = candidates.filter((p) => googleAlcoholSignal(p) !== "yes");
    }
    const ranked = rank(candidates, query, bias, 12);
    for (const p of ranked.places) this.placeBuffer.set(p.id, p);
    logger.info(
      { textQuery, found: found.length, kept: ranked.places.length, limited: ranked.limited },
      "Arama sonuçları",
    );
    return { places: ranked.places, limited: ranked.limited };
  }

  private async locate(city: string, cityPlaceId: string | undefined): Promise<GeoBias | null> {
    const key = cityPlaceId ? `pid:${cityPlaceId}` : `txt:${foldTr(city)}`;
    const cached = this.geo.get(key);
    if (cached) return cached;
    try {
      const bias =
        (cityPlaceId ? await this.deps.places.locatePlace(cityPlaceId) : null) ??
        (await this.deps.places.geocode(city));
      // Başarısız konum önbelleğe yazılmaz; geçici bir hata kalıcı olmasın.
      if (bias) this.geo.set(key, bias);
      return bias;
    } catch (err) {
      if (err instanceof PlacesBudgetExceeded) throw err;
      logger.warn({ err: String(err), city }, "Konum bulunamadı; konumsuz aranıyor");
      return null;
    }
  }

  private async toVenues(places: GooglePlace[], filters: SearchFilters): Promise<VenueResult[]> {
    const ids = places.map((p) => p.id);
    const [stored, flagged] = await Promise.all([
      this.deps.store.getMany(ids),
      this.deps.flaggedPlaces(ids),
    ]);
    return places.flatMap((p) => {
      const insight = stored.get(p.id) ?? null;
      const features = effectiveFeatures(p, insight?.features ?? null);
      const status = filterStatus(filters, features);
      return status === null ? [] : [this.venue(p, features, status, insight, flagged.has(p.id))];
    });
  }

  private venue<S extends FilterStatus | null>(
    p: GooglePlace,
    features: PlaceInsightFeatures,
    status: S,
    insight: PlaceInsight | null,
    flagged: boolean,
  ) {
    return {
      placeId: p.id,
      name: p.name,
      address: p.address ?? "",
      rating: p.rating ?? 0,
      totalRatings: p.userRatingCount ?? 0,
      location: p.location,
      googleMapsUri: p.googleMapsUri,
      features,
      filterStatus: status,
      insight: insight && {
        ...insight.summary,
        analyzedAt: insight.analyzedAt.toISOString(),
      },
      needsVerification: flagged,
    };
  }

  private async place(placeId: string): Promise<GooglePlace> {
    const buffered = this.placeBuffer.get(placeId);
    if (buffered) return buffered;
    try {
      const place = await this.deps.places.placeDetails(placeId);
      this.placeBuffer.set(placeId, place);
      return place;
    } catch (err) {
      if (err instanceof PlacesBudgetExceeded) throw err;
      logger.warn({ err: String(err), placeId }, "Place Details başarısız");
      throw new SearchError("Mekân bilgisi alınamadı.", 502);
    }
  }

  /** Aynı mekân için eşzamanlı istekler tek analizi paylaşır. */
  private async analyze(places: GooglePlace[]): Promise<Map<string, PlaceInsight>> {
    const waiting = places.filter((p) => this.inflight.has(p.id));
    const todo = places.filter((p) => !this.inflight.has(p.id));
    let batch: Promise<PlaceInsight[]> = Promise.resolve([]);
    if (todo.length > 0) {
      batch = this.deps.analyzer.analyze(todo).then(async (insights) => {
        // Kayıt başarısız olsa da bu yanıtta analiz gösterilir.
        await this.deps.store.saveMany(insights).catch((err: unknown) => {
          logger.error({ err: String(err) }, "Mekân analizleri kaydedilemedi");
        });
        return insights;
      });
      for (const p of todo) {
        const own = batch.then((all) => all.find((i) => i.placeId === p.id));
        this.inflight.set(p.id, own);
        void own.catch(() => undefined).finally(() => this.inflight.delete(p.id));
      }
    }
    const results = await Promise.allSettled([
      ...todo.map((p) => this.inflight.get(p.id)!),
      ...waiting.map((p) => this.inflight.get(p.id)!),
    ]);
    const map = new Map<string, PlaceInsight>();
    for (const r of results) {
      if (r.status === "fulfilled" && r.value) map.set(r.value.placeId, r.value);
      if (r.status === "rejected") logger.warn({ err: String(r.reason) }, "Analiz kaydedilemedi");
    }
    return map;
  }
}
