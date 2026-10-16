import * as ImagePicker from "expo-image-picker";
import { router, useLocalSearchParams } from "expo-router";
import React, { useState } from "react";
import { Alert, Image, Pressable, Text, View } from "react-native";
import { Action, Empty, Eyebrow, Field, Masthead, Page, Rule, S } from "@/components/Editorial";
import { C } from "@/constants/colors";
import { useJournal } from "@/context/JournalContext";
export default function EditVisit() {
  const { id, placeId } = useLocalSearchParams<{ id?: string; placeId: string }>();
  const { places, visits, profile, saveVisit, deleteVisit } = useJournal();
  const p = places.find(x => x.id === placeId);
  const current = visits.find(v => v.id === id);
  const [date, setDate] = useState(current?.date || new Date().toISOString().slice(0, 10));
  const [title, setTitle] = useState(current?.title || "");
  const [note, setNote] = useState(current?.note || "");
  const [order, setOrder] = useState(current?.order || "");
  const [recommended, setRecommended] = useState(current?.recommended || false);
  const [revisit, setRevisit] = useState<"yes" | "no" | "undecided">(current?.revisit || "undecided");
  const [dishes, setDishes] = useState(current?.dishes || "");
  const [photos, setPhotos] = useState<string[]>(current?.photos || []);
  const [visibility, setVisibility] = useState<"private" | "public">(current?.visibility || profile.defaultVisitVisibility || "private");
  const pickPhotos = async () => {
    const result = await ImagePicker.launchImageLibraryAsync({ mediaTypes: ["images"], allowsMultipleSelection: true, selectionLimit: 4, quality: 0.7 });
    if (!result.canceled) setPhotos(prev => [...prev, ...result.assets.map(a => a.uri)].slice(0, 4));
  };
  if (!p) return <Page><Masthead back /><Empty title="Mekân bulunamadı." detail="Önce bir mekân ekle." action="Mekân ekle" onPress={() => router.replace("/place/edit")} /></Page>;
  const submit = () => {
    if (!note.trim()) return Alert.alert("Bir not yaz", "Deneyimin için kısa da olsa bir not ekle.");
    saveVisit({ id, placeId, date: date.trim(), title: title.trim(), note: note.trim(), order: order.trim(), recommended, revisit, dishes: dishes.trim(), photos, visibility });
    router.replace(`/place/${placeId}`);
  };
  return <Page><Masthead back /><Eyebrow>GURME SAHA ARŞİVİ / {p.district || p.city}</Eyebrow><Text style={S.title}>{current ? "Deneyimi düzenle" : "Deneyimini yaz"}</Text><Text style={[S.subhead, { marginTop: 12, marginBottom: 30 }]}>{p.name}</Text>
    <Field label="ZİYARET TARİHİ (YYYY-MM-DD)" value={date} onChangeText={setDate} placeholder="2025-05-18" />
    <Field label="DENEYİM BAŞLIĞI" value={title} onChangeText={setTitle} placeholder="O sabahki ilk fincan" />
    <Field label="NE TATTIN?" value={order} onChangeText={setOrder} placeholder="Bir kahve, bir tabak..." />
    <Field label="ÖNERDİĞİN ÜRÜNLER" value={dishes} onChangeText={setDishes} placeholder="Örn. filtre kahve, tahinli çörek" />
    <Field label="KİŞİSEL GÖZLEM & AMBIYANS *" value={note} onChangeText={setNote} placeholder="Tat, atmosfer, küçük ayrıntılar..." multiline />
    <Eyebrow>TEKRAR GİDER MİSİN?</Eyebrow><View style={{ flexDirection: "row", gap: 6, marginTop: 10 }}>{([["yes", "EVET"], ["no", "HAYIR"], ["undecided", "KARARSIZIM"]] as const).map(([value, label]) => <Pressable key={value} onPress={() => setRevisit(value)} style={{ flex: 1, borderWidth: 1, borderColor: C.line, padding: 11, backgroundColor: revisit === value ? C.ink : C.paper }}><Text style={[S.label, { textAlign: "center", color: revisit === value ? C.paper : C.ink }]}>{label}</Text></Pressable>)}</View>
    <Rule space={22} /><Eyebrow>KENDİ FOTOĞRAFLARIN ({photos.length}/4)</Eyebrow><View style={{ flexDirection: "row", flexWrap: "wrap", gap: 7, marginTop: 12 }}>{photos.map((uri, i) => <Pressable key={`${uri}-${i}`} onPress={() => setPhotos(prev => prev.filter((_, n) => n !== i))}><Image source={{ uri }} style={{ width: 74, height: 74 }} /><Text style={S.small}>Kaldır ×</Text></Pressable>)}</View><View style={{ marginTop: 12 }}><Action secondary icon="image" onPress={pickPhotos}>Fotoğraf seç</Action></View>
    <Pressable onPress={() => setRecommended(!recommended)} style={[S.row, { paddingVertical: 18, borderBottomWidth: 1, borderColor: C.line, marginBottom: 25 }]}><Text style={S.body}>Bu mekânı öneriyorum</Text><View style={{ width: 22, height: 22, borderWidth: 1, borderColor: C.ink, backgroundColor: recommended ? C.ink : C.paper, alignItems: "center", justifyContent: "center" }}><Text style={{ color: C.paper }}>{recommended ? "✓" : ""}</Text></View></Pressable>
    <Eyebrow>PAYLAŞIM TERCİHİ</Eyebrow><View style={{ flexDirection: "row", gap: 7, marginTop: 10 }}>{([["private", "YALNIZCA BEN"], ["public", "HERKESE AÇIK NİYETİ"]] as const).map(([value, label]) => <Pressable key={value} onPress={() => setVisibility(value)} style={{ flex: 1, borderWidth: 1, borderColor: C.line, padding: 11, backgroundColor: visibility === value ? C.ink : C.paper }}><Text style={[S.label, { textAlign: "center", fontSize: 9, color: visibility === value ? C.paper : C.ink }]}>{label}</Text></Pressable>)}</View>
    <Text style={[S.small, { marginTop: 10, marginBottom: 22 }]}>Ziyaretlerin sunucuya gönderilmez. Herkese açık tercihi yalnızca bu cihazda saklanır; yayınlama henüz bağlı değildir. Özel notların hiçbir listede paylaşılmaz.</Text>
    <Action onPress={submit}>{current ? "Değişiklikleri kaydet" : "Deneyimi kaydet"}</Action>
    {!!current && <><Rule /><Action secondary onPress={() => Alert.alert("Deneyimi sil?", "Bu işlem geri alınamaz.", [{ text: "Vazgeç" }, { text: "Sil", style: "destructive", onPress: () => { deleteVisit(current.id); router.replace(`/place/${placeId}`); } }])}>Deneyimi sil</Action></>}
  </Page>;
}