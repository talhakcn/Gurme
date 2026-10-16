import { router } from "expo-router";
import { useListGurmeLists } from "@workspace/api-client-react";
import React, { useState } from "react";
import { Pressable, Text, TextInput, View } from "react-native";
import { Action, Empty, Eyebrow, Masthead, Page, PlaceRow, Rule, S } from "@/components/Editorial";
import { PlaceFilters } from "@/components/PlaceFilters";
import { C } from "@/constants/colors";
import { useJournal } from "@/context/JournalContext";
import { listCollection } from "@/components/list-network";
export default function Search() {
  const { places, lists, profile } = useJournal();
  const discovery = useListGurmeLists();
  const remoteLists = listCollection(discovery.data);
  const [query, setQuery] = useState("");
  const [scope, setScope] = useState<"places" | "lists" | "people">("places");
  const [city, setCity] = useState("");
  const [district, setDistrict] = useState("");
  const [category, setCategory] = useState("");
  const q = query.toLocaleLowerCase("tr").trim();
  const matchingPlaces = places.filter(p => (!city || p.city === city) && (!district || p.district === district) && (!category || p.category === category) && `${p.name} ${p.district} ${p.city} ${p.category}`.toLocaleLowerCase("tr").includes(q));
  const matchingLists = lists.filter(l => `${l.title} ${l.description} ${l.city}`.toLocaleLowerCase("tr").includes(q));
  const matchingPublic = (remoteLists ?? []).filter(l => l.visibility === "public" && `${l.title} ${l.description} ${l.authorName} ${l.items.map(i => `${i.name} ${i.area}`).join(" ")}`.toLocaleLowerCase("tr").includes(q));
  return <Page><Masthead /><Eyebrow>DEFTERİNDE VE AÇIK ROTALARDA ARA</Eyebrow><Text style={S.title}>Ne arıyorsun?</Text>
    <TextInput autoCapitalize="none" value={query} onChangeText={setQuery} placeholder="Mekân, rota veya kişi..." placeholderTextColor={C.muted} style={[S.input, { marginTop: 20, fontSize: 18 }]} />
    <View style={{ flexDirection: "row", gap: 24, marginTop: 23 }}>{([["places", "MEKÂNLAR"], ["lists", "LİSTELER"], ["people", "KİŞİLER"]] as const).map(([key, label]) => <Pressable key={key} onPress={() => setScope(key)} style={{ paddingBottom: 12, borderBottomWidth: scope === key ? 2 : 0, borderColor: C.ink }}><Text style={[S.label, { color: scope === key ? C.ink : C.muted }]}>{label}</Text></Pressable>)}</View>
    {scope === "places" && <PlaceFilters places={places} city={city} district={district} category={category} onCity={setCity} onDistrict={setDistrict} onCategory={setCategory} />}
    <Rule space={12} />
    {scope === "places" && <><Eyebrow>KAYNAK: BU CİHAZDAKİ KİŞİSEL KAYITLAR</Eyebrow>{matchingPlaces.length ? matchingPlaces.map((p, i) => <PlaceRow key={p.id} place={p} index={i + 1} />) : <Empty title={q ? "Bu adı bulamadık." : "Yeni bir yer keşfet."} detail="Mekân kataloğu bağlı değil. Şu an yalnızca bu cihazdaki kayıtları arayabilirsin." action="Mekân ekle" onPress={() => router.push("/place/edit")} />}</>}
    {scope === "lists" && <><Eyebrow>KAYNAK: YEREL LİSTELER + GURME AÇIK ROTALARI</Eyebrow>{matchingLists.map(l => <Pressable key={l.id} onPress={() => router.push(`/list/${l.id}`)} style={{ paddingVertical: 20, borderBottomWidth: 1, borderColor: C.line }}><Eyebrow>BENİM LİSTEM</Eyebrow><Text style={S.heading}>{l.title}</Text><Text style={S.small}>{l.city} · {l.items.length} mekân</Text></Pressable>)}
      {matchingPublic.map(l => <Pressable key={l.id} onPress={() => router.push(`/shared/${l.id}`)} style={{ paddingVertical: 20, borderBottomWidth: 1, borderColor: C.line }}><Eyebrow>AÇIK ROTA · {l.authorName}</Eyebrow><Text style={S.heading}>{l.title}</Text><Text style={S.small}>{l.items.length} mekân</Text></Pressable>)}
      {discovery.isPending && <View style={{ height: 65, backgroundColor: C.wash, marginTop: 18 }} />}
      {(discovery.isError || remoteLists === null) && <Empty title="Açık rotalara ulaşılamadı." detail="Kişisel listelerin görünmeye devam ediyor." action="Tekrar dene" onPress={() => discovery.refetch()} />}
      {!matchingLists.length && !matchingPublic.length && !discovery.isPending && !discovery.isError && remoteLists !== null && <Empty title="Bu aramada rota yok." detail="Yeni bir liste oluşturabilir ya da başka bir sözcük deneyebilirsin." action="Liste oluştur" onPress={() => router.push("/list/edit")} />}
    </>}
    {scope === "people" && <Empty title="Kişiler henüz burada değil." detail={`Şimdilik ${profile.name || "senin"} kişisel defterin açık. Kişi keşfi ve takip özelliği bağlantı kurulduğunda gelecek.`} />}
    {scope === "places" && !!matchingPlaces.length && <View style={{ marginTop: 25 }}><Action onPress={() => router.push("/place/edit")} icon="plus">Mekân ekle</Action></View>}
  </Page>;
}