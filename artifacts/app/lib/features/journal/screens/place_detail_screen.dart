import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gurme_client/gurme_client.dart';

import '../../../core/clock.dart';
import '../../../core/platform/external.dart';
import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../../../core/widgets/sparkline.dart';
import '../../lists/data/list_repository.dart';
import '../data/dish_summary.dart';
import '../data/journal_models.dart';
import '../data/journal_notifier.dart';
import '../widgets/place_cover.dart';
import '../widgets/taste_mark.dart';
import '../widgets/place_widgets.dart';

class PlaceDetailScreen extends ConsumerStatefulWidget {
  const PlaceDetailScreen({
    super.key,
    required this.placeId,
    this.embedded = false,
  });

  final String placeId;

  /// Arşivin liste–ayrıntı düzeninde sağ sütun: geri düğmesi ve logo yok.
  final bool embedded;

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  var _listPicker = false;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(journalDataProvider);
    final journal = ref.read(journalProvider.notifier);
    final text = Theme.of(context).textTheme;
    final id = widget.placeId;
    final p = data.placeById(id);

    if (p == null) {
      return GurmePage(
        masthead: const Masthead(back: true),
        children: [
          EmptyState(
            title: 'Bu adres bulunamadı.',
            detail: 'Mekân silinmiş ya da henüz kaydedilmemiş olabilir.',
            action: 'Arşive dön',
            onPressed: () => context.go('/archive'),
          ),
        ],
      );
    }

    final visits = data.visitsFor(id);

