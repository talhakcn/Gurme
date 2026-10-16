import { BodoniModa_400Regular, BodoniModa_400Regular_Italic, useFonts as useBodoni } from "@expo-google-fonts/bodoni-moda";
import { PlusJakartaSans_400Regular, PlusJakartaSans_600SemiBold, useFonts as useJakarta } from "@expo-google-fonts/plus-jakarta-sans";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { setBaseUrl } from "@workspace/api-client-react";
import { Stack } from "expo-router";
import * as SplashScreen from "expo-splash-screen";
import React, { useEffect } from "react";
import { Platform } from "react-native";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { JournalProvider } from "@/context/JournalContext";
import { C } from "@/constants/colors";

const apiDomain = process.env.EXPO_PUBLIC_DOMAIN;
setBaseUrl(apiDomain ? `https://${apiDomain}` : Platform.OS === "web" && typeof window !== "undefined" ? window.location.origin : "");
const queryClient = new QueryClient();
SplashScreen.preventAutoHideAsync();
export default function RootLayout() {
  const [a, ea] = useBodoni({ BodoniModa_400Regular, BodoniModa_400Regular_Italic });
  const [b, eb] = useJakarta({ PlusJakartaSans_400Regular, PlusJakartaSans_600SemiBold });
  useEffect(() => { if ((a || ea) && (b || eb)) SplashScreen.hideAsync(); }, [a, ea, b, eb]);
  if (!(a || ea) || !(b || eb)) return null;
  return <SafeAreaProvider><QueryClientProvider client={queryClient}><GestureHandlerRootView style={{ flex: 1 }}><JournalProvider>
    <Stack screenOptions={{ headerShown: false, contentStyle: { backgroundColor: C.paper }, animation: "slide_from_right" }}>
      <Stack.Screen name="(tabs)" />
    </Stack>
  </JournalProvider></GestureHandlerRootView></QueryClientProvider></SafeAreaProvider>;
}