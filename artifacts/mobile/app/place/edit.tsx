import * as ImagePicker from "expo-image-picker";
import { router, useLocalSearchParams } from "expo-router";
import React, { useState } from "react";
import { Alert, Image, Pressable, Text, View } from "react-native";
import { Action, Eyebrow, Field, Masthead, Page, Rule, S } from "@/components/Editorial";
import { useJournal, type Status } from "@/context/JournalContext";
import { C } from "@/constants/colors";
const normalize = (value: string) => value.trim().toLocaleLowerCase("tr").normalize("NFKD").replace(/[\u0300-\u036f]/g, "").replace(/[^\p{L}\p{N}]+/gu, " ").trim();
export default function EditPlace() {
  const { id } = useLocalSearchParams<{ id?: string }>();
  const { places, lists, addPlace, updatePlace, deletePlace, saveList } = useJournal();
  const current = places.find(p => p.id === id);
  const [name, setName] = useState(current?.name || "");
  const [district, setDistrict] = useState(current?.district || "");
  const [city, setCity] = useState(current?.city || "");
  const [address, setAddress] = useState(current?.address || "");
  const [category, setCategory] = useState(current?.category || "");
  const [description, setDescription] = useState(current?.description || "");
  const [image, setImage] = useState(current?.image || "");
  const [status, setStatus] = useState<Status | undefined>(current?.status);
  const [recommended, setRecommended] = useState(!!current?.recommended);
  const [selectedLists, setSelectedLists] = useState<string[]>(lists.filter(l => !l.remoteId && !!current && l.items.some(i => i.placeId === current.id)).map(l => l.id));
  const [error, setError] = useState("");
  const suggestions = name.trim().length >= 2 ? places.filter(p => p.id !== current?.id && normalize(p.name).includes(normalize(name))).slice(0, 5) : [];
  const duplicate = places.find(p => p.id !== current?.id && normalize(p.name) === normalize(name) && normalize(p.district) === normalize(district) && normalize(p.city) === normalize(city) && !!name.trim());
  const pick = async () => {
    const result = await ImagePicker.launchImageLibraryAsync({ mediaTypes: ["images"], quality: 0.7, allowsEditing: true });
    if (!result.canceled && result.assets[0]) setImage(result.assets[0].uri);
  };
  const submit = () => {
    if (!name.trim()) { setError("Mekân adı gerekli."); return; }
    if (duplicate) { setError("Bu ad, semt ve şehirle kayıtlı bir mekân var. Yeni kayıt yerine mevcut kaydı seç."); return; }
    const values = { name: name.trim(), district: district.trim(), city: city.trim(), address: address.trim(), category: category.trim() || "Mekân", description: description.trim(), image, status, recommended };
    const placeId = current?.id || addPlace(values);
    if (current) updatePlace(current.id, values);
    lists.filter(l => !l.remoteId).forEach(l => {
      const has = l.items.some(i => i.placeId === placeId);
      const selected = selectedLists.includes(l.id);
      if (has !== selected) saveList({ id: l.id, title: l.title, description: l.description, city: l.city, items: selected ? [...l.items, { placeId, note: "" }] : l.items.filter(i => i.placeId !== placeId) });
    });
    router.replace(`/place/${placeId}`);
  };
  return <Page><Masthead back /><Eyebrow>DEFTERİNE YENİ BİR ADRES</Eyebrow><Text style={S.title}>{current ? "Mekânı düzenle" : "Mekân ekle"}</Text><Text style={[S.small, { marginTop: 9, marginBottom: 30 }]}>Bu kayıt cihazında saklanır. Adresleri şimdilik elle ekleyebilirsin.</Text>
    <Field label="MEKÂN ADI *" value={name} onChangeText={setName} placeholder="Örn. köşedeki küçük kahveci" />
    <Field label="SEMT" value={district} onChangeText={setDistrict} placeholder="Moda, Karaköy..." />
    <Field label="ŞEHİR" value={city} onChangeText={setCity} placeholder="İstanbul" />
    <Field label="AÇIK ADRES / KONUM (HARİTA İÇİN)" value={address} onChangeText={setAddress} placeholder="Sokak ve numara, açık adres..." />
    {!!suggestions.length && <View style={{ marginBottom: 22, borderTopWidth: 1, borderColor: C.line, paddingTop: 13 }}><Eyebrow>BU KAYITLAR ZATEN VAR · YALNIZCA SENİN DEFTERİN</Eyebrow>{suggestions.map(p => <Pressable key={p.id} onPress={() => router.replace(`/place/${p.id}`)} style={{ paddingVertical: 11, borderBottomWidth: 1, borderColor: C.line }}><Text style={S.body}>{p.name}</Text><Text style={S.small}>{[p.district, p.city].filter(Boolean).join(", ")} · {p.category}  → Mevcut kaydı seç</Text></Pressable>)}</View>}
    <Field label="TÜR" value={category} onChangeText={setCategory} placeholder="Kahve, lokanta, fırın..." />
    <Field label="KISA TANIM" value={description} onChangeText={setDescription} placeholder="Nesi aklında kaldı?" multiline />
    <Eyebrow>KAYIT DURUMU</Eyebrow><View style={{ flexDirection: "row", gap: 6, marginTop: 10 }}>{([["want", "GİTMEK İSTİYORUM"], ["went", "GİTTİM"]] as [Status, string][]).map(([value, label]) => <Pressable key={value} onPress={() => { setStatus(status === value ? undefined : value); if (value === "want") setRecommended(false); }} style={{ flex: 1, borderWidth: 1, borderColor: C.line, padding: 12, backgroundColor: status === value ? C.ink : C.paper }}><Text style={[S.label, { fontSize: 9, color: status === value ? C.paper : C.ink }]}>{label}</Text></Pressable>)}</View>
    <Pressable onPress={() => { setRecommended(!recommended); if (!recommended) setStatus("went"); }} style={{ borderWidth: 1, borderColor: C.line, padding: 12, marginTop: 7, marginBottom: 23, backgroundColor: recommended ? C.gold : C.paper }}><Text style={[S.label, { color: C.ink }]}>ÖNERİYORUM  ·  {recommended ? "EVET" : "HAYIR"}</Text></Pressable>
    <Text style={[S.small, { marginTop: -12, marginBottom: 22 }]}>“Gittim” ve “Öneriyorum” birbirinden bağımsız tercihlerdir.</Text>
    {!!lists.length && <><Eyebrow>HANGİ LİSTEYE?</Eyebrow>{lists.map(l => <Pressable key={l.id} onPress={() => l.remoteId ? router.push({ pathname: "/list/edit", params: { id: l.id } }) : setSelectedLists(prev => prev.includes(l.id) ? prev.filter(x => x !== l.id) : [...prev, l.id])} style={{ paddingVertical: 12, borderBottomWidth: 1, borderColor: C.line }}><Text style={S.body}>{selectedLists.includes(l.id) ? "■" : "□"}  {l.title}</Text>{l.remoteId && <Text style={S.small}>Paylaşılan liste · eklemek için liste düzenleyiciye git</Text>}</Pressable>)}<View style={{ height: 23 }} /></>}
    <Pressable onPress={pick} style={{ borderWidth: 1, borderColor: C.line, minHeight: 60, justifyContent: "center", padding: 15, marginBottom: 23 }}><Text style={S.label}>{image ? "FOTOĞRAFI DEĞİŞTİR" : "+ FOTOĞRAF SEÇ"}</Text></Pressable>
    {!!image && <Image source={{ uri: image }} style={{ width: "100%", height: 220, marginBottom: 23 }} />}
    {!!error && <Text style={[S.small, { color: "#A74A3E", marginBottom: 12 }]}>{error}</Text>}
    <Action onPress={submit}>{current ? "Değişiklikleri kaydet" : "Mekânı kaydet"}</Action>
    {!!current && <><Rule /><Action secondary onPress={() => {
      if (lists.some(l => l.remoteId && l.items.some(i => i.placeId === current.id))) {
        Alert.alert("Önce paylaşılan listeden kaldır", "Bu mekân yayınlanmış bir rotada yer alıyor. Önce listeyi düzenleyip eşitle, sonra mekânı sil.");
        return;
      }
      Alert.alert("Mekânı sil?", "Deneyimleri ve listelerdeki kaydı da silinecek.", [{ text: "Vazgeç" }, { text: "Sil", style: "destructive", onPress: () => { deletePlace(current.id); router.replace("/history"); } }]);
    }}>Mekânı sil</Action></>}
  </Page>;
}