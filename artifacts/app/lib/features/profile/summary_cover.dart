import 'package:flutter/material.dart';

import '../../core/text/turkish.dart';
import '../journal/data/journal_models.dart';
import '../lists/screens/list_cover_screen.dart';
import 'cover_kit.dart';
import 'year_summary.dart';

/// Dönem cümlesi: "Bu ay 6 mekâna gittim, 9 deneyim yazdım." Görseli
/// paylaşan kendi dönemini anlattığı için birinci tekil kişiyle yazılır;
/// sıfır olan sayı yazılmaz.
String periodSentence(YearSummary s) {
  final parts = [
    if (s.visitedPlaces > 0) '${s.visitedPlaces} mekâna gittim',
    if (s.places > s.visitedPlaces)
      '${s.places - s.visitedPlaces} yeni yeri deftere ekledim',
    if (s.visits > 0) '${s.visits} deneyim yazdım',
    if (s.lists > 0) '${s.lists} liste oluşturdum',
  ];
  if (parts.isEmpty) return '';
  return '${s.isMonth ? 'Bu ay' : 'Bu yıl'} ${joinTr(parts)}.';
}

/// Bir dönemin (ayın ya da yılın) tek sayfalık paylaşım görseli: liste
/// kapağıyla aynı dil ve boyut ([coverSize], 1080×1920 piksel).
class SummaryCover extends StatelessWidget {
  const SummaryCover({
    super.key,
    required this.summary,
    required this.author,
    required this.style,
  });

  final YearSummary summary;
  final String author;
  final CoverStyle style;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final t = CoverText(style);
    final sentence = periodSentence(s);
    // "Diğer" bir semt değil; kapakta yalnızca adı olan semtler sıralanır.
    final districts = s.topDistricts.take(3).toList();
    final favorite = s.favorite;
    final dish = s.dish;
    final unit = s.isMonth ? 'Ayın' : 'Yılın';

    return CoverFrame(
      style: style,
      tag: '$unit özeti',
      author: author,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            t.rule(),
            const SizedBox(height: 14),
            if (s.isMonth) ...[
              Text('${s.year}', style: t.label(12)),
              const SizedBox(height: 4),
              Text(monthNameTr(s.month!), maxLines: 1, style: t.display(72)),
            ] else
              Text('${s.year}', style: t.display(84)),
            Text('defterimden', style: t.display(30, italic: true)),
            if (sentence.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                sentence,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: t.display(19).copyWith(height: 1.35),
              ),
            ],
          ],
        ),
        if (districts.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              t.heading(
                districts.length == 1
                    ? 'En çok döndüğüm semt'
                    : 'En çok döndüğüm semtler',
              ),
              CoverRows(
                style: style,
                rows: [for (final (name, n) in districts) (name, '$n deneyim')],
              ),
            ],
          ),
        // Tek türün "%100" çubuğu bir şey söylemez.
        if (s.categories.length > 1)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              t.heading('Defterimin karakteri'),
              CoverMix(style: style, parts: s.categories),
            ],
          ),
        if (favorite != null || dish != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (favorite != null)
                Expanded(
                  child: CoverPick(
                    style: style,
                    heading: '$unit mekânı',
                    title: favorite.name,
                    detail: s.favoriteVisits > 0
                        ? '${s.favoriteVisits} deneyim'
                        : 'Önerdiğim mekân',
                  ),
                ),
              if (favorite != null && dish != null) const SizedBox(width: 18),
              if (dish != null)
                Expanded(
                  child: CoverPick(
                    style: style,
                    heading: '$unit tabağı',
                    title: dish.name,
                    italic: true,
                    // Puan önde: uzun mekân adı alta kayarsa puan satır
                    // başında kalır.
                    detail: [
                      if (dish.score case final score?)
                        '${formatScore(score)} / 5',
                      ?s.dishPlace?.name,
                    ].join(' · '),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
