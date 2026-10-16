import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/discard_guard.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../../journal/data/journal_models.dart';
import '../../journal/data/journal_notifier.dart';
import '../data/list_repository.dart';
import '../data/list_sync.dart';
import '../widgets/list_widgets.dart';

/// Liste oluşturma ([listId] yoksa) ve düzenleme.
class ListEditScreen extends ConsumerStatefulWidget {
  const ListEditScreen({super.key, this.listId});

  final String? listId;

  @override
  ConsumerState<ListEditScreen> createState() => _ListEditScreenState();
}

class _ListEditScreenState extends ConsumerState<ListEditScreen>
    with DiscardGuard<ListEditScreen> {
  late final CuratedList? _current;
  late final _title = TextEditingController(text: _current?.title);
  late final _city = TextEditingController(text: _current?.city);
  late final _description = TextEditingController(text: _current?.description);
  late final _visibility = _current?.visibility ?? ListVisibility.private;

  /// Sıralı mekân kimlikleri ve her biri için not alanı.
  late final List<String> _placeIds;
  final _notes = <String, TextEditingController>{};
  var _picker = false;
  var _busy = false;
  var _error = '';

  @override
  List<Object?> get formValues => [
    _title.text,
    _city.text,
    _description.text,
    _visibility.name,
    _placeIds,
    [for (final id in _placeIds) _notes[id]?.text],
  ];

  @override
  void initState() {
    super.initState();
    _current = widget.listId == null
        ? null
        : ref.read(journalDataProvider).listById(widget.listId!);
    _placeIds = [for (final i in _current?.items ?? const []) i.placeId];
    for (final i in _current?.items ?? const <ListItem>[]) {
      _notes[i.placeId] = TextEditingController(text: i.note);
    }
    // Başlık yazıldıkça kayıt düğmesi etkinleşir.
    _title.addListener(() => setState(() {}));
    watchFields([_title, _city, _description, ..._notes.values]);
    rememberInitialValues();
  }

  @override
  void dispose() {
    for (final c in [_title, _city, _description, ..._notes.values]) {
      c.dispose();
    }
    super.dispose();
  }

  void _add(String placeId) => setState(() {
    _placeIds.add(placeId);
    _notes.putIfAbsent(placeId, TextEditingController.new);
    _picker = false;
  });

  /// Mekânı listeden çıkarır; notu saklanır, "Geri al" ikisini de
  /// eski yerine koyar.
  void _remove(int index) {
    final id = _placeIds[index];
    setState(() => _placeIds.removeAt(index));
    showUndo(ScaffoldMessenger.of(context), 'Mekân listeden çıkarıldı.', () {
      if (!mounted || _placeIds.contains(id)) return;
      setState(() => _placeIds.insert(index.clamp(0, _placeIds.length), id));
    });
  }

  void _move(int index, int direction) {
    final target = index + direction;
    if (target < 0 || target >= _placeIds.length) return;
    setState(() {
      final id = _placeIds.removeAt(index);
      _placeIds.insert(target, id);
    });
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) {
      await infoDialog(
        context,
        title: 'Liste adı gerekli',
        message: 'Listene bir ad ver.',
      );
      return;
    }
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final id = await ref
          .read(listSyncProvider)
          .save(
            listId: _current?.id,
            title: _title.text.trim(),
            description: _description.text.trim(),
            city: _city.text.trim(),
            items: [
              for (final id in _placeIds)
                ListItem(placeId: id, note: _notes[id]!.text.trim()),
            ],
            visibility: _visibility,
          );
      if (!mounted) return;
      markSaved();
      final messenger = ScaffoldMessenger.of(context);
      if (_current == null) {
        context.pushReplacement('/list/$id');
      } else {
        context.pop();
      }
      showNotice(
        messenger,
        _current == null ? 'Liste oluşturuldu.' : 'Liste kaydedildi.',
      );
    } on ListSyncException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(CuratedList current) async {
    // Yalnızca geri alınamayan silme onay ister; cihazdaki liste hemen
    // ardından geri alınabilir.
    if (current.isPublished) {
      final ok = await confirmDialog(
        context,
        title: 'Liste silinsin mi?',
        message:
            'Bu liste ve yayınlanmış kopyası kalıcı olarak silinecek; '
            'bağlantıyı açanlar artık göremez.',
        confirm: 'Evet, sil',
      );
      if (!ok) return;
    }
    if (!mounted || _busy) return;
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final messenger = ScaffoldMessenger.of(context);
      final undo = await ref.read(listSyncProvider).delete(current.id);
      markSaved();
      if (mounted) context.go('/lists');
      // Yalnızca bu cihazdaki liste geri alınabilir; yayınlanmış kopya
      // sunucudan da silindi.
      if (undo != null) {
        showUndo(messenger, '"${current.title}" silindi.', undo);
      } else {
        showNotice(messenger, '"${current.title}" silindi.');
      }
    } on ListSyncException catch (e) {
      if (mounted) {
        setState(
          () => _error =
              '${e.message} Liste sunucudan silinemedi; yerel kayıt korundu.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(journalDataProvider);
    final text = Theme.of(context).textTheme;
    final current = _current;

    if (widget.listId != null && current == null) {
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

    final available = data.places
        .where((p) => !_placeIds.contains(p.id))
        .toList();

    return guarded(
      GurmePage(
        masthead: const Masthead(back: true),
        children: [
          PageTitle(
            current == null ? 'Yeni bir liste' : 'Listeyi düzenle',
            style: text.headlineLarge,
          ),
          const SizedBox(height: Space.s),
          Text(
            'Mekânları seç, sıralamayı düzenle ve her biri için küçük bir not bırak.',
            style: text.bodySmall,
          ),
          const SizedBox(height: Space.xl),
          Field(
            label: 'Liste başlığı',
            controller: _title,
            placeholder: "Kadıköy'de sakin kahveciler",
          ),
          Field(
            label: 'Şehir / bölge',
            controller: _city,
            placeholder: 'İstanbul',
          ),
          Field(
            label: 'Kısa açıklama',
            controller: _description,
            placeholder: 'Bu adresleri neden seçtin?',
            multiline: true,
          ),
          // Görünürlük yalnızca liste sayfasının "Paylaş" bölümünde seçilir;
          // iki yerde seçilince hangisinin geçerli olduğu karışıyordu.
          Text(
            current?.isPublished ?? false
                ? 'Bu liste yayınlanmış; kaydettiğinde sunucudaki kopyası da '
                      'güncellenir.'
                : 'Liste önce cihazında kaydedilir. Kimlerin görebileceğini '
                      'liste sayfasının “Paylaş” bölümünde seçersin.',
            style: text.bodySmall,
          ),
          const Rule(),
          Eyebrow('Listedeki mekânlar (${_placeIds.length})'),
          const SizedBox(height: Space.s),
          // Listeye ekleme her yerde aynı biçimde: artı simgeli ikincil düğme.
          ActionButton(
            _picker ? 'Mekân seçimini kapat' : 'Mekân ekle',
            icon: _picker ? GurmeGlyph.close : GurmeGlyph.add,
            secondary: true,
            onPressed: () => setState(() => _picker = !_picker),
          ),
          const SizedBox(height: Space.s),
          Text(
            'Bir mekânı listeye almak, oraya gittiğin veya önerdiğin anlamına gelmez.',
            style: text.bodySmall,
          ),
          if (_picker)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final p in available)
                    ListTileFrame(
                      onTap: () => _add(p.id),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(p.name, style: text.bodyMedium),
                            ),
                            GurmeIcon(
                              GurmeGlyph.add,
                              size: 18,
                              color: context.colors.ink,
                            ),
                          ],
                        ),
                        if (p.area.isNotEmpty)
                          Text(p.area, style: text.bodySmall),
                      ],
                    ),
                  if (data.places.isEmpty)
                    Text(
                      'Önce arşivine bir mekân eklemelisin.',
                      style: text.bodySmall,
                    )
                  else if (available.isEmpty)
                    Text(
                      'Defterindeki bütün mekânlar bu listede.',
                      style: text.bodySmall,
                    ),
                  LinkLabel(
                    'Yeni mekân oluştur',
                    onTap: () => context.push('/place/new'),
                  ),
                ],
              ),
            ),
          for (final (i, placeId) in _placeIds.indexed)
            Container(
              key: ValueKey(placeId),
              // Satırı not alanının alt çizgisi ayırır; ayrıca bir ayırıcı
              // çizilmez (çift çizgi olurdu).
              padding: const EdgeInsets.symmetric(vertical: Space.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${ordinal(i + 1)}  '
                          '${data.placeById(placeId)?.name ?? 'Silinen mekân'}',
                          style: text.headlineSmall,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Yukarı taşı',
                        icon: GurmeIcon(GurmeGlyph.up, size: 18),
                        onPressed: i == 0 ? null : () => _move(i, -1),
                      ),
                      IconButton(
                        tooltip: 'Aşağı taşı',
                        icon: GurmeIcon(GurmeGlyph.down, size: 18),
                        onPressed: i == _placeIds.length - 1
                            ? null
                            : () => _move(i, 1),
                      ),
                      IconButton(
                        tooltip: 'Listeden çıkar',
                        icon: GurmeIcon(GurmeGlyph.close, size: 18),
                        onPressed: () => _remove(i),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _notes[placeId],
                    minLines: 1,
                    maxLines: 5,
                    style: Theme.of(context).textTheme.bodyMedium,
                    // Liste sayfasındaki başlıkla aynı ad.
                    decoration: InputDecoration(
                      hintText: 'Neden bu listede?',
                      hintStyle: TextStyle(color: context.colors.muted),
                    ),
                  ),
                ],
              ),
            ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Space.l),
              child: Text(
                _error,
                style: text.bodySmall!.copyWith(color: context.colors.error),
              ),
            ),
          const SizedBox(height: Space.xl),
          SaveButton(
            _busy
                ? 'Kaydediliyor…'
                : current == null
                ? 'Listeyi oluştur'
                : 'Listeyi kaydet',
            onPressed: _busy ? null : _submit,
            missing: _title.text.trim().isEmpty
                ? 'Kaydetmek için listeye bir ad ver.'
                : null,
          ),
          if (current != null)
            DangerLink(
              'Listeyi sil',
              onPressed: _busy ? null : () => _delete(current),
            ),
        ],
      ),
    );
  }
}
