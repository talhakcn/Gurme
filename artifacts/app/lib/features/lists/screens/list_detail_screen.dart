import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/platform/external.dart';
import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../../journal/data/journal_models.dart';
import '../../journal/data/journal_notifier.dart';
import '../../journal/widgets/place_widgets.dart';
import '../data/list_repository.dart';
import '../data/list_sync.dart';
import '../widgets/list_widgets.dart';

class ListDetailScreen extends ConsumerStatefulWidget {
  const ListDetailScreen({super.key, required this.listId});

  final String listId;

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  var _alphabetic = false;
  ListVisibility? _choice;
  var _busy = false;
  var _error = '';
  var _notice = '';

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = '';
      _notice = '';
    });
    try {
      await action();
    } on ListSyncException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share(
    BuildContext origin,
    ListVisibility choice,
    String title,
  ) => _run(() async {
    final url = await ref.read(listSyncProvider).publish(widget.listId, choice);
    if (origin.mounted) await shareLink(origin, url, title);
  });

  Future<void> _saveVisibility(ListVisibility choice) => _run(() async {
    await ref.read(listSyncProvider).updateVisibility(widget.listId, choice);
    if (mounted) {
      setState(
        () => _notice = choice == ListVisibility.private
            ? 'Liste artık özel; paylaşım bağlantısı erişilemez.'
            : 'Görünürlük güncellendi.',
      );
    }
  });

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(journalDataProvider);
    final text = Theme.of(context).textTheme;
    final list = data.listById(widget.listId);

    if (list == null) {
      return GurmePage(
        masthead: const Masthead(back: true),
        children: [
          EmptyState(
            title: 'Liste bulunamadı.',
            detail: 'Bu liste kaldırılmış olabilir.',
            action: 'Listelere dön',
            onPressed: () => context.go('/lists'),
          ),
        ],
      );
    }

    final choice = _choice ?? list.visibility;
    final hasName = data.profile.name.trim().isNotEmpty;
    final placeOf = {for (final p in data.places) p.id: p};
    final items = [...list.items];
    if (_alphabetic) {
      items.sort(
        (a, b) => compareTr(
          placeOf[a.placeId]?.name ?? '',
          placeOf[b.placeId]?.name ?? '',
        ),
      );
    }

    return GurmePage(
      // Kendi listen: sağ üstte mekân sayfasındaki gibi düzenle. Kaydetme
      // yalnızca başkasının listesi içindir.
      masthead: Masthead(
        back: true,
        rightIcon: GurmeGlyph.edit,
        rightTooltip: 'Listeyi düzenle',
        onRight: () => context.push('/list/${list.id}/edit'),
      ),
      children: [
        PageTitle(list.title, style: text.headlineLarge),
        const SizedBox(height: Space.xs),
        Text(
          [
            if (list.city.isNotEmpty) list.city,
            hasName ? data.profile.name : 'Sen',
            'güncellendi ${formatDateTr(list.updatedAt)}',
          ].join(' · '),
          style: text.bodySmall,
        ),
        if (list.description.isNotEmpty) ...[
          const SizedBox(height: Space.l),
          Text('“${list.description}”', style: text.titleMedium),
        ],
        SectionTitle(items.isEmpty ? 'Mekânlar' : 'Mekânlar (${items.length})'),
        if (items.length > 1) ...[
          const Eyebrow('Sıralama'),
          const SizedBox(height: Space.s),
          SegmentRow<bool>(
            options: const [(false, 'Senin sıran'), (true, 'A–Z')],
            selected: _alphabetic,
            onSelected: (v) => setState(() => _alphabetic = v),
          ),
        ],
        if (items.isEmpty)
          EmptyState(
            title: 'Liste henüz boş.',
            detail:
                'Listeye adresler ekleyerek kişisel şehir rehberini tamamla.',
            action: 'Mekân ekle',
            onPressed: () => context.push('/list/${list.id}/edit'),
          )
        else
          for (final (i, item) in items.indexed)
            if (placeOf[item.placeId] case final place?) ...[
              // Not satırın içinde: bir sonraki mekâna aitmiş gibi okunmaz.
              PlaceRow(
                place: place,
                index: i + 1,
                footer: item.note.isEmpty
                    ? null
                    : NoteQuote(title: 'Neden bu listede?', text: item.note),
              ),
            ],
        const SectionTitle('Paylaş'),
        const Eyebrow('Kimler görebilir?'),
        const SizedBox(height: Space.s),
        SegmentRow<ListVisibility>(
          options: visibilityOptions,
          selected: choice,
          onSelected: (v) => setState(() {
            _choice = v;
            _error = '';
          }),
        ),
        const SizedBox(height: Space.s),
        Text(visibilityHint(choice), style: text.bodySmall),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Space.s),
            child: Text(
              _error,
              style: text.bodySmall!.copyWith(color: context.colors.error),
            ),
          ),
        if (!hasName)
          LinkLabel(
            'Görünen adını profilde ekle',
            onTap: () => context.push('/profile/edit'),
          ),
        if (_notice.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Space.s),
            child: Text(
              _notice,
              style: text.bodySmall!.copyWith(color: context.colors.ink),
            ),
          ),
        if (list.isPublished && choice != list.visibility) ...[
          const SizedBox(height: Space.l),
          ActionButton(
            _busy ? 'Kaydediliyor…' : 'Görünürlüğü kaydet',
            icon: GurmeGlyph.check,
            secondary: true,
            onPressed: _busy ? null : () => _saveVisibility(choice),
          ),
        ],
        const SizedBox(height: Space.xl),
        // Ekranın tek altın düğmesi: liste özelken görsel paylaşımı,
        // değilse bağlantıyla yayınlama.
        if (choice == ListVisibility.private && !list.isPublished)
          ActionButton(
            'Kapak görseli olarak paylaş',
            icon: GurmeGlyph.image,
            onPressed: () => context.push('/list/${list.id}/cover'),
          )
        else ...[
          Builder(
            // Paylaşım penceresi iPad'de bu düğmenin yanında açılır.
            builder: (buttonContext) => ActionButton(
              _busy
                  ? 'Eşitleniyor…'
                  : list.isPublished
                  ? 'Güncelle ve paylaş'
                  : 'Yayınla ve paylaş',
              icon: GurmeGlyph.share,
              onPressed: _busy
                  ? null
                  : () => _share(buttonContext, choice, list.title),
            ),
          ),
          LinkLabel(
            'Kapak görseli olarak paylaş',
            onTap: () => context.push('/list/${list.id}/cover'),
          ),
        ],
      ],
    );
  }
}
