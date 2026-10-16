import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../search/data/search_controller.dart';
import '../data/dish_summary.dart';
import '../widgets/dish_widgets.dart';
import '../widgets/place_widgets.dart';
import '../../../core/widgets/motion.dart';

const _maxPhotos = 4;

/// Deneyim ekleme ([visitId] yoksa) ve düzenleme.
class VisitEditScreen extends ConsumerStatefulWidget {
  const VisitEditScreen({super.key, required this.placeId, this.visitId});

  final String placeId;
  final String? visitId;

  @override
  ConsumerState<VisitEditScreen> createState() => _VisitEditScreenState();
}

class _VisitEditScreenState extends ConsumerState<VisitEditScreen>
    with DiscardGuard<VisitEditScreen> {
  late final Visit? _current;
  late var _date = _current?.date ?? isoDate(DateTime.now());
  late final _title = TextEditingController(text: _current?.title);
  late final _note = TextEditingController(text: _current?.note);
  late final _order = TextEditingController(text: _current?.order);
  late final _dishes = TextEditingController(text: _current?.dishes);

  /// Öneri mekân sayfasında verilir; eski deneyimlerin işareti korunur.
  late final _recommended = _current?.recommended ?? false;

  /// Yeni deneyimde cevapsız; seçili seçeneğe yeniden dokununca kalkar.
  late Revisit? _revisit = _current?.revisit;
  late var _photos = [...?_current?.photos];
  late var _scores = _current?.scores ?? const TastingScores();
  late var _tasted = [...?_current?.tastedDishes];

  /// Kartların kalıcı anahtarı: tabak çıkarılınca diğerlerinin not alanı
  /// karışmasın.
  late var _tastedKeys = [for (var i = 0; i < _tasted.length; i++) i];
  var _nextKey = 1000;

  /// Açık tabak kartı; yeni deneyimde hiçbiri, eklenen tabak açık gelir.
  int? _openDish;

  /// Eski kayıtların serbest "Ne tattın?" metni; yalnızca doluysa gösterilir.
  late final _hasLegacyOrder = (_current?.order ?? '').trim().isNotEmpty;
  late final _hasLegacyDishes = (_current?.dishes ?? '').trim().isNotEmpty;
  late VisitVisibility _visibility;
  var _pickingPhotos = false;

  @override
  List<Object?> get formValues => [
    _date,
    _title.text,
    _note.text,
    _order.text,
    _dishes.text,
    _revisit?.name,
    _photos,
    _scores.all,
    _visibility.name,
    [for (final d in _tasted) d.toJson()],
  ];

  @override
  void initState() {
    super.initState();
    final data = ref.read(journalDataProvider);
    _current = widget.visitId == null ? null : data.visitById(widget.visitId!);
    _visibility = _current?.visibility ?? data.profile.defaultVisitVisibility;
    watchFields([_title, _note, _order, _dishes]);
    rememberInitialValues();
  }

  @override
  void dispose() {
    for (final c in [_title, _note, _order, _dishes]) {
      c.dispose();
    }
    super.dispose();
  }

  /// iOS'ta sistemin tekerlekli seçicisi, diğerlerinde Material takvimi.
  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_date) ?? DateTime.now();
    final first = DateTime(1990);
    // Deneyim yaşanmış bir ziyarettir; gelecek tarih seçilemez.
    final last = DateTime.now();
    final platform = Theme.of(context).platform;
    final picked =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
        ? await _pickDateCupertino(initial, first, last)
        : await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: first,
            lastDate: last,
          );
    if (picked != null) setState(() => _date = isoDate(picked));
  }

  Future<DateTime?> _pickDateCupertino(
    DateTime initial,
    DateTime first,
    DateTime last,
  ) {
    var value = initial;
    final colors = context.colors;
    final brightness = Theme.of(context).brightness;
    return showCupertinoModalPopup<DateTime>(
      context: context,
      barrierColor: colors.scrim,
      builder: (sheet) => Container(
        color: colors.paper,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(sheet).pop(),
                    child: Text(
                      'Vazgeç',
                      style: TextStyle(color: colors.muted),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(sheet).pop(value),
                    child: Text(
                      'Tamam',
                      style: TextStyle(
                        color: colors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 216,
                child: CupertinoTheme(
                  data: CupertinoThemeData(brightness: brightness),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initial,
                    minimumDate: first,
                    maximumDate: last,
                    onDateTimeChanged: (d) => value = d,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhotos() async {
    final remaining = _maxPhotos - _photos.length;
    if (remaining <= 0 || _pickingPhotos) return;
    setState(() => _pickingPhotos = true);
    try {
      final picker = ImagePicker();
      final files = remaining == 1
          ? [
              ?await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 1600,
                imageQuality: 80,
              ),
            ]
          : await picker.pickMultiImage(
              maxWidth: 1600,
              imageQuality: 80,
              limit: remaining,
            );
      final store = ref.read(photoStoreProvider);
      final imported = [
        for (final f in files.take(remaining)) await store.import(f.path),
      ];
      if (mounted) setState(() => _photos = [..._photos, ...imported]);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraflar eklenemedi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _pickingPhotos = false);
    }
  }

  /// Fotoğrafı deneyimden çıkarır; "Geri al" onu aynı sıraya koyar.
  /// Kullanılmayan dosyalar ancak uygulama yeniden açılınca silinir.
  void _removePhoto(int index) {
    final photo = _photos[index];
    setState(() => _photos.removeAt(index));
    showUndo(ScaffoldMessenger.of(context), 'Fotoğraf kaldırıldı.', () {
      if (!mounted || _photos.contains(photo)) return;
      setState(() => _photos.insert(index.clamp(0, _photos.length), photo));
    });
  }

  /// Hiçbir alan zorunlu değil: tarih ve mekân bile "gittim" demeye yeter.
  void _submit() {
    ref
        .read(journalProvider.notifier)
        .saveVisit(
          Visit(
            id: _current?.id ?? '',
            placeId: widget.placeId,
            date: _date,
            title: _title.text.trim(),
            note: _note.text.trim(),
            order: _order.text.trim(),
            recommended: _recommended,
            revisit: _revisit,
            dishes: _dishes.text.trim(),
            photos: _photos,
            visibility: _visibility,
            scores: _scores,
            tastedDishes: [
              for (final d in _tasted)
                d.copyWith(name: d.name.trim(), note: d.note.trim()),
            ],
          ),
        );
    markSaved();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    showNotice(
      messenger,
      _current == null ? 'Deneyim deftere eklendi.' : 'Deneyim kaydedildi.',
    );
  }

  /// Bu mekândaki puanlı ziyaretlerin ortalamaları, bu ziyaret dahil,
  /// tarihe göre eskiden yeniye.
  List<double> _trend(JournalData data, Visit? current) {
    final average = _scores.average;
    if (average == null) return const [];
    final dated = [
      for (final v in data.visitsFor(widget.placeId))
        if (v.id != current?.id && v.scores.average != null)
          (v.date, v.scores.average!),
      (_date, average),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final (_, a) in dated) a];
  }

  /// Bu mekânda daha önce tadılan tabaklar (bu deneyim hariç), en son
  /// hâlleriyle, en yeniden eskiye.
  List<TastedDish> _previousDishes(JournalData data) {
    final visits = [
      for (final v in data.visitsFor(widget.placeId))
        if (v.id != _current?.id) v,
    ]..sort((a, b) => b.date.compareTo(a.date));
    final seen = <String>{};
    return [
      for (final v in visits)
        for (final d in v.tastedDishes)
          if (d.key.isNotEmpty && seen.add(d.key)) d,
    ];
  }

  Future<void> _addDish(JournalData data, Place place) async {
    final venue = place.googlePlaceId == null
        ? null
        : ref.read(searchControllerProvider).venueById(place.googlePlaceId!);
    final taken = {for (final d in _tasted) d.key};
    final dish = await showAddDishSheet(
      context,
      kinds: dishKindsFor(place.category),
      previous: [
        for (final d in _previousDishes(data))
          if (!taken.contains(d.key)) d,
      ],
      highlights: venue?.insight?.highlights ?? const [],
    );
    if (dish == null || !mounted) return;
    setState(() {
      _tasted = [..._tasted, dish];
      _tastedKeys = [..._tastedKeys, _nextKey++];
      _openDish = _tasted.length - 1;
    });
  }

  void _removeDish(int index) {
    final dish = _tasted[index];
    final key = _tastedKeys[index];
    setState(() {
      _tasted = [..._tasted]..removeAt(index);
      _tastedKeys = [..._tastedKeys]..removeAt(index);
      _openDish = null;
    });
    showUndo(ScaffoldMessenger.of(context), '${dish.name} çıkarıldı.', () {
      if (!mounted) return;
      final at = index.clamp(0, _tasted.length);
      setState(() {
        _tasted = [..._tasted]..insert(at, dish);
        _tastedKeys = [..._tastedKeys]..insert(at, key);
      });
    });
  }

  /// Onay sorulmaz; silme alttaki "Geri al" ile geri alınabilir.
  void _delete(Visit current) {
    final messenger = ScaffoldMessenger.of(context);
    final undo = ref.read(journalProvider.notifier).deleteVisit(current.id);
    markSaved();
    context.pop();
    showUndo(messenger, 'Deneyim silindi.', undo);
  }

  List<Widget> _tastedSection(JournalData data, Place place) {
    final text = Theme.of(context).textTheme;
    final never = [
      for (final d in summarizeDishes(data.visitsFor(widget.placeId)))
        if (d.never && !_tasted.any((t) => t.key == normalizeForMatch(d.name)))
          d.name,
    ];
    return [
      const Eyebrow('Ne tattın?'),
      if (data.visits.length < 3)
        Text(
          'Her tabağı ayrı puanla. Bileşenleri işaretlemek isteğe bağlı.',
          style: text.bodySmall,
        ),
      const SizedBox(height: Space.m),
      if (never.isNotEmpty) ...[
        HintBox(text: 'Bir daha söyleme dediklerin: ${never.join(', ')}.'),
        const SizedBox(height: Space.m),
      ],
      for (final (i, dish) in _tasted.indexed)
        DishCard(
          key: ValueKey(_tastedKeys[i]),
          dish: dish,
          expanded: _openDish == i,
          onToggle: () => setState(() => _openDish = _openDish == i ? null : i),
          onChanged: (d) => setState(() => _tasted = [..._tasted]..[i] = d),
          onRemove: () => _removeDish(i),
        ),
      const SizedBox(height: Space.m),
      ActionButton(
        'Tabak ekle',
        icon: GurmeGlyph.add,
        secondary: true,
        onPressed: () => _addDish(data, place),
      ),
      const SizedBox(height: Space.xl),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(journalDataProvider);
    final text = Theme.of(context).textTheme;
    final p = data.placeById(widget.placeId);
    final current = _current;

    if (p == null) {
      return GurmePage(
        masthead: const Masthead(back: true),
        children: [
          EmptyState(
            title: 'Mekân bulunamadı.',
            detail: 'Önce bir mekân ekle.',
            action: 'Mekân ekle',
            onPressed: () => context.pushReplacement('/place/new'),
          ),
        ],
      );
    }

    final newcomer = data.visits.length < 3;
    final examples = visitExamples(p.category);
    return guarded(
      GurmePage(
        masthead: const Masthead(back: true),
        children: [
          PageTitle(
            current == null ? 'Deneyimini yaz' : 'Deneyimi düzenle',
            style: text.headlineLarge,
          ),
          Text(
            p.name,
            style: text.bodyMedium!.copyWith(color: context.colors.muted),
          ),
          // Yardım metinleri ilk birkaç deneyimde; sonra form sadeleşir,
          // ayrıntı rehberde durur.
          if (newcomer) ...[
            const SizedBox(height: Space.s),
            Text(
              'Hiçbir alan zorunlu değil; aklında kalanı yazman yeter.',
              style: text.bodySmall,
            ),
          ],
          const SizedBox(height: Space.xxl),
          const Eyebrow('Gittiğin gün'),
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: Space.m),
              margin: const EdgeInsets.only(bottom: Space.xl),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: context.colors.control),
                ),
              ),
              child: SpacedRow(
                left: Text(formatIsoDateTr(_date), style: text.bodyMedium),
                right: GurmeIcon(GurmeGlyph.calendar, size: 18),
              ),
            ),
          ),
          // Karne en üstte: asıl puan formun başında.
          _TastingCard(
            scores: _scores,
            onTap: (i, n) => setState(
              // Seçili kutuya yeniden dokununca puan kalkar.
              () => _scores = _scores.withScore(i, _scores.all[i] == n ? 0 : n),
            ),
            trend: _trend(data, current),
            help: newcomer,
          ),
          const SizedBox(height: Space.xl),
          // Fotoğraf karnenin ardından: deneyimin en görünür izi, mekânın
          // kapağı da buradan gelir.
          Eyebrow('Kendi fotoğrafların (${_photos.length}/$_maxPhotos)'),
          if (newcomer)
            Text(
              'Mekâna ayrıca kapak eklemediysen son deneyimindeki ilk '
              'fotoğraf kapak olur.',
              style: text.bodySmall,
            ),
          const SizedBox(height: Space.m),
          Wrap(
            spacing: Space.s,
            runSpacing: Space.s,
            children: [
              for (final (i, photo) in _photos.indexed)
                InkWell(
                  onTap: () => _removePhoto(i),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      JournalPhoto(photo, width: 74, height: 74),
                      Text('Kaldır ×', style: text.bodySmall),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.m),
          ActionButton(
            _pickingPhotos ? 'Fotoğraflar hazırlanıyor…' : 'Fotoğraf seç',
            icon: GurmeGlyph.image,
            secondary: true,
            onPressed: _photos.length >= _maxPhotos ? null : _pickPhotos,
          ),
          const SizedBox(height: Space.xl),
          ..._tastedSection(data, p),
          const SizedBox(height: Space.xl),
          Field(
            label: 'Deneyim başlığı',
            controller: _title,
            placeholder: examples.title,
          ),
          if (_hasLegacyOrder)
            Field(
              label: 'Ne tattın? (eski not)',
              controller: _order,
              placeholder: 'Bir kahve, bir tabak…',
            ),
          // Önerilen ürünler artık beğenilen tabaklardan okunur; eski
          // kayıtların metni yalnızca doluysa gösterilir.
          if (_hasLegacyDishes)
            Field(label: 'Önerdiğin ürünler (eski not)', controller: _dishes),
          Field(
            label: 'Notun',
            controller: _note,
            placeholder: examples.note,
            multiline: true,
          ),
          const Eyebrow('Tekrar gider misin?'),
          const SizedBox(height: Space.s),
          SegmentRow<Revisit>(
            options: const [
              (Revisit.yes, 'Evet'),
              (Revisit.no, 'Hayır'),
              (Revisit.undecided, 'Belki'),
            ],
            selected: _revisit,
            onSelected: (v) =>
                setState(() => _revisit = _revisit == v ? null : v),
          ),
          const SizedBox(height: Space.xl),
          SaveButton(
            current == null ? 'Deneyimi kaydet' : 'Değişiklikleri kaydet',
            onPressed: _submit,
          ),
          if (current != null)
            DangerLink('Deneyimi sil', onPressed: () => _delete(current)),
        ],
      ),
    );
  }
}

