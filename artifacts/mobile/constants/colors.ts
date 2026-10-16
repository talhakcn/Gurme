export const C = {
  paper: "#F2F0EF",
  ink: "#20373B",
  teal: "#519CAB",
  line: "#A9C8CC",
  gold: "#FFC64F",
  muted: "#687B7E",
  wash: "#E7E9E7",
  pale: "#F8F5EE",
};

export default {
  light: {
    text: C.ink, textSecondary: C.muted, textMuted: C.muted,
    background: C.paper, surface: C.paper, surfaceStrong: C.wash,
    card: C.paper, border: C.line, tint: C.ink, primary: C.ink,
    primaryDark: C.ink, accent: C.gold, dark: C.ink,
    tabIconDefault: C.muted, tabIconSelected: C.ink,
    success: C.teal, warning: C.gold, error: "#A74A3E",
    shadow: "transparent", overlay: "rgba(32,55,59,0.25)",
  },
};