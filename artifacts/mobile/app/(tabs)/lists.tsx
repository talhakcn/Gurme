import { useListGurmeLists, type GurmeList } from "@workspace/api-client-react";
import { router, useLocalSearchParams } from "expo-router";
import React, { useEffect, useState } from "react";
import { Pressable, Text, View } from "react-native";
import { Action, Empty, Eyebrow, Masthead, Page, Rule, S } from "@/components/Editorial";
import { displayDate } from "@/components/date";
import { C } from "@/constants/colors";
import { useJournal } from "@/context/JournalContext";
import { listCollection } from "@/components/list-network";

export default function Lists() {
  const { tab: initialTab } = useLocalSearchParams<{ tab?: string }>();
  const { lists, savedListIds, savedRemoteLists } = useJournal();
  const discovery = useListGurmeLists();
  const remoteLists = listCollection(discovery.data);
  const [tab, setTab] = useState<"mine" | "saved" | "discover">(initialTab === "saved" || initialTab === "discover" ? initialTab : "mine");
  useEffect(() => { if (initialTab === "saved" || initialTab === "discover") setTab(initialTab); }, [initialTab]);
  const visible = lists.filter(l => tab === "mine" || savedListIds.includes(l.id));
  const remoteRow = (l: GurmeList) => <Pressable key={l.id} onPress={() => router.push(`/shared/${l.id}`)} style={{ paddingVertical: 22, borderBottomWidth: 1, borderColor: C.line }}>
    <Eyebrow>{l.visibility === "public" ? "TOPLULUK ROTASI" : "KAYDEDİLEN ROTA"} · {l.authorName}</Eyebrow>
    <Text style={[S.heading, { marginTop: 7 }]}>{l.title}</Text>
    <Text numberOfLines={2} style={[S.small, { marginTop: 8 }]}>{l.description || "Küratörün seçtiği adresler."}</Text>
    <Text style={[S.label, { marginTop: 14 }]}>{l.items.length} MEKÂN · {displayDate(l.updatedAt)}  →</Text>
  </Pressable>;
  return <Page><Masthead /><Eyebrow>KÜRATÖRÜN SEN OL</Eyebrow><Text style={S.title}>Listeler</Text>
    <Text style={[S.body, { color: C.muted, marginTop: 8 }]}>Bir semt, bir lezzet, bir hikâye. Rotanı kendin çiz.</Text>
    <View style={{ marginTop: 24 }}><Action icon="plus" onPress={() => router.push("/list/edit")}>Yeni liste oluştur</Action></View>
    <View style={{ flexDirection: "row", justifyContent: "space-between", marginTop: 29 }}>
      {([["mine", "LİSTELERİM"], ["saved", "KAYDEDİLEN"], ["discover", "KEŞFET"]] as const).map(([key, label]) => <Pressable key={key} onPress={() => setTab(key)} style={{ borderBottomWidth: tab === key ? 2 : 0, borderColor: C.ink, paddingBottom: 12 }}><Text style={[S.label, { color: tab === key ? C.ink : C.muted }]}>{label}</Text></Pressable>)}
    </View><Rule space={12} />
    {tab === "mine" && (visible.length ? visible.map((l, i) => <Pressable key={l.id} onPress={() => router.push(`/list/${l.id}`)} style={{ paddingVertical: 22, borderBottomWidth: 1, borderColor: C.line }}><Eyebrow>{String(i + 1).padStart(2, "0")} / {l.city || "KİŞİSEL ROTA"} · {l.remoteId ? l.visibility === "public" ? "HERKESE AÇIK" : l.visibility === "unlisted" ? "BAĞLANTIYLA" : "ÖZEL" : "YEREL"}</Eyebrow><Text style={[S.heading, { marginTop: 7 }]}>{l.title}</Text><Text numberOfLines={2} style={[S.small, { marginTop: 8 }]}>{l.description || "Bu rotanın hikâyesi henüz yazılmadı."}</Text><Text style={[S.label, { marginTop: 14 }]}>{l.items.length} MEKÂN · {displayDate(l.updatedAt)}  →</Text></Pressable>) : <Empty title="İlk rotanı çiz." detail="Favori adreslerini bir araya getir. Notlar ekle, sırasını belirle ve şehir rehberini oluştur." action="Liste oluştur" onPress={() => router.push("/list/edit")} />)}
    {tab === "saved" && <>{visible.filter(l => savedListIds.includes(l.id)).map(l => <Pressable key={l.id} onPress={() => router.push(`/list/${l.id}`)} style={{ paddingVertical: 20, borderBottomWidth: 1, borderColor: C.line }}><Eyebrow>KENDİ ROTAN</Eyebrow><Text style={S.heading}>{l.title}</Text></Pressable>)}{savedRemoteLists.map(remoteRow)}{!savedRemoteLists.length && !savedListIds.length && <Empty title="Henüz kaydedilen liste yok." detail="Keşfettiğin bir rotayı arşivine eklediğinde burada görünür." action="Listeleri keşfet" onPress={() => setTab("discover")} />}</>}
    {tab === "discover" && (discovery.isPending ? <View style={{ paddingTop: 20 }}>{[0, 1, 2].map(i => <View key={i} style={{ marginBottom: 25, height: 76, backgroundColor: C.wash }} />)}</View> : discovery.isError || remoteLists === null ? <Empty title="Rotalar yüklenemedi." detail="Bağlantını kontrol edip tekrar deneyebilirsin." action="Tekrar dene" onPress={() => discovery.refetch()} /> : remoteLists.length ? remoteLists.filter(l => l.visibility === "public").map(remoteRow) : <Empty title="Henüz açık rota yok." detail="Herkese açık olarak paylaşılan küratör listeleri burada yer alacak." />)}
  </Page>;
}