import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/discard_guard.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../data/journal_models.dart';
import '../data/journal_notifier.dart';
import '../widgets/place_widgets.dart';

/// Mekân ekleme ([placeId] yoksa) ve düzenleme.
/// Hızlı eklemede yazılanlar; ayrıntılı forma geçince kaybolmaz.
typedef PlaceDraft = ({String name, PlaceStatus status, String source});

class PlaceEditScreen extends ConsumerStatefulWidget {
  const PlaceEditScreen({super.key, this.placeId, this.draft});

  final String? placeId;

  /// Yeni mekânda başlangıç değerleri (hızlı ekleme sayfasından).
  final PlaceDraft? draft;

  @override
  ConsumerState<PlaceEditScreen> createState() => _PlaceEditScreenState();
}

class _PlaceEditScreenState extends ConsumerState<PlaceEditScreen>
    with DiscardGuard<PlaceEditScreen> {
  late final Place? _current;
  late final _name = TextEditingController(text: _current?.name);
  late final _district = TextEditingController(text: _current?.district);
  late final _city = TextEditingController(text: _current?.city);
  late final _address = TextEditingController(text: _current?.address);
  late final _category = TextEditingController(text: _current?.category);
  late final _description = TextEditingController(text: _current?.description);
  late var _image = _current?.image ?? '';
  late var _status = _current?.status;
  late var _recommended = _current?.recommended ?? false;
  late var _source = _current?.source ?? '';
  late final Set<String> _selectedLists;
  var _error = '';
  var _pickingPhoto = false;

  @override
  List<Object?> get formValues => [
    _name.text,
    _district.text,
    _city.text,
    _address.text,
    _category.text,
    _description.text,
    _image,
    _status?.name,
    _recommended,
    _source,
    [..._selectedLists]..sort(),
  ];

  @override
  void initState() {
    super.initState();
    final data = ref.read(journalDataProvider);
    _current = widget.placeId == null ? null : data.placeById(widget.placeId!);
    _selectedLists = {
      for (final l in data.lists)
        if (!l.isPublished && _current != null && l.contains(_current.id)) l.id,
    };
    // Ad yazıldıkça kayıt düğmesi etkinleşir.
    _name.addListener(() => setState(() {}));
    // Tür yazıldıkça öneri seçimi ve "tanımadım" uyarısı güncellenir.
    _category.addListener(() => setState(() {}));
    watchFields([_name, _district, _city, _address, _category, _description]);
    rememberInitialValues();
    // Taslak, ilk değerler kaydedildikten sonra yazılır: form değişmiş
    // sayılır, çıkarken yazılanların atılıp atılmayacağı sorulur.
    if (widget.draft case final draft? when _current == null) {
      _name.text = draft.name;
      _status = draft.status;
      _source = draft.source;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _district,
      _city,
      _address,
      _category,
      _description,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_pickingPhoto) return;
    setState(() => _pickingPhoto = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (file == null) return;
      final path = await ref.read(photoStoreProvider).import(file.path);
      if (mounted) setState(() => _image = path);
    } catch (_) {
      if (mounted) setState(() => _error = 'Fotoğraf eklenemedi.');
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  Place? _duplicate(List<Place> places) {
    if (_name.text.trim().isEmpty) return null;
    return places
        .where(
          (p) =>
              p.id != _current?.id &&
              normalizeForMatch(p.name) == normalizeForMatch(_name.text) &&
              normalizeForMatch(p.district) ==
                  normalizeForMatch(_district.text) &&
              normalizeForMatch(p.city) == normalizeForMatch(_city.text),
        )
        .firstOrNull;
  }

  void _submit() {
    final data = ref.read(journalDataProvider);
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Mekân adı gerekli.');
      return;
    }
    if (_duplicate(data.places) != null) {
      setState(
        () => _error =
            'Bu ad, semt ve şehirle kayıtlı bir mekân var. Yeni kayıt yerine '
            'mevcut kaydı seç.',
      );
      return;
    }
    final journal = ref.read(journalProvider.notifier);
    Place apply(Place p) => p.copyWith(
      name: _name.text.trim(),
      district: _district.text.trim(),
      city: _city.text.trim(),
      address: _address.text.trim(),
      category: _category.text.trim().isEmpty ? 'Mekân' : _category.text.trim(),
      description: _description.text.trim(),
      image: _image,
      status: _status,
      recommended: _recommended,
      source: _source,
    );
    final current = _current;
    final placeId = current == null
        ? journal.addPlace(
            (id, now) => apply(Place(id: id, name: '', createdAt: now)),
          )
        : current.id;
    if (current != null) journal.updatePlace(placeId, apply);

    for (final l in data.lists.where((l) => !l.isPublished)) {
      if (l.contains(placeId) != _selectedLists.contains(l.id)) {
        journal.togglePlaceInList(l.id, placeId);
      }
    }
    markSaved();
    final messenger = ScaffoldMessenger.of(context);
    if (current == null) {
      context.pushReplacement('/place/$placeId');
    } else {
      context.pop();
    }
    showNotice(
      messenger,
      current == null ? 'Deftere eklendi.' : 'Mekân kaydedildi.',
    );
  }

  Future<void> _delete(Place current) async {
    final data = ref.read(journalDataProvider);
    if (data.lists.any((l) => l.isPublished && l.contains(current.id))) {
      await infoDialog(
        context,
        title: 'Önce paylaşılan listeden kaldır',
        message:
            'Bu mekân yayınlanmış bir listede yer alıyor. Önce listeyi '
            'düzenleyip eşitle, sonra mekânı sil.',
      );
      return;
    }
    final ok = await confirmDialog(
      context,
      title: 'Mekân silinsin mi?',
      message: 'Deneyimleri ve listelerdeki kaydı da silinecek.',
    );
    if (!ok || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final undo = ref.read(journalProvider.notifier).deletePlace(current.id);
    markSaved();
    context.go('/archive');
    showUndo(messenger, '${current.name} silindi.', undo);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(journalDataProvider);
    final text = Theme.of(context).textTheme;
    final current = _current;
    final suggestions = _name.text.trim().length >= 2
        ? data.places
              .where(
                (p) =>
                    p.id != current?.id &&
                    normalizeForMatch(p.name)
                        .contains(normalizeForMatch(_name.text)),
              )
              .take(5)
              .toList()
        : const <Place>[];

    if (widget.placeId != null && current == null) {
      return GurmePage(
        masthead: const Masthead(back: true),
        children: [
          EmptyState(
            title: 'Bu adres bulunamadı.',
            detail: 'Mekân silinmiş olabilir.',
            action: 'Arşive dön',
            onPressed: () => context.go('/archive'),
          ),
        ],
      );
    }

    final missing = _name.text.trim().isEmpty
        ? 'Kaydetmek için mekânın adını yaz.'
        : null;
    return guarded(
      GurmePage(
        masthead: const Masthead(back: true),
        children: [
          PageTitle(
            current == null ? 'Mekân ekle' : 'Mekânı düzenle',
            style: text.headlineLarge,
          ),
          const SizedBox(height: Space.s),
          Text(
            current == null
                ? 'Adresi elle yazabilir ya da Arama sekmesinden bulup '
                      'ekleyebilirsin.'
                : 'Değişiklikleri kaydetmeyi unutma.',
            style: text.bodySmall,
          ),
          const SizedBox(height: Space.xxl),
          Field(
            label: 'Mekân adı',
            controller: _name,
            placeholder: 'Örn. köşedeki küçük kahveci',
            onChanged: (_) => setState(() => _error = ''),
          ),
          Field(
            label: 'Semt',
            controller: _district,
            placeholder: 'Moda, Karaköy…',
          ),
          Field(label: 'Şehir', controller: _city, placeholder: 'İstanbul'),
          Field(
            label: 'Açık adres / konum (harita için)',
            controller: _address,
            placeholder: 'Sokak ve numara, açık adres…',
          ),
          if (suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: Space.xl),
              padding: const EdgeInsets.only(top: Space.m),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.colors.line)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Eyebrow(
                    'Bu kayıtlar zaten var · yalnızca senin defterin',
                  ),
                  for (final p in suggestions)
                    InkWell(
                      onTap: () => context.pushReplacement('/place/${p.id}'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: Space.m),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: context.colors.line),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: text.bodyMedium),
                            Text(
                              '${p.area} · ${p.category}  → Mevcut kaydı seç',
                              style: text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Field(
            label: 'Tür',
            controller: _category,
            placeholder: 'Kahve, lokanta, fırın…',
            // Tür serbest yazılır ama tabak türleri ve çizilen kapak ondan
            // çıkarılır: öneriler tanınan adları gösterir, tanınmayan ad
            // sessizce genel türe düşmez.
            footer: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChoiceStrip(
                  children: [
                    for (final c in categorySuggestions)
                      ChoiceBox(
                        label: c,
                        compact: true,
                        selected:
                            normalizeForMatch(_category.text.trim()) ==
                            normalizeForMatch(c),
                        onTap: () => setState(() => _category.text = c),
                      ),
                  ],
                ),
                if (!isKnownCategory(_category.text)) ...[
                  const SizedBox(height: Space.s),
                  Text(
                    'Bu türü tanımadım; tabaklar genel başlıklarla '
                    '(ana yemek, başlangıç, tatlı) puanlanır. Önerilerden '
                    'birini seçebilirsin.',
                    style: text.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          Field(
            label: 'Kısa tanım',
            controller: _description,
            placeholder: 'Nesi aklında kaldı?',
            multiline: true,
          ),
          // Fotoğraf formun ortasında değil, tanımın hemen ardında: mekânın
          // kapağı olur.
          const Eyebrow('Kapak fotoğrafı'),
          const SizedBox(height: Space.s),
          ActionButton(
            _pickingPhoto
                ? 'Fotoğraf hazırlanıyor…'
                : _image.isEmpty
                ? 'Fotoğraf seç'
                : 'Fotoğrafı değiştir',
            icon: GurmeGlyph.image,
            secondary: true,
            onPressed: _pickPhoto,
          ),
          if (_image.isNotEmpty) ...[
            const SizedBox(height: Space.m),
            JournalPhoto(_image, height: 220),
            RemoveLink(
              'Fotoğrafı kaldır',
              onPressed: () => setState(() => _image = ''),
            ),
          ],
          const SizedBox(height: Space.xl),
          const Eyebrow('Kayıt durumu'),
          const SizedBox(height: Space.s),
          SegmentRow<PlaceStatus>(
            options: const [
              (PlaceStatus.want, 'Gideceğim'),
              (PlaceStatus.went, 'Gittim'),
            ],
            selected: _status,
            onSelected: (value) => setState(() {
              _status = _status == value ? null : value;
              if (value == PlaceStatus.want) _recommended = false;
            }),
          ),
          CheckRow(
            label: 'Bu mekânı öneriyorum',
            checked: _recommended,
            onTap: () => setState(() {
              _recommended = !_recommended;
              if (_recommended) _status = PlaceStatus.went;
            }),
          ),
          const SizedBox(height: Space.xl),
          if (data.lists.isNotEmpty) ...[
            const Eyebrow('Hangi listeye?'),
            for (final l in data.lists)
              CheckRow(
                label: l.title,
                checked: l.isPublished
                    ? current != null && l.contains(current.id)
                    : _selectedLists.contains(l.id),
                detail: l.isPublished
                    ? 'Paylaşılan liste · eklemek için liste düzenleyiciye git'
                    : null,
                onTap: () => l.isPublished
                    ? context.push('/list/${l.id}/edit')
                    : setState(
                        () => _selectedLists.contains(l.id)
                            ? _selectedLists.remove(l.id)
                            : _selectedLists.add(l.id),
                      ),
              ),
            const SizedBox(height: Space.xl),
          ],
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.m),
              child: Text(
                _error,
                style: text.bodySmall!.copyWith(color: context.colors.error),
              ),
            ),
          SaveButton(
            current == null ? 'Mekânı kaydet' : 'Değişiklikleri kaydet',
            onPressed: _submit,
            missing: missing,
          ),
          if (current != null)
            DangerLink('Mekânı sil', onPressed: () => _delete(current)),
        ],
      ),
    );
  }
}
