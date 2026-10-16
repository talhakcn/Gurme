import React from "react";
import { Text } from "react-native";
import { Empty, Eyebrow, Masthead, Page, S } from "@/components/Editorial";
export default function Notifications() {
  return <Page><Masthead back /><Eyebrow>HABERLER</Eyebrow><Text style={S.title}>Bildirimler</Text><Empty title="Şimdilik sessizlik." detail="Topluluk bildirimleri henüz bağlı değil. Lezzet defterin ise her zaman seni bekliyor." /></Page>;
}