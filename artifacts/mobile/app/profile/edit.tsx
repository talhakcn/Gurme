import { router } from "expo-router";
import React, { useState } from "react";
import { Text } from "react-native";
import { Action, Eyebrow, Field, Masthead, Page, S } from "@/components/Editorial";
import { useJournal } from "@/context/JournalContext";
export default function EditProfile() {
  const { profile, updateProfile } = useJournal();
  const [name, setName] = useState(profile.name);
  const [handle, setHandle] = useState(profile.handle);
  const [city, setCity] = useState(profile.city);
  const [bio, setBio] = useState(profile.bio);
  const [interests, setInterests] = useState(profile.interests || "");
  const [areas, setAreas] = useState(profile.areas || "");
  return <Page><Masthead back /><Eyebrow>SENİN HİKÂYEN</Eyebrow><Text style={[S.title, { marginBottom: 27 }]}>Profili düzenle</Text>
    <Field label="ADIN" value={name} onChangeText={setName} placeholder="Nasıl hitap edelim?" />
    <Field label="KULLANICI ADI" value={handle} onChangeText={setHandle} placeholder="Bir takma ad seç" />
    <Field label="ŞEHRİN" value={city} onChangeText={setCity} placeholder="Nereden keşfediyorsun?" />
    <Field label="KISA BİYOGRAFİ" value={bio} onChangeText={setBio} placeholder="Lezzetle ilişkin nasıl başladı?" multiline />
    <Field label="İLGİ ALANLARIN" value={interests} onChangeText={setInterests} placeholder="Kahve, fırınlar, esnaf mutfağı..." />
    <Field label="SEVDİĞİN BÖLGELER" value={areas} onChangeText={setAreas} placeholder="Kadıköy, Karaköy..." />
    <Action onPress={() => { updateProfile({ name: name.trim(), handle: handle.trim().replace(/^@/, ""), city: city.trim(), bio: bio.trim(), interests: interests.trim(), areas: areas.trim() }); router.back(); }}>Profili kaydet</Action>
  </Page>;
}