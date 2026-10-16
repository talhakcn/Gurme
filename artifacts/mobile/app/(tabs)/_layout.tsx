import { Feather } from "@expo/vector-icons";
import { isLiquidGlassAvailable } from "expo-glass-effect";
import { Tabs } from "expo-router";
import { NativeTabs } from "expo-router/unstable-native-tabs";
import React from "react";
import { Platform } from "react-native";
import { C } from "@/constants/colors";

const items = [
  { name: "index", title: "Keşfet", sf: "safari", icon: "compass" },
  { name: "search", title: "Arama", sf: "magnifyingglass", icon: "search" },
  { name: "history", title: "Arşivim", sf: "square.stack", icon: "bookmark" },
  { name: "lists", title: "Listelerim", sf: "list.bullet.rectangle", icon: "list" },
  { name: "profile", title: "Profil", sf: "person.crop.circle", icon: "user" },
] as const;
export default function TabLayout() {
  if (isLiquidGlassAvailable()) return <NativeTabs tintColor={C.ink}>
    {items.map(i => <NativeTabs.Trigger key={i.name} name={i.name}><NativeTabs.Trigger.Icon sf={{ default: i.sf, selected: i.sf }} /><NativeTabs.Trigger.Label>{i.title}</NativeTabs.Trigger.Label></NativeTabs.Trigger>)}
  </NativeTabs>;
  return <Tabs screenOptions={{ headerShown: false, tabBarActiveTintColor: C.ink, tabBarInactiveTintColor: C.muted, tabBarStyle: { backgroundColor: C.paper, borderTopColor: C.line, borderTopWidth: 1, elevation: 0, height: Platform.OS === "web" ? 84 : 66, paddingTop: 8 }, tabBarLabelStyle: { fontSize: 10, fontFamily: "PlusJakartaSans_600SemiBold" } }}>
    {items.map(i => <Tabs.Screen key={i.name} name={i.name} options={{ title: i.title, tabBarIcon: ({ color }) => <Feather name={i.icon} size={20} color={color} /> }} />)}
  </Tabs>;
}