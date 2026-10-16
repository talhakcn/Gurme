import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../data/dish_summary.dart';
import '../data/journal_models.dart';
import '../data/journal_notifier.dart';

/// Bir türün bütün mekânlardaki tabakları, genel puana ya da tek bir
/// bileşene göre sıralı ("en iyi köfte nerede?").
class DishRankingScreen extends ConsumerStatefulWidget {
  const DishRankingScreen({super.key, required this.kind});

  final DishKind kind;

  @override
  ConsumerState<DishRankingScreen> createState() => _DishRankingScreenState();
}

class _DishRankingScreenState extends ConsumerState<DishRankingScreen> {
  /// Boş: genel puan.
  var _part = '';

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final data = ref.watch(journalDataProvider);
    final kind = widget.kind;
    final all = summarizeDishes(data.visits);
    final ofKind = all.where((d) => d.kind == kind).toList();
    final parts = rankableParts(all, kind);
    final ranked = rankDishes(all, kind, part: _part);
    final unranked = ofKind.where((d) => !ranked.contains(d)).toList();
    final places = {for (final d in ofKind) d.placeId}.length;
    final note = palateNote(all, kind);

    String detail(DishSummary d) => [
      if (_part.isNotEmpty)
        if (d.part(_part) case final p?) '${p.name}: ${p.text}',
      if (d.score != null) 'Genel ${formatScore(d.score!)} / 5',
      if (d.never) 'Bir daha söyleme',
    ].join(' · ');

    Widget row(String rank, DishSummary d) {
      final place = data.placeById(d.placeId);
      return InkWell(
        onTap: place == null ? null : () => context.push('/place/${place.id}'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Space.l),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.line)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 36,
                child: Text(rank, style: text.headlineMedium),
              ),
              const SizedBox(width: Space.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.name,
                      style: text.headlineSmall!.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      place?.name ?? 'Silinmiş mekân',
                      style: text.bodyMedium,
                    ),
                    if (detail(d) case final s when s.isNotEmpty)
                      Text(s, style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GurmePage(
      masthead: const Masthead(back: true),
      children: [
        PageTitle('${kind.label} sıralaman', style: text.headlineLarge),
        Text(
          '$places mekân · ${ofKind.length} tabak',
          style: text.bodyMedium!.copyWith(color: colors.muted),
        ),
        if (parts.isNotEmpty)
          FilterChipsRow(
            title: 'Neye göre?',
            choices: parts,
            selected: _part,
            onSelected: (v) => setState(() => _part = v),
            allLabel: 'Genel',
          ),
        const SizedBox(height: Space.xl),
        if (ranked.isEmpty)
          EmptyState(
            title: _part.isEmpty
                ? 'Henüz puanladığın tabak yok.'
                : '$_part için işaret yok.',
            detail: _part.isEmpty
                ? 'Tabağın genelini puanladıkça burada sıralanır.'
                : 'Bu bileşeni işaretlediğin tabaklar burada sıralanır.',
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.ink, width: 2)),
            ),
            child: Column(
              children: [
                for (final (i, d) in ranked.indexed) row('${i + 1}', d),
                for (final d in unranked) row('–', d),
              ],
            ),
          ),
        if (note != null) ...[
          const SizedBox(height: Space.xxl),
          Container(
            padding: const EdgeInsets.all(Space.l),
            decoration: BoxDecoration(
              color: colors.wash,
              border: Border(top: BorderSide(color: colors.ink, width: 2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Damak notun'),
                const SizedBox(height: Space.xs),
                Text(
                  'Genel puanını en çok ${toLowerTr(note.part)} belirliyor.',
                  style: text.titleMedium!.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: Space.xs),
                Text(
                  'Beğendiğin ${toLowerTr(note.part)}: ortalama '
                  '${formatScore(note.liked)} / 5. Beğenmediğin '
                  '${toLowerTr(note.part)}: ortalama '
                  '${formatScore(note.disliked)} / 5.',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
