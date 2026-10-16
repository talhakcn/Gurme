import 'package:flutter/material.dart';

import '../../core/text/turkish.dart';
import '../journal/data/journal_models.dart';
import '../lists/screens/list_cover_screen.dart';
import 'cover_kit.dart';
import 'year_summary.dart';

/// Yılın çok sayfalı paylaşım seti: her sayfa hikâye boyutunda (1080×1920)
/// ayrı bir görsel. Verisi olmayan sayfa sete girmez (tabak puanlanmadıysa
/// "Yılın tabakları" yok). Sayfalar sırayla ya da tek tek paylaşılır.
List<Widget> yearStoryPages({
  required YearSummary summary,
  required String author,
  required CoverStyle style,
}) {
  final s = summary;
  final builders = <Widget Function(String page)>[
    (page) => _Opening(s, author, style, page),
    if (s.visits > 0 || s.places > 0)
      (page) => _Numbers(s, author, style, page),
    if (s.visits > 0) (page) => _Months(s, author, style, page),
    if (s.topDistricts.isNotEmpty) (page) => _Districts(s, author, style, page),
    if (s.categories.isNotEmpty) (page) => _Character(s, author, style, page),
    if (s.topPlaces.isNotEmpty) (page) => _Places(s, author, style, page),
    if (s.topDishes.isNotEmpty) (page) => _Dishes(s, author, style, page),
    if (_Recap.hasContent(s)) (page) => _Recap(s, author, style, page),
  ];
  return [
    for (final (i, build) in builders.indexed)
      build('${i + 1} / ${builders.length}'),
  ];
}

/// Sayfanın başlığı: altın çizgi, büyük başlık, isteğe bağlı açıklama.
Widget _title(CoverText t, String title, [String? lead]) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    t.rule(),
    const SizedBox(height: 14),
    Text(title, maxLines: 2, style: t.display(44)),
    if (lead != null && lead.isNotEmpty) ...[
      const SizedBox(height: 14),
      Text(
        lead,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: t.display(19).copyWith(height: 1.35),
      ),
    ],
  ],
);

class _Opening extends StatelessWidget {
  const _Opening(this.s, this.author, this.style, this.page);

  final YearSummary s;
  final String author;
  final CoverStyle style;
  final String page;

  @override
  Widget build(BuildContext context) {
    final t = CoverText(style);
    return CoverFrame(
      style: style,
      tag: 'Yılın özeti',
      author: author,
      page: page,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            t.rule(),
            const SizedBox(height: 18),
            Text('${s.year}', style: t.display(112)),
            Text('defterimden', style: t.display(40, italic: true)),
          ],
        ),
      ],
    );
  }
}

class _Numbers extends StatelessWidget {
  const _Numbers(this.s, this.author, this.style, this.page);

  final YearSummary s;
  final String author;
  final CoverStyle style;
  final String page;

