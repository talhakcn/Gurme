import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/clock.dart';
import '../../../core/platform/external.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../data/journal_notifier.dart';
import '../data/today_pick.dart';
import 'place_cover.dart';

/// Keşfet'te "Bugün ne yesem?": gideceklerinden bir öneri. Gidecek mekân
/// yoksa hiçbir şey göstermez.
class TodayCard extends ConsumerStatefulWidget {
  const TodayCard({super.key});

  @override
  ConsumerState<TodayCard> createState() => _TodayCardState();
}

class _TodayCardState extends ConsumerState<TodayCard> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(journalDataProvider);
    final now = ref.watch(clockProvider)();
    final picks = rankTodayPicks(data, now);
    if (picks.isEmpty) return const SizedBox.shrink();

    final pick = picks[_index % picks.length];
    final p = pick.place;
    final text = Theme.of(context).textTheme;
    final days = now.difference(p.createdAt).inDays;
    final waiting = days < 1 ? 'Bugün ekledin' : '$days gündür gideceklerinde';
    final detail = [p.district, p.category].where((s) => s.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gün dilimi yazılmaz; Keşfet'in selamı zaten söylüyor.
        const SectionTitle('Bugün ne yesem?'),
        const SizedBox(height: Space.s),
        Container(
          decoration: BoxDecoration(
            // Gece krem çerçeve sert durur; denetim çizgisi rengi yeter.
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? context.colors.control
                  : context.colors.ink,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlaceCover(p, height: 168, google: true),
              InkWell(
                onTap: () => context.push('/place/${p.id}'),
                child: Padding(
                  padding: const EdgeInsets.all(Space.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: text.headlineMedium),
                      Eyebrow([...detail, waiting].join(' · ')),
                      if (p.description.isNotEmpty) ...[
                        const SizedBox(height: Space.m),
                        // Kendi notun, kendi sözlerinle.
                        MarginNote(
                          child: Text(
                            p.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: context.colors.line)),
                ),
                // Büyük yazıda düğmeler alt alta.
                child: Flex(
                  direction: largeText(context)
                      ? Axis.vertical
                      : Axis.horizontal,
                  crossAxisAlignment: largeText(context)
                      ? CrossAxisAlignment.stretch
                      : CrossAxisAlignment.center,
                  children: [
                    _flexible(
                      context,
                      _CardButton(
                        // Ne yaptığını söyler: haritada yol tarifi açar;
                        // dar ekranda tek satıra sığar.
                        'Yol tarifi',
                        filled: true,
                        // Uygulamadan çıkıp haritayı açtığı belli olsun.
                        icon: GurmeGlyph.map,
                        hint: 'Haritada açılır',
                        onTap: () async {
                          final opened = await openInMaps(
                            p.address.isNotEmpty
                                ? p.address
                                : [p.name, p.area].join(', '),
                          );
                          if (!opened && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Harita açılamadı.'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    _flexible(
                      context,
                      _CardButton(
                        'Başka öner',
                        onTap: picks.length < 2
                            ? null
                            : () => setState(() => _index++),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (pick.reasons.isNotEmpty) ...[
          const SizedBox(height: Space.m),
          Text('Neden bu? ${pick.reasons.join(' ')}', style: text.bodySmall),
        ],
      ],
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton(
    this.label, {
    required this.onTap,
    this.filled = false,
    this.icon,
    this.hint,
  });

  final String label;
  final VoidCallback? onTap;
  final bool filled;

  /// Düğmenin uygulama dışına çıkardığını söyleyen simge (harita).
  final GurmeGlyph? icon;

  /// Ekran okuyucuya ne olacağını söyler.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? context.colors.gold : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          alignment: Alignment.center,
          // Büyük yazıda düğme yazıyla birlikte uzar; yazı kenara yapışmaz.
          padding: const EdgeInsets.symmetric(
            horizontal: Space.l,
            vertical: Space.m,
          ),
          decoration: filled
              ? null
              : BoxDecoration(
                  border: largeText(context)
                      ? Border(top: BorderSide(color: context.colors.line))
                      : Border(left: BorderSide(color: context.colors.line)),
                ),
          child: Semantics(
            hint: hint,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  GurmeIcon(
                    icon!,
                    size: 18,
                    color: filled ? context.colors.onGold : context.colors.ink,
                  ),
                  const SizedBox(width: Space.s),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: onTap == null
                          ? context.colors.muted
                          : filled
                          ? context.colors.onGold
                          : context.colors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Yan yanayken eşit genişlik, alt altayken doğal yükseklik.
Widget _flexible(BuildContext context, Widget child) =>
    largeText(context) ? child : Expanded(child: child);
