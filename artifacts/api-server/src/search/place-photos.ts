import axios from "axios";
import { intFromEnv, PlacesBudget } from "./places-budget";

/** Mekânın Google'daki ilk fotoğrafı: kısa ömürlü adres ve çekenin adı. */
export interface PlacePhoto {
  uri: string;
  author?: { name: string; uri?: string };
}

/** Google'a giden tek GET; testlerde sahtesi verilir. */
export type PhotoHttpGet = (
  url: string,
  config: { headers?: Record<string, string>; params?: Record<string, unknown> },
) => Promise<{ data: unknown }>;

/**
 * Fotoğraflar arama bütçesinden ayrı bir günlük sayaçla sınırlanır:
 * bir fotoğraf iki istek (fotoğraf listesi ve adres). `PLACES_PHOTO_DAILY_LIMIT`
 * ile değiştirilir; varsayılan 200 istek, yani günde 100 fotoğraf.
 */
export const DEFAULT_PLACES_PHOTO_DAILY_LIMIT = 200;

/**
 * Tek kullanıcının fotoğraf sayacından günde harcayabileceği istek (20
 * fotoğraf). `PLACES_PHOTO_USER_DAILY_LIMIT` ile değiştirilir.
 */
export const DEFAULT_PLACES_PHOTO_USER_DAILY_LIMIT = 40;

export function photoBudgetFromEnv(env: NodeJS.ProcessEnv): PlacesBudget {
  return new PlacesBudget(
    intFromEnv(env.PLACES_PHOTO_DAILY_LIMIT, DEFAULT_PLACES_PHOTO_DAILY_LIMIT),
    undefined,
    intFromEnv(env.PLACES_PHOTO_USER_DAILY_LIMIT, DEFAULT_PLACES_PHOTO_USER_DAILY_LIMIT),
  );
}

/** Fotoğrafların ortak sayacı (yönetim paneli de okur). */
export const placesPhotoBudget = photoBudgetFromEnv(process.env);

/** Google mekân kimliği: harf, rakam, `-` ve `_`. Yol enjeksiyonunu önler. */
export const PLACE_ID_PATTERN = /^[A-Za-z0-9_-]{10,300}$/;

type RawPhotos = {
  photos?: Array<{
    name?: string;
    authorAttributions?: Array<{ displayName?: string; uri?: string }>;
  }>;
};

/**
 * Google'ın koşulları gereği fotoğraf adı ve adresi saklanmaz; her istekte
 * tazesi alınır. Önbelleğe alma uygulamanın bellek içi görsel önbelleğidir.
 */
export function createPlacePhotos(
  apiKey: string,
  budget: PlacesBudget,
  get: PhotoHttpGet = (url, config) => axios.get(url, { timeout: 10_000, ...config }),
) {
  const headers = { "X-Goog-Api-Key": apiKey };
  return {
    async photo(placeId: string, maxWidthPx = 800): Promise<PlacePhoto | null> {
      budget.spend();
      const details = (
        await get(`https://places.googleapis.com/v1/places/${placeId}`, {
          headers: { ...headers, "X-Goog-FieldMask": "photos" },
        })
      ).data as RawPhotos;
      const first = details.photos?.find((p) => p.name);
      if (!first?.name) return null;

      budget.spend();
      const media = (
        await get(`https://places.googleapis.com/v1/${first.name}/media`, {
          headers,
          params: { maxWidthPx, skipHttpRedirect: true },
        })
      ).data as { photoUri?: string };
      if (!media.photoUri) return null;

      const author = first.authorAttributions?.find((a) => a.displayName);
      return {
        uri: media.photoUri,
        author: author?.displayName
          ? { name: author.displayName, uri: author.uri }
          : undefined,
      };
    },
  };
}
