import { Feather } from "@expo/vector-icons";
import { router } from "expo-router";
import React from "react";
import { Pressable, Text, View } from "react-native";
import { Action, Eyebrow, Masthead, Page, Rule, S } from "@/components/Editorial";
import { C } from "@/constants/colors";
import { useJournal } from "@/context/JournalContext";
export default function ProfileScreen() {
  const { profile, places, visits, lists } = useJournal();
  const publicLists = lists.filter(l => l.visibility === "public" && l.remoteId);
  return <Page><Masthead right="settings" onRight={() => router.push("/settings")} /><Eyebrow>KİŞİSEL PROFİL</Eyebrow>
    <View style={{ width: 70, height: 70, borderWidth: 1, borderColor: C.teal, alignItems: "center", justifyContent: "center", marginTop: 22 }}><Text style={S.heading}>{(profile.name || "G").slice(0, 1).toLocaleUpperCase("tr")}</Text></View>
    <Text style={[S.title, { marginTop: 16 }]}>{profile.name || "Adını yaz, hikâyen başlasın."}</Text>
    <Text style={[S.label, { marginTop: 8 }]}>{profile.handle ? `@${profile.handle}` : "KULLANICI ADI EKLE"} · {profile.city || "ŞEHİR BELİRTİLMEDİ"}</Text>
    <Text style={[S.body, { color: C.muted, marginTop: 18 }]}>{profile.bio || "Bu sayfa senin lezzet hikâyenin başlangıcı."}</Text>
    {!!profile.interests && <Text style={[S.small, { marginTop: 13 }]}>İlgi alanları: {profile.interests}</Text>}
    {!!profile.areas && <Text style={[S.small, { marginTop: 5 }]}>Bölgeler: {profile.areas}</Text>}
    <View style={{ marginTop: 24 }}><Action onPress={() => router.push("/profile/edit")} icon="edit-2">Profili düzenle</Action></View>
    <Rule space={30} /><View style={[S.row, { alignItems: "flex-start" }]}>{[[places.length, "MEKÂN"], [visits.length, "DENEYİM"], [lists.length, "LİSTE"]].map(([n, label]) => <View key={label}><Text style={S.heading}>{n}</Text><Text style={S.label}>{label}</Text></View>)}</View><Rule space={30} />
    <Eyebrow>HERKESE AÇIK LİSTELERİN</Eyebrow>
    {publicLists.length ? publicLists.map(l => <Pressable key={l.id} onPress={() => router.push(`/list/${l.id}`)} style={{ paddingVertical: 16, borderBottomWidth: 1, borderColor: C.line }}><Text style={S.subhead}>{l.title}</Text><Text style={S.small}>{l.items.length} mekân · {new Date(l.updatedAt).toLocaleDateString("tr-TR")}</Text></Pressable>) : <Text style={[S.small, { marginTop: 12 }]}>Henüz herkese açık bir listen yok. Özel listeler burada gösterilmez.</Text>}
    <Text style={[S.small, { marginTop: 12 }]}>Profilin ve kişisel önerilerin herkese açık bir kullanıcı sayfası değildir; takip ve hesap sistemi henüz bağlı değil.</Text><Rule space={30} />
    {([["Lezzet arşivim", "/history", "bookmark"], ["Küratör listelerim", "/lists", "list"], ["Etkinlik", "/activity", "activity"], ["Bildirimler", "/notifications", "bell"], ["Ayarlar", "/settings", "settings"]] as const).map(([label, route, icon]) => <Pressable key={route} onPress={() => router.push(route)} style={[S.row, { paddingVertical: 19, borderBottomWidth: 1, borderColor: C.line }]}><View style={{ flexDirection: "row", gap: 13, alignItems: "center" }}><Feather name={icon} size={18} color={C.ink} /><Text style={S.body}>{label}</Text></View><Feather name="arrow-up-right" size={18} color={C.teal} /></Pressable>)}
    <Text style={[S.small, { textAlign: "center", marginTop: 36 }]}>GURME · KİŞİSEL LEZZET DEFTERİ</Text>
  </Page>;
}