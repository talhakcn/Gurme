import 'package:flutter/material.dart';

/// Gündüz paleti; Expo uygulamasındaki `constants/colors.ts` karşılığı.
///
/// Ekranlar renkleri bu sabitlerden değil, temaya göre değişen
/// `context.colors` paletinden alır. Bu sabitler yalnızca her zaman gündüz
/// renginde kalan yerler içindir: tema tanımı ve paylaşılan görseller
/// (liste kapağı, yıl özeti).
///
/// Metinde [tealText] ve [muted] kullanılır; ikisi de kâğıt zeminde WCAG AA
/// eşiğini (4,5:1) geçer. [teal] (2,8:1) yalnızca çizgi ve yüzeyler içindir.
abstract final class GurmeColors {
  static const paper = Color(0xFFF2F0EF);
  static const ink = Color(0xFF20373B);
  static const teal = Color(0xFF519CAB);

  /// Turkuaz metin ve simgeler, 4,7:1.
  static const tealText = Color(0xFF2F7482);
  static const line = Color(0xFFA9C8CC);
  static const gold = Color(0xFFFFC64F);

  /// İkincil metin, 5,1:1.
  static const muted = Color(0xFF57696C);
  static const wash = Color(0xFFE7E9E7);
  static const pale = Color(0xFFF8F5EE);
  static const error = Color(0xFFA74A3E);
}

/// Temaya göre değişen palet. Adlar gündüz ve gecede aynı rolü taşır:
/// [paper] zemin, [ink] yazı, [onGold] altın zemin üstündeki yazı.
@immutable
class GurmePalette extends ThemeExtension<GurmePalette> {
  const GurmePalette({
    required this.paper,
    required this.ink,
    required this.teal,
    required this.tealText,
    required this.line,
    required this.gold,
    required this.onGold,
    required this.muted,
    required this.wash,
    required this.pale,
    required this.error,
    required this.raised,
    required this.scrim,
    required this.control,
    required this.onRaised,
    required this.chosen,
    required this.mark,
  });

  final Color paper;
  final Color ink;
  final Color teal;
  final Color tealText;
  final Color line;
  final Color gold;

  /// Altın zemin üstündeki yazı; iki temada da koyu.
  final Color onGold;
  final Color muted;
  final Color wash;
  final Color pale;
  final Color error;

  /// Bilgi çubuğu gibi zeminden ayrılan yüzeyler.
  final Color raised;

  /// Alttan açılan sayfa ve pencerelerin arkasındaki perde; sayfayı her
  /// iki temada da karartır.
  final Color scrim;

  /// Seçenek kutusu, ikincil düğme, metin alanı çizgisi ve boş karne
  /// karesi kenarı: zeminde en az 3:1 (WCAG 1.4.11). [line] yalnızca
  /// ayırıcı çizgiler içindir.
  final Color control;

  /// [raised] zemin üstündeki yazı (bilgi çubuğu, kaydırma arka planı).
  final Color onRaised;

  /// Seçili seçenek kutusunun zemini. Gece koyu turkuaz: krem ya da açık
  /// turkuaz, ekrandaki tek altın ana eylemle parlaklık yarışırdı.
  final Color chosen;

  /// Dolu puan karesi (karne, tabak geneli, lezzet izi). Gece turkuaz:
  /// krem dolgu geniş, parlak bloklara dönüşüyordu.
  final Color mark;

  static const light = GurmePalette(
    paper: GurmeColors.paper,
    ink: GurmeColors.ink,
    teal: GurmeColors.teal,
    tealText: GurmeColors.tealText,
    line: GurmeColors.line,
    gold: GurmeColors.gold,
    onGold: GurmeColors.ink,
    muted: GurmeColors.muted,
    wash: GurmeColors.wash,
    pale: GurmeColors.pale,
    error: GurmeColors.error,
    raised: GurmeColors.ink,
    scrim: Color(0x4020373B),
    control: Color(0xFF688A8F),
    onRaised: GurmeColors.paper,
    chosen: GurmeColors.ink,
    mark: GurmeColors.ink,
  );

  /// Gece: koyu mürekkep kâğıt, açık yazı. Kontrastlar gece kâğıdı
  /// (#152024) üstünde: ink 13,5, muted 7,2, tealText 8,1, error 6,6.
  static const dark = GurmePalette(
    paper: Color(0xFF152024),
    ink: Color(0xFFECE7E1),
    teal: GurmeColors.teal,
    tealText: Color(0xFF7CC0CD),
    // Ayırıcı çizgi gece zemininde 3,2:1; bölümler seçilir.
    line: Color(0xFF56707A),
    gold: GurmeColors.gold,
    onGold: GurmeColors.ink,
    muted: Color(0xFF9BAEB1),
    wash: Color(0xFF213036),
    pale: Color(0xFF1B282C),
    error: Color(0xFFE58C7E),
    raised: Color(0xFF2A3B40),
    scrim: Color(0x99000000),
    control: Color(0xFF6A8489),
    onRaised: Color(0xFFECE7E1),
    // Puan kareleriyle aynı turkuaz: gece tek bir "seçili" rengi. Zeminden
    // 5,3:1 ayrılır; üstündeki yazı koyu kâğıt rengi (5,3:1).
    chosen: GurmeColors.teal,
    mark: GurmeColors.teal,
  );

  @override
  GurmePalette copyWith() => this;

  @override
  GurmePalette lerp(GurmePalette? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

extension GurmePaletteOf on BuildContext {
  /// Geçerli temanın paleti.
  GurmePalette get colors =>
      Theme.of(this).extension<GurmePalette>() ?? GurmePalette.light;
}
