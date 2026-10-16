import { router } from "expo-router";
import React from "react";
import { Text } from "react-native";
import { Empty, Eyebrow, Masthead, Page, S } from "@/components/Editorial";
import { C } from "@/constants/colors";
import { useJournal } from "@/context/JournalContext";
export default function Activity() {
  const { visits, places } = useJournal();
  return <Page><Masthead back /><Eyebrow>KİŞİSEL ZAMAN ÇİZELGESİ</Eyebrow><Text style={S.title}>Etkinlik</Text>
    {visits.length ? visits.map(v => <Text key={v.id} onPress={() => router.push(`/place/${v.placeId}`)} style={[S.body, { paddingVertical: 20, borderBottomWidth: 1, borderColor: C.line }]}>{v.date}  ·  {places.find(p => p.id === v.placeId)?.name || "Mekân"}{"\n"}{v.title || v.note}</Text>) : <Empty title="Hikâye ilk notla başlar." detail="Deneyim yazdığında kişisel zaman çizelgen burada oluşacak." action="Arşive git" onPress={() => router.push("/history")} />}
  </Page>;
}