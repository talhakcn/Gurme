import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/clock.dart';
import '../../core/platform/external.dart';
import '../../core/text/turkish.dart';
import '../../core/theme/gurme_colors.dart';
import '../../core/widgets/editorial.dart';
import '../../core/widgets/gurme_icons.dart';
import '../journal/data/journal_models.dart';
import '../journal/data/journal_notifier.dart';
import '../lists/screens/list_cover_screen.dart';
import 'year_story.dart';
import 'year_summary.dart';

/// "Lezzet haritan": bu yılın defter özeti ve çok sayfalı paylaşım seti.
class YearSummaryScreen extends ConsumerStatefulWidget {
  const YearSummaryScreen({super.key});

  @override
  ConsumerState<YearSummaryScreen> createState() => _YearSummaryScreenState();
}

class _YearSummaryScreenState extends ConsumerState<YearSummaryScreen> {
  final _pages = PageController();
  final _keys = <GlobalKey>[];
  var _page = 0;
  var _busy = false;
  var _style = CoverStyle.ink;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// [only] verilirse yalnızca o sayfa, yoksa bütün set paylaşılır.
  Future<void> _share(BuildContext origin, int year, {int? only}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final dir = '${ref.read(appDirectoryProvider).path}/exports';
    final indexes = only == null
        ? [for (var i = 0; i < _keys.length; i++) i]
        : [only];
    try {
      await shareBoundaryImages(
        origin: origin,
        images: [
          for (final i in indexes)
            (_keys[i], File('$dir/gurme-$year-${i + 1}.png')),
        ],
        width: 1080,
        text: '$year defterimden · Gurme',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Paylaşılamadı.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(journalDataProvider);
    final year = ref.watch(clockProvider)().year;
    final summary = YearSummary.of(data, year);
    final text = Theme.of(context).textTheme;

    if (summary.isEmpty) {
      return GurmePage(
        masthead: const Masthead(back: true),
        children: [
          Text('$year defterin', style: text.headlineLarge),
          EmptyState(
            title: 'Bu yılın haritası boş.',
            detail:
                'Mekân ekledikçe ve deneyim yazdıkça yılın özeti burada '
                'oluşacak.',
            action: 'Arşive git',
            onPressed: () => context.go('/archive'),
          ),
        ],
      );
    }

    final author = data.profile.name.trim();
    final pages = yearStoryPages(
      summary: summary,
      author: author,
      style: _style,
    );
    while (_keys.length < pages.length) {
      _keys.add(GlobalKey());
    }
    _keys.length = pages.length;
    final page = _page.clamp(0, pages.length - 1);

    return GurmePage(
      masthead: const Masthead(back: true),
      children: [
        PeriodSummaryBody(summary: summary),
        const Rule(space: Space.xxl),
        Text('Paylaşım seti', style: text.headlineSmall),
        const SizedBox(height: Space.xs),
        Text(
          'Yılın ${pages.length} sayfada; her sayfa hikâye boyutunda '
          '(1080×1920) ayrı bir görsel. Kaydırarak bak; hepsini birden ya da '
          'yalnızca gördüğün sayfayı paylaşabilirsin.',
          style: text.bodySmall,
        ),
        const SizedBox(height: Space.l),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: AspectRatio(
              aspectRatio: coverSize.aspectRatio,
              child: FittedBox(
                child: SizedBox.fromSize(
                  size: coverSize,
                  // Paylaşılacak sayfaların hepsi çizili durur (görüntüsü
                  // alınabilsin diye); üstlerini kaydırılan önizleme örter.
                  child: Stack(
                    children: [
                      for (final (i, p) in pages.indexed)
                        ExcludeSemantics(
                          child: RepaintBoundary(key: _keys[i], child: p),
                        ),
                      Positioned.fill(
                        child: PageView(
                          controller: _pages,
                          onPageChanged: (i) => setState(() => _page = i),
                          children: [
                            for (final (i, p) in pages.indexed)
                              Semantics(
                                label:
                                    '${i + 1}. sayfa, toplam ${pages.length}',
                                child: p,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.m),
        _PageDots(
          count: pages.length,
          current: page,
          onTap: (i) => _pages.animateToPage(
            i,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          ),
        ),
        const SizedBox(height: Space.l),
        SegmentRow<CoverStyle>(
          options: [for (final s in CoverStyle.values) (s, s.label)],
          selected: _style,
          onSelected: (s) => setState(() => _style = s),
        ),
        const SizedBox(height: Space.m),
        Builder(
          builder: (buttonContext) => ActionButton(
            _busy ? 'Hazırlanıyor…' : 'Hepsini paylaş (${pages.length} görsel)',
            icon: GurmeGlyph.share,
            onPressed: _busy ? null : () => _share(buttonContext, year),
          ),
        ),
        const SizedBox(height: Space.s),
        Builder(
          builder: (buttonContext) => ActionButton(
            'Bu sayfayı paylaş',
            secondary: true,
            onPressed: _busy
                ? null
                : () => _share(buttonContext, year, only: page),
          ),
        ),
      ],
    );
  }
}

/// Sayfa göstergesi: her sayfa için bir çizgi; dokunulan sayfaya gider.
class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.count,
    required this.current,
    required this.onTap,
  });

  final int count;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${current + 1}. sayfa, toplam $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            ExcludeSemantics(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                // Çizgi ince, dokunma alanı 36×44: sekiz sayfa telefona sığar.
                child: SizedBox(
                  width: 36,
                  height: 44,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: i == current ? 22 : 10,
                      height: 3,
                      color: i == current
                          ? context.colors.ink
                          : context.colors.control,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Dönem özetinin ekrandaki hâli: cümle, semtler, türler, seçimler. Ay ve
/// yıl için aynı; yalnızca dönem sözcükleri değişir.
class PeriodSummaryBody extends StatelessWidget {
  const PeriodSummaryBody({super.key, required this.summary});

  final YearSummary summary;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = summary;
    final period = s.isMonth ? 'Bu ay' : 'Bu yıl';
    final periodOf = s.isMonth ? 'Bu ayki' : 'Bu yılki';
    final unit = s.isMonth ? 'Ayın' : 'Yılın';
    // Semt adının yeri yazı boyutuyla büyür; satırın yarısını geçmez.
    final scaler = MediaQuery.textScalerOf(context);
    final maxDistrict = s.districts.isEmpty ? 1 : s.districts.first.$2;
    final categoryTotal = s.categories.fold(0, (sum, c) => sum + c.$2);
    // Altın ana eyleme ayrılır; grafik mürekkebin tonlarıyla çizilir.
    // İlk iki dilim koyu (üstünde kâğıt rengi yazı), son ikisi açık.
    final categoryColors = [
      // Dolu çubuk `mark`: gece krem blok yerine turkuaz. İkinci dilim aynı
      // rengin kâğıda karışmış tonu; ayrı bir gri blok gibi kopmaz.
      context.colors.mark,
      // Oran, üstündeki açık yazıya iki temada da 4,5:1 bırakır.
      Color.lerp(
        context.colors.mark,
        context.colors.paper,
        Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.25,
      )!,
      context.colors.line,
      context.colors.wash,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitle('${s.periodLabel} defterin', style: text.headlineLarge),
        const SizedBox(height: Space.s),
        // Sayılar tablo yerine tek cümlede.
        Text(
          '$period ${joinTr([if (s.visitedPlaces > 0) '${s.visitedPlaces} mekâna gittin', if (s.places > s.visitedPlaces) '${s.places - s.visitedPlaces} yeni yeri deftere ekledin', if (s.visits > 0) '${s.visits} deneyim yazdın', if (s.lists > 0) '${s.lists} liste oluşturdun'])}.',
          style: text.headlineSmall,
        ),
        // Tek semt için çubuk grafik anlam taşımaz; cümleyle söylenir.
        if (s.districts.length == 1) ...[
          const SizedBox(height: Space.xl),
          const Eyebrow('En çok döndüğün semt'),
          Text(
            '$periodOf deneyimlerinin hepsi ${s.districts.single.$1} semtinde.',
            style: text.bodyMedium,
          ),
        ],
        if (s.districts.length > 1) ...[
          const SizedBox(height: Space.xl),
          const Eyebrow('En çok döndüğün semtler'),
          const SizedBox(height: Space.s),
          for (final (name, n) in s.districts)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s),
              child: LayoutBuilder(
                builder: (context, box) => Row(
                  children: [
                    SizedBox(
                      width: scaler.scale(96).clamp(96, box.maxWidth / 2),
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall!.copyWith(
                          color: context.colors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: Space.s),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: (n / maxDistrict).clamp(0.04, 1.0),
                          child: Container(
                            height: 10,
                            color: name == 'Diğer'
                                ? context.colors.line
                                : context.colors.mark,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: scaler.scale(32),
                      child: Text(
                        '$n',
                        textAlign: TextAlign.right,
                        style: text.bodySmall!.copyWith(
                          color: context.colors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
        // Tek tür varsa "%100" çubuğu anlam taşımaz; cümleyle söylenir.
        if (s.categories.length == 1) ...[
          const SizedBox(height: Space.m),
          const Eyebrow('Defterinin karakteri'),
          Text(
            '$periodOf bütün deneyimlerin ${toLowerTr(s.categories.single.$1)} üzerine.',
            style: text.bodyMedium,
          ),
        ],
        if (s.categories.length > 1) ...[
          const SizedBox(height: Space.m),
          const Eyebrow('Defterinin karakteri'),
          const SizedBox(height: Space.s),
          Container(
            height: 34,
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.mark),
            ),
            child: Row(
              children: [
                for (final (i, (name, n)) in s.categories.indexed)
                  Expanded(
                    flex: n,
                    child: Container(
                      color: categoryColors[i],
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: Space.s),
                      child: n / categoryTotal >= 0.18
                          ? Eyebrow(
                              name,
                              // Yazı rengi, dilimle karşıtlığı yüksek olan.
                              color: _readableOn(categoryColors[i]),
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.s),
          Text(
            [
              for (final (name, n) in s.categories)
                '$name %${(n * 100 / categoryTotal).round()}',
            ].join(' · '),
            style: text.bodySmall,
          ),
        ],
        if (s.favorite case final favorite?) ...[
          const SizedBox(height: Space.xl),
          const Eyebrow('Önerdiklerinden en çok gittiğin'),
          const SizedBox(height: Space.xs),
          Text(favorite.name, style: text.headlineSmall),
          Text(
            '${s.favoriteVisits} deneyim'
            '${s.favoriteLists > 0 ? ' · ${s.favoriteLists} listende' : ''}',
            style: text.bodySmall,
          ),
        ],
        if (s.dish case final dish?) ...[
          const SizedBox(height: Space.xl),
          Eyebrow('$unit tabağı'),
          const SizedBox(height: Space.xs),
          Text(
            dish.name,
            style: text.headlineSmall!.copyWith(fontStyle: FontStyle.italic),
          ),
          Text(
            [?s.dishPlace?.name, '${formatScore(dish.score!)} / 5'].join(' · '),
            style: text.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// [ground] üstünde kâğıt ve mürekkepten hangisi daha okunaklıysa o.
Color _readableOn(Color ground) {
  double contrast(Color a, Color b) {
    final la = a.computeLuminance(), lb = b.computeLuminance();
    final (hi, lo) = la > lb ? (la, lb) : (lb, la);
    return (hi + 0.05) / (lo + 0.05);
  }

  return contrast(GurmeColors.paper, ground) >=
          contrast(GurmeColors.ink, ground)
      ? GurmeColors.paper
      : GurmeColors.ink;
}
