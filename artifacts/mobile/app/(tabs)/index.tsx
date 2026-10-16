import { Feather } from "@expo/vector-icons";
import { useListGurmeLists } from "@workspace/api-client-react";
import { router } from "expo-router";
import React from "react";
import { Image, Pressable, Text, View } from "react-native";
import { Action, Empty, Eyebrow, F, Masthead, Page, PlaceRow, Rule, S } from "@/components/Editorial";
import { areaToLocation, listCollection } from "@/components/list-network";
import { C } from "@/constants/colors";
import { useJournal } from "@/context/JournalContext";

export default function Discover() {
  const { places, lists, visits, loaded, profile, savedRemoteLists, toggleRemoteSaved, addPlace } = useJournal();
  const discovery = useListGurmeLists();
  const remoteLists = listCollection(discovery.data);
  const region = profile.city.trim().toLocaleLowerCase("tr");
  const regionalLists = (remoteLists ?? []).filter(l => l.visibility === "public" && !!region && l.items.some(item => item.area.toLocaleLowerCase("tr").includes(region)));
  const featured = regionalLists[0];
  const featuredPlace = featured?.items.find(item => item.area.toLocaleLowerCase("tr").includes(region));
  const saveFeaturedPlace = () => {
    if (!featuredPlace) return;
    const existing = places.find(p => p.name.toLocaleLowerCase("tr") === featuredPlace.name.toLocaleLowerCase("tr") && [p.district, p.city].filter(Boolean).join(", ").toLocaleLowerCase("tr") === featuredPlace.area.toLocaleLowerCase("tr"));
    if (existing) { router.push(`/place/${existing.id}`); return; }
    const id = addPlace({ name: featuredPlace.name, ...areaToLocation(featuredPlace.area), category: featuredPlace.category || "Mekân", description: featuredPlace.note, status: "want" });
    router.push(`/place/${id}`);
  };
  return <Page><Masthead right="bell" onRight={() => router.push("/notifications")} />
    <View style={[S.row, { marginBottom: 17 }]}><Eyebrow>KİŞİSEL LEZZET DEFTERİ</Eyebrow><Eyebrow>{profile.city || "ŞEHRİNİ EKLE"}</Eyebrow></View>
    <Text style={[S.title, { fontSize: 43, lineHeight: 47 }]}>Şehrin tadı,<Text style={{ fontFamily: F.italic }}> senin hikâyen.</Text></Text>
    <Text style={[S.body, { marginTop: 14, color: C.muted }]}>Gittiğin yerleri kaydet. Dönmek istediklerini sakla. Kendi rotanı bir listeye dönüştür.</Text>
    <View style={{ marginTop: 25 }}><Action icon="search" onPress={() => router.push("/search")}>Mekân, liste veya kişi ara</Action></View>
    <View style={{ flexDirection: "row", gap: 8, marginTop: 8 }}><View style={{ flex: 1 }}><Action secondary icon="bookmark" onPress={() => router.push("/history")}>Mekânlarım</Action></View><View style={{ flex: 1 }}><Action secondary icon="list" onPress={() => router.push("/lists?tab=saved")}>Kaydettiklerim</Action></View></View>
    <Rule space={31} />
    <View style={S.row}><Eyebrow>DEFTERDEN</Eyebrow><Text style={S.small}>{places.length} mekân · {visits.length} deneyim</Text></View>
    {!loaded ? <Text style={[S.small, { paddingVertical: 36 }]}>Defter açılıyor…</Text> : places.length === 0 ?
      <Empty title="Henüz boş bir sayfa." detail="Saklamaya değer ilk adresinle başla. Bu defter yalnızca sana ait." action="Mekân ekle" onPress={() => router.push("/place/edit")} /> :
      places.slice(0, 3).map((p, i) => <PlaceRow key={p.id} place={p} index={i + 1} />)}
    <Rule space={31} />
    <View style={S.row}><Eyebrow>ROTALARIN</Eyebrow><Pressable onPress={() => router.push("/lists")}><Feather name="arrow-up-right" size={20} color={C.ink} /></Pressable></View>
    {lists.length ? lists.slice(0, 2).map(l => <Pressable key={l.id} onPress={() => router.push(`/list/${l.id}`)} style={{ borderBottomWidth: 1, borderColor: C.line, paddingVertical: 20 }}><Text style={S.heading}>{l.title}</Text><Text style={S.small}>{l.city} · {l.items.length} mekân</Text></Pressable>) :
      <View style={{ paddingVertical: 25 }}><Text style={S.subhead}>Bir rota, birçok hatıra.</Text><Text style={[S.small, { marginVertical: 9 }]}>Sevdiğin mekânları bir araya getirip kendi rehberini yaz.</Text><Pressable onPress={() => router.push("/list/edit")}><Text style={[S.label, { color: C.ink }]}>+ İLK LİSTENİ OLUŞTUR</Text></Pressable></View>}
    <Rule space={30} /><View style={S.row}><Eyebrow>{profile.city ? `${profile.city} · AÇIK ROTALAR` : "BÖLGESEL KEŞİF"}</Eyebrow><Pressable onPress={() => router.push("/lists?tab=discover")}><Feather name="arrow-up-right" size={19} color={C.ink} /></Pressable></View>
    {!profile.city ? <View style={{ paddingTop: 16 }}><Text style={S.small}>Bölgen için kullanıcıların yayımladığı listeleri görmek istersen profilinde şehir seç.</Text><Pressable onPress={() => router.push("/profile/edit")} style={{ paddingVertical: 15 }}><Text style={[S.label, { color: C.ink }]}>ŞEHRİMİ EKLE →</Text></Pressable></View> :
      discovery.isPending ? <View style={{ height: 78, backgroundColor: C.wash, marginTop: 17 }} /> :
      (discovery.isError || remoteLists === null) ? <View style={{ paddingTop: 16 }}><Text style={S.small}>Açık listeler yüklenemedi.</Text><Pressable onPress={() => discovery.refetch()} style={{ paddingVertical: 12 }}><Text style={[S.label, { color: C.ink }]}>YENİDEN DENE →</Text></Pressable></View> :
      !featured ? <Text style={[S.small, { marginTop: 16 }]}>Bu şehir için henüz yayımlanmış liste yok. Başka bölgelerin açık rotalarını keşfedebilirsin.</Text> :
      <View style={{ paddingTop: 19 }}><Pressable onPress={() => router.push(`/shared/${featured.id}`)}><Eyebrow>{featured.authorName} · HERKESE AÇIK LİSTE</Eyebrow><Text style={[S.heading, { marginTop: 7 }]}>{featured.title}</Text><Text style={[S.small, { marginTop: 8 }]}>Neden gösteriliyor? Listedeki bir mekân, profilindeki {profile.city} bölgesiyle eşleşiyor.</Text></Pressable>
        <View style={{ marginTop: 15 }}><Action secondary icon={savedRemoteLists.some(l => l.id === featured.id) ? "check" : "bookmark"} onPress={() => toggleRemoteSaved(featured)}>{savedRemoteLists.some(l => l.id === featured.id) ? "Kaydı kaldır" : "Listeyi kaydet"}</Action></View>
        {!!featuredPlace && <View style={{ borderTopWidth: 1, borderColor: C.line, marginTop: 21, paddingTop: 16 }}><Eyebrow>BU LİSTEDEN BİR DURAK</Eyebrow><Text style={[S.subhead, { marginTop: 5 }]}>{featuredPlace.name}</Text><Text style={S.small}>{featuredPlace.area} · {featuredPlace.category}</Text><Pressable onPress={saveFeaturedPlace} style={{ paddingVertical: 13 }}><Text style={[S.label, { color: C.ink }]}>+ MEKÂNI GİDECEKLERİME EKLE →</Text></Pressable></View>}
      </View>}
    <Rule space={32} /><Eyebrow>GURME NOTU · ÖRNEK EDİTORYAL İÇERİK</Eyebrow>
    <Text style={[S.heading, { marginTop: 11 }]}>İyi bir kahvenin peşinde</Text>
    <Image source={require("../../assets/images/coffee-editorial.png")} style={{ width: "100%", height: 240, marginTop: 16 }} resizeMode="cover" />
    <Text style={[S.body, { marginTop: 15 }]}>Bir şehri bazen en iyi, sabahın ilk fincanında tanırsın. Kendi keşiflerini ekle; bu sayfa senin hikâyenle dolsun.</Text>
  </Page>;
}