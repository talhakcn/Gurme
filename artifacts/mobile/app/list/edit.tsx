import { Feather } from "@expo/vector-icons";
import { useDeleteGurmeList, useUpdateGurmeList, type GurmeListVisibility } from "@workspace/api-client-react";
import { useQueryClient } from "@tanstack/react-query";
import { router, useLocalSearchParams } from "expo-router";
import React, { useState } from "react";
import { Alert, Pressable, Text, TextInput, View } from "react-native";
import { Action, Eyebrow, Field, Masthead, Page, Rule, S } from "@/components/Editorial";
import { listPayload, ownerRequest } from "@/components/list-network";
import { C } from "@/constants/colors";
import { useJournal, type ListItem } from "@/context/JournalContext";
export default function EditList() {
  const { id } = useLocalSearchParams<{ id?: string }>();
  const { lists, places, profile, saveList, deleteList } = useJournal();
  const current = lists.find(l => l.id === id);
  const updateRemote = useUpdateGurmeList({ request: ownerRequest(current?.ownerKey || "") });
  const deleteRemote = useDeleteGurmeList({ request: ownerRequest(current?.ownerKey || "") });
  const queryClient = useQueryClient();
  const [title, setTitle] = useState(current?.title || "");
  const [description, setDescription] = useState(current?.description || "");
  const [city, setCity] = useState(current?.city || "");
  const [visibility, setVisibility] = useState<GurmeListVisibility>(current?.visibility || "private");
  const [items, setItems] = useState<ListItem[]>(current?.items || []);
  const [showPicker, setShowPicker] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);
  const [busy, setBusy] = useState(false);
  const [syncError, setSyncError] = useState("");
  const move = (index: number, direction: -1 | 1) => {
    const next = [...items]; const target = index + direction;
    if (target < 0 || target >= next.length) return;
    [next[index], next[target]] = [next[target], next[index]]; setItems(next);
  };
  const submit = async () => {
    if (!title.trim()) return Alert.alert("Liste adı gerekli", "Rotana bir ad ver.");
    if (busy) return;
    setBusy(true); setSyncError("");
    try {
      const draft = { title: title.trim(), description: description.trim(), city: city.trim(), items };
      if (current?.remoteId) {
        if (!profile.name.trim()) throw new Error("Yayınlanmış listeyi güncellemek için profilinde görünen bir ad belirle.");
        if (!current.ownerKey) throw new Error("Bu listenin düzenleme anahtarı bulunamadı. Değişiklikler kaydedilmedi.");
        await updateRemote.mutateAsync({ id: current.remoteId, data: listPayload(draft, places, profile.name, visibility) });
        await queryClient.invalidateQueries({ queryKey: ["/api/gurme/lists"] });
      }
      const next = saveList({ id, ...draft, visibility });
      router.replace(`/list/${next}`);
    } catch (error) { setSyncError(error instanceof Error ? error.message : "Değişiklikler eşitlenemedi. Yeniden dene."); }
    finally { setBusy(false); }
  };
  const remove = async () => {
    if (!current || busy) return;
    setBusy(true); setSyncError("");
    try {
      if (current.remoteId) {
        if (!current.ownerKey) throw new Error("Düzenleme anahtarı bulunamadı. Yayınlanan liste silinmedi.");
        await deleteRemote.mutateAsync({ id: current.remoteId });
        await queryClient.invalidateQueries({ queryKey: ["/api/gurme/lists"] });
      }
      deleteList(current.id); router.replace("/lists");
    } catch (error) { setSyncError(error instanceof Error ? error.message : "Liste sunucudan silinemedi. Yerel kayıt korundu."); setConfirmDelete(false); }
    finally { setBusy(false); }
  };
  return <Page><Masthead back /><Eyebrow>KENDİ ROTANI YAZ</Eyebrow><Text style={S.title}>{current ? "Listeyi düzenle" : "Yeni bir liste"}</Text><Text style={[S.small, { marginTop: 9, marginBottom: 27 }]}>Adresleri seç, sıralamayı düzenle ve her biri için küçük bir not bırak.</Text>
    <Field label="LİSTE BAŞLIĞI *" value={title} onChangeText={setTitle} placeholder="Kadıköy'de sakin kahveciler" />
    <Field label="ŞEHİR / BÖLGE" value={city} onChangeText={setCity} placeholder="İstanbul" />
    <Field label="BU ROTANIN HİKÂYESİ" value={description} onChangeText={setDescription} placeholder="Bu adresleri neden seçtin?" multiline />
    <Eyebrow>GÖRÜNÜRLÜK</Eyebrow><View style={{ flexDirection: "row", gap: 6, marginTop: 11 }}>{([["private", "ÖZEL"], ["unlisted", "BAĞLANTIYLA"], ["public", "HERKESE AÇIK"]] as [GurmeListVisibility, string][]).map(([value, label]) => <Pressable key={value} onPress={() => setVisibility(value)} style={{ flex: 1, padding: 12, borderWidth: 1, borderColor: C.line, backgroundColor: visibility === value ? C.ink : C.paper }}><Text style={[S.label, { fontSize: 9, color: visibility === value ? C.paper : C.ink }]}>{label}</Text></Pressable>)}</View>
    <Text style={[S.small, { marginTop: 9 }]}>Yeni liste önce cihazında kaydedilir. Paylaşmak için liste sayfasından “Yayınla ve paylaş” seç; görünürlük seçimi tek başına yayınlama yapmaz.</Text>
    <Rule /><View style={S.row}><Eyebrow>ROTADAKİ MEKÂNLAR ({items.length})</Eyebrow><Pressable onPress={() => setShowPicker(!showPicker)}><Text style={[S.label, { color: C.ink }]}>+ MEKÂN EKLE</Text></Pressable></View>
    <Text style={[S.small, { marginTop: 8 }]}>Bir mekânı listeye almak, oraya gittiğin veya önerdiğin anlamına gelmez.</Text>
    {showPicker && <View style={{ paddingVertical: 15 }}>{places.filter(p => !items.some(i => i.placeId === p.id)).map(p => <Pressable key={p.id} onPress={() => { setItems([...items, { placeId: p.id, note: "" }]); setShowPicker(false); }} style={{ paddingVertical: 14, borderBottomWidth: 1, borderColor: C.line }}><Text style={S.body}>+ {p.name}</Text><Text style={S.small}>{p.district} · {p.city}</Text></Pressable>)}{!places.length && <Text style={S.small}>Önce arşivine bir mekân eklemelisin.</Text>}<Pressable onPress={() => router.push("/place/edit")} style={{ paddingVertical: 15 }}><Text style={[S.label, { color: C.ink }]}>+ YENİ MEKÂN OLUŞTUR →</Text></Pressable></View>}
    {items.map((item, index) => <View key={item.placeId} style={{ paddingVertical: 18, borderBottomWidth: 1, borderColor: C.line }}>
      <View style={S.row}><Text style={S.subhead}>{String(index + 1).padStart(2, "0")}  {places.find(p => p.id === item.placeId)?.name || "Silinen mekân"}</Text><View style={{ flexDirection: "row", gap: 14 }}><Pressable onPress={() => move(index, -1)}><Feather name="arrow-up" size={18} color={C.ink} /></Pressable><Pressable onPress={() => move(index, 1)}><Feather name="arrow-down" size={18} color={C.ink} /></Pressable><Pressable onPress={() => setItems(items.filter(i => i.placeId !== item.placeId))}><Feather name="x" size={18} color={C.ink} /></Pressable></View></View>
      <TextInput value={item.note} onChangeText={value => setItems(items.map((i, n) => n === index ? { ...i, note: value } : i))} placeholder="Bu durak hakkında küratör notun..." placeholderTextColor={C.muted} multiline style={[S.input, { fontSize: 13, minHeight: 47 }]} />
    </View>)}
    {!!syncError && <Text style={[S.small, { color: "#A74A3E", marginTop: 17 }]}>{syncError}</Text>}
    <View style={{ marginTop: 27 }}><Action onPress={submit}>{busy ? "Kaydediliyor…" : current ? "Listeyi kaydet" : "Listeyi oluştur"}</Action></View>
    {!!current && <><Rule /><Action secondary onPress={() => setConfirmDelete(true)}>Listeyi sil</Action>
      {confirmDelete && <View style={{ paddingVertical: 20 }}><Text style={S.body}>Bu rota{current.remoteId ? " ve yayınlanmış kopyası" : ""} kalıcı olarak silinecek. Emin misin?</Text><View style={{ flexDirection: "row", gap: 8, marginTop: 15 }}><View style={{ flex: 1 }}><Action secondary onPress={() => setConfirmDelete(false)}>Vazgeç</Action></View><View style={{ flex: 1 }}><Action onPress={remove}>{busy ? "Siliniyor…" : "Evet, sil"}</Action></View></View></View>}
    </>}
  </Page>;
}