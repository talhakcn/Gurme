import React from "react";
import { Pressable, ScrollView, Text, View } from "react-native";
import { C } from "@/constants/colors";
import type { Place } from "@/context/JournalContext";
import { Eyebrow, S } from "@/components/Editorial";

export function PlaceFilters({ places, city, district, category, onCity, onDistrict, onCategory }: {
  places: Place[]; city: string; district: string; category: string;
  onCity: (value: string) => void; onDistrict: (value: string) => void; onCategory: (value: string) => void;
}) {
  const cities = [...new Set(places.map(p => p.city.trim()).filter(Boolean))].sort((a, b) => a.localeCompare(b, "tr"));
  const districts = [...new Set(places.filter(p => !city || p.city === city).map(p => p.district.trim()).filter(Boolean))].sort((a, b) => a.localeCompare(b, "tr"));
  const categories = [...new Set(places.map(p => p.category.trim()).filter(Boolean))].sort((a, b) => a.localeCompare(b, "tr"));
  const group = (title: string, choices: string[], selected: string, select: (value: string) => void) =>
    <View style={{ marginTop: 15 }}><Eyebrow>{title}</Eyebrow><ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ gap: 7, paddingTop: 9, paddingRight: 20 }}>
      {["Tümü", ...choices].map((choice, index) => {
        const value = index === 0 ? "" : choice;
        return <Pressable key={choice} onPress={() => select(value)} style={{ borderWidth: 1, borderColor: C.line, paddingHorizontal: 11, paddingVertical: 8, backgroundColor: selected === value ? C.ink : C.paper }}>
          <Text style={[S.label, { color: selected === value ? C.paper : C.ink }]}>{choice}</Text>
        </Pressable>;
      })}
    </ScrollView></View>;
  return <>{group("ŞEHİR", cities, city, value => { onCity(value); onDistrict(""); })}{group("BÖLGE / SEMT", districts, district, onDistrict)}{group("KATEGORİ", categories, category, onCategory)}</>;
}