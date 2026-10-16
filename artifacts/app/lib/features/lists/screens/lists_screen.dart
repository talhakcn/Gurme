import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gurme_client/gurme_client.dart';

import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../../journal/data/journal_models.dart';
import '../../journal/data/journal_notifier.dart';
import '../data/list_repository.dart';
import '../widgets/list_widgets.dart';

enum ListsTab { mine, saved, discover }

ListsTab listsTabFromQuery(String? value) =>
    ListsTab.values.where((t) => t.name == value).firstOrNull ?? ListsTab.mine;

class ListsScreen extends ConsumerStatefulWidget {
  const ListsScreen({super.key, this.initialTab = ListsTab.mine});

  /// `/lists?tab=saved` gibi adreslerden gelir.
  final ListsTab initialTab;

  @override
  ConsumerState<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends ConsumerState<ListsScreen> {
  late var _tab = widget.initialTab;

  @override
  void didUpdateWidget(ListsScreen old) {
    super.didUpdateWidget(old);
    if (widget.initialTab != old.initialTab) _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(journalDataProvider);
    final text = Theme.of(context).textTheme;
    return GurmePage(
      children: [
        PageTitle('Listelerim', style: text.headlineLarge),
        const SizedBox(height: Space.s),
        Text(
          'Sevdiğin mekânları sıraya koy, not ekle; istersen paylaş.',
          style: text.bodyMedium!.copyWith(color: context.colors.muted),
        ),
        const SizedBox(height: Space.xl),
        ActionButton(
          'Yeni liste oluştur',
          icon: GurmeGlyph.add,
          onPressed: () => context.push('/list/new'),
        ),
        const SizedBox(height: Space.xxl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (tab, label) in const [
              (ListsTab.mine, 'Listelerim'),
              (ListsTab.saved, 'Kaydedilen'),
              (ListsTab.discover, 'Herkese açık'),
            ])
              // Eşit genişlik: büyük yazıda ad taşmaz, iki satıra iner.
              Expanded(
                child: Semantics(
                  selected: _tab == tab,
                  button: true,
                  child: InkWell(
                    onTap: () => setState(() => _tab = tab),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(
                        bottom: Space.m,
                        top: Space.xs,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _tab == tab
                                ? context.colors.ink
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      // Büyük yazıda kelime bölünmez ("Kaydedil-en"); en uzun
                      // kelime sığacak kadar küçülür.
                      child: WordSafeText(
                        label,
                        textAlign: TextAlign.center,
                        style: text.labelSmall!.copyWith(
                          color: _tab == tab
                              ? context.colors.ink
                              : context.colors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const Rule(space: Space.m),
        ...switch (_tab) {
          ListsTab.mine => _mine(context, data),
          ListsTab.saved => _saved(context, data),
          ListsTab.discover => [const _DiscoverLists()],
        },
      ],
    );
  }

  List<Widget> _mine(BuildContext context, JournalData data) {
    final text = Theme.of(context).textTheme;
    if (data.lists.isEmpty) {
      return [
        EmptyState(
          title: 'Henüz listen yok.',
          detail:
              'Birkaç mekânı sırayla bir listede topla: bir sabah turu, '
              'misafire önerilecek yerler…',
          action: 'Liste oluştur',
          onPressed: () => context.push('/list/new'),
        ),
      ];
    }
    return [
      for (final l in data.lists)
        ListTileFrame(
          onTap: () => context.push('/list/${l.id}'),
          children: [
            Eyebrow(
              '${l.city.isEmpty ? 'Kişisel liste' : l.city} · ${_status(l)}',
            ),
            const SizedBox(height: Space.s),
            Text(l.title, style: text.headlineMedium),
            if (l.description.isNotEmpty) ...[
              const SizedBox(height: Space.s),
              Text(
                l.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall,
              ),
            ],
            if ([for (final item in l.items) ?data.placeById(item.placeId)]
                case final stops when stops.isNotEmpty) ...[
              const SizedBox(height: Space.s),
              // Rotanın durakları, sırasıyla.
              Text(
                stops.map((p) => p.name).join('  →  '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium,
              ),
            ],
            const SizedBox(height: Space.m),
            Eyebrow('${l.items.length} mekân · ${formatDateTr(l.updatedAt)}'),
          ],
        ),
    ];
  }

  static String _status(CuratedList l) => !l.isPublished
      ? 'Paylaşılmadı'
      : switch (l.visibility) {
          ListVisibility.public => 'Herkese açık',
          ListVisibility.unlisted => 'Bağlantıyla',
          ListVisibility.private => 'Özel',
        };

  // Kaydedilen yalnızca başkalarının listeleridir; kendi listen zaten
  // "Listelerim"de.
  List<Widget> _saved(BuildContext context, JournalData data) {
    if (data.savedRemoteLists.isEmpty) {
      return [
        EmptyState(
          title: 'Henüz kaydedilen liste yok.',
          detail: 'Başkalarının listelerinden kaydettiklerin burada görünür.',
          action: 'Listeleri keşfet',
          onPressed: () => setState(() => _tab = ListsTab.discover),
        ),
      ];
    }
    return [for (final l in data.savedRemoteLists) RemoteListRow(list: l)];
  }
}

class _DiscoverLists extends ConsumerWidget {
  const _DiscoverLists();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(publicListsProvider);
    if (lists.isLoading && !lists.hasValue) {
      return const Column(
        children: [SkeletonBlock(), SkeletonBlock(), SkeletonBlock()],
      );
    }
    if (lists.hasError && !lists.hasValue) {
      return EmptyState(
        title: 'Listeler yüklenemedi.',
        detail: 'Bağlantını kontrol edip tekrar deneyebilirsin.',
        action: 'Tekrar dene',
        onPressed: () => ref.invalidate(publicListsProvider),
      );
    }
    final public = lists.requireValue
        .where((l) => l.visibility == GurmeListVisibility.public)
        .toList();
    if (public.isEmpty) {
      return const EmptyState(
        title: 'Henüz herkese açık liste yok.',
        detail:
            'Başkalarının herkese açık paylaştığı listeler burada yer alacak.',
      );
    }
    return Column(children: [for (final l in public) RemoteListRow(list: l)]);
  }
}
