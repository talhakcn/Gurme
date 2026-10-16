import type { PlaceInsightFeatures, Signal } from "@workspace/db/schema";
import type { GooglePlace } from "./google-places";
import { containsAny } from "./text";

export interface SearchFilters {
  alcoholFree: boolean;
  helal: boolean;
  glutenFree: boolean;
  celiac: boolean;
}

export const NO_FILTERS: SearchFilters = {
  alcoholFree: false,
  helal: false,
  glutenFree: false,
  celiac: false,
};

/** Filtreye uyum: kesin değil, yalnızca "olası" ya da "bilinmiyor". */
export type FilterStatus = "none" | "likely" | "unverified";

export const ALCOHOL_KEYWORDS = [
  "meyhane", "taverna", "birahane", "bira", "şarap", "rakı", "viski", "votka",
  "kokteyl", "alkol", "içki", "içkili", "pub", "bar", "happy hour", "şaraphane",
  "gin", "tekila", "beer", "wine", "alcohol", "cocktail",
];

/** Alkolsüz aramada hiç gösterilmeyen Google mekân türleri. */
const ALCOHOL_VENUE_TYPES = [
  "bar", "night_club", "liquor_store", "casino", "wine_bar", "cocktail_bar", "gastropub", "pub",
];

/**
 * Google verisinden alkol sinyali. Tek bir `serves*` alanı yanlış pozitif
 * verebildiği için (gözlenen vakalar: aile lokantaları) en az iki alan
 * aranır; üçü de açıkça `false` ise alkolsüz sayılır.
 */
export function googleAlcoholSignal(place: GooglePlace): Signal {
  const isHalalNamed = containsAny(place.name, ["helal", "halal"]);
  if (!isHalalNamed && place.types.some((t) => ALCOHOL_VENUE_TYPES.includes(t))) return "yes";
  const fields = [place.servesBeer, place.servesWine, place.servesCocktails];
  if (fields.filter((f) => f === true).length >= 2) return "yes";
  if (fields.every((f) => f === false)) return "no";
  return "unknown";
}

/**
 * Google sinyali ile yapay zekâ özetini birleştirir. Alkolde Google'ın
 * kesin verisi önceliklidir; diğer özellikler yalnızca yorumlardan gelir.
 */
export function effectiveFeatures(
  place: GooglePlace,
  insight: PlaceInsightFeatures | null,
): PlaceInsightFeatures {
  const google = googleAlcoholSignal(place);
  let alcohol: Signal = google !== "unknown" ? google : (insight?.alcohol ?? "unknown");
  if (alcohol === "unknown" && containsAny(place.name, ALCOHOL_KEYWORDS)) alcohol = "yes";
  return {
    alcohol,
    helal: insight?.helal ?? "unknown",
    glutenFree: insight?.glutenFree ?? "unknown",
    celiacSafe: insight?.celiacSafe ?? "unknown",
  };
}

function requirements(filters: SearchFilters, f: PlaceInsightFeatures): Signal[] {
  // Helal arama her zaman alkolsüz olmayı da gerektirir. "Alkol yok" sinyali
  // "evet" anlamına gelir; bu yüzden ters çevrilir.
  const noAlcohol: Signal = f.alcohol === "yes" ? "no" : f.alcohol === "no" ? "yes" : "unknown";
  return [
    ...(filters.alcoholFree || filters.helal ? [noAlcohol] : []),
    ...(filters.helal ? [f.helal] : []),
    ...(filters.glutenFree ? [f.glutenFree] : []),
    ...(filters.celiac ? [f.celiacSafe] : []),
  ];
}

/**
 * Mekân filtrelere uyuyor mu? `null`: listeden çıkarılmalı.
 * Helal, glutensiz ve çölyak bilgisi yalnızca yorumlardan tahmin edildiği
 * için "evet" bile olsa arayüzde "doğrulanmamış" uyarısı gösterilir.
 */
export function filterStatus(filters: SearchFilters, f: PlaceInsightFeatures): FilterStatus | null {
  const required = requirements(filters, f);
  if (required.length === 0) return "none";
  if (required.includes("no")) return null;
  return required.every((s) => s === "yes") ? "likely" : "unverified";
}

/** Filtreye göre Google sorgusunun başına eklenen kelimeler. */
export function queryPrefix(filters: SearchFilters): string {
  if (filters.celiac) return "çölyak dostu glutensiz";
  if (filters.glutenFree) return "glutensiz";
  if (filters.helal) return "helal";
  return "";
}

export function hasFilters(filters: SearchFilters): boolean {
  return filters.alcoholFree || filters.helal || filters.glutenFree || filters.celiac;
}
