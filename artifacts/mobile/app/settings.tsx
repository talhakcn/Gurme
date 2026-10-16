import { router } from "expo-router";
import React from "react";
import { Pressable, Switch, Text, View } from "react-native";
import { Action, Eyebrow, Masthead, Page, Rule, S } from "@/components/Editorial";
import { C } from "@/constants/colors";
import { useJournal } from "@/context/JournalContext";
export default function Settings() {
  const { profile, updateProfile } = useJournal();
  return <Page><Masthead back /><Eyebrow>TERCİHLER</Eyebrow><Text style={S.title}>Ayarlar</Text>
    <Rule space={28} /><Eyebrow>GİZLİLİK & VERİ</Eyebrow>
    <View style={{ paddingVertical: 19, borderBottomWidth: 1, borderColor: C.line }}><Text style={S.body}>Kişisel defter · yalnızca bu cihazda</Text><Text style={S.small}>Mekânların, ziyaretlerin ve profil tercihlerin sunucuya gönderilmez. Liste yayınlarken görünürlüğü ayrıca seçersin.</Text></View>
    <Eyebrow>YENİ ZİYARETLERİN VARSAYILAN TERCİHİ</Eyebrow>
    <View style={{ flexDirection: "row", gap: 8, marginTop: 11 }}>{([["private", "YALNIZCA BEN"], ["public", "HERKESE AÇIK NİYETİ"]] as const).map(([value, label]) => <Pressable key={value} onPress={() => updateProfile({ defaultVisitVisibility: value })} style={{ flex: 1, borderWidth: 1, borderColor: C.line, padding: 12, backgroundColor: profile.defaultVisitVisibility === value ? C.ink : C.paper }}><Text style={[S.label, { color: profile.defaultVisitVisibility === value ? C.paper : C.ink, fontSize: 9 }]}>{label}</Text></Pressable>)}</View>
    <Text style={[S.small, { marginTop: 9 }]}>Varsayılan: yalnızca ben. Ziyaretler, “herkese açık” seçilse bile henüz sunucuya yayımlanmaz.</Text>
    <View style={[S.row, { paddingVertical: 19, borderBottomWidth: 1, borderColor: C.line }]}><View style={{ flex: 1, paddingRight: 20 }}><Text style={S.body}>Bildirim tercihi</Text><Text style={S.small}>Bildirim hizmeti bağlı değil; gelecekteki tercihin yalnızca yerel kaydedilir.</Text></View><Switch value={profile.notifications} onValueChange={value => updateProfile({ notifications: value })} trackColor={{ false: C.line, true: C.teal }} thumbColor={C.paper} /></View>
    <Rule space={25} /><Eyebrow>KONUM</Eyebrow><Text style={[S.body, { marginTop: 10 }]}>Konum izni istenmez. Şehrini ve sevdiğin bölgeleri profilinde kendin yazarsın; harita yalnızca elle girdiğin açık adresle açılır.</Text>
    <View style={{ marginTop: 20 }}><Action secondary onPress={() => router.push("/profile/edit")}>Şehir ve bölgeleri düzenle</Action></View>
    <Rule space={25} /><Eyebrow>HESABIM & İÇERİKLERİM</Eyebrow><Text style={[S.body, { marginTop: 10 }]}>Hesap girişi ve cihazlar arası eşitleme yok. Mekânların ve ziyaretlerin bu cihazda tutulur; uygulama verileri silinirse kaybolabilir. Listeleri özel, bağlantıyla erişilen veya herkese açık olarak yayınlayabilirsin. Yayınlanan listeler sunucuda ayrıca saklanır.</Text>
    <View style={{ flexDirection: "row", gap: 8, marginTop: 20 }}><View style={{ flex: 1 }}><Action secondary onPress={() => router.push("/history")}>Mekânlarım</Action></View><View style={{ flex: 1 }}><Action secondary onPress={() => router.push("/lists")}>Listelerim</Action></View></View>
    <Rule space={25} /><Eyebrow>VERİ KAYNAKLARI & YARDIM</Eyebrow><Text style={[S.body, { marginTop: 10 }]}>Mekân bilgilerini sen elle girersin; Google puanı, çalışma saati veya doğrulanmış katalog verisi gösterilmez. Keşfet’teki açık listeler, kullanıcıların Gurme’de yayımladığı yazılı içerikten gelir. Editoryal kahve fotoğrafı örnek görseldir, hiçbir mekâna ait değildir.</Text>
    <Text style={[S.small, { marginTop: 15 }]}>Yardım: yanlış kaydı kendi mekân sayfandan düzeltebilirsin. Bildirim/raporlama, engellenen hesaplar ve sosyal profil hizmeti henüz bağlı değil. Ayrı bir kullanım koşulları veya gizlilik metni bu prototipte yayımlanmadı; yayın öncesi sağlanmalı.</Text>
  </Page>;
}