import { Feather } from "@expo/vector-icons";
import { useCreateGurmeList, useUpdateGurmeList } from "@workspace/api-client-react";
import { useQueryClient } from "@tanstack/react-query";
import { router, useLocalSearchParams } from "expo-router";
import React, { useState } from "react";
import { Platform, Pressable, Share, Text, View } from "react-native";
import { Action, Empty, Eyebrow, F, Masthead, Page, PlaceRow, Rule, S } from "@/components/Editorial";
import { listPayload, ownerRequest, shareUrl } from "@/components/list-network";
import { displayDate } from "@/components/date";
import { C } from "@/constants/colors";
import { useJournal } from "@/context/JournalContext";
import type { GurmeListVisibility } from "@workspace/api-client-react";
export default function ListDetail() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { lists, places, profile, savedListIds, toggleSaved, linkRemoteList, setListVisibility } = useJournal();
  const [order, setOrder] = useState<"curated" | "alphabetic">("curated");
  const list = lists.find(l => l.id === id);
  const [visibilityChoice, setVisibilityChoice] = useState<GurmeListVisibility>(list?.visibility || "private");
  const [syncError, setSyncError] = useState("");
  const [syncNotice, setSyncNotice] = useState("");
  const [busy, setBusy] = useState(false);
  const createRemote = useCreateGurmeList();
  const updateRemote = useUpdateGurmeList({ request: ownerRequest(list?.ownerKey || "") });
  const queryClient = useQueryClient();
  const saveVisibility = async () => {
    if (!list?.remoteId || busy) return;
    if (!profile.name.trim()) { setSyncError("Görünürlüğü güncellemek için profilinde görünen bir ad belirle."); return; }
    if (!list.ownerKey) { setSyncError("Bu listenin düzenleme anahtarı bu cihazda yok."); return; }
    setBusy(true); setSyncError(""); setSyncNotice("");
    try {
      await updateRemote.mutateAsync({ id: list.remoteId, data: listPayload(list, places, profile.name, visibilityChoice) });
      setListVisibility(list.id, visibilityChoice);
      setSyncNotice(visibilityChoice === "private" ? "Liste artık özel; paylaşım bağlantısı erişilemez." : "Görünürlük güncellendi.");
      await queryClient.invalidateQueries({ queryKey: ["/api/gurme/lists"] });
    } catch (error) { setSyncError(error instanceof Error ? error.message : "Görünürlük değiştirilemedi."); }
    finally { setBusy(false); }
  };
  const share = async () => {
    if (!list || busy) return;
    if (!profile.name.trim()) {
      setSyncError("Listeyi yayımlamak için profilinde görünen bir ad belirle.");
      return;
    }
    if (visibilityChoice === "private") {
      setSyncError("Özel listeye bağlantı oluşturulamaz. Bağlantı ile erişim veya herkese açık seç.");
      return;
    }
    setBusy(true); setSyncError(""); setSyncNotice("");
    try {
      const data = listPayload(list, places, profile.name, visibilityChoice);
      let remoteId = list.remoteId;
      if (remoteId) {
        if (!list.ownerKey) throw new Error("Bu listenin düzenleme anahtarı bu cihazda yok. Paylaşım güncellenemedi.");
        await updateRemote.mutateAsync({ id: remoteId, data });
        setListVisibility(list.id, visibilityChoice);
      } else {
        const created = await createRemote.mutateAsync({ data });
        remoteId = created.id;
        linkRemoteList(list.id, created.id, created.ownerKey, visibilityChoice);
      }
      await queryClient.invalidateQueries({ queryKey: ["/api/gurme/lists"] });
      const url = shareUrl(remoteId);
      if (!url) {
        setSyncError("Liste yayınlandı ancak paylaşım adresi bu ortamda oluşturulamadı.");
        return;
      }
      if (Platform.OS === "web" && typeof window !== "undefined") {
        if (navigator.share) await navigator.share({ title: list.title, url });
        else if (navigator.clipboard?.writeText) { await navigator.clipboard.writeText(url); setSyncNotice("Bağlantı panoya kopyalandı."); }
        else window.open(url, "_blank", "noopener,noreferrer");
      } else {
        await Share.share({ message: url, url, title: list.title });
      }
    } catch (error) {
      setSyncError(error instanceof Error ? error.message : "Liste eşitlenemedi. Tekrar dene.");
    } finally { setBusy(false); }
  };
  if (!list) return <Page><Masthead back /><Empty title="Liste bulunamadı." detail="Bu rota kaldırılmış olabilir." action="Listelere dön" onPress={() => router.replace("/lists")} /></Page>;
  const items = order === "curated" ? list.items : [...list.items].sort((a, b) => (places.find(p => p.id === a.placeId)?.name || "").localeCompare(places.find(p => p.id === b.placeId)?.name || "", "tr"));
  return <Page><Masthead back right="bookmark" onRight={() => toggleSaved(id)} />
    <Eyebrow>ÖZEL SEÇKİ · {list.city || "KİŞİSEL ROTA"}</Eyebrow><Text style={[S.title, { marginTop: 6 }]}>{list.title}</Text>
    <View style={[S.row, { marginTop: 19 }]}><Text style={S.small}>□  {profile.name || "Sen"} · Küratör notlarıyla hazırlanmış</Text><Text style={S.label}>{savedListIds.includes(id) ? "KAYDEDİLDİ" : "KAYDET"}</Text></View>
    <Text style={[S.small, { marginTop: 8 }]}>Oluşturuldu: {displayDate(list.createdAt)} · Güncellendi: {displayDate(list.updatedAt)}</Text>
    <Rule space={19} />
    <Text style={[S.body, { fontFamily: F.italic, fontSize: 18, lineHeight: 28 }]}>{list.description ? `“${list.description}”` : "“Bu rotanın hikâyesi henüz yazılmadı.”"}</Text>
    <Rule space={22} /><Eyebrow>PAYLAŞIM GÖRÜNÜRLÜĞÜ</Eyebrow>
    <View style={{ flexDirection: "row", gap: 5, marginTop: 12 }}>
      {([["private", "ÖZEL"], ["unlisted", "BAĞLANTIYLA"], ["public", "HERKESE AÇIK"]] as [GurmeListVisibility, string][]).map(([value, label]) =>
        <Pressable key={value} onPress={() => { setVisibilityChoice(value); setSyncError(""); }} style={{ flex: 1, paddingVertical: 13, borderWidth: 1, borderColor: C.line, backgroundColor: visibilityChoice === value ? C.ink : C.paper, alignItems: "center" }}>
          <Text style={[S.label, { fontSize: 9, color: visibilityChoice === value ? C.paper : C.ink }]}>{label}</Text>
        </Pressable>)}
    </View>
    <Text style={[S.small, { marginTop: 9 }]}>{visibilityChoice === "public" ? "Keşfet ekranında herkes görebilir." : visibilityChoice === "unlisted" ? "Yalnızca bağlantıya sahip kişiler görebilir." : "Bu liste yalnızca sende kalır; paylaşım bağlantısı oluşturulmaz."}</Text>
    {!!syncError && <Text style={[S.small, { marginTop: 10, color: "#A74A3E" }]}>{syncError}</Text>}
    {!profile.name.trim() && <Pressable onPress={() => router.push("/profile/edit")} style={{ paddingVertical: 13 }}><Text style={[S.label, { color: C.ink }]}>GÖRÜNEN ADINI PROFİLDE EKLE →</Text></Pressable>}
    {!!syncNotice && <Text style={[S.small, { marginTop: 10, color: C.ink }]}>{syncNotice}</Text>}
    {!!list.remoteId && visibilityChoice !== (list.visibility || "private") && <View style={{ marginTop: 15 }}><Action secondary icon="check" onPress={saveVisibility}>{busy ? "Kaydediliyor…" : "Görünürlüğü kaydet"}</Action></View>}
    <View style={{ marginTop: 22 }}><Action icon="share-2" onPress={share}>{busy ? "Eşitleniyor…" : list.remoteId ? "Güncelle ve paylaş" : "Yayınla ve paylaş"}</Action></View>
    <View style={{ flexDirection: "row", gap: 9, marginTop: 10 }}><View style={{ flex: 1 }}><Action secondary icon={savedListIds.includes(id) ? "check" : "bookmark"} onPress={() => toggleSaved(id)}>{savedListIds.includes(id) ? "Kaydedildi" : "Listeyi kaydet"}</Action></View><View style={{ flex: 1 }}><Action secondary icon="edit-2" onPress={() => router.push({ pathname: "/list/edit", params: { id } })}>Düzenle</Action></View></View>
    <Rule space={29} /><View style={S.row}><Eyebrow>SEÇKİDEKİ MEKÂNLAR ({items.length})</Eyebrow><Pressable onPress={() => setOrder(order === "curated" ? "alphabetic" : "curated")}><Text style={[S.label, { color: C.ink }]}>{order === "curated" ? "KRONOLOJİK REHBER" : "A–Z SIRASI"}  <Feather name="chevron-down" size={10} /></Text></Pressable></View>
    {items.length ? items.map((item, index) => {
      const place = places.find(p => p.id === item.placeId);
      return place ? <View key={item.placeId}><PlaceRow place={place} index={index + 1} />{!!item.note && <View style={{ borderLeftWidth: 1, borderColor: C.teal, paddingLeft: 13, marginTop: 13, marginBottom: 10 }}><Eyebrow>NEDEN BU LİSTEDE?</Eyebrow><Text style={[S.body, { marginTop: 5 }]}>{item.note}</Text></View>}<Text style={[S.label, { marginVertical: 12, color: C.ink }]}>MEKÂNA GİT  →</Text></View> : null;
    }) : <Empty title="Rota henüz boş." detail="Listeye adresler ekleyerek kişisel şehir rehberini tamamla." action="Mekân ekle" onPress={() => router.push({ pathname: "/list/edit", params: { id } })} />}
    <Rule space={30} /><Text style={[S.subhead, { fontFamily: F.italic, textAlign: "center" }]}>Bir liste, bir şehrin başka bir okuması.</Text><Text style={[S.label, { textAlign: "center", marginTop: 18 }]}>GURME · KİŞİSEL KÜRATÖR DEFTERİ</Text>
  </Page>;
}