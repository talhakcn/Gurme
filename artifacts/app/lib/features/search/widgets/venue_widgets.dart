import 'package:flutter/material.dart';
import 'package:gurme_client/gurme_client.dart';

import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';

String categoryLabel(VenueCategory? category) => switch (category) {
  VenueCategory.classic => 'Gözde',
  VenueCategory.discovery => 'Gizli keşif',
  VenueCategory.option => 'Seçenek',
  null => 'Mekân',
};

String signalLabel(Signal signal, {required String yes, required String no}) =>
    switch (signal) {
      Signal.yes => yes,
      Signal.no => no,
      Signal.unknown => 'Bilinmiyor',
    };

/// Yorumlardan tahmin edilen filtrelerden biri açık mı (helal, glutensiz,
/// çölyak). Bunlar için her zaman "doğrulanmamış" uyarısı gösterilir.
bool hasReviewBasedFilter(SearchFilters f) =>
    f.helal || f.glutenFree || f.celiac;

String ratingText(Venue v) {
  if (v.totalRatings == 0) return 'Henüz puan yok';
  final rating = v.rating.toStringAsFixed(1).replaceAll('.', ',');
  return '★ $rating · ${_thousands(v.totalRatings)} yorum';
}

String _thousands(int n) {
  final s = n.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}

/// Altın çizgili küçük uyarı kutusu.
class NoticeBox extends StatelessWidget {
  const NoticeBox(this.text, {super.key, this.icon = GurmeGlyph.info});

  final String text;
  final GurmeGlyph icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: Space.s),
      padding: const EdgeInsets.symmetric(
        horizontal: Space.s,
        vertical: Space.s,
      ),
      decoration: BoxDecoration(
        color: context.colors.pale,
        border: Border(left: BorderSide(color: context.colors.gold, width: 2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GurmeIcon(icon, size: 16, color: context.colors.ink),
          const SizedBox(width: Space.s),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

/// Arama sonucundaki bir mekân.
class VenueCard extends StatelessWidget {
  const VenueCard({
    super.key,
    required this.venue,
    required this.index,
    required this.analyzing,
    required this.filters,
    required this.onTap,
    this.inJournal = false,
  });

  /// Mekân zaten defterde; kartta belirtilir ki iki kez eklenmesin.
  final bool inJournal;
  final Venue venue;
  final int index;
  final bool analyzing;
  final SearchFilters filters;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final insight = venue.insight;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Space.l),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.colors.line)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (venue.category != null) ...[
                        Eyebrow(
                          categoryLabel(venue.category),
                          color: venue.category == VenueCategory.discovery
                              ? context.colors.ink
                              : null,
                        ),
                        const SizedBox(height: Space.xs),
                      ],
                      Text(venue.name, style: text.headlineSmall),
                      const SizedBox(height: Space.xs),
                      Text(
                        inJournal
                            ? '${ratingText(venue)} · Defterinde'
                            : ratingText(venue),
                        style: text.bodySmall,
                      ),
                      if (venue.address.isNotEmpty)
                        Text(
                          venue.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall,
                        ),
                    ],
                  ),
                ),
                GurmeIcon(
                  GurmeGlyph.next,
                  size: 20,
                  color: context.colors.muted,
                ),
              ],
            ),
            const SizedBox(height: Space.m),
            if (insight != null) ...[
              Text(insight.summary, style: text.bodyMedium),
              if (insight.vibeTags.isNotEmpty) ...[
                const SizedBox(height: Space.s),
                Eyebrow(insight.vibeTags.join(' · ')),
              ],
            ] else if (analyzing)
              Row(
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                  const SizedBox(width: Space.s),
                  Text('Yorumlar analiz ediliyor…', style: text.bodySmall),
                ],
              )
            else
              Text('Analiz için mekânı aç.', style: text.bodySmall),
            if (venue.needsVerification)
              const NoticeBox(
                'Kullanıcılar bu mekân için bildirimde bulundu; bilgiler '
                'güncel olmayabilir.',
                icon: GurmeGlyph.flag,
              )
            else if (hasReviewBasedFilter(filters) ||
                venue.filterStatus == FilterStatus.unverified)
              const NoticeBox(
                'Doğrulanmamış, mekânla teyit edin. Bilgi yorumlardan tahmin '
                'edildi.',
              ),
          ],
        ),
      ),
    );
  }
}
