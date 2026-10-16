import axios from "axios";
import { placesBudget, type PlacesBudget } from "./places-budget";

/** Google Places API (New) yanıtının uygulamada kullanılan kısmı. */
export interface GooglePlace {
  id: string;
  name: string;
  rating?: number;
  userRatingCount?: number;
  address?: string;
  location?: { lat: number; lng: number };
  types: string[];
  googleMapsUri?: string;
  servesBeer?: boolean;
  servesWine?: boolean;
  servesCocktails?: boolean;
  /**
   * En fazla 5 yorum. Google'ın kullanım koşulları gereği yalnızca analiz
   * için kısa süre bellekte tutulur, veritabanına yazılmaz.
   */
  reviews: Array<{ text: string; rating: number }>;
}

export interface GeoBias {
  lat: number;
  lng: number;
  radiusKm: number;
}

export interface PlacesClient {
  /** Tek Text Search çağrısı; yorumlar ve alkol alanları dahil. */
  textSearch(query: string, bias: GeoBias | null): Promise<GooglePlace[]>;
  /** Text Search'te görünmeyen bir mekân açıldığında kullanılır. */
  placeDetails(placeId: string): Promise<GooglePlace>;
  /** Otomatik tamamlamadan seçilen bölgenin merkezi ve yarıçapı. */
  locatePlace(placeId: string): Promise<GeoBias | null>;
  /** Serbest metin konumun merkezi ve yarıçapı. */
  geocode(location: string): Promise<GeoBias | null>;
}

// Alanların her biri Google'da bir fiyat katmanına bağlı: rating ve
// userRatingCount "Enterprise", reviews ve serves* "Enterprise + Atmosphere"
// katmanında. Tek Text Search çağrısı (1000'de 40 $) mekân başına Place
// Details çağrısından (1000'de 25 $) çok daha ucuz.
const PLACE_FIELDS = [
  "id",
  "displayName",
  "rating",
  "userRatingCount",
  "formattedAddress",
  "location",
  "types",
  "googleMapsUri",
  "servesBeer",
  "servesWine",
  "servesCocktails",
  "reviews",
];

const TEXT_SEARCH_MASK = PLACE_FIELDS.map((f) => `places.${f}`).join(",");
const DETAILS_MASK = PLACE_FIELDS.join(",");

type RawPlace = {
  id?: string;
  displayName?: { text?: string };
  rating?: number;
  userRatingCount?: number;
  formattedAddress?: string;
  location?: { latitude?: number; longitude?: number };
  types?: string[];
  googleMapsUri?: string;
  servesBeer?: boolean;
  servesWine?: boolean;
  servesCocktails?: boolean;
  reviews?: Array<{ text?: { text?: string }; originalText?: { text?: string }; rating?: number }>;
  viewport?: {
    low?: { latitude?: number; longitude?: number };
    high?: { latitude?: number; longitude?: number };
  };
};

export function toGooglePlace(p: RawPlace): GooglePlace {
  const lat = p.location?.latitude;
  const lng = p.location?.longitude;
  return {
    id: p.id ?? "",
    name: p.displayName?.text ?? "",
    rating: p.rating,
    userRatingCount: p.userRatingCount,
    address: p.formattedAddress,
    location: lat !== undefined && lng !== undefined ? { lat, lng } : undefined,
    types: p.types ?? [],
    googleMapsUri: p.googleMapsUri,
    servesBeer: p.servesBeer,
    servesWine: p.servesWine,
    servesCocktails: p.servesCocktails,
    reviews: (p.reviews ?? [])
      .map((r) => ({
        text: (r.originalText?.text ?? r.text?.text ?? "").trim(),
        rating: r.rating ?? 0,
      }))
      .filter((r) => r.text.length > 0),
  };
}

/** Görünüm alanının (viewport) yarısından hesaplanan arama yarıçapı. */
export function radiusFromSpan(latSpan: number, lngSpan: number, factor: number, min: number): number {
  const spanKm = Math.max(Math.abs(latSpan), Math.abs(lngSpan)) * 111;
  return Math.max(min, Math.min(spanKm * factor, 50));
}

/**
 * Her çağrı önce günlük sayaçtan bir hak düşer; sınır dolunca Google'a
 * istek gitmez ve [PlacesBudgetExceeded] fırlatılır.
 */
export function createGooglePlacesClient(
  apiKey: string,
  budget: PlacesBudget = placesBudget,
): PlacesClient {
  const http = axios.create({
    timeout: 15_000,
    headers: { "X-Goog-Api-Key": apiKey },
  });
  http.interceptors.request.use((config) => {
    budget.spend();
    return config;
  });

  return {
    async textSearch(query, bias) {
      const body: Record<string, unknown> = {
        textQuery: query,
        languageCode: "tr",
        regionCode: "TR",
        pageSize: 20,
      };
      if (bias) {
        body.locationBias = {
          circle: {
            center: { latitude: bias.lat, longitude: bias.lng },
            radius: Math.round(bias.radiusKm * 1000),
          },
        };
      }
      const response = await http.post<{ places?: RawPlace[] }>(
        "https://places.googleapis.com/v1/places:searchText",
        body,
        { headers: { "X-Goog-FieldMask": TEXT_SEARCH_MASK } },
      );
      return (response.data.places ?? []).map(toGooglePlace).filter((p) => p.id);
    },

    async placeDetails(placeId) {
      const response = await http.get<RawPlace>(
        `https://places.googleapis.com/v1/places/${encodeURIComponent(placeId)}`,
        { headers: { "X-Goog-FieldMask": DETAILS_MASK }, params: { languageCode: "tr" } },
      );
      return toGooglePlace(response.data);
    },

    async locatePlace(placeId) {
      // Yalnızca konum alanları: en ucuz (Essentials) katman.
      const response = await http.get<RawPlace>(
        `https://places.googleapis.com/v1/places/${encodeURIComponent(placeId)}`,
        { headers: { "X-Goog-FieldMask": "location,viewport" } },
      );
      const { location, viewport } = response.data;
      if (location?.latitude === undefined || location.longitude === undefined) return null;
      const radiusKm =
        viewport?.high?.latitude !== undefined && viewport.low?.latitude !== undefined
          ? radiusFromSpan(
              viewport.high.latitude - viewport.low.latitude,
              (viewport.high.longitude ?? 0) - (viewport.low.longitude ?? 0),
              2,
              2,
            )
          : 5;
      return { lat: location.latitude, lng: location.longitude, radiusKm };
    },

    async geocode(locationText) {
      // Geocoding API yerine Places Text Search: anahtar yalnızca Places
      // API (New)'a izinli, ayrı bir API açmak gerekmez.
      const response = await http.post<{ places?: RawPlace[] }>(
        "https://places.googleapis.com/v1/places:searchText",
        { textQuery: locationText, languageCode: "tr", regionCode: "TR", pageSize: 1 },
        { headers: { "X-Goog-FieldMask": "places.location,places.viewport" } },
      );
      const place = response.data.places?.[0];
      const location = place?.location;
      if (location?.latitude === undefined || location.longitude === undefined) return null;
      const viewport = place?.viewport;
      const radiusKm =
        viewport?.high?.latitude !== undefined && viewport.low?.latitude !== undefined
          ? radiusFromSpan(
              viewport.high.latitude - viewport.low.latitude,
              (viewport.high.longitude ?? 0) - (viewport.low.longitude ?? 0),
              1.5,
              5,
            )
          : 15;
      return { lat: location.latitude, lng: location.longitude, radiusKm };
    },
  };
}
