import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../../../core/widgets/gurme_map.dart';
import '../../hints/hints.dart';
import '../data/journal_models.dart';
import '../data/journal_notifier.dart';
import '../widgets/place_widgets.dart';
import '../widgets/quick_add_sheet.dart';
import 'place_detail_screen.dart';

enum _StatusFilter { all, want, went, recommend }

/// Arşivim: defterdeki bütün mekânlar, arama ve filtrelerle.
class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  final _query = TextEditingController();
  var _status = _StatusFilter.all;
  var _city = '';
  var _district = '';
  var _category = '';
  var _moreFilters = false;

  /// Liste yerine (üstünde) harita.
  var _map = false;

  /// Boş: defterdeki sıra (son eklenen önce).
  var _sort = '';
  static const _byName = 'Ada göre';
  static const _byScore = 'Karneye göre';

  /// Liste–ayrıntı düzeninde sağda açık mekân.
  String? _selected;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool _matches(Place p) {
    final q = toLowerTr(_query.text.trim());
    final statusOk = switch (_status) {
      _StatusFilter.all => true,
      _StatusFilter.want => p.status == PlaceStatus.want,
      _StatusFilter.went => p.status == PlaceStatus.went,
      _StatusFilter.recommend => p.recommended,
    };
    return statusOk &&
        (_city.isEmpty || p.city == _city) &&
        (_district.isEmpty || p.district == _district) &&
        (_category.isEmpty || p.category == _category) &&
        toLowerTr(
          '${p.name} ${p.district} ${p.city} ${p.category} ${p.description}',
        ).contains(q);
  }

  void _clearFilters() => setState(() {
    _query.clear();
    _status = _StatusFilter.all;
    _city = _district = _category = '';
  });

  /// Süzülen mekânların haritası; yeri bilinmeyenler sayıyla söylenir.
  List<Widget> _mapOf(BuildContext context, List<Place> places) {
    final located = places.where((p) => p.hasLocation).toList();
    final missing = places.length - located.length;
    return [
      const SizedBox(height: Space.s),
      // Yeri bilinen mekân yoksa boş harita değil, yalnızca açıklama.
      if (located.isNotEmpty)
        GurmeMap(
          pins: [
            for (final p in located)
              MapPin(
                id: p.id,
                title: p.name,
                detail: placeStatusLabel(p),
                lat: p.lat!,
                lng: p.lng!,
                onOpen: () => context.push('/place/${p.id}'),
              ),
          ],
        ),
      if (missing > 0)
        Padding(
          padding: const EdgeInsets.only(top: Space.s),
          child: Text(
            located.isEmpty
                ? 'Bu mekânların haritada yeri yok. Aramadan eklenen '
                      'mekânların yeri bilinir.'
                : '$missing mekânın haritada yeri yok; aramadan eklenen '
                      'mekânların yeri bilinir.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      const SizedBox(height: Space.l),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(journalDataProvider);
    final places = data.places;
    final filtered = places.where(_matches).toList();
    // Karnesi olmayan mekân karne sıralamasında sona düşer.
    double score(Place p) {
      final averages = [
        for (final v in data.visitsFor(p.id)) ?v.scores.average,
      ];
      return averages.isEmpty
          ? -1
          : averages.reduce((a, b) => a + b) / averages.length;
    }

    switch (_sort) {
      case _byName:
        filtered.sort((a, b) => compareTr(a.name, b.name));
      case _byScore:
        filtered.sort((a, b) => score(b).compareTo(score(a)));
    }
    final text = Theme.of(context).textTheme;

    List<String> distinct(Iterable<String> values) =>
        values.map((v) => v.trim()).where((v) => v.isNotEmpty).toSet().toList()
          ..sort(compareTr);

    // [inPane]: liste–ayrıntı düzeninin sol sütunu.
    GurmePage list({required bool inPane}) => GurmePage(
      children: [
        PageTitle('Arşivim', style: text.headlineLarge),
        const SizedBox(height: Space.m),
        TextField(
          controller: _query,
          onChanged: (_) => setState(() {}),
          style: text.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Kayıtlarımda ara…',
            hintStyle: TextStyle(color: context.colors.muted),
          ),
        ),
        const SizedBox(height: Space.l),
        // Tek satır, yatay kaydırılır: dar ekranda tek kutu alta düşmez.
        ChoiceStrip(
          children: [
            for (final (value, label) in const [
              (_StatusFilter.all, 'Tümü'),
              (_StatusFilter.want, 'Gideceğim'),
              (_StatusFilter.went, 'Gittim'),
              (_StatusFilter.recommend, 'Öneriyorum'),
            ])
              ChoiceBox(
                label: label,
                selected: _status == value,
                onTap: () => setState(() => _status = value),
              ),
          ],
        ),

        ...() {
          // Tek seçenekli filtre gösterilmez; filtreler istenince açılır.
          final rows = [
            if (places.length > 1)
              FilterChipsRow(
                title: 'Sırala',
                allLabel: 'Son eklenen',
                choices: const [_byName, _byScore],
                selected: _sort,
                onSelected: (v) => setState(() => _sort = v),
              ),
            if (distinct(places.map((p) => p.city)) case final c
                when c.length > 1)
              FilterChipsRow(
                title: 'Şehir',
                choices: c,
                selected: _city,
                onSelected: (v) => setState(() {
                  _city = v;
                  _district = '';
                }),
              ),
            if (distinct(
                  places
                      .where((p) => _city.isEmpty || p.city == _city)
                      .map((p) => p.district),
                )
                case final d when d.length > 1)
              FilterChipsRow(
                title: 'Semt',
                choices: d,
                selected: _district,
                onSelected: (v) => setState(() => _district = v),
              ),
            if (distinct(places.map((p) => p.category)) case final c
                when c.length > 1)
              FilterChipsRow(
                title: 'Tür',
                choices: c,
                selected: _category,
                onSelected: (v) => setState(() => _category = v),
              ),
          ];
          if (rows.isEmpty) return const <Widget>[];
          final active = [
            _city,
            _district,
            _category,
            _sort,
          ].where((v) => v.isNotEmpty).length;
          final open = _moreFilters || active > 0;
          return [
            LinkLabel(
              open
                  ? 'Filtreleri gizle'
                  : active > 0
                  ? 'Filtreler ($active)'
                  : 'Sırala ve süz',
              onTap: () => setState(() => _moreFilters = !open),
            ),
            if (open) ...rows,
          ];
        }(),
        const Rule(),
        SpacedRow(
          left: Eyebrow('${filtered.length} mekân'),
          right: filtered.isEmpty
              ? const SizedBox.shrink()
              : LinkLabel(
                  _map ? 'Haritayı kapat' : 'Haritada gör',
                  onTap: () => setState(() => _map = !_map),
                ),
        ),
        if (_map && filtered.isNotEmpty) ..._mapOf(context, filtered),
        if (filtered.isEmpty)
          EmptyState(
            title: places.isEmpty
                ? 'Arşivin seni bekliyor.'
                : 'Bu aramada kayıt yok.',
            detail: places.isEmpty
                ? 'Gitmek istediğin ya da gittiğin yerleri burada biriktir.'
                : 'Arama veya filtreleri değiştirebilirsin.',
            action: places.isEmpty ? 'Mekân ekle' : 'Filtreleri temizle',
            onPressed: places.isEmpty
                ? () => showQuickAddSheet(context)
                : _clearFilters,
          )
        else ...[
          for (final (i, p) in filtered.indexed) ...[
            SwipeablePlaceRow(
              place: p,
              // İpuçları okununca yeniden kurulur (watch).
              peek:
                  i == 0 &&
                  ref.watch(hintsProvider) != null &&
                  ref.read(hintsProvider.notifier).shows('archive-gestures'),
              child: PlaceRow(
                place: p,
                index: i + 1,
                meta: [
                  placeStatusLabel(p),
                  if (data.visitsFor(p.id).length case final n when n > 0)
                    '$n deneyim',
                ].join(' · '),
              ),
            ),
          ],
          // Hareketler görünmez; bir kez, listenin altında anlatılır.
          // Unutulsa da eylemlerin hepsi satırdaki düğmede durur.
          const HintNote(
            id: 'archive-gestures',
            text:
                'Satırı sağa kaydır: Gittim / Gideceğim. Sola kaydır: sil. '
                'Bütün eylemler satırın sağındaki düğmede.',
          ),
          const SizedBox(height: Space.xl),
          // "Mekân ekle" her yerde aynı ağırlıkta, ikincil: altın düğme
          // ekranın asıl eylemine (Yol tarifi, Deneyim ekle, Ara,
          // Kaydet) ya da boş durumun tek eylemine kalır.
          ActionButton(
            'Mekân ekle',
            icon: GurmeGlyph.add,
            secondary: true,
            onPressed: () => showQuickAddSheet(context),
          ),
        ],
      ],
    );

    // Geniş ekranda (yatay iPad) liste solda, seçili mekân sağda. Seçim
    // filtrede kalmadıysa ilk kayıt açılır; liste boşsa yalnızca liste.
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth < listDetailWidth || filtered.isEmpty) {
          return list(inPane: false);
        }
        final selected = filtered.any((p) => p.id == _selected)
            ? _selected!
            : filtered.first.id;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: listColumnWidth,
              child: PlaceSelection(
                selectedId: selected,
                onSelect: (id) => setState(() => _selected = id),
                child: list(inPane: true),
              ),
            ),
            VerticalDivider(width: 1, color: context.colors.line),
            Expanded(
              child: PlaceDetailScreen(
                key: ValueKey(selected),
                placeId: selected,
                embedded: true,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Liste–ayrıntı düzeninin açıldığı en dar sayfa genişliği (yan menü
/// hariç): yatay iPad. Dikey iPad'de ayrıntı sütunu okunamayacak kadar
/// daralacağı için Arşiv tek sütun kalır.
const listDetailWidth = 880.0;

/// Liste–ayrıntı düzeninde liste sütunu.
const listColumnWidth = 380.0;
