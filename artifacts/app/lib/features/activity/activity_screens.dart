import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/text/turkish.dart';
import '../../core/theme/gurme_colors.dart';
import '../../core/widgets/editorial.dart';
import '../journal/data/journal_models.dart';
import '../journal/data/journal_notifier.dart';

/// Deneyimlerin tarihe göre, aylara bölünmüş zaman çizelgesi.
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(journalDataProvider);
    final text = Theme.of(context).textTheme;
    final places = {for (final p in data.places) p.id: p};
    // ISO tarih metin olarak sıralanabilir; en yeni üstte.
    final visits = [...data.visits]..sort((a, b) => b.date.compareTo(a.date));

    final children = <Widget>[];
    String? month;
    for (final v in visits) {
      final parsed = DateTime.tryParse(v.date);
      final label = parsed == null ? 'Tarihsiz' : formatMonthTr(parsed);
      if (label != month) {
        month = label;
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: Space.xl, bottom: Space.xs),
            child: Eyebrow(label),
          ),
        );
      }
      children.add(_VisitRow(visit: v, place: places[v.placeId]));
    }

    return GurmePage(
      masthead: const Masthead(back: true),
      children: [
        PageTitle('Etkinlik', style: text.headlineLarge),
        if (visits.isEmpty)
          EmptyState(
            title: 'Henüz deneyim yazmadın.',
            detail:
                'Yazdığın deneyimler burada, aylara bölünmüş olarak görünecek.',
            action: 'Arşive git',
            onPressed: () => context.go('/archive'),
          )
        else
          ...children,
      ],
    );
  }
}

class _VisitRow extends StatelessWidget {
  const _VisitRow({required this.visit, required this.place});

  final Visit visit;
  final Place? place;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final summary = visit.title.isNotEmpty ? visit.title : visit.note;
    return InkWell(
      onTap: place == null ? null : () => context.push('/place/${place!.id}'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: Space.l),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.colors.line)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Öneri mekânın; deneyim satırında tekrar yazılmaz.
            Text(formatIsoDateTr(visit.date), style: text.bodySmall),
            const SizedBox(height: Space.xs),
            Text(place?.name ?? 'Silinmiş mekân', style: text.headlineSmall),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: Space.s),
              Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium!.copyWith(color: context.colors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
