import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gurme_client/gurme_client.dart';

import '../../../core/clock.dart';
import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../../lists/data/list_repository.dart';
import '../data/dish_summary.dart';
import '../data/journal_models.dart';
import '../data/journal_notifier.dart';
import '../widgets/discover_extras.dart';
import '../widgets/place_widgets.dart';
import '../widgets/quick_add_sheet.dart';
import '../widgets/today_card.dart';
import '../../hints/hints.dart';

/// Ana sayfa: defterin bugünkü hali. Selam ve defterin özeti, bugün için
/// bir öneri, son eklenenler, rotalar ve şehrindeki açık bir liste.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(journalDataProvider);
    final text = Theme.of(context).textTheme;
    final now = ref.watch(clockProvider)();
    final name = data.profile.name.trim().split(' ').first;

    return GurmePage(
      children: [
        Eyebrow(
          [
            formatLongDateTr(now),
            if (data.profile.city.isNotEmpty) data.profile.city,
          ].join(' · '),
        ),
        const SizedBox(height: Space.s),
        PageTitle(
          name.isEmpty ? '${greetingTr(now)}.' : '${greetingTr(now)}, $name.',
          style: text.headlineLarge,
        ),
        const SizedBox(height: Space.s),
        Text(
          journalSummaryLine(data, now),
          style: text.bodyLarge!.copyWith(color: context.colors.muted),
        ),
        if (!StartGuide.isComplete(data)) StartGuide(data: data),
        if (data.places.any((p) => p.status == PlaceStatus.want))
          const TodayCard(),
        SectionTitle(
          'Son eklediklerin',
          trailing: data.places.length > 3
              ? LinkLabel('Tümü', onTap: () => context.go('/archive'))
              : null,
        ),
        if (data.places.isEmpty)
          EmptyState(
            title: 'Defterin boş.',
            detail: 'Gittiğin ya da gitmek istediğin bir yerle başla.',
            action: 'Mekân ekle',
            onPressed: () => showQuickAddSheet(context),
          )
        else ...[
          for (final (i, p) in data.places.take(3).indexed)
            SwipeablePlaceRow(
              place: p,
              child: PlaceRow(place: p, index: i + 1),
            ),
          // İpuçları içeriğin altında: ekranı açan kişi önce kendi
          // defterini görür.
          if (data.places
              .take(3)
              .any((p) => data.visitsFor(p.id).any((v) => !v.scores.isEmpty)))
            const HintNote(
              id: 'taste-mark',
              after: 'welcome',
              text:
                  'Adların yanındaki kareler lezzet izi: karnenin dört '
                  'ölçütü (lezzet, servis, ambiyans, fiyat), her biri 5 '
                  'üzerinden. Dokununca ayrıntısı görünür.',
            ),
          // Arşiv'deki gibi düğme; burada ana eylem değil, ikincil.
          const SizedBox(height: Space.l),
          ActionButton(
            'Mekân ekle',
            icon: GurmeGlyph.add,
            secondary: true,
            onPressed: () => showQuickAddSheet(context),
          ),
        ],
        // İlk açılışta bir kez: Gurme'nin ne olduğu, üç cümlede. Defterin
        // altında durur; üstte içeriği aşağı itmez.
        const HintNote(
          id: 'welcome',
          text:
              'Gurme senin lezzet defterin. Gittiğin ve gitmek istediğin '
              'yerleri ekle, her deneyimi karneyle puanla. “Bugün ne '
              'yesem?” gideceklerinden birini önerir.',
        ),
        _FavoriteDishes(data: data),
        if (data.lists.isNotEmpty) ...[
          SectionTitle(
            'Listelerin',
            trailing: LinkLabel('Tümü', onTap: () => context.go('/lists')),
          ),
          for (final l in data.lists.take(2))
            InkWell(
              onTap: () => context.push('/list/${l.id}'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: Space.l),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: context.colors.line),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.title, style: text.headlineSmall),
                    Text(
                      [
                        for (final item in l.items)
                          ?data.placeById(item.placeId)?.name,
                      ].join('  →  '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
        ],
        _RegionalLists(data: data),
      ],
    );
  }
}

