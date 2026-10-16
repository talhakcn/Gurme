import 'package:flutter/material.dart';

import '../../core/theme/gurme_colors.dart';
import '../../core/theme/gurme_theme.dart';
import '../lists/screens/list_cover_screen.dart';

/// Paylaşılan görsellerin ortak yazı stilleri; renk kapağın stilinden gelir.
class CoverText {
  const CoverText(this.style);

  final CoverStyle style;

  Color get fg => style.foreground;

  TextStyle display(double size, {bool italic = false}) => TextStyle(
    fontFamily: GurmeFonts.display,
    fontSize: size,
    height: 1.05,
    color: fg,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
  );

  TextStyle label(double size, {FontWeight weight = FontWeight.w600}) =>
      TextStyle(
        fontFamily: GurmeFonts.body,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: 0.2,
        color: fg,
      );

  /// Bölüm başlığı: küçük, cümle düzeninde.
  Widget heading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: label(10)),
  );

  /// Başlığın üstündeki kısa altın çizgi; altın zeminde mürekkep.
  Widget rule() => Container(
    width: 44,
    height: 2,
    color: style == CoverStyle.gold ? GurmeColors.ink : GurmeColors.gold,
  );

  /// Yazı renginin tonu (grafik dilimleri ve ikincil çubuklar).
  Color shade(double alpha) => fg.withValues(alpha: alpha);
}

/// Hikâye boyutunda (1080×1920) kapağın çerçevesi: zemin, üstte "GURME"
/// ve ne olduğu, ortada içerik, altta paylaşanın adı. İçerik bölümleri
/// sayfaya eşit aralıkla dağılır. Yazılar sistem yazı boyutuyla büyümez.
class CoverFrame extends StatelessWidget {
  const CoverFrame({
    super.key,
    required this.style,
    required this.tag,
    required this.author,
    required this.children,
    this.page,
  });

  final CoverStyle style;

  /// Sağ üstteki tanım: "Ayın özeti", "Yılın özeti".
  final String tag;
  final String author;
  final List<Widget> children;

  /// Çok sayfalı sette "2 / 7"; tek sayfada `null`.
  final String? page;

  @override
  Widget build(BuildContext context) {
    final t = CoverText(style);
    return MediaQuery.withNoTextScaling(
      child: SizedBox.fromSize(
        size: coverSize,
        child: Material(
          color: style.ground,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 34, 30, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GURME',
                      style: t.display(20).copyWith(letterSpacing: 4),
                    ),
                    Text(
                      page == null ? tag : '$tag · $page',
                      style: t.label(10),
                    ),
                  ],
                ),
                ...children,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        author.isEmpty ? 'Gurme defteri' : author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.label(10, weight: FontWeight.w400),
                      ),
                    ),
                    Text(
                      'Gurme uygulamasında',
                      style: t.label(9).copyWith(letterSpacing: 0.4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Üstü çizgili satırlar (semtler, mekânlar): ad solda, sayı sağda.
class CoverRows extends StatelessWidget {
  const CoverRows({
    super.key,
    required this.style,
    required this.rows,
    this.size = 19,
    this.leading,
  });

  final CoverStyle style;
  final List<(String, String)> rows;
  final double size;

  /// Satırın başındaki sıra numarası rengi; `null` ise numara yok.
  final Color? leading;

  @override
  Widget build(BuildContext context) {
    final t = CoverText(style);
    return Column(
      children: [
        for (final (i, (name, value)) in rows.indexed)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: t.fg),
                bottom: i == rows.length - 1
                    ? BorderSide(color: t.fg)
                    : BorderSide.none,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (leading != null) ...[
                  Text(
                    '${i + 1}',
                    style: t.display(size).copyWith(color: leading),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.display(size),
                  ),
                ),
                const SizedBox(width: 8),
                Text(value, style: t.label(10, weight: FontWeight.w400)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Türlerin dağılımı: dilimli çubuk ve altında oranlar.
class CoverMix extends StatelessWidget {
  const CoverMix({super.key, required this.style, required this.parts});

  final CoverStyle style;
  final List<(String, int)> parts;

  static const _shades = [1.0, 0.6, 0.35, 0.18];

  @override
  Widget build(BuildContext context) {
    final t = CoverText(style);
    final total = parts.fold(0, (sum, c) => sum + c.$2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 12,
          child: Row(
            children: [
              for (final (i, (_, n)) in parts.indexed)
                Expanded(
                  flex: n,
                  child: Container(
                    color: t.shade(_shades[i.clamp(0, _shades.length - 1)]),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          // Çubuk bütünü gösterir; "Diğer" yazıda sıralanmaz.
          [
            for (final (name, n) in parts)
              if (name != 'Diğer') '$name %${(n * 100 / total).round()}',
          ].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: t.label(10, weight: FontWeight.w400),
        ),
      ],
    );
  }
}

/// Başlık, büyük ad ve küçük açıklamadan oluşan seçim (ayın mekânı).
class CoverPick extends StatelessWidget {
  const CoverPick({
    super.key,
    required this.style,
    required this.heading,
    required this.title,
    required this.detail,
    this.italic = false,
    this.size = 20,
  });

  final CoverStyle style;
  final String heading;
  final String title;
  final String detail;
  final bool italic;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = CoverText(style);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: t.label(10)),
        const SizedBox(height: 6),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: t.display(size, italic: italic),
        ),
        if (detail.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.label(10, weight: FontWeight.w400),
          ),
        ],
      ],
    );
  }
}
