import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gurme_client/gurme_client.dart';

import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../account/data/auth_service.dart';
import '../../journal/data/journal_notifier.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../../../core/widgets/gurme_map.dart';
import '../data/recent_searches.dart';
import '../data/search_controller.dart';
import '../data/search_repository.dart';
import '../widgets/venue_widgets.dart';

/// Yapay zekâ destekli mekân araması.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _query;
  late final TextEditingController _city;
  final _cityFocus = FocusNode();
  Timer? _debounce;
  List<AutocompleteSuggestion> _suggestions = const [];
  var _validation = '';

  /// Sonuçların üstünde harita.
  var _map = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(searchControllerProvider);
    _query = TextEditingController(text: state.query);
    _city = TextEditingController(text: state.city);
    // Girişliyse kalan hak arama yapmadan da görünsün.
    Future.microtask(() {
      // Akış henüz değer vermemiş olabilir; anlık kullanıcıya bakılır.
      if (!mounted || ref.read(authServiceProvider).currentUser == null) return;
      ref.read(searchControllerProvider.notifier).loadQuota();
    });
    _cityFocus.addListener(() {
      if (!_cityFocus.hasFocus && mounted) {
        setState(() => _suggestions = const []);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _city.dispose();
    _cityFocus.dispose();
    super.dispose();
  }

  void _onCityChanged(String value) {
    ref.read(searchControllerProvider.notifier).setCity(value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final found = await ref
            .read(searchRepositoryProvider)
            .autocomplete(value);
        if (mounted && _city.text == value) {
          setState(() => _suggestions = found);
        }
      } on SearchException {
        // Öneri alınamazsa kullanıcı yazdığıyla arayabilir.
      }
    });
  }

  void _choose(AutocompleteSuggestion s) {
    ref.read(searchControllerProvider.notifier).chooseCity(s);
    _city.text = s.description;
    _cityFocus.unfocus();
    setState(() => _suggestions = const []);
  }

  /// Sonuçların başı; arama başlayınca ve bitince buraya kaydırılır.
  /// Form uzun olduğu için sonuç ve hata yoksa ilk ekranın dışında kalır.
  final _resultsKey = GlobalKey();

  void _revealResults() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _resultsKey.currentContext;
      if (target == null || !mounted) return;
      Scrollable.ensureVisible(
        target,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _suggestions = const []);
    final error = await ref.read(searchControllerProvider.notifier).submit();
    if (!mounted) return;
    setState(() => _validation = error ?? '');
    // Yalnızca yapılabilen arama hatırlanır.
    final done = ref.read(searchControllerProvider);
    if (done.phase == SearchPhase.done) {
      await ref
          .read(recentSearchesProvider.notifier)
          .add(done.searchedQuery, done.searchedCity);
    }
  }

  /// Son aramalardan biri seçilince kelime ve yer formda yerine konur;
  /// arama hakkı harcanmadan önce değiştirilebilir.
  void _useRecent(RecentSearch s) {
    final controller = ref.read(searchControllerProvider.notifier);
    _query.text = s.query;
    _city.text = s.city;
    controller.setQuery(s.query);
    controller.setCity(s.city);
    setState(() => _suggestions = const []);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final controller = ref.read(searchControllerProvider.notifier);
    ref.listen(searchControllerProvider.select((s) => s.phase), (prev, next) {
      if (prev != next &&
          (next == SearchPhase.loading || prev == SearchPhase.loading)) {
        _revealResults();
      }
    });
    final text = Theme.of(context).textTheme;
    final f = state.filters;
    // Giriş sistemi açık ve kullanıcı girmemişse arama sunucuda reddedilir.
    // Giriş kapalıyken (Firebase kurulmamış) arama girişsiz çalışır.
    final needsSignIn =
        ref.watch(authServiceProvider).enabled &&
        ref.watch(currentUserProvider).value == null;
    final quotaLeft = switch (state.quota) {
      final q? => (q.searchesLimit - q.searchesUsed).clamp(0, q.searchesLimit),
      null => null,
    };

    // Sonuç ya da hata gelince ekran okuyucu duyurur; kullanıcı aşağı
    // inmeden ne olduğunu öğrenir.
    ref.listen(searchControllerProvider, (previous, next) {
      if (previous?.phase == next.phase) return;
      final message = switch (next.phase) {
        SearchPhase.done when next.venues.isEmpty => 'Uygun mekân bulunamadı.',
        SearchPhase.done => '${next.venues.length} mekân bulundu.',
        SearchPhase.error => switch (next.errorCode) {
          'auth_required' || 'auth_invalid' => 'Arama için giriş yap.',
          'quota_exceeded' => 'Bugünkü ücretsiz araman bitti.',
          'places_budget' => 'Arama bugünlük kapandı.',
          'user_places_budget' => 'Bugünlük arama sınırına ulaştın.',
          'network' => 'İnternete bağlanılamadı.',
          'server' => 'Arama şu an yapılamıyor.',
          _ => 'Arama yapılamadı.',
        },
        _ => null,
      };
      if (message != null) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          message,
          TextDirection.ltr,
        );
      }
    });

    return GurmePage(
      children: [
        PageTitle('Ne yemek istersin?', style: text.headlineLarge),
        const SizedBox(height: Space.s),
        Text(
          'Google yorumlarını yapay zekâ özetler. Beğendiğini tek dokunuşla '
          'defterine ekle.',
          style: text.bodyMedium!.copyWith(color: context.colors.muted),
        ),
        // Giriş gerektiği "Ara"ya basınca değil, baştan söylenir.
        if (needsSignIn) ...[
          const SizedBox(height: Space.m),
          // Girişe götüren tek düğme formun altındaki ana eylem.
          const HintBox(
            text:
                'Yapay zekâ araması için giriş gerekir; her gün 3 ücretsiz '
                'arama hakkın olur.',
          ),
        ],
        const SizedBox(height: Space.xl),
        if (ref.watch(recentSearchesProvider) case final recent
            when recent.isNotEmpty) ...[
          const Eyebrow('Son aramaların'),
          const SizedBox(height: Space.s),
          ChoiceStrip(
            children: [
              for (final s in recent)
                ChoiceBox(
                  label: s.city.isEmpty ? s.query : '${s.query} · ${s.city}',
                  selected:
                      _query.text.trim() == s.query &&
                      _city.text.trim() == s.city,
                  onTap: () => _useRecent(s),
                ),
            ],
          ),
          const SizedBox(height: Space.xl),
        ],
        const Eyebrow('Ne arıyorsun?'),
        TextField(
          controller: _query,
          textInputAction: TextInputAction.search,
          onChanged: controller.setQuery,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            hintText: 'Lahmacun, üçüncü dalga kahve, brunch…',
            hintStyle: TextStyle(color: context.colors.muted),
          ),
        ),
        const SizedBox(height: Space.l),
        const Eyebrow('Nerede?'),
        TextField(
          controller: _city,
          focusNode: _cityFocus,
          onChanged: _onCityChanged,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            hintText: 'Şehir ya da semt',
            hintStyle: TextStyle(color: context.colors.muted),
          ),
        ),
        for (final s in _suggestions)
          InkWell(
            onTap: () => _choose(s),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: Space.m),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.colors.line)),
              ),
              child: Row(
                children: [
                  GurmeIcon(GurmeGlyph.pin, size: 16),
                  const SizedBox(width: Space.s),
                  Expanded(
                    child: Text(
                      s.description,
                      style: text.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: Space.xl),
        Eyebrow(
          state.activeFilterCount == 0
              ? 'Filtreler'
              : 'Filtreler · ${state.activeFilterCount} açık',
        ),
        const SizedBox(height: Space.s),
        // Tek satır, yatay kaydırılır: dar ekranda tek kutu alta düşmez.
        ChoiceStrip(
          children: [
            ChoiceBox(
              label: 'Alkolsüz',
              selected: f.alcoholFree || f.helal,
              onTap: () => controller.setFilters(
                f.copyWith(
                  alcoholFree: !(f.alcoholFree || f.helal),
                  helal: false,
                ),
              ),
            ),
            ChoiceBox(
              label: 'Helal',
              selected: f.helal,
              onTap: () => controller.setFilters(f.copyWith(helal: !f.helal)),
            ),
            ChoiceBox(
              label: 'Glutensiz',
              selected: f.glutenFree,
              onTap: () =>
                  controller.setFilters(f.copyWith(glutenFree: !f.glutenFree)),
            ),
            ChoiceBox(
              label: 'Çölyağa uygun',
              selected: f.celiac,
              onTap: () => controller.setFilters(f.copyWith(celiac: !f.celiac)),
            ),
          ],
        ),
        // Filtrelerin birbirine etkisi gizli kalmaz.
        if (f.helal || f.celiac) ...[
          const SizedBox(height: Space.s),
          Text(
            [
              if (f.helal) 'Helal seçince alkolsüz mekânlar aranır.',
              if (f.celiac)
                'Çölyağa uygun: glutensiz seçeneğin ötesinde, mutfağında '
                    'bulaşmaya dikkat edilen yerler.',
            ].join(' '),
            style: text.bodySmall,
          ),
        ],
        if (hasReviewBasedFilter(f))
          const NoticeBox(
            'Helal, glutensiz ve çölyak bilgisi Google yorumlarından tahmin '
            'edilir; mekânla teyit etmeden güvenme.',
          ),
        const SizedBox(height: Space.xl),
        // Girişsizken ana eylem girişe götürür; arama nasılsa reddedilir.
        if (needsSignIn)
          ActionButton(
            'Giriş yap ve ara',
            icon: GurmeGlyph.signIn,
            onPressed: () => context.push('/account'),
          )
        else
          // Hak bitince düğme kapanır; nedeni hemen altında yazar.
          ActionButton(
            state.phase == SearchPhase.loading ? 'Aranıyor…' : 'Ara',
            icon: GurmeGlyph.search,
            onPressed:
                state.phase == SearchPhase.loading ||
                    quotaLeft == 0 ||
                    _limitCodes.contains(state.errorCode)
                ? null
                : _submit,
          ),
        // Düğme kapalıysa nedeni hemen altında; aşağıdaki boş durum bunu
        // tekrarlamaz.
        // Üç sınırın (ücretsiz hak, kişisel ve genel günlük kapasite) nedeni
        // aynı yerde, aynı biçimde yazar.
        if (_limitNote(state, quotaLeft) case final note?)
          Padding(
            padding: const EdgeInsets.only(top: Space.s),
            child: Text(note, style: text.bodySmall),
          ),
        if (_validation.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Space.s),
            child: Text(
              _validation,
              style: text.bodySmall!.copyWith(color: context.colors.error),
            ),
          ),
        KeyedSubtree(
          key: _resultsKey,
          child: const Rule(space: Space.xxl),
        ),
        ..._results(context, state),
      ],
    );
  }

  static const _limitCodes = {
    'quota_exceeded',
    'places_budget',
    'user_places_budget',
  };

  /// Düğmenin altındaki satır: kalan hak ya da aramanın neden kapalı olduğu.
  String? _limitNote(SearchState state, int? quotaLeft) =>
      switch ((state.errorCode, state.quota, quotaLeft)) {
        ('user_places_budget', _, _) =>
          'Bugünlük arama sınırına ulaştın; gece yarısı yeniden açılır.',
        ('places_budget', _, _) =>
          'Arama bugünlük kapandı; gece yarısı yeniden açılır.',
        (_, final q?, final left?) when left > 0 =>
          'Bugün kalan ücretsiz arama: $left/${q.searchesLimit}',
        (_, final q?, _) =>
          'Bugünkü ${q.searchesLimit} ücretsiz araman bitti; gece yarısı '
              'yenilenir.',
        ('quota_exceeded', _, _) =>
          'Bugünkü ücretsiz araman bitti; gece yarısı yenilenir.',
        _ => null,
      };

  /// Arama yapılamayan ya da sonuç vermeyen durumda çıkış: aranan yer
  /// biliniyorsa deftere elle eklenir.
  Widget _manualAdd(BuildContext context) => LinkLabel(
    'Aradığın yeri biliyorsan elle ekle',
    onTap: () => context.push('/place/new'),
  );

  List<Widget> _results(BuildContext context, SearchState state) {
    final journal = ref.watch(journalDataProvider);
    final text = Theme.of(context).textTheme;
    switch (state.phase) {
      case SearchPhase.idle:
        return [
          Text(
            'Arama Google ve yapay zekâ kullandığı için günlük arama hakkın '
            'sınırlıdır.',
            style: text.bodySmall,
          ),
        ];
      case SearchPhase.loading:
        return const [SkeletonBlock(), SkeletonBlock(), SkeletonBlock()];
      case SearchPhase.error:
        if ((state.errorCode == 'auth_required' ||
                state.errorCode == 'auth_invalid') &&
            !ref.watch(authServiceProvider).enabled) {
          // Bu derlemede giriş yok: hesap ekranına göndermek çıkmaz yol olur.
          return [
            EmptyState(
              icon: null,
              secondary: true,
              title: 'Arama bu sürümde kapalı.',
              detail:
                  'Yapay zekâ araması hesapla çalışıyor; giriş bu sürümde '
                  'henüz açık değil. Bildiğin bir yeri deftere elle '
                  'ekleyebilirsin.',
            ),
            _manualAdd(context),
          ];
        }
        if (state.errorCode == 'auth_required' ||
            state.errorCode == 'auth_invalid') {
          return [
            EmptyState(
              icon: null,
              secondary: true,
              title: 'Arama için giriş yap.',
              detail:
                  'Yapay zekâ araması hesapla çalışır; her gün 3 ücretsiz '
                  'arama hakkın olur.',
              action: 'Giriş yap',
              onPressed: () => context.push('/account'),
            ),
          ];
        }
        // Neden düğmenin altında yazıyor; burada yalnızca ne yapılabileceği.
        if (_limitCodes.contains(state.errorCode)) {
          return [
            Text(
              'Defterin ve listelerin bu arada her zamanki gibi çalışır.',
              style: text.bodyMedium,
            ),
            _manualAdd(context),
          ];
        }
        // Ağ ve sunucu hatasında aranan kelime ve filtreler yerinde kalır;
        // yeniden denemek yukarıdaki "Ara" düğmesiyle: aynı işi yapan ikinci
        // bir düğme konmaz. Sunucunun genel iletisi gösterilmez: ne olduğu
        // ve ne yapılacağı burada yazar.
        final (title, detail) = switch (state.errorCode) {
          'network' => (
            'İnternete bağlanılamadı.',
            'Bağlantını kontrol edip yeniden “Ara”ya dokun; aradığın kelime ve '
                'filtreler yerinde duruyor.',
          ),
          'server' => (
            'Arama şu an yapılamıyor.',
            'Sunucuda geçici bir sorun var. Birkaç dakika sonra yeniden '
                '“Ara”ya dokun; aradığın kelime ve filtreler yerinde duruyor.',
          ),
          _ => (
            'Arama yapılamadı.',
            'Biraz sonra yeniden “Ara”ya dokun; aradığın kelime ve filtreler '
                'yerinde duruyor.',
          ),
        };
        return [
          EmptyState(icon: null, secondary: true, title: title, detail: detail),
          _manualAdd(context),
        ];
      case SearchPhase.done:
        if (state.venues.isEmpty) {
          return [
            EmptyState(
              icon: null,
              secondary: true,
              title: 'Uygun mekân bulunamadı.',
              detail: state.searchedFilters == noFilters
                  ? 'Farklı bir kelime ya da daha geniş bir bölge dene.'
                  : 'Filtreleri azaltmayı ya da daha geniş bir bölgeyi dene.',
              action: state.searchedFilters == noFilters
                  ? null
                  : 'Filtresiz ara',
              onPressed: () {
                ref
                    .read(searchControllerProvider.notifier)
                    .setFilters(noFilters);
                _submit();
              },
            ),
            _manualAdd(context),
          ];
        }
        final located = [
          for (final v in state.venues)
            if (v.location case final l?)
              MapPin(
                id: v.placeId,
                title: v.name,
                detail: [
                  ratingText(v),
                  if (journal.placeForVenue(v.placeId, v.name) != null)
                    'Defterde',
                ].join(' · '),
                lat: l.lat.toDouble(),
                lng: l.lng.toDouble(),
                onOpen: () =>
                    context.push('/venue/${Uri.encodeComponent(v.placeId)}'),
              ),
        ];
        return [
          SpacedRow(
            left: Eyebrow(
              '${state.venues.length} mekân · ${state.searchedQuery} · '
              '${state.searchedCity}',
            ),
            right: located.isEmpty
                ? const SizedBox.shrink()
                : LinkLabel(
                    _map ? 'Haritayı kapat' : 'Haritada gör',
                    onTap: () => setState(() => _map = !_map),
                  ),
          ),
          if (_map && located.isNotEmpty) ...[
            const SizedBox(height: Space.s),
            GurmeMap(pins: located),
            const SizedBox(height: Space.l),
          ],
          if (state.limitedResults)
            const NoticeBox(
              'Bu bölgede az sonuç var; puanı ya da yorum sayısı düşük mekânlar '
              'da gösteriliyor.',
            ),
          for (final (i, v) in state.venues.indexed)
            VenueCard(
              venue: v,
              inJournal: journal.placeForVenue(v.placeId, v.name) != null,
              index: i + 1,
              analyzing: state.analyzing.contains(v.placeId),
              filters: state.searchedFilters,
              onTap: () =>
                  context.push('/venue/${Uri.encodeComponent(v.placeId)}'),
            ),
        ];
    }
  }
}
