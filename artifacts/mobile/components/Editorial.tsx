import { Feather } from "@expo/vector-icons";
import { router } from "expo-router";
import React from "react";
import { Image, Platform, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { C } from "@/constants/colors";
import type { Place } from "@/context/JournalContext";

export const F = { display: "BodoniModa_400Regular", italic: "BodoniModa_400Regular_Italic", body: "PlusJakartaSans_400Regular", medium: "PlusJakartaSans_600SemiBold" };
export const S = StyleSheet.create({
  page: { flex: 1, backgroundColor: C.paper },
  content: { paddingHorizontal: 20, paddingBottom: 120 },
  label: { fontFamily: F.medium, fontSize: 10, letterSpacing: 1.5, color: C.teal, textTransform: "uppercase", lineHeight: 16 },
  title: { fontFamily: F.display, fontSize: 37, lineHeight: 43, color: C.ink },
  heading: { fontFamily: F.display, fontSize: 29, lineHeight: 35, color: C.ink },
  subhead: { fontFamily: F.display, fontSize: 22, lineHeight: 28, color: C.ink },
  body: { fontFamily: F.body, fontSize: 14, lineHeight: 23, color: C.ink },
  small: { fontFamily: F.body, fontSize: 12, lineHeight: 19, color: C.muted },
  rule: { height: 1, backgroundColor: C.line, opacity: 0.75 },
  row: { flexDirection: "row", alignItems: "center", justifyContent: "space-between" },
  input: { fontFamily: F.body, color: C.ink, fontSize: 15, minHeight: 50, borderBottomWidth: 1, borderBottomColor: C.teal, paddingVertical: 10 },
  button: { minHeight: 49, backgroundColor: C.gold, alignItems: "center", justifyContent: "center", paddingHorizontal: 16, flexDirection: "row", gap: 8 },
  buttonText: { fontFamily: F.medium, fontSize: 11, letterSpacing: 1, color: C.ink, textTransform: "uppercase" },
});
export function Page({ children, scroll = true }: { children: React.ReactNode; scroll?: boolean }) {
  const insets = useSafeAreaInsets();
  const style = { paddingTop: Platform.OS === "web" ? Math.max(insets.top, 67) : insets.top };
  return <View style={[S.page, style]}>{scroll ? <ScrollView keyboardShouldPersistTaps="handled" contentContainerStyle={S.content} showsVerticalScrollIndicator={false}>{children}</ScrollView> : children}</View>;
}
export function Masthead({ back = false, right, onRight }: { back?: boolean; right?: keyof typeof Feather.glyphMap; onRight?: () => void }) {
  return <View style={{ marginHorizontal: -20, borderBottomWidth: 1, borderColor: C.line, height: 62, flexDirection: "row", alignItems: "center", justifyContent: "center", marginBottom: 24 }}>
    {back && <Pressable testID="back" onPress={() => router.back()} style={{ position: "absolute", left: 20, padding: 10 }}><Feather name="arrow-left" size={21} color={C.ink} /></Pressable>}
    <Text style={{ fontFamily: F.display, fontSize: 25, letterSpacing: 4.5, color: C.ink }}>GURME</Text>
    {right && <Pressable onPress={onRight} style={{ position: "absolute", right: 20, padding: 10 }}><Feather name={right} size={20} color={C.ink} /></Pressable>}
  </View>;
}
export function Eyebrow({ children }: { children: React.ReactNode }) { return <Text style={S.label}>{children}</Text>; }
export function Rule({ space = 22 }: { space?: number }) { return <View style={[S.rule, { marginVertical: space }]} />; }
export function Action({ children, onPress, secondary = false, icon }: { children: React.ReactNode; onPress: () => void; secondary?: boolean; icon?: keyof typeof Feather.glyphMap }) {
  return <Pressable testID="action" onPress={onPress} style={[S.button, secondary && { backgroundColor: "transparent", borderWidth: 1, borderColor: C.line }]}>
    {icon && <Feather name={icon} size={15} color={C.ink} />}<Text style={S.buttonText}>{children}</Text>
  </Pressable>;
}
export function Field({ label, value, onChangeText, placeholder, multiline = false }: { label: string; value: string; onChangeText: (v: string) => void; placeholder?: string; multiline?: boolean }) {
  return <View style={{ marginBottom: 23 }}><Eyebrow>{label}</Eyebrow><TextInput value={value} onChangeText={onChangeText} placeholder={placeholder} placeholderTextColor={C.muted} multiline={multiline} style={[S.input, multiline && { minHeight: 94, textAlignVertical: "top" }]} /></View>;
}
export function Empty({ title, detail, action, onPress }: { title: string; detail: string; action?: string; onPress?: () => void }) {
  return <View style={{ paddingVertical: 45, alignItems: "flex-start" }}><View style={{ width: 36, height: 2, backgroundColor: C.gold, marginBottom: 22 }} /><Text style={S.heading}>{title}</Text><Text style={[S.body, { color: C.muted, marginTop: 10, marginBottom: 25 }]}>{detail}</Text>{action && onPress && <Action onPress={onPress} icon="plus">{action}</Action>}</View>;
}
export function PlaceRow({ place, index, onPress }: { place: Place; index?: number; onPress?: () => void }) {
  return <Pressable onPress={onPress || (() => router.push(`/place/${place.id}`))} style={{ paddingVertical: 20, borderBottomWidth: 1, borderColor: C.line }}>
    <View style={{ flexDirection: "row", gap: 12 }}>
      <Text style={[S.subhead, { color: C.teal, fontSize: 22 }]}>{String(index ?? 1).padStart(2, "0")}</Text>
      <View style={{ flex: 1 }}><Text style={S.subhead}>{place.name}</Text><Text style={[S.label, { marginTop: 5 }]}>{place.district} · {place.city} · {place.category}</Text></View>
      <Feather name="arrow-up-right" size={18} color={C.ink} />
    </View>
    {!!place.image && <Image source={{ uri: place.image }} style={{ width: "100%", height: 205, marginTop: 15 }} resizeMode="cover" />}
    {!!place.description && <Text numberOfLines={2} style={[S.small, { marginTop: 11 }]}>{place.description}</Text>}
  </Pressable>;
}