  @override
  Widget build(BuildContext context) {
    final t = CoverText(style);
    // Tablo değil, cümleler: sayı cümlenin içinde, büyük yazılır
    // ("31 mekâna gittim.").
    final lines = [
      if (s.visitedPlaces > 0) (s.visitedPlaces, 'mekâna gittim.'),
      if (s.visits > 0) (s.visits, 'deneyim yazdım.'),
      if (s.places > s.visitedPlaces)
        (s.places - s.visitedPlaces, 'yeni yeri deftere ekledim.'),
      if (s.recommended > 0) (s.recommended, 'mekânı önerdim.'),
      if (s.lists > 0) (s.lists, 'liste oluşturdum.'),
    ];
    return CoverFrame(
      style: style,
      tag: 'Yılın özeti',
      author: author,
      page: page,
      children: [
        _title(t, 'Bu yıl'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (n, rest) in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '$n ', style: t.display(40)),
                      TextSpan(text: rest, style: t.display(24)),
                    ],
                  ),
                  maxLines: 2,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Months extends StatelessWidget {
  const _Months(this.s, this.author, this.style, this.page);

  final YearSummary s;
  final String author;
  final CoverStyle style;
  final String page;

  @override
  Widget build(BuildContext context) {
    final t = CoverText(style);
    final counts = s.monthlyVisits;
    final busiest = s.busiestMonth;
    final top = counts.fold(0, (a, b) => a > b ? a : b);
    final active = counts.where((n) => n > 0).length;
    final lead = busiest == null
        ? null
        : 'En yoğun ayım ${monthNameTr(busiest)}: '
              '${counts[busiest - 1]} deneyim. '
              '${active == 1 ? 'Bütün deneyimlerim tek ayda.' : '$active ayda deftere yazdım.'}';
    const barArea = 230.0;
    return CoverFrame(
      style: style,
      tag: 'Yılın özeti',
      author: author,
      page: page,
      children: [
        _title(t, 'Ay ay', lead),
        SizedBox(
          height: barArea + 44,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (i, n) in counts.indexed) ...[
                if (i > 0) const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (n > 0)
                        Text(
                          '$n',
                          maxLines: 1,
                          style: t.label(9, weight: FontWeight.w400),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        height: top == 0
                            ? 0
                            : (n / top * barArea).clamp(
                                n > 0 ? 3.0 : 1.0,
                                barArea,
                              ),
                        color: i + 1 == busiest
                            ? style.accent
                            : n == 0
                            ? t.shade(0.25)
                            : t.shade(0.7),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        monthShortTr(i + 1),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: t.label(8, weight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Districts extends StatelessWidget {
  const _Districts(this.s, this.author, this.style, this.page);

  final YearSummary s;
  final String author;
  final CoverStyle style;
  final String page;

  @override
  Widget build(BuildContext context) {
    final t = CoverText(style);
    final one = s.topDistricts.length == 1;
    return CoverFrame(
      style: style,
      tag: 'Yılın özeti',
      author: author,
      page: page,
      children: [
        _title(
          t,
          one ? 'Semtim' : 'Semtlerim',
          one
              ? 'Bu yılki deneyimlerimin hepsi ${s.topDistricts.single.$1} semtinde.'
              : 'En çok döndüğüm semtler, yazdığım deneyim sayısına göre.',
        ),
        CoverRows(
          style: style,
          size: 22,
          leading: style.accent,
          rows: [for (final (name, n) in s.topDistricts) (name, '$n deneyim')],
        ),
      ],
    );
  }
}

class _Character extends StatelessWidget {
  const _Character(this.s, this.author, this.style, this.page);

  final YearSummary s;
  final String author;
  final CoverStyle style;
  final String page;

  @override
  Widget build(BuildContext context) {
    final t = CoverText(style);
    final total = s.categories.fold(0, (sum, c) => sum + c.$2);
    final first = s.categories.first;
    final lead = s.categories.length == 1
        ? 'Bu yılki bütün deneyimlerim ${toLowerTr(first.$1)} üzerine.'
        : 'Deneyimlerimin %${(first.$2 * 100 / total).round()} kadarı '
              '${toLowerTr(first.$1)} üzerine.';
    return CoverFrame(
      style: style,
      tag: 'Yılın özeti',
      author: author,
      page: page,
      children: [
        _title(t, 'Defterimin karakteri', lead),
        Column(
          children: [
            // "Diğer" bir tür değil; oranlar bütün deneyimlere göre.
            for (final (i, (name, n)) in s.categories.indexed)
              if (name != 'Diğer')
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.display(20),
                            ),
                          ),
                          Text(
                            '%${(n * 100 / total).round()}',
                            style: t.label(11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(height: 10, color: t.shade(0.18)),
                      Transform.translate(
                        offset: const Offset(0, -10),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (n / total).clamp(0.02, 1.0),
                          child: Container(
                            height: 10,
                            color: i == 0 ? style.accent : t.shade(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ],
    );
  }
}

class _Places extends StatelessWidget {
  const _Places(this.s, this.author, this.style, this.page);

  final YearSummary s;
  final String author;
  final CoverStyle style;
  final String page;

  @override
  Widget build(BuildContext context) {
    final t = CoverText(style);
    final favorite = s.favorite;
    return CoverFrame(
      style: style,
      tag: 'Yılın özeti',
      author: author,
      page: page,
      children: [
        _title(
          t,
          'En çok gittiklerim',
          favorite == null
              ? null
              : 'Önerdiklerimden en çok gittiğim: ${favorite.name}.',
        ),
        CoverRows(
          style: style,
          size: 21,
          leading: style.accent,
          rows: [
            for (final (place, n) in s.topPlaces) (place.name, '$n deneyim'),
          ],
        ),
      ],
    );
  }
}

class _Dishes extends StatelessWidget {
  const _Dishes(this.s, this.author, this.style, this.page);

  final YearSummary s;
  final String author;
  final CoverStyle style;
  final String page;

  @override
  Widget build(BuildContext context) {
    final t = CoverText(style);
    return CoverFrame(
      style: style,
      tag: 'Yılın özeti',
      author: author,
      page: page,
      children: [
        _title(
          t,
          s.topDishes.length == 1 ? 'Yılın tabağı' : 'Yılın tabakları',
          'Bu yıl tattıklarım içinde en yüksek puan verdiklerim.',
        ),
        Column(
          children: [
            for (final (i, dish) in s.topDishes.indexed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: t.fg),
                    bottom: i == s.topDishes.length - 1
                        ? BorderSide(color: t.fg)
                        : BorderSide.none,
                  ),
                ),
                child: CoverPick(
                  style: style,
                  heading: [
                    if (dish.score case final score?)
                      '${formatScore(score)} / 5',
                    if (dish.times > 1) '${dish.times} kez tattım',
                  ].join(' · '),
                  title: dish.name,
                  italic: true,
                  size: 24,
                  detail: s.placeName(dish.placeId) ?? '',
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Son sayfa: yılın kısa özeti, dört seçimle.
class _Recap extends StatelessWidget {
  const _Recap(this.s, this.author, this.style, this.page);

  final YearSummary s;
  final String author;
  final CoverStyle style;
  final String page;

  static bool hasContent(YearSummary s) =>
      s.favorite != null ||
      s.dish != null ||
      s.busiestMonth != null ||
      s.topDistricts.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final t = CoverText(style);
    final favorite = s.favorite;
    final dish = s.dish;
    final busiest = s.busiestMonth;
    final picks = [
      if (favorite != null)
        CoverPick(
          style: style,
          heading: 'Yılın mekânı',
          title: favorite.name,
          detail: s.favoriteVisits > 0 ? '${s.favoriteVisits} deneyim' : '',
        ),
      if (dish != null)
        CoverPick(
          style: style,
          heading: 'Yılın tabağı',
          title: dish.name,
          italic: true,
          detail: [
            if (dish.score case final score?) '${formatScore(score)} / 5',
            ?s.dishPlace?.name,
          ].join(' · '),
        ),
      if (busiest != null)
        CoverPick(
          style: style,
          heading: 'En yoğun ayım',
          title: monthNameTr(busiest),
          detail: '${s.monthlyVisits[busiest - 1]} deneyim',
        ),
      if (s.topDistricts.isNotEmpty)
        CoverPick(
          style: style,
          heading: 'En çok döndüğüm semt',
          title: s.topDistricts.first.$1,
          detail: '${s.topDistricts.first.$2} deneyim',
        ),
    ];
    return CoverFrame(
      style: style,
      tag: 'Yılın özeti',
      author: author,
      page: page,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            t.rule(),
            const SizedBox(height: 14),
            Text('${s.year}', style: t.display(84)),
            Text('kısaca', style: t.display(30, italic: true)),
          ],
        ),
        Column(
          children: [
            for (var i = 0; i < picks.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: picks[i]),
                    const SizedBox(width: 18),
                    Expanded(
                      child: i + 1 < picks.length
                          ? picks[i + 1]
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
