import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../data/journal_models.dart';
import 'quick_add_sheet.dart';

/// Yeni defter için üç adım. Hepsi tamamlanınca görünmez.
class StartGuide extends StatelessWidget {
  const StartGuide({super.key, required this.data});

  final JournalData data;

  static bool isComplete(JournalData data) =>
      data.places.isNotEmpty && data.visits.isNotEmpty && data.lists.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final firstPlace = data.places.firstOrNull;
    final steps = [
      (
        'İlk mekânını ekle',
        'Gittiğin ya da gitmek istediğin bir yer.',
        data.places.isNotEmpty,
        () => showQuickAddSheet(context),
      ),
      (
        'İlk deneyimini yaz',
        'Ne yedin, nasıldı? Karneyle puanla.',
        data.visits.isNotEmpty,
        firstPlace == null
            ? () => showQuickAddSheet(context)
            : () => context.push('/place/${firstPlace.id}/visit/new'),
      ),
      (
        'İlk listeni oluştur',
        'Sevdiğin mekânları bir listede topla, paylaş.',
        data.lists.isNotEmpty,
        () => context.push('/list/new'),
      ),
    ];
    final done = steps.where((s) => s.$3).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'Başlarken',
          trailing: Text('$done / ${steps.length}', style: text.bodySmall),
        ),
        const SizedBox(height: Space.s),
        // İlerleme: üç parçalı çizgi.
        Row(
          children: [
            for (final (i, s) in steps.indexed) ...[
              if (i > 0) const SizedBox(width: Space.xs),
              Expanded(
                child: Container(
                  height: 3,
                  color: s.$3 ? context.colors.ink : context.colors.line,
                ),
              ),
            ],
          ],
        ),
        for (final (i, (title, detail, isDone, onTap)) in steps.indexed)
          InkWell(
            onTap: isDone ? null : onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: Space.m),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.colors.line)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDone ? context.colors.ink : null,
                      border: Border.all(
                        color: isDone
                            ? context.colors.ink
                            : context.colors.line,
                      ),
                    ),
                    child: isDone
                        ? GurmeIcon(
                            GurmeGlyph.check,
                            size: 16,
                            color: context.colors.paper,
                          )
                        : Text('${i + 1}', style: text.bodySmall),
                  ),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: text.bodyMedium!.copyWith(
                            color: isDone ? context.colors.muted : null,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (!isDone) Text(detail, style: text.bodySmall),
                      ],
                    ),
                  ),
                  if (!isDone)
                    GurmeIcon(
                      GurmeGlyph.next,
                      size: 20,
                      color: context.colors.muted,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Son 7 günün özeti: deneyim sayısı, yeni mekânlar ve ortalama karne.
({int visits, int added, double? score}) weekSummaryOf(
  JournalData data,
  DateTime now,
) {
  final since = now.subtract(const Duration(days: 7));
  final from = isoDate(since);
  final visits = data.visits.where((v) => v.date.compareTo(from) >= 0);
  final scores = [for (final v in visits) ?v.scores.average];
  return (
    visits: visits.length,
    added: data.places.where((p) => p.createdAt.isAfter(since)).length,
    score: scores.isEmpty
        ? null
        : scores.reduce((a, b) => a + b) / scores.length,
  );
}
