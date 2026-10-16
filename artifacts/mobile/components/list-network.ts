import type { GurmeList, GurmeListInput, GurmeListVisibility } from "@workspace/api-client-react";
import { Platform } from "react-native";
import type { CuratedList, Place } from "@/context/JournalContext";

export function listCollection(value: unknown): GurmeList[] | null {
  return Array.isArray(value) ? value as GurmeList[] : null;
}

export function listPayload(
  list: Pick<CuratedList, "title" | "description" | "items">,
  places: Place[],
  authorName: string,
  visibility: GurmeListVisibility,
): GurmeListInput {
  return {
    title: list.title.trim(),
    description: list.description.trim(),
    authorName: authorName.trim(),
    visibility,
    items: list.items.map(item => {
      const place = places.find(p => p.id === item.placeId);
      return { placeId: item.placeId, name: place?.name || "Mekân", area: [place?.district, place?.city].filter(Boolean).join(", "), category: place?.category || "", note: item.note.trim() };
    }),
  };
}
export function shareUrl(remoteId: string): string | null {
  const domain = process.env.EXPO_PUBLIC_DOMAIN;
  const origin = domain ? `https://${domain}` : Platform.OS === "web" && typeof window !== "undefined" ? window.location.origin : null;
  return origin ? `${origin}/api/gurme/share/${encodeURIComponent(remoteId)}` : null;
}
export function ownerRequest(ownerKey: string) {
  return { headers: { Authorization: `Bearer ${ownerKey}` } };
}
export function areaToLocation(area: string): { district: string; city: string } {
  const parts = area.split(",").map(part => part.trim()).filter(Boolean);
  return parts.length > 1 ? { city: parts[parts.length - 1], district: parts.slice(0, -1).join(", ") } : { district: area, city: "" };
}