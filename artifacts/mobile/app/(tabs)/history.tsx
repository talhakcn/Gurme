import { router } from "expo-router";
import React, { useState } from "react";
import { Pressable, Text, TextInput, View } from "react-native";
import { Action, Empty, Eyebrow, Masthead, Page, PlaceRow, Rule, S } from "@/components/Editorial";
import { PlaceFilters } from "@/components/PlaceFilters";
import { C } from "@/constants/colors";
import { useJournal, type Status } from "@/context/JournalContext";
export default function Archive() {
  const { places, visits } = useJournal();
  const [filter, setFilter] = useState<Status | "all">("all");
  const [query, setQuery] = useState("");
  const [city, setCity] = useState("");
  const [district, setDistrict] = useState("");
  const [category, setCategory] = useState("");
  const q = query.trim().toLocaleLowerCase("tr");
  const filtered = places.filter(p =>
    (filter === "all" || (filter === "recommend" ? p.recommended || p.status === "recommend" : p.status === filter)) &&
    (!city || p.city === city) && (!district || p.district === district) && (!category || p.category === category) &&
    `${p.name} ${p.district} ${p.city} ${p.category} ${p.description}`.toLocaleLowerCase("tr").includes(q),
  );
  return <Page><Masthead /><Eyebrow>SENİN DEFTERİN · YALNIZCA BU CİHAZ</Eyebrow><Text style={S.title}>Lezzet arşivi</Text><Text style={[S.small, { marginTop: 7 }]}>Kaydettiğin adresler ve kişisel notların.</Text>
    <TextInput value={query} onChangeText={setQuery} placeholder="Kayıtlarımda ara…" placeholderTextColor={C.muted} style={[S.input, { marginTop: 18 }]} />
    <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 8, marginTop: 20 }}>
      {([["all", "TÜMÜ"], ["want", "GİDECEĞİM"], ["went", "GİTTİM"], ["recommend", "ÖNERİYORUM"]] as const).map(([key, label]) => <Pressable key={key} onPress={() => setFilter(key)} style={{ paddingHorizontal: 11, paddingVertical: 10, borderWidth: 1, borderColor: C.line, backgroundColor: filter === key ? C.ink : C.paper }}><Text style={[S.label, { color: filter === key ? C.paper : C.ink }]}>{label}</Text></Pressable>)}
    </View>
    <PlaceFilters places={places} city={city} district={district} category={category} onCity={setCity} onDistrict={setDistrict} onCategory={setCategory} />
    <Rule />
    <Eyebrow>{filtered.length} KAYIT · KİŞİSEL DEFTER</Eyebrow>
    {filtered.length ? filtered.map((p, i) => <View key={p.id}><PlaceRow place={p} index={i + 1} /><Text style={[S.small, { marginTop: 7 }]}>{p.status === "want" ? "Gidilecek" : p.status === "went" ? "Gidildi" : "Henüz işaretlenmedi"}{p.recommended ? " · Öneriyorum" : ""} · {visits.filter(v => v.placeId === p.id).length} deneyim</Text></View>) :
      <Empty title={places.length ? "Bu aramada kayıt yok." : "Arşivin seni bekliyor."} detail={places.length ? "Arama veya filtreleri değiştirebilirsin." : "Gitmek istediğin ya da gittiğin yerleri burada biriktir."} action={places.length ? "Filtreleri temizle" : "Mekân ekle"} onPress={() => places.length ? (setQuery(""), setCity(""), setDistrict(""), setCategory(""), setFilter("all")) : router.push("/place/edit")} />}
    {!!filtered.length && <View style={{ marginTop: 28 }}><Action icon="plus" onPress={() => router.push("/place/edit")}>Mekân ekle</Action></View>}
  </Page>;
}