import { Feather } from "@expo/vector-icons";
import { getGetGurmeListQueryKey, useGetGurmeList } from "@workspace/api-client-react";
import { router, useLocalSearchParams } from "expo-router";
import React, { useState } from "react";
import { Platform, Pressable, Share, Text, View } from "react-native";
import { Action, Empty, Eyebrow, F, Masthead, Page, Rule, S } from "@/components/Editorial";
import { displayDate } from "@/components/date";
import { areaToLocation, shareUrl } from "@/components/list-network";
import { C } from "@/constants/colors";
import { useJournal } from "@/context/JournalContext";

export default function SharedListDetail() {
  const { id = "" } = useLocalSearchParams<{ id: string }>();
  const { savedRemoteLists, toggleRemoteSaved, places, addPlace } = useJournal();
  const query = useGetGurmeList(id, { query: { queryKey: getGetGurmeListQueryKey(id), enabled: !!id } });
  const snapshot = savedRemoteLists.find(l => l.id === id);
  const list = query.data || snapshot;
  const [notice, setNotice] = useState("");
  const [reportFor, setReportFor] = useState("");
  const saved = !!snapshot;
  const share = async () => {
    if (!list || list.visibility === "private") { setNotice("Özel listeler paylaşılamaz."); return; }
    const url = shareUrl(list.id);
    if (!url) { setNotice("Bu ortamda paylaşım adresi oluşturulamadı."); return; }
    try {
      if (Platform.OS === "web" && typeof window !== "undefined") {
        if (navigator.share) await navigator.share({ title: list.title, url });
        else if (navigator.clipboard?.writeText) { await navigator.clipboard.writeText(url); setNotice("Bağlantı panoya kopyalandı."); }
        else window.open(url, "_blank", "noopener,noreferrer");
      } else await Share.share({ message: url, url, title: list.title });
    } catch { setNotice("Paylaşım açılamadı. Tekrar deneyebilirsin."); }
  };
  const addToJournal = (item: NonNullable<typeof list>["items"][number]) => {
    if (places.some(p => p.name.toLocaleLowerCase("tr") === item.name.toLocaleLowerCase("tr") && [p.district, p.city].filter(Boolean).join(", ").toLocaleLowerCase("tr") === item.area.toLocaleLowerCase("tr"))) {
      setNotice("Bu mekân zaten defterinde."); return;
    }
    const placeId = addPlace({ name: item.name, ...areaToLocation(item.area), category: item.category || "Mekân", description: item.note, status: "want" });
    setNotice("Mekân gidilecekler listene eklendi.");
    router.push(`/place/${placeId}`);
  };
  return <Page><Masthead back />
    {query.isLoading && !list ? <View style={{ paddingTop: 22 }}><View style={{ height: 12, width: 120, backgroundColor: C.wash }} /><View style={{ height: 42, width: "85%", backgroundColor: C.wash, marginTop: 21 }} /><View style={{ height: 16, width: "60%", backgroundColor: C.wash, marginTop: 20 }} /></View> :
      !list ? <Empty title="Liste açılamadı." detail="Bağlantı geçersiz olabilir veya bağlantı şu anda kullanılamıyor." action="Yeniden dene" onPress={() => query.refetch()} /> :
      <>
        <Eyebrow>{list.visibility === "public" ? "AÇIK KÜRATÖR ROTASI" : "BAĞLANTIYLA ERİŞİLEN ROTA"}</Eyebrow>
        <Text style={[S.title, { marginTop: 6 }]}>{list.title}</Text>
        <Text style={[S.small, { marginTop: 16 }]}>{list.authorName} · {list.items.length} mekân</Text>
        <Text style={[S.small, { marginTop: 7 }]}>Oluşturuldu: {displayDate(list.createdAt)} · Güncellendi: {displayDate(list.updatedAt)}</Text>
        <Text style={[S.small, { marginTop: 7 }]}>Yazar profili ve takip özelliği henüz bağlı değil.</Text>
        {query.isError && <Text style={[S.small, { color: "#A74A3E", marginTop: 9 }]}>Çevrimdışı kayıt gösteriliyor. Güncellemek için yeniden dene.</Text>}
        <Rule space={20} />
        <Text style={[S.body, { fontFamily: F.italic, fontSize: 18, lineHeight: 28 }]}>{list.description || "Küratörün kişisel şehir rotası."}</Text>
        <View style={{ marginTop: 23 }}><Action icon={saved ? "check" : "bookmark"} onPress={() => { toggleRemoteSaved(list); setNotice(saved ? "Liste kayıtlardan çıkarıldı." : "Liste cihazına kaydedildi."); }}>{saved ? "Kaydedilenlerden çıkar" : "Listeyi kaydet"}</Action></View>
        <View style={{ marginTop: 9 }}><Action secondary icon="share-2" onPress={share}>Bağlantıyı paylaş</Action></View>
        {!!notice && <Text style={[S.small, { marginTop: 13, color: C.ink }]}>{notice}</Text>}
        <Rule space={29} /><Eyebrow>ROTADAKİ MEKÂNLAR ({list.items.length})</Eyebrow>
        {list.items.length ? list.items.map((item, index) =>
          <View key={`${item.placeId}-${index}`} style={{ paddingVertical: 22, borderBottomWidth: 1, borderColor: C.line }}>
            <View style={{ flexDirection: "row", gap: 12 }}><Text style={[S.subhead, { color: C.teal }]}>{String(index + 1).padStart(2, "0")}</Text><View style={{ flex: 1 }}><Text style={S.subhead}>{item.name}</Text><Text style={[S.label, { marginTop: 6 }]}>{item.area} · {item.category}</Text></View></View>
            {!!item.note && <View style={{ borderLeftWidth: 1, borderColor: C.teal, paddingLeft: 12, marginTop: 17 }}><Eyebrow>KÜRATÖR NOTU</Eyebrow><Text style={[S.body, { marginTop: 5 }]}>{item.note}</Text></View>}
            <Pressable onPress={() => addToJournal(item)} style={{ flexDirection: "row", gap: 8, alignItems: "center", marginTop: 17, paddingVertical: 8 }}><Feather name="plus" size={14} color={C.ink} /><Text style={[S.label, { color: C.ink }]}>DEFTERİME EKLE</Text></Pressable>
            <Pressable onPress={() => setReportFor(item.placeId)} style={{ paddingVertical: 8 }}><Text style={S.small}>Eski veya kapanmış mekânı bildir</Text></Pressable>
            {reportFor === item.placeId && <Text style={[S.small, { color: C.ink }]}>Bildirim hizmeti bağlı değil; “{item.name}” için rapor gönderilmedi.</Text>}
          </View>
        ) : <Empty title="Bu rota henüz boş." detail="Küratör bu listeye henüz mekân eklemedi." />}
        <Rule /><Text style={[S.small, { textAlign: "center" }]}>GURME · TOPLULUK ROTASI</Text>
      </>}
  </Page>;
}