/// Bütün defterden en yüksek puanlı üç tabak (4 ve üstü, "bir daha
/// söyleme" denmemiş). Tabak kaydı yoksa bölüm görünmez.
class _FavoriteDishes extends StatelessWidget {
  const _FavoriteDishes({required this.data});

  final JournalData data;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final best = [
      for (final d in summarizeDishes(data.visits))
        if (!d.never && (d.score ?? 0) >= 4) d,
    ]..sort((a, b) => b.score!.compareTo(a.score!));
    if (best.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('En sevdiğin tabaklar'),
        for (final d in best.take(3))
          InkWell(
            onTap: () => context.push('/place/${d.placeId}'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: Space.l),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.colors.line)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.name,
                    style: text.headlineSmall!.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    [
                      data.placeById(d.placeId)?.name ?? 'Silinmiş mekân',
                      '${formatScore(d.score!)} / 5',
                      if (d.times > 1) '${d.times} kez',
                    ].join(' · '),
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

/// Defterin tek cümlelik özeti: kaç mekân, kaçına gidilmedi, bu hafta ne
/// oldu. Sayılar tablo yerine cümle içinde.
String journalSummaryLine(JournalData data, DateTime now) {
  if (data.places.isEmpty) return 'Defterin henüz boş.';
  final want = data.places.where((p) => p.status == PlaceStatus.want).length;
  final week = weekSummaryOf(data, now);
  return [
    want == 0
        ? 'Defterinde ${data.places.length} mekân var.'
        : 'Defterinde ${data.places.length} mekân var; $want tanesine '
              'henüz gitmedin.',
    if (week.visits > 0)
      'Bu hafta ${week.visits} deneyim yazdın.'
    else if (week.added > 0)
      'Bu hafta ${week.added} yeni yer ekledin.',
  ].join(' ');
}

/// Profildeki şehirle eşleşen bir mekân içeren ilk herkese açık liste.
/// Böyle bir liste yoksa (ya da yüklenemediyse) bölüm hiç görünmez.
class _RegionalLists extends ConsumerWidget {
  const _RegionalLists({required this.data});

  final JournalData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final city = data.profile.city.trim();
    final lists = ref.watch(publicListsProvider).value;
    if (city.isEmpty || lists == null) return const SizedBox.shrink();

    final region = toLowerTr(city);
    bool inRegion(GurmeListItem item) => toLowerTr(item.area).contains(region);
    final featured = lists
        .where(
          (l) =>
              l.visibility == GurmeListVisibility.public &&
              l.items.any(inRegion),
        )
        .firstOrNull;
    if (featured == null) return const SizedBox.shrink();

    final stop = featured.items.firstWhere(inRegion);
    final saved = data.isRemoteSaved(featured.id);
    final journal = ref.read(journalProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'Şehrinden bir liste',
          trailing: LinkLabel(
            'Diğerleri',
            onTap: () => context.go('/lists?tab=discover'),
          ),
        ),
        InkWell(
          onTap: () => context.push('/shared/${featured.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(featured.title, style: text.headlineMedium),
                Text(
                  '${featured.authorName} · ${featured.items.length} mekân',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: Space.s),
          padding: const EdgeInsets.only(left: Space.m),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: context.colors.teal)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stop.name, style: text.headlineSmall),
              Text(
                [
                  stop.area,
                  stop.category,
                ].where((s) => s.isNotEmpty).join(' · '),
                style: text.bodySmall,
              ),
              LinkLabel(
                'Gideceklerime ekle',
                onTap: () {
                  final added = journal.addFromListItem(stop);
                  context.push('/place/${added.id}');
                },
              ),
            ],
          ),
        ),
        LinkLabel(
          saved ? 'Kaydedildi' : 'Listeyi kaydet',
          onTap: () => journal.toggleRemoteSaved(featured),
        ),
      ],
    );
  }
}
