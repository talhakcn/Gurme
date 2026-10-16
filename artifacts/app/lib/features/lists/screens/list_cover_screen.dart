import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/platform/external.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/theme/gurme_theme.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../../journal/data/journal_models.dart';
import '../../journal/data/journal_notifier.dart';
import '../data/list_repository.dart';

/// Kapağın renk seçenekleri: zemin, yazı, numara rengi.
enum CoverStyle {
  paper('Kâğıt', GurmeColors.paper, GurmeColors.ink, GurmeColors.tealText),
  ink('Mürekkep', GurmeColors.ink, GurmeColors.paper, GurmeColors.gold),
  gold('Altın', GurmeColors.gold, GurmeColors.ink, GurmeColors.ink);

  const CoverStyle(this.label, this.ground, this.foreground, this.accent);

  final String label;
  final Color ground;
  final Color foreground;
  final Color accent;
}

/// Kapağın mantıksal boyutu; paylaşılan görsel 1080×1920 piksel.
const coverSize = Size(405, 720);
const _maxStops = 5;

/// Listeyi hikâye boyutunda bir görsel olarak paylaşma ekranı.
class ListCoverScreen extends ConsumerStatefulWidget {
  const ListCoverScreen({super.key, required this.listId});

  final String listId;

  @override
  ConsumerState<ListCoverScreen> createState() => _ListCoverScreenState();
}

class _ListCoverScreenState extends ConsumerState<ListCoverScreen> {
  final _boundary = GlobalKey();
  var _style = CoverStyle.ink;
  var _busy = false;

  Future<void> _share(
    BuildContext origin,
    CuratedList list,
    String? url,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await shareBoundaryImage(
        origin: origin,
        boundary: _boundary,
        file: File(
          '${ref.read(appDirectoryProvider).path}/exports/'
          'gurme-kapak-${list.id}.png',
        ),
        width: 1080,
        text: url == null ? list.title : '${list.title}\n$url',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kapak paylaşılamadı.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
    final url =
        list.remoteId != null && list.visibility != ListVisibility.private
        ? shareUrl(ref.watch(apiBaseUrlProvider), list.remoteId!)
        : null;

    return GurmePage(
      masthead: const Masthead(back: true),
      children: [
        PageTitle(list.title, style: text.headlineLarge),
        const SizedBox(height: 18),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: AspectRatio(
              aspectRatio: coverSize.aspectRatio,
              child: FittedBox(
                child: RepaintBoundary(
                  key: _boundary,
                  child: ListCover(
                    list: list,
                    places: data.places,
                    author: data.profile.name.trim(),
                    link: url,
                    style: _style,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.l),
        SegmentRow<CoverStyle>(
          options: [for (final s in CoverStyle.values) (s, s.label)],
          selected: _style,
          onSelected: (s) => setState(() => _style = s),
        ),
        const SizedBox(height: Space.m),
        Builder(
          builder: (buttonContext) => ActionButton(
            _busy ? 'Hazırlanıyor…' : 'Kapağı paylaş',
            icon: GurmeGlyph.share,
            onPressed: _busy ? null : () => _share(buttonContext, list, url),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          url == null
              ? 'Liste yayınlanmadığı için kapakta bağlantı yok; görselde '
                    'yalnızca liste adı, notu ve mekân adları görünür.'
              : 'Bağlantı kapağın altında ve paylaşım metninde yer alır.',
          style: text.bodySmall,
        ),
      ],
    );
  }
}

/// Paylaşılan görselin kendisi; [coverSize] boyutunda çizilir.
class ListCover extends StatelessWidget {
  const ListCover({
    super.key,
    required this.list,
    required this.places,
    required this.author,
    required this.style,
    this.link,
  });

  final CuratedList list;
  final List<Place> places;
  final String author;
  final CoverStyle style;
  final String? link;

  /// Kapak sabit boyutlu bir görseldir; yazıları sistem yazı boyutuyla
  /// büyümez, yoksa paylaşılan görsel taşar.
  @override
  Widget build(BuildContext context) =>
      MediaQuery.withNoTextScaling(child: Builder(builder: _cover));

  Widget _cover(BuildContext context) {
    final fg = style.foreground;
    TextStyle display(double size, {bool italic = false}) => TextStyle(
      fontFamily: GurmeFonts.display,
      fontSize: size,
      height: 1.05,
      color: fg,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );
    TextStyle label(double size, {FontWeight weight = FontWeight.w600}) =>
        TextStyle(
          fontFamily: GurmeFonts.body,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: 0.2,
          color: fg,
        );

    final placeOf = {for (final p in places) p.id: p};
    final stops = [for (final item in list.items) ?placeOf[item.placeId]];
    final districts = {
      for (final p in stops)
        if (p.district.isNotEmpty) p.district,
    };
    final where = [
      if (list.city.isNotEmpty) list.city,
      if (districts.length == 1) districts.first,
    ].join(' · ');
    final words = list.title.trim().split(RegExp(r'\s+'));
    final link = this.link;

    return SizedBox.fromSize(
      size: coverSize,
      child: Material(
        color: style.ground,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 34, 30, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('GURME', style: display(20).copyWith(letterSpacing: 4)),
                  Text('Lezzet listesi', style: label(10)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 2,
                    // Altın zeminde altın çizgi görünmez.
                    color: style == CoverStyle.gold
                        ? GurmeColors.ink
                        : GurmeColors.gold,
                  ),
                  const SizedBox(height: 14),
                  if (where.isNotEmpty) ...[
                    Text(where, style: label(11)),
                    const SizedBox(height: 14),
                  ],
                  Text.rich(
                    TextSpan(
                      children: [
                        if (words.length > 1)
                          TextSpan(
                            text:
                                '${words.sublist(0, words.length - 1).join(' ')} ',
                          ),
                        TextSpan(
                          text: words.last,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: display(list.title.length > 24 ? 38 : 50),
                  ),
                  if (list.description.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      '“${list.description}”',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: display(17, italic: true).copyWith(
                        height: 1.5,
                        color: fg.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
              Column(
                children: [
                  for (final (i, p) in stops.take(_maxStops).indexed)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: fg),
                          bottom: i == stops.take(_maxStops).length - 1
                              ? BorderSide(color: fg)
                              : BorderSide.none,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            (i + 1).toString().padLeft(2, '0'),
                            style: display(22).copyWith(color: style.accent),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: display(21),
                            ),
                          ),
                          if (p.district.isNotEmpty)
                            Text(
                              p.district,
                              style: label(10, weight: FontWeight.w400),
                            ),
                        ],
                      ),
                    ),
                  if (stops.length > _maxStops)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '+ ${stops.length - _maxStops} mekân daha',
                          style: label(10),
                        ),
                      ),
                    ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      '${author.isEmpty ? 'Gurme' : author} · '
                      '${stops.length} mekân',
                      style: label(10, weight: FontWeight.w400),
                    ),
                  ),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      // Görseldeki adrese dokunulamaz ve teknik görünür;
                      // bağlantı paylaşımın metninde gider.
                      child: Text(
                        link == null
                            ? 'Gurme uygulamasında'
                            : 'Bağlantısı gönderide',
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        style: label(9).copyWith(letterSpacing: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