    return GurmePage(
      masthead: Masthead(
        back: !widget.embedded,
        logo: !widget.embedded,
        rightIcon: GurmeGlyph.edit,
        rightTooltip: 'Mekânı düzenle',
        onRight: () => context.push('/place/$id/edit'),
      ),
      children: [
        PageTitle(p.name, style: text.displayLarge),
        const SizedBox(height: Space.xs),
        Eyebrow(
          [
            p.address.isNotEmpty ? p.address : p.area,
            p.category,
          ].where((s) => s.isNotEmpty).join(' · '),
        ),
        if (p.address.isNotEmpty)
          LinkLabel(
            'Haritada aç',
            onTap: () async {
              final opened = await openInMaps(p.address);
              if (!opened && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Harita açılamadı.')),
                );
              }
            },
          ),
        const SizedBox(height: Space.l),
        PlaceCover(p, height: 220, google: true),
        if (p.description.isNotEmpty) ...[
          const SizedBox(height: Space.l),
          MarginNote(child: Text(p.description, style: text.titleMedium)),
        ],
        if (p.source.isNotEmpty) ...[
          const SizedBox(height: Space.xs),
          Text('Kaynak: ${p.source}', style: text.bodySmall),
        ],
        const SizedBox(height: Space.xl),
        // Seçili duruma yeniden dokunmak bir şey yapmaz; her değişiklik
        // geri alınabilir.
        SegmentRow<PlaceStatus>(
          options: const [
            (PlaceStatus.want, 'Gideceğim'),
            (PlaceStatus.went, 'Gittim'),
          ],
          selected: p.status,
          onSelected: (status) {
            if (status == p.status) return;
            final undo = journal.setStatus(id, status);
            showUndo(
              ScaffoldMessenger.of(context),
              status == PlaceStatus.want
                  ? p.recommended
                        ? 'Gideceklerine taşındı; öneri kaldırıldı.'
                        : 'Gideceklerine taşındı.'
                  : 'Gittiklerine taşındı.',
              undo,
            );
          },
        ),
        CheckRow(
          label: 'Bu mekânı öneriyorum',
          checked: p.recommended,
          onTap: () => journal.toggleRecommended(id),
        ),
        const SizedBox(height: Space.xl),
        _PlaceFacts(place: p, visits: visits, now: ref.watch(clockProvider)()),
        const SizedBox(height: Space.l),
        // Ana eylem üstte; uzun notların altında kaybolmasın.
        ActionButton(
          'Deneyim ekle',
          icon: GurmeGlyph.write,
          onPressed: () => context.push('/place/$id/visit/new'),
        ),
        _PlaceDishes(placeId: id, data: data),
        if (visits.isNotEmpty) ...[
          SectionTitle(
            'Deneyimlerin',
            trailing: Text('${visits.length} deneyim', style: text.bodySmall),
          ),
          for (final v in visits)
            _VisitCard(visit: v, placeId: id, now: ref.watch(clockProvider)()),
        ],
        const SectionTitle('Yer aldığı listeler'),
        for (final l in data.lists.where((l) => l.contains(id)))
          InkWell(
            onTap: () => context.push('/list/${l.id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: Space.l),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.colors.line)),
              ),
              child: SpacedRow(
                left: Text(l.title, style: text.headlineSmall),
                right: GurmeIcon(
                  GurmeGlyph.next,
                  size: 20,
                  color: context.colors.muted,
                ),
              ),
            ),
          ),
        LinkLabel(
          'Listeye ekle ya da çıkar',
          onTap: () => setState(() => _listPicker = !_listPicker),
        ),
        if (_listPicker) ...[
          for (final l in data.lists)
            CheckRow(
              label: l.title,
              checked: l.contains(id),
              detail: l.isPublished
                  ? 'Paylaşılan liste: düzenle ve sunucuyla eşitle'
                  : null,
              onTap: () => l.isPublished
                  ? context.push('/list/${l.id}/edit')
                  : journal.togglePlaceInList(l.id, id),
            ),
          LinkLabel(
            'Yeni liste oluştur',
            onTap: () => context.push('/list/new'),
          ),
        ],
        _PublicListMatches(place: p),
      ],
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({
    required this.visit,
    required this.placeId,
    required this.now,
  });

  final Visit visit;
  final String placeId;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final v = visit;
    return InkWell(
      onTap: () => context.push('/place/$placeId/visit/${v.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Space.xl),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.colors.line)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Öneri mekânın; her deneyimde tekrar yazılmaz.
            Eyebrow(
              '${relativeIsoDateTr(v.date, now)}'
              '${v.scores.average == null ? '' : ' · Karne ${formatScore(v.scores.average!)} / 5'}',
            ),
            const SizedBox(height: Space.s),
            MarginNote(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.title.isEmpty ? 'Başlıksız deneyim' : v.title,
                    style: text.headlineMedium!.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (v.note.isNotEmpty) ...[
                    const SizedBox(height: Space.s),
                    Text(v.note, style: text.bodyMedium),
                  ],
                ],
              ),
            ),
            if (v.tastedDishes.isNotEmpty || v.order.isNotEmpty) ...[
              const SizedBox(height: Space.s),
              Text(
                'Tadılan: ${[for (final d in v.tastedDishes) d.score > 0 ? '${d.name} (${d.score} / 5)' : d.name, if (v.order.isNotEmpty) v.order].join(', ')}',
                style: text.bodySmall,
              ),
            ],
            if (v.dishes.isNotEmpty) ...[
              const SizedBox(height: Space.xs),
              Text('Önerilenler: ${v.dishes}', style: text.bodySmall),
            ],
            if (v.revisit case final revisit?) ...[
              const SizedBox(height: Space.xs),
              Text(
                'Tekrar gider miyim? ${switch (revisit) {
                  Revisit.yes => 'Evet',
                  Revisit.no => 'Hayır',
                  Revisit.undecided => 'Belki',
                }}',
                style: text.bodySmall,
              ),
            ],
            if (v.photos.isNotEmpty) ...[
              const SizedBox(height: Space.m),
              Wrap(
                spacing: Space.s,
                runSpacing: Space.s,
                children: [
                  for (final photo in v.photos)
                    JournalPhoto(photo, width: 82, height: 82),
                ],
              ),
            ],
            const SizedBox(height: Space.s),
            LinkLabel(
              'Deneyimi düzenle',
              onTap: () => context.push('/place/$placeId/visit/${v.id}'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Aynı ad ve bölgeyle eşleşen herkese açık listeler.
/// Mekânın defterdeki hali, tek paragrafta: kaç kez gidildi, en son ne
/// zaman, ortalama karne ve ne zamandır defterde. Üç ya da daha çok
/// puanlı ziyaret varsa karne gidişatı çizilir.
class _PlaceFacts extends StatelessWidget {
  const _PlaceFacts({
    required this.place,
    required this.visits,
    required this.now,
  });

  final Place place;
  final List<Visit> visits;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dated = [...visits]..sort((a, b) => a.date.compareTo(b.date));
    final scores = [for (final v in dated) ?v.scores.average];
    final average = scores.isEmpty
        ? null
        : scores.reduce((a, b) => a + b) / scores.length;
    final days = now.difference(place.createdAt).inDays;

    final line = [
      if (dated.isEmpty)
        place.status == PlaceStatus.went
            ? 'Henüz deneyim yazmadın.'
            : 'Henüz gitmedin.'
      else
        '${dated.length} deneyimin var; en sonuncusu '
            '${relativeIsoDateTr(dated.last.date, now, sentence: true)}.',
      if (average != null)
        'Ortalama karnen 5 üzerinden ${formatScore(average)}.',
      // Sayı cümle başında önceki sayıya yapışmasın: "3,6. 67 gündür" değil.
      days < 1
          ? 'Bugün defterine ekledin.'
          : 'Defterine $days gün önce ekledin.',
    ].join(' ');

    final mark = TastingScores.averageOf([for (final v in visits) v.scores]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!mark.isEmpty) ...[
          // İz ilk kez burada büyük görünür; ne olduğu yanında söylenir.
          Text(
            'Lezzet izi: deneyimlerinin karne ortalaması. Her satır bir '
            'ölçüt, dolu kare kadar puan.',
            style: text.bodySmall,
          ),
          const SizedBox(height: Space.s),
          TasteMark(
            mark,
            cell: 12,
            labels: true,
            exact: TastingScores.meansOf([for (final v in visits) v.scores]),
          ),
          const SizedBox(height: Space.l),
        ],
        Text(
          line,
          style: text.bodyMedium!.copyWith(color: context.colors.muted),
        ),
        if (scores.length >= 3) ...[
          const SizedBox(height: Space.m),
          Sparkline(values: scores),
          const SizedBox(height: Space.xs),
          Text(
            'Karne gidişatı: ${scores.map(formatScore).join(' → ')}',
            style: text.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _PublicListMatches extends ConsumerWidget {
  const _PublicListMatches({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final lists = ref.watch(publicListsProvider);
    final matches = (lists.value ?? const [])
        .where(
          (l) =>
              l.visibility == GurmeListVisibility.public &&
              l.items.any(
                (item) =>
                    equalsTr(item.name, place.name) &&
                    equalsTr(item.area, place.area),
              ),
        )
        .toList();
    if (matches.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Rule(),
        const Eyebrow('Gurme açık listelerinde'),
        for (final l in matches)
          InkWell(
            onTap: () => context.push('/shared/${l.id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: Space.m),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.colors.line)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.title, style: text.headlineSmall),
                  Text(
                    '${l.authorName} · aynı ad ve bölge eşleşmesi',
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Mekânda tadılan tabaklar: önce "Bir dahaki sefere" notu, ardından her
/// tabağın bütün deneyimlerden özeti. Tabak yoksa hiçbir şey çizilmez.
class _PlaceDishes extends StatelessWidget {
  const _PlaceDishes({required this.placeId, required this.data});

  final String placeId;
  final JournalData data;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final all = summarizeDishes(data.visits);
    final here = [
      for (final d in all)
        if (d.placeId == placeId) d,
    ]..sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));
    if (here.isEmpty) return const SizedBox.shrink();

    final never = [
      for (final d in here)
        if (d.never) d,
    ];
    final best = here.where((d) => !d.never && (d.score ?? 0) >= 4).firstOrNull;
    // Sıralaması anlamlı türler: bütün defterde en az üç tabağı olan.
    final kinds = {
      for (final d in here)
        if (d.kind != DishKind.other &&
            rankDishes(all, d.kind).length >= minRankedDishes)
          d.kind,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (never.isNotEmpty || best != null) ...[
          const SizedBox(height: Space.xl),
          Container(
            padding: const EdgeInsets.all(Space.l),
            decoration: BoxDecoration(
              color: colors.wash,
              border: Border(top: BorderSide(color: colors.ink, width: 2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Bir dahaki sefere'),
                for (final d in never) ...[
                  const SizedBox(height: Space.xs),
                  Text(
                    'Söyleme: ${d.name}',
                    // İtalik yalnızca kullanıcının kendi sözlerinde; bu satır
                    // uygulamanın.
                    style: text.bodyMedium,
                  ),
                  if (d.parts.where((p) => p.verdict == DishVerdict.bad)
                      case final bad when bad.isNotEmpty)
                    Text(
                      // Bileşen tabağıyla birlikte: "iç" tek başına bir şey
                      // söylemez.
                      '${d.name}: beğenmediğin '
                      '${bad.map((p) => toLowerTr(p.name)).join(', ')}',
                      style: text.bodyMedium,
                    ),
                ],
                if (best != null) ...[
                  const SizedBox(height: Space.xs),
                  Text(
                    'En beğendiğin: ${best.name} · ${formatScore(best.score!)} / 5',
                    style: text.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
        SectionTitle(
          'Tabakların',
          trailing: Text('${here.length} tabak', style: text.bodySmall),
        ),
        for (final d in here) _DishSummaryRow(dish: d),
        for (final k in kinds)
          LinkLabel(
            '${k.label} sıralaman',
            onTap: () => context.push('/dishes/${k.name}'),
          ),
      ],
    );
  }
}

class _DishSummaryRow extends StatelessWidget {
  const _DishSummaryRow({required this.dish});

  final DishSummary dish;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final d = dish;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Space.l),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            d.name,
            style: text.headlineSmall!.copyWith(fontStyle: FontStyle.italic),
          ),
          Text(
            [
              d.kind.label,
              '${d.times} kez',
              if (d.score != null) '${formatScore(d.score!)} / 5',
            ].join(' · '),
            style: text.bodySmall,
          ),
          if (d.never)
            Text(
              'Bir daha söyleme',
              // Hata değil, kullanıcının kendi notu: hata rengiyle yazılmaz.
              style: text.labelSmall!.copyWith(color: colors.ink),
            ),
          if (d.parts.isNotEmpty) const SizedBox(height: Space.s),
          for (final p in d.parts)
            Padding(
              padding: const EdgeInsets.only(top: Space.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(p.name, style: text.bodyMedium),
                  ),
                  const SizedBox(width: Space.m),
                  Expanded(
                    flex: 3,
                    child: Text(
                      p.text,
                      style: text.bodyMedium!.copyWith(
                        fontWeight: p.verdict == DishVerdict.fine
                            ? FontWeight.w400
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
