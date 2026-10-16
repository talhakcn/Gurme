import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'gurme_colors.dart';
import 'gurme_space.dart';

abstract final class GurmeFonts {
  static const display = 'Bodoni Moda';
  static const body = 'Plus Jakarta Sans';
}

/// Expo uygulamasındaki `components/Editorial.tsx` stillerinin karşılığı:
/// başlıklar Bodoni Moda, metinler Plus Jakarta Sans, köşesiz ve gölgesiz yüzeyler.
/// Rakamlar eşit genişlikte: puanlar, sayaçlar ve sıra numaraları kaymaz.
const _tabular = [FontFeature.tabularFigures()];

/// Gündüz ya da gece teması; renkler [GurmePalette]'ten gelir.
ThemeData buildGurmeTheme([Brightness brightness = Brightness.light]) {
  final p = brightness == Brightness.dark
      ? GurmePalette.dark
      : GurmePalette.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.ink,
    onPrimary: p.paper,
    secondary: p.gold,
    onSecondary: p.onGold,
    tertiary: p.tealText,
    onTertiary: p.paper,
    error: p.error,
    onError: p.paper,
    surface: p.paper,
    onSurface: p.ink,
    onSurfaceVariant: p.muted,
    surfaceContainerHighest: p.wash,
    outline: p.line,
    outlineVariant: p.line,
  );

  final textTheme = TextTheme(
    // Sayfanın tek büyük başlığı: Keşfet girişi, mekân adı, karne puanı.
    displayLarge: TextStyle(
      fontFeatures: _tabular,
      fontFamily: GurmeFonts.display,
      fontSize: 44,
      height: 48 / 44,
      color: p.ink,
    ),
    // S.title
    headlineLarge: TextStyle(
      fontFeatures: _tabular,
      fontFamily: GurmeFonts.display,
      fontSize: 37,
      height: 43 / 37,
      color: p.ink,
    ),
    // S.heading
    headlineMedium: TextStyle(
      fontFeatures: _tabular,
      fontFamily: GurmeFonts.display,
      fontSize: 29,
      height: 35 / 29,
      color: p.ink,
    ),
    // S.subhead
    headlineSmall: TextStyle(
      fontFeatures: _tabular,
      fontFamily: GurmeFonts.display,
      fontSize: 22,
      height: 28 / 22,
      color: p.ink,
    ),
    // Masthead "GURME"
    titleLarge: TextStyle(
      fontFamily: GurmeFonts.display,
      fontSize: 25,
      letterSpacing: 4.5,
      color: p.ink,
    ),
    // Alıntı ve özet: italik Bodoni.
    titleMedium: TextStyle(
      fontFeatures: _tabular,
      fontFamily: GurmeFonts.display,
      fontStyle: FontStyle.italic,
      fontSize: 18,
      height: 28 / 18,
      color: p.ink,
    ),
    // Metin alanlarına yazılan metin.
    bodyLarge: TextStyle(
      fontFeatures: _tabular,
      fontFamily: GurmeFonts.body,
      fontSize: 16,
      height: 24 / 16,
      color: p.ink,
    ),
    // S.body
    bodyMedium: TextStyle(
      fontFeatures: _tabular,
      fontFamily: GurmeFonts.body,
      fontSize: 14,
      height: 23 / 14,
      color: p.ink,
    ),
    // S.small
    bodySmall: TextStyle(
      fontFeatures: _tabular,
      fontFamily: GurmeFonts.body,
      // iOS dipnot boyutu (13); 12 yardımcı metin için küçük kalıyordu.
      fontSize: 13,
      height: 20 / 13,
      color: p.muted,
    ),
    // Küçük etiket (Eyebrow): cümle düzeninde, soluk; başlık değil, bilgi.
    labelSmall: TextStyle(
      fontFeatures: _tabular,
      fontFamily: GurmeFonts.body,
      fontWeight: FontWeight.w600,
      fontSize: 12,
      height: 18 / 12,
      color: p.muted,
    ),
    // Düğme ve bağlantı yazısı.
    labelLarge: TextStyle(
      fontFeatures: _tabular,
      fontFamily: GurmeFonts.body,
      fontWeight: FontWeight.w600,
      fontSize: 15,
      height: 20 / 15,
      color: p.ink,
    ),
  );

  return ThemeData(
    brightness: brightness,
    extensions: [p],
    colorScheme: scheme,
    scaffoldBackgroundColor: p.paper,
    // iOS'ta dokunuşta Material dalgası yok; seçimler titreşim ve renkle
    // belli olur.
    splashFactory: defaultTargetPlatform == TargetPlatform.iOS
        ? NoSplash.splashFactory
        : null,
    fontFamily: GurmeFonts.body,
    // apply(bodyColor: …) kullanılmıyor: bodySmall ve labelSmall'ın kendi
    // soluk rengini ezer.
    textTheme: textTheme,
    dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: p.paper,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      shape: Border(bottom: BorderSide(color: p.line)),
      titleTextStyle: TextStyle(
        fontFamily: GurmeFonts.display,
        fontSize: 25,
        letterSpacing: 4.5,
        color: p.ink,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.paper,
      indicatorColor: Colors.transparent,
      elevation: 0,
      height: 66,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: GurmeFonts.body,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: states.contains(WidgetState.selected) ? p.ink : p.muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 20,
          color: states.contains(WidgetState.selected) ? p.ink : p.muted,
        ),
      ),
    ),
    // Geniş ekranda yan menü: alt çubukla aynı dil; seçili sekme dolu
    // simge ve koyu yazı, vurgu zemini yok.
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: p.paper,
      indicatorColor: Colors.transparent,
      elevation: 0,
      minWidth: 88,
      selectedLabelTextStyle: TextStyle(
        fontFamily: GurmeFonts.body,
        fontWeight: FontWeight.w600,
        fontSize: 11,
        color: p.ink,
      ),
      unselectedLabelTextStyle: TextStyle(
        fontFamily: GurmeFonts.body,
        fontWeight: FontWeight.w600,
        fontSize: 11,
        color: p.muted,
      ),
      selectedIconTheme: IconThemeData(size: 20, color: p.ink),
      unselectedIconTheme: IconThemeData(size: 20, color: p.muted),
    ),
    // S.button: altın zemin, köşesiz.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.gold,
        foregroundColor: p.onGold,
        minimumSize: Size(0, 49),
        // Büyük yazıda düğme yazıyla birlikte uzar; yazı kenara yapışmaz.
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(),
        textStyle: TextStyle(
          fontFamily: GurmeFonts.body,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.ink,
        minimumSize: Size(0, 49),
        // Büyük yazıda düğme yazıyla birlikte uzar; yazı kenara yapışmaz.
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: BorderSide(color: p.control),
        shape: RoundedRectangleBorder(),
        textStyle: TextStyle(
          fontFamily: GurmeFonts.body,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    // Pencere ve tarih seçici: köşesiz, kâğıt zemin, perde paletten.
    dialogTheme: DialogThemeData(
      backgroundColor: p.paper,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(),
      barrierColor: p.scrim,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: p.paper,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(),
      headerBackgroundColor: p.paper,
      headerForegroundColor: p.ink,
      dividerColor: p.line,
      dayShape: WidgetStatePropertyAll(RoundedRectangleBorder()),
      todayBorder: BorderSide(color: p.ink),
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: p.ink),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: p.ink),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.paper,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: p.scrim,
      shape: RoundedRectangleBorder(),
      // Tutma çubuğu: aşağı çekilerek kapandığı belli olur (iOS alışkanlığı).
      showDragHandle: true,
      dragHandleColor: p.control,
      dragHandleSize: Size(36, 4),
    ),
    // İpucu baloncuğu bilgi çubuğuyla aynı: mürekkep zemin, köşesiz, gece
    // de koyu (Material'ın gri ya da beyaz baloncuğu tema dışıydı).
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: p.raised,
        border: Border(top: BorderSide(color: p.ink, width: 2)),
      ),
      textStyle: TextStyle(
        fontFamily: GurmeFonts.body,
        fontSize: 14,
        height: 20 / 14,
        color: p.onRaised,
      ),
      padding: EdgeInsets.symmetric(horizontal: Space.m, vertical: Space.s),
      margin: EdgeInsets.symmetric(horizontal: Space.l),
    ),
    // Alt bilgi çubuğu: mürekkep zemin, köşesiz; "Geri al" altın. Üstte
    // alttan açılan sayfalardaki gibi mürekkep çizgi: gece koyu yüzey
    // zemine karışmasın diye (gündüz zeminle aynı renkte, görünmez).
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.raised,
      actionTextColor: p.gold,
      shape: Border(top: BorderSide(color: p.ink, width: 2)),
      contentTextStyle: TextStyle(
        fontFamily: GurmeFonts.body,
        fontSize: 14,
        height: 20 / 14,
        color: p.onRaised,
      ),
    ),
    // S.input: yalnızca alt çizgi.
    inputDecorationTheme: InputDecorationTheme(
      border: UnderlineInputBorder(borderSide: BorderSide(color: p.control)),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: p.control),
      ),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: p.ink)),
    ),
  );
}