/// Dört ölçüt için 1–5 kutu ve ortalama.
class _TastingCard extends StatelessWidget {
  const _TastingCard({
    required this.scores,
    required this.onTap,
    required this.trend,
    this.help = true,
  });

  final TastingScores scores;

  /// Uzun açıklama yalnızca ilk deneyimlerde; sonra tek kısa satır.
  final bool help;

  /// [TastingScores.labels] sırasındaki ölçüt ve dokunulan kutu (1–5).
  final void Function(int index, int score) onTap;

  /// Bu mekândaki puanlı ziyaretlerin ortalamaları, bu ziyaret dahil.
  final List<double> trend;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final average = scores.average;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Karne'),
        Text(
          help
              ? 'Her ölçütü 1–5 arası puanla; boş bıraktığın ölçüt '
                    'ortalamaya katılmaz. Seçili kutuya yeniden dokunursan '
                    'puan kalkar. Mekânın lezzet izi bu puanlardan çizilir.'
              : 'Seçili kutuya yeniden dokunursan puan kalkar.',
          style: text.bodySmall,
        ),
        for (final (i, label) in TastingScores.labels.indexed)
          Container(
            padding: const EdgeInsets.symmetric(vertical: Space.s),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: context.colors.line)),
            ),
            child: Builder(
              builder: (context) {
                final boxes = <Widget>[
                  for (var n = 1; n <= 5; n++)
                    Semantics(
                      button: true,
                      selected: scores.all[i] == n,
                      label: '$label $n / 5',
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onTap(i, n);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(Space.xs),
                          child: AnimatedContainer(
                            duration: Motion.short,
                            curve: Motion.curve,
                            // 36 + kenar boşluğu: dokunma alanı 44 pt.
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: n <= scores.all[i]
                                  ? context.colors.mark
                                  : Colors.transparent,
                              border: Border.all(
                                color: n <= scores.all[i]
                                    ? context.colors.mark
                                    : context.colors.control,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ];
                // Büyük yazıda ölçüt adı karelerin üstünde: yan yana
                // kalınca "Fiyat / değer" iki satıra kırılıyordu.
                if (MediaQuery.textScalerOf(context).scale(1) > 1.2) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: text.bodyMedium),
                      Row(children: boxes),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: Text(label, style: text.bodyMedium)),
                    ...boxes,
                  ],
                );
              },
            ),
          ),
        if (average != null)
          Padding(
            padding: const EdgeInsets.only(top: Space.m),
            // Büyük yazıda açıklama puanın yanında dar bir sütuna sıkışmaz,
            // altına iner.
            child: Builder(
              builder: (context) {
                final score = Text.rich(
                  TextSpan(
                    text: formatScore(average),
                    style: text.displayLarge,
                    children: [
                      TextSpan(text: ' / 5', style: text.headlineSmall),
                    ],
                  ),
                );
                final note = Text(
                  // Büyük sayı bu deneyimin karnesi; dizi mekândaki bütün
                  // karneler, tarih sırasıyla.
                  trend.length < 2
                      ? 'Bu deneyimin karnesi, 5 üzerinden'
                      : 'Bu deneyimin karnesi. Bu mekândaki karnelerin, '
                            'eskiden yeniye: '
                            '${trend.map(formatScore).join(' → ')}',
                  style: text.bodySmall,
                );
                if (MediaQuery.textScalerOf(context).scale(1) > 1.3) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      score,
                      const SizedBox(height: Space.xs),
                      note,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Puan her zaman ölçeğiyle.
                    score,
                    const SizedBox(width: Space.m),
                    Expanded(child: note),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
