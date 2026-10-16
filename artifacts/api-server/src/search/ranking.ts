import type { GeoBias, GooglePlace } from "./google-places";
import { foldTr, significantWords } from "./text";

export type VenueCategory = "classic" | "option" | "discovery";

const MIN_RATING = 3.8;
const MIN_RATINGS = 30;

export function haversineKm(a: { lat: number; lng: number }, b: { lat: number; lng: number }): number {
  const R = 6371;
  const rad = (d: number) => (d * Math.PI) / 180;
  const dLat = rad(b.lat - a.lat);
  const dLng = rad(b.lng - a.lng);
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(rad(a.lat)) * Math.cos(rad(b.lat)) * Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h));
}

/** Bölge yarıçapının dışında kalan mekânları çıkarır. */
export function withinArea(places: GooglePlace[], bias: GeoBias | null): GooglePlace[] {
  if (!bias) return places;
  return places.filter((p) => !p.location || haversineKm(bias, p.location) <= bias.radiusKm);
}

/**
 * Puan ve yorum sayısına dayalı skor. Uzaklık en fazla %30 düşürür; adında
 * aranan kelime geçen mekânın skoru iki katına çıkar.
 */
export function score(place: GooglePlace, query: string, bias: GeoBias | null): number {
  const rating = place.rating ?? 0;
  const count = place.userRatingCount ?? 0;
  const weight = count >= 1000 ? 2000 : count >= 250 ? 750 : 250;
  let s = count + rating * weight;
  if (bias && place.location) {
    s *= 1 - Math.min(haversineKm(bias, place.location) / bias.radiusKm, 1) * 0.3;
  }
  const name = foldTr(place.name);
  if (significantWords(query).some((w) => name.includes(w))) s *= 2;
  return s;
}

export function meetsQuality(place: GooglePlace): boolean {
  return (place.rating ?? 0) >= MIN_RATING && (place.userRatingCount ?? 0) >= MIN_RATINGS;
}

/**
 * Kalite eşiğini geçenleri skora göre sıralar. En az 2 sonuç yoksa eşik
 * gevşetilir ve `limited` işaretlenir.
 */
export function rank(
  places: GooglePlace[],
  query: string,
  bias: GeoBias | null,
  limit: number,
): { places: GooglePlace[]; limited: boolean } {
  const byScore = (a: GooglePlace, b: GooglePlace) => score(b, query, bias) - score(a, query, bias);
  const quality = places.filter(meetsQuality).sort(byScore).slice(0, limit);
  if (quality.length >= 2) return { places: quality, limited: false };
  const ids = new Set(quality.map((p) => p.id));
  const fallback = places.filter((p) => !ids.has(p.id) && (p.rating ?? 0) > 0).sort(byScore);
  const combined = [...quality, ...fallback].slice(0, Math.max(2, Math.min(5, places.length)));
  return { places: combined, limited: combined.length > quality.length };
}

/**
 * Gözde (klasik): puan × log(yorum sayısı) en yüksek mekân.
 * Gizli keşif: 4.3 ve üstü puanlı, 250'den az yorumlu en iyi mekân.
 * Diğerleri seçenek.
 */
export function categorize(places: GooglePlace[]): Map<string, VenueCategory> {
  const classicScore = (p: GooglePlace) => (p.rating ?? 0) * Math.log10((p.userRatingCount ?? 0) + 1);
  const discovery = [...places]
    .filter((p) => (p.rating ?? 0) >= 4.3 && (p.userRatingCount ?? 0) < 250)
    .sort((a, b) => (b.rating ?? 0) - (a.rating ?? 0) || (b.userRatingCount ?? 0) - (a.userRatingCount ?? 0))[0];
  const classic = places
    .filter((p) => p.id !== discovery?.id)
    .sort((a, b) => classicScore(b) - classicScore(a))[0];
  const categories = new Map<string, VenueCategory>();
  for (const p of places) {
    categories.set(p.id, p.id === classic?.id ? "classic" : p.id === discovery?.id ? "discovery" : "option");
  }
  return categories;
}
