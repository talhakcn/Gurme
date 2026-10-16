import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gurme_client/gurme_client.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/platform/external.dart';
import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../../journal/data/journal_notifier.dart';
import '../../moderation/report_list_sheet.dart';
import '../data/list_repository.dart';

/// Başka birinin yayınladığı liste. Kaydedilmişse çevrimdışı kopyası da
/// gösterilebilir.
class SharedListScreen extends ConsumerStatefulWidget {
  const SharedListScreen({super.key, required this.remoteId});

  final String remoteId;

  @override
  ConsumerState<SharedListScreen> createState() => _SharedListScreenState();
}

class _SharedListScreenState extends ConsumerState<SharedListScreen> {
  var _notice = '';

  void _addToJournal(GurmeListItem item) {
    final added = ref.read(journalProvider.notifier).addFromListItem(item);
    if (added.existed) {
      setState(() => _notice = 'Bu mekân zaten defterinde.');
      return;
    }
    setState(() => _notice = 'Mekân gidilecekler listene eklendi.');
    context.push('/place/${added.id}');
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(journalDataProvider);
    final query = ref.watch(remoteListProvider(widget.remoteId));
    final text = Theme.of(context).textTheme;
    final snapshot = data.savedRemoteLists
        .where((l) => l.id == widget.remoteId)
        .firstOrNull;
    final list = query.value ?? snapshot;

    if (list == null) {
      return GurmePage(
        masthead: const Masthead(back: true),
        children: query.isLoading
            ? const [
                SkeletonBlock(height: 12, width: 120),
                SkeletonBlock(height: 42),
                SkeletonBlock(height: 16, width: 200),
              ]
            : [
                EmptyState(
                  title: 'Liste açılamadı.',
                  detail:
                      'Bağlantı geçersiz olabilir veya liste şu anda '
                      'kullanılamıyor.',
                  action: 'Yeniden dene',
                  onPressed: () =>
                      ref.invalidate(remoteListProvider(widget.remoteId)),
                ),
              ],
      );
    }

    final saved = snapshot != null;
    final isPublic = list.visibility == GurmeListVisibility.public;

    return GurmePage(
      masthead: const Masthead(back: true),
      children: [
        PageTitle(list.title, style: text.headlineLarge),
        const SizedBox(height: Space.l),
        Text(
          '${list.authorName} · ${list.items.length} mekân · '
          '${isPublic ? 'Herkese açık' : 'Bağlantıyla paylaşıldı'}',
          style: text.bodySmall,
        ),
        const SizedBox(height: Space.s),
        Text(
          'Oluşturuldu: ${formatDateTr(list.createdAt)} · '
          'Güncellendi: ${formatDateTr(list.updatedAt)}',
          style: text.bodySmall,
        ),
        if (query.hasError && !query.hasValue)
          Padding(
            padding: const EdgeInsets.only(top: Space.s),
            child: Text(
              'Çevrimdışı kayıt gösteriliyor. Güncellemek için yeniden dene.',
              style: text.bodySmall!.copyWith(color: context.colors.error),
            ),
          ),
        const Rule(space: Space.l),
        if (list.description.isNotEmpty)
          Text(list.description, style: text.titleMedium),
        const SizedBox(height: Space.xl),
        ActionButton(
          saved ? 'Kaydedilenlerden çıkar' : 'Listeyi kaydet',
          icon: saved ? GurmeGlyph.check : GurmeGlyph.archive,
          onPressed: () {
            ref.read(journalProvider.notifier).toggleRemoteSaved(list);
            setState(
              () => _notice = saved
                  ? 'Liste kayıtlardan çıkarıldı.'
                  : 'Liste cihazına kaydedildi.',
            );
          },
        ),
        const SizedBox(height: Space.s),
        Builder(
          builder: (buttonContext) => ActionButton(
            'Bağlantıyı paylaş',
            icon: GurmeGlyph.share,
            secondary: true,
            onPressed: list.visibility == GurmeListVisibility.private
                ? null
                : () => shareLink(
                    buttonContext,
                    shareUrl(ref.read(apiBaseUrlProvider), list.id),
                    list.title,
                  ),
          ),
        ),
        if (_notice.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Space.m),
            child: Text(
              _notice,
              style: text.bodySmall!.copyWith(color: context.colors.ink),
            ),
          ),
        const Rule(space: Space.xxl),
        Eyebrow('Listedeki mekânlar (${list.items.length})'),
        if (list.items.isEmpty)
          const EmptyState(
            title: 'Bu liste henüz boş.',
            detail: 'Bu listede henüz mekân yok.',
          )
        else
          for (final (i, item) in list.items.indexed)
            Container(
              padding: const EdgeInsets.only(top: Space.xl, bottom: Space.s),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.colors.line)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ordinal(i + 1),
                        style: text.headlineSmall!.copyWith(
                          color: context.colors.tealText,
                        ),
                      ),
                      const SizedBox(width: Space.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: text.headlineSmall),
                            const SizedBox(height: Space.s),
                            Eyebrow(
                              [
                                item.area,
                                item.category,
                              ].where((s) => s.isNotEmpty).join(' · '),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (item.note.isNotEmpty)
                    NoteQuote(title: 'Hazırlayanın notu', text: item.note),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: context.colors.ink,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => _addToJournal(item),
                      icon: GurmeIcon(GurmeGlyph.add, size: 14),
                      label: Eyebrow(
                        'Defterime ekle',
                        color: context.colors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        const Rule(),
        const Center(child: Eyebrow('Gurme · herkese açık liste')),
        const SizedBox(height: Space.l),
        // Başkalarının gördüğü içerik bildirilebilir (App Store 1.2).
        Center(
          child: LinkLabel(
            'Bu listeyi bildir',
            onTap: () => showReportListSheet(context, list.id),
          ),
        ),
      ],
    );
  }
}
