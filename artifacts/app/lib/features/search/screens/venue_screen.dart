import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gurme_client/gurme_client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/platform/external.dart';
import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../../journal/data/journal_notifier.dart';
import '../data/search_controller.dart';
import '../data/search_repository.dart';
import '../../journal/widgets/drawn_cover.dart';
import '../../journal/widgets/place_cover.dart';
import '../widgets/venue_widgets.dart';

/// Arama sonucundaki ya da bağlantıyla açılan bir Google mekânı.
class VenueScreen extends ConsumerStatefulWidget {
  const VenueScreen({super.key, required this.placeId});

  final String placeId;

  @override
  ConsumerState<VenueScreen> createState() => _VenueScreenState();
}

class _VenueScreenState extends ConsumerState<VenueScreen> {
  @override
  void initState() {
    super.initState();
    // Aramadan açıldıysa ve analizi yoksa iste.
    Future.microtask(
      () => ref
          .read(searchControllerProvider.notifier)
          .requestInsight(widget.placeId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(searchControllerProvider);
    final fromSearch = search.venueById(widget.placeId);
    if (fromSearch != null) {
      return _VenueView(
        venue: fromSearch,
        analyzing: search.analyzing.contains(widget.placeId),
        category: search.searchedQuery,
        fallbackCity: search.searchedCity,
      );
    }
    final fetched = ref.watch(venueProvider(widget.placeId));
    return fetched.when(
      data: (venue) => _VenueView(
        venue: venue,
        analyzing: false,
        category: '',
        fallbackCity: '',
      ),
      loading: () => const GurmePage(
        masthead: Masthead(back: true),
        children: [
          SkeletonBlock(height: 12, width: 120),
          SkeletonBlock(height: 42),
          SkeletonBlock(height: 120),
        ],
      ),
      error: (error, _) => GurmePage(
        masthead: const Masthead(back: true),
        children: [
          EmptyState(
            title: 'Mekân açılamadı.',
            detail: '$error',
            action: 'Tekrar dene',
            onPressed: () => ref.invalidate(venueProvider(widget.placeId)),
          ),
        ],
      ),
    );
  }
}

class _VenueView extends ConsumerWidget {
  const _VenueView({
    required this.venue,
    required this.analyzing,
    required this.category,
    required this.fallbackCity,
  });

  final Venue venue;
  final bool analyzing;

  /// Deftere eklenirken tür olarak kullanılan arama kelimesi.
  final String category;
  final String fallbackCity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final journal = ref.watch(journalDataProvider);
    final saved = journal.placeForVenue(venue.placeId, venue.name);
    final insight = venue.insight;
    final f = venue.features;

    void addToJournal() {
      final added = ref
          .read(journalProvider.notifier)
          .addFromSearch(
            googlePlaceId: venue.placeId,
            name: venue.name,
            address: venue.address,
            category: category.isEmpty
                ? ''
                : '${toUpperTr(category.substring(0, 1))}${category.substring(1)}',
            fallbackCity: fallbackCity,
            lat: venue.location?.lat.toDouble(),
            lng: venue.location?.lng.toDouble(),
          );
      context.push('/place/${added.id}');
    }

    Future<void> openMaps() async {
      final uri = venue.googleMapsUri;
      final opened = uri != null
          ? await launchUrl(
              Uri.parse(uri),
              mode: LaunchMode.externalApplication,
            )
          : await openInMaps('${venue.name}, ${venue.address}');
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Harita açılamadı.')));
      }
    }

    return GurmePage(
      masthead: const Masthead(back: true),
      children: [
        Eyebrow(
          venue.category == null
              ? 'Google mekânı'
              : '${categoryLabel(venue.category)} · arama sonucu',
        ),
        const SizedBox(height: Space.s),
        PageTitle(
          venue.name,
          style: text.displayLarge!.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: Space.m),
        Text(ratingText(venue), style: text.bodySmall),
        if (venue.address.isNotEmpty) ...[
          const SizedBox(height: Space.xs),
          Text(venue.address, style: text.bodySmall),
        ],
        const SizedBox(height: Space.l),
        GooglePhotoCover(
          placeId: venue.placeId,
          height: 200,
          fallback: DrawnCover(category: category, height: 200),
        ),
        if (venue.needsVerification)
          const NoticeBox(
            'Kullanıcılar bu mekân için bildirimde bulundu; bilgiler güncel '
            'olmayabilir.',
            icon: GurmeGlyph.flag,
          ),
        const SizedBox(height: Space.xl),
        if (saved == null)
          ActionButton(
            'Deftere ekle · gideceğim',
            icon: GurmeGlyph.save,
            onPressed: addToJournal,
          )
        else
          ActionButton(
            'Defterde · kaydı aç',
            icon: GurmeGlyph.archive,
            secondary: true,
            onPressed: () => context.push('/place/${saved.id}'),
          ),
        const SizedBox(height: Space.s),
        ActionButton(
          'Haritada aç · yol tarifi',
          icon: GurmeGlyph.pin,
          secondary: true,
          onPressed: openMaps,
        ),
        const Rule(),
        const Eyebrow('Yorumların özeti'),
        const SizedBox(height: Space.s),
        if (insight == null)
          Text(
            analyzing
                ? 'Yorumlar analiz ediliyor…'
                : 'Bu mekân için henüz analiz yok. Yorumu olmayan mekânlar '
                      'analiz edilemez.',
            style: text.bodySmall,
          )
        else ...[
          Text(insight.summary, style: text.titleMedium),
          if (insight.whyGo.isNotEmpty) ...[
            const SizedBox(height: Space.l),
            const Eyebrow('Neden gidilir?'),
            for (final item in insight.whyGo) _Bullet(item),
          ],
          if (insight.warnings.isNotEmpty) ...[
            const SizedBox(height: Space.m),
            const Eyebrow('Dikkat'),
            for (final item in insight.warnings) _Bullet(item),
          ],
          if (insight.highlights.isNotEmpty) ...[
            const SizedBox(height: Space.m),
            const Eyebrow('Öne çıkanlar'),
            const SizedBox(height: Space.s),
            Text(insight.highlights.join(' · '), style: text.bodyMedium),
          ],
          if (insight.vibeTags.isNotEmpty) ...[
            const SizedBox(height: Space.m),
            const Eyebrow('Ambiyans'),
            const SizedBox(height: Space.s),
            Wrap(
              spacing: Space.s,
              runSpacing: Space.s,
              children: [
                for (final tag in insight.vibeTags)
                  ChoiceBox(label: tag, selected: false, onTap: () {}),
              ],
            ),
          ],
        ],
        const Rule(),
        const Eyebrow('Özellikler'),
        const SizedBox(height: Space.s),
        _FeatureRow(
          'Alkol',
          signalLabel(
            f.alcohol,
            yes: 'Servis ediliyor',
            no: 'Servis edilmiyor',
          ),
        ),
        _FeatureRow('Helal', signalLabel(f.helal, yes: 'Olası', no: 'Değil')),
        _FeatureRow(
          'Glutensiz seçenek',
          signalLabel(f.glutenFree, yes: 'Olası', no: 'Yok'),
        ),
        _FeatureRow(
          'Çölyak için güvenli',
          signalLabel(f.celiacSafe, yes: 'Olası', no: 'Güvenli değil'),
        ),
        const NoticeBox(
          'Alkol bilgisi mümkünse Google verisinden gelir. Helal, glutensiz ve '
          'çölyak bilgisi en fazla 5 yorumdan yapay zekâ ile tahmin edilir; '
          'doğrulanmamıştır, mekânla teyit edin.',
        ),
        if (insight != null) ...[
          const SizedBox(height: Space.m),
          Text(
            'Analiz: ${formatDateTr(insight.analyzedAt)} · Kaynak: Google '
            'yorumları',
            style: text.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Space.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 1,
            margin: const EdgeInsets.only(top: Space.m, right: Space.s),
            color: context.colors.teal,
          ),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Space.m),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.line)),
      ),
      child: SpacedRow(
        left: Text(label, style: text.bodyMedium),
        right: Text(value, style: text.bodySmall),
      ),
    );
  }
}
