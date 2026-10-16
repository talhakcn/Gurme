import { Feather } from "@expo/vector-icons";
import { useListGurmeLists } from "@workspace/api-client-react";
import { router, useLocalSearchParams } from "expo-router";
import React, { useState } from "react";
import { Image, Linking, Pressable, Text, View } from "react-native";
import { Action, Empty, Eyebrow, F, Masthead, Page, Rule, S } from "@/components/Editorial";
import { C } from "@/constants/colors";
import { useJournal, type Status } from "@/context/JournalContext";
import { listCollection } from "@/components/list-network";
export default function PlaceDetail() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { places, visits, lists, setStatus, saveList } = useJournal();
  const publicLists = useListGurmeLists();
  const remoteLists = listCollection(publicLists.data);
  const [reportType, setReportType] = useState("");
  const [listPicker, setListPicker] = useState(false);
  const p = places.find(x => x.id === id);
  if (!p) return <Page><Masthead back /><Empty title="Bu adres bulunamadı." detail="Mekân silinmiş ya da henüz kaydedilmemiş olabilir." action="Arşive dön" onPress={() => router.replace("/history")} /></Page>;
  const ownVisits = visits.filter(v => v.placeId === id);
  const listMatches = (remoteLists ?? []).filter(l => l.visibility === "public" && l.items.some(item => item.name.trim().toLocaleLowerCase("tr") === p.name.trim().toLocaleLowerCase("tr") && item.area.trim().toLocaleLowerCase("tr") === [p.district, p.city].filter(Boolean).join(", ").toLocaleLowerCase("tr")));
  const toggleList = (listId: string) => {
    const l = lists.find(x => x.id === listId);
    if (!l) return;
    if (l.remoteId) { router.push({ pathname: "/list/edit", params: { id: l.id } }); return; }
    saveList({ id: l.id, title: l.title, description: l.description, city: l.city, items: l.items.some(i => i.placeId === id) ? l.items.filter(i => i.placeId !== id) : [...l.items, { placeId: id, note: "" }] });
  };
  return <Page><Masthead back right="edit-2" onRight={() => router.push({ pathname: "/place/edit", params: { id } })} />
    <View style={[S.row, { marginBottom: 10 }]}><Eyebrow>{p.district || "KONUM YOK"} · {p.category}</Eyebrow><Eyebrow>KAYIT NO #{p.id.slice(-5).toUpperCase()}</Eyebrow></View>
    <Text style={[S.title, { fontFamily: F.italic, fontSize: 42, lineHeight: 46 }]}>{p.name}</Text>
    <Text style={[S.small, { marginTop: 11 }]}>{[p.district, p.city].filter(Boolean).join(", ")}</Text>
    {!!p.address && <Text style={[S.small, { marginTop: 5 }]}>{p.address}</Text>}
    {!!p.image ? <Image source={{ uri: p.image }} resizeMode="cover" style={{ width: "100%", height: 290, marginTop: 25 }} /> :
      <Image source={require("../../assets/images/coffee-detail.png")} resizeMode="cover" style={{ width: "100%", height: 290, marginTop: 25 }} />}
    {!p.image && <Text style={[S.label, { marginTop: 7 }]}>EDİTORYAL GÖRSEL · MEKÂNA AİT DEĞİL</Text>}
    <Rule space={20} /><Eyebrow>SENİN ZİYARET STATÜN & TERCİHİN</Eyebrow>
    <View style={{ flexDirection: "row", marginTop: 14, gap: 5 }}>
      {([["want", "Gideceğim"], ["went", "Gittim"], ["recommend", "Öneriyorum"]] as [Status, string][]).map(([status, title]) => {
        const active = status === "recommend" ? !!p.recommended : p.status === status;
        return <Pressable key={status} onPress={() => setStatus(id, active ? status === "recommend" ? "recommend" : undefined : status)} style={{ flex: 1, minHeight: 49, justifyContent: "center", alignItems: "center", paddingHorizontal: 3, backgroundColor: active ? status === "recommend" ? C.gold : C.ink : C.paper, borderWidth: active ? 0 : 1, borderColor: C.line }}><Text style={[S.small, { fontFamily: F.medium, color: active && status !== "recommend" ? C.paper : C.ink, textAlign: "center", fontSize: 11 }]}>{title}</Text></Pressable>;
      })}
    </View><Rule space={22} />
    <Text style={S.small}>“Gittim” ve “Öneriyorum” ayrı tercihlerdir. Ziyaret notların yalnızca bu cihazda saklanır.</Text>
    {!!p.address && <View style={{ marginTop: 18 }}><Action secondary icon="map-pin" onPress={() => Linking.openURL(`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(p.address || "")}`)}>Haritada aç · yol tarifi</Action></View>}
    {!!p.description && <><Eyebrow>MEKÂN HAKKINDA</Eyebrow><Text style={[S.body, { marginTop: 10 }]}>{p.description}</Text><Rule /></>}
    <View style={S.row}><Eyebrow>SENİN DENEYİMLERİN</Eyebrow><Text style={S.small}>{ownVisits.length} kayıt</Text></View>
    {ownVisits.length ? ownVisits.map(v => <Pressable key={v.id} onPress={() => router.push({ pathname: "/visit/edit", params: { placeId: id, id: v.id } })} style={{ paddingVertical: 22, borderBottomWidth: 1, borderColor: C.line }}>
      <Text style={S.label}>{v.date} · {v.visibility === "public" ? "HERKESE AÇIK NİYETİ / YEREL" : "ÖZEL"} · {v.recommended ? "ÖNERİYORUM" : "GİTTİM"}</Text><Text style={[S.heading, { fontFamily: F.italic, marginTop: 7 }]}>{v.title || "Bir ziyaret notu"}</Text><Text style={[S.body, { marginTop: 10 }]}>{v.note}</Text>{!!v.order && <Text style={[S.small, { marginTop: 8 }]}>Tadılan: {v.order}</Text>}
      {!!v.dishes && <Text style={[S.small, { marginTop: 5 }]}>Önerilenler: {v.dishes}</Text>}
      <Text style={[S.small, { marginTop: 5 }]}>Tekrar gider miyim? {v.revisit === "yes" ? "Evet" : v.revisit === "no" ? "Hayır" : "Kararsızım"}</Text>
      {!!v.photos?.length && <View style={{ flexDirection: "row", gap: 6, marginTop: 11 }}>{v.photos.map((uri, i) => <Image key={`${uri}-${i}`} source={{ uri }} style={{ width: 82, height: 82 }} />)}</View>}
      <Text style={[S.label, { color: C.ink, marginTop: 12 }]}>DENEYİMİ DÜZENLE →</Text>
    </Pressable>) : <Text style={[S.small, { marginVertical: 21 }]}>Henüz bir deneyim yazmadın. İlk notunu şimdi bırak.</Text>}
    <View style={{ marginTop: 16 }}><Action icon="edit-3" onPress={() => router.push({ pathname: "/visit/edit", params: { placeId: id } })}>Deneyim ekle</Action></View>
    <Rule space={26} /><Eyebrow>YER ALDIĞI LİSTELER</Eyebrow>
    {lists.filter(l => l.items.some(item => item.placeId === id)).map(l => <Pressable key={l.id} onPress={() => router.push(`/list/${l.id}`)} style={[S.row, { paddingVertical: 17, borderBottomWidth: 1, borderColor: C.line }]}><Text style={S.subhead}>{l.title}</Text><Feather name="arrow-right" size={17} color={C.teal} /></Pressable>)}
    <Pressable onPress={() => setListPicker(!listPicker)} style={{ paddingVertical: 17 }}><Text style={[S.label, { color: C.ink }]}>+ LİSTEYE EKLE / ÇIKAR →</Text></Pressable>
    {listPicker && <View>{lists.map(l => <Pressable key={l.id} onPress={() => toggleList(l.id)} style={{ paddingVertical: 13, borderBottomWidth: 1, borderColor: C.line }}><Text style={S.body}>{l.items.some(i => i.placeId === id) ? "■" : "□"}  {l.title}</Text>{l.remoteId && <Text style={S.small}>Paylaşılan liste: düzenle ve sunucuyla eşitle</Text>}</Pressable>)}<Pressable onPress={() => router.push("/list/edit")} style={{ paddingVertical: 14 }}><Text style={[S.label, { color: C.ink }]}>+ YENİ LİSTE OLUŞTUR</Text></Pressable></View>}
    <Rule /><Eyebrow>GURME AÇIK LİSTELERİNDE</Eyebrow>
    {listMatches.map(l => <Pressable key={l.id} onPress={() => router.push(`/shared/${l.id}`)} style={{ paddingVertical: 12, borderBottomWidth: 1, borderColor: C.line }}><Text style={S.subhead}>{l.title}</Text><Text style={S.small}>{l.authorName} · aynı ad ve bölge eşleşmesi</Text></Pressable>)}
    {!listMatches.length && <Text style={[S.small, { marginTop: 10 }]}>{publicLists.isPending ? "Açık listeler kontrol ediliyor…" : publicLists.isError || remoteLists === null ? "Açık listeler yüklenemedi." : "Aynı ad ve bölgeyle eşleşen açık liste bulunmadı."}</Text>}
    <Rule /><Eyebrow>KAYNAK & DOĞRULAMA</Eyebrow><Text style={[S.small, { marginTop: 8 }]}>Mekân bilgileri senin elle girdiğin kayıttan gelir. Dış kaynak/Google verisi ve doğrulanmış ziyaret bilgisi kullanılmaz. Son bağımsız doğrulama yok.</Text>
    <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 10, marginTop: 20 }}>{["Yanlış bilgi", "Kapanmış", "Yinelenen kayıt"].map(label => <Pressable key={label} onPress={() => setReportType(label)} style={{ paddingVertical: 9, paddingHorizontal: 12, borderWidth: 1, borderColor: C.line }}><Text style={S.label}>{label}</Text></Pressable>)}</View>
    {!!reportType && <Text style={[S.small, { marginTop: 12 }]}>“{reportType}” bildirimi için sunucu bağlantısı yok; rapor gönderilmedi. Kendi kaydını sağ üstteki düzenleme simgesinden düzeltebilirsin.</Text>}
  </Page>;
}