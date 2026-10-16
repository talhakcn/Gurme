import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../data/google_photos.dart';
import '../data/journal_models.dart';
import '../data/journal_notifier.dart';
import 'drawn_cover.dart';
import 'place_widgets.dart';

/// Mekânın kapağı, sırasıyla: mekâna eklenen fotoğraf, deneyimlerdeki en
/// son fotoğraf, [google] açıksa mekânın Google fotoğrafı, türünden
/// çizilmiş kapak. Kullanıcının kendi fotoğrafı her zaman önce gelir.
///
/// Google fotoğrafı yalnızca çekeninin adını gösterecek kadar büyük
/// kapaklarda istenir (Google'ın koşulu); satırdaki küçük kapakta istenmez.
class PlaceCover extends ConsumerWidget {
  const PlaceCover(
    this.place, {
    super.key,
    required this.height,
    this.width,
    this.google = false,
  });

  final Place place;
  final double height;
  final double? width;
  final bool google;

  /// Mekânın kendi ya da deneyimlerindeki fotoğrafı; yoksa `null`.
  static String? photoOf(Place place, JournalData data) {
    if (place.image.isNotEmpty) return place.image;
    final visits =
        data.visitsFor(place.id).where((v) => v.photos.isNotEmpty).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return visits.firstOrNull?.photos.first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = photoOf(place, ref.watch(journalDataProvider));
    if (photo != null) {
      return JournalPhoto(photo, height: height, width: width);
    }
    final drawn = DrawnCover(
      category: place.category,
      height: height,
      width: width,
    );
    if (!google) return drawn;
    return switch (place.googlePlaceId) {
      final id? => GooglePhotoCover(
        placeId: id,
        height: height,
        width: width,
        fallback: drawn,
      ),
      null => drawn,
    };
  }
}

/// Google'daki mekân fotoğrafı ve altında çekeninin adı. Fotoğraf yoksa,
/// gelene kadar ya da yüklenemezse [fallback] görünür.
class GooglePhotoCover extends ConsumerWidget {
  const GooglePhotoCover({
    super.key,
    required this.placeId,
    required this.height,
    required this.fallback,
    this.width,
  });

  final String placeId;
  final double height;
  final double? width;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(googlePhotoProvider(placeId)).value;
    if (photo == null) return fallback;
    final text = Theme.of(context).textTheme;
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            photo.uri,
            fit: BoxFit.cover,
            color: nightPhotoDim(context),
            colorBlendMode: BlendMode.srcATop,
            cacheWidth:
                ((width ?? MediaQuery.sizeOf(context).width) *
                        MediaQuery.devicePixelRatioOf(context))
                    .round(),
            // Yüklenirken çizilmiş kapak durur; fotoğraf gelince yerini alır.
            frameBuilder: (context, child, frame, sync) =>
                frame == null && !sync ? fallback : child,
            errorBuilder: (context, error, stack) => fallback,
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Semantics(
              link: photo.authorUri != null,
              child: GestureDetector(
                onTap: photo.authorUri == null
                    ? null
                    : () => launchUrl(
                        Uri.parse(photo.authorUri!),
                        mode: LaunchMode.externalApplication,
                      ),
                child: Container(
                  color: const Color(0x99000000),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.s,
                    vertical: Space.xs,
                  ),
                  child: Text(
                    photo.author == null
                        ? 'Fotoğraf: Google'
                        : 'Fotoğraf: ${photo.author} · Google',
                    style: text.bodySmall!.copyWith(
                      color: GurmeColors.paper,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
