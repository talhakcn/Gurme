import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/clock.dart';
import '../../core/platform/external.dart';
import '../../core/text/turkish.dart';
import '../../core/widgets/editorial.dart';
import '../../core/widgets/gurme_icons.dart';
import '../journal/data/journal_notifier.dart';
import '../lists/screens/list_cover_screen.dart';
import 'summary_cover.dart';
import 'year_summary.dart';
import 'year_summary_screen.dart';

/// Ayın özeti: seçilen ayın defteri ve tek sayfalık paylaşım görseli.
/// Son 12 ay içinde kaydı olan aylar seçilebilir; bu ay her zaman listede.
class MonthSummaryScreen extends ConsumerStatefulWidget {
  const MonthSummaryScreen({super.key});

  @override
  ConsumerState<MonthSummaryScreen> createState() => _MonthSummaryScreenState();
}

class _MonthSummaryScreenState extends ConsumerState<MonthSummaryScreen> {
  final _boundary = GlobalKey();
  var _busy = false;
  var _style = CoverStyle.ink;

  /// Seçilen ay (yıl, ay); `null` ise bu ay.
  (int, int)? _picked;

  Future<void> _share(BuildContext origin, YearSummary s) async {
    if (_busy) return;
    setState(() => _busy = true);
    final mm = s.month.toString().padLeft(2, '0');
    try {
      await shareBoundaryImage(
        origin: origin,
        boundary: _boundary,
        file: File(
          '${ref.read(appDirectoryProvider).path}/exports/'
          'gurme-${s.year}-$mm.png',
        ),
        width: 1080,
        text: '${s.periodLabel} defterimden · Gurme',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Paylaşılamadı.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(journalDataProvider);
    final now = ref.watch(clockProvider)();
    final text = Theme.of(context).textTheme;
    final current = (now.year, now.month);

    // Son 12 ay, yeniden eskiye; kaydı olmayan geçmiş aylar çıkmaz.
    final months = <(int, int)>[
      for (var i = 0; i < 12; i++)
        (
          now.month - i > 0 ? now.year : now.year - 1,
          (now.month - i - 1) % 12 + 1,
        ),
    ];
    final summaries = {
      for (final (y, m) in months) (y, m): YearSummary.of(data, y, month: m),
    };
    final choices = [
      for (final ym in months)
        if (ym == current || !summaries[ym]!.isEmpty) ym,
    ];
    final picked = choices.contains(_picked) ? _picked! : current;
    final summary = summaries[picked]!;

    String label((int, int) ym) => ym.$1 == now.year
        ? monthNameTr(ym.$2)
        : '${monthNameTr(ym.$2)} ${ym.$1}';

    return GurmePage(
      masthead: const Masthead(back: true),
      children: [
        if (choices.length > 1) ...[
          ChoiceStrip(
            children: [
              for (final ym in choices)
                ChoiceBox(
                  label: label(ym),
                  selected: ym == picked,
                  onTap: () => setState(() => _picked = ym),
                ),
            ],
          ),
          const SizedBox(height: Space.xl),
        ],
        if (summary.isEmpty) ...[
          Text('${summary.periodLabel} defterin', style: text.headlineLarge),
          EmptyState(
            title: 'Bu ayın sayfası boş.',
            detail:
                'Bu ay mekân ekledikçe ve deneyim yazdıkça ayın özeti burada '
                'oluşacak.',
            action: 'Arşive git',
            onPressed: () => context.go('/archive'),
          ),
        ] else ...[
          PeriodSummaryBody(summary: summary),
          const Rule(space: Space.xxl),
          Text('Paylaşım görseli', style: text.headlineSmall),
          const SizedBox(height: Space.xs),
          Text(
            'Hikâye boyutunda (1080×1920) bir kapak; renkleri ekranın '
            'temasından bağımsız.',
            style: text.bodySmall,
          ),
          const SizedBox(height: Space.l),
          // Kapak sabit boyutta çizilir, ekrana sığacak kadar küçültülür;
          // paylaşılan görsel her zaman 1080×1920.
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: AspectRatio(
                aspectRatio: coverSize.aspectRatio,
                child: FittedBox(
                  child: RepaintBoundary(
                    key: _boundary,
                    child: SummaryCover(
                      summary: summary,
                      author: data.profile.name.trim(),
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
              _busy ? 'Hazırlanıyor…' : 'Ay özetini paylaş',
              icon: GurmeGlyph.share,
              onPressed: _busy ? null : () => _share(buttonContext, summary),
            ),
          ),
        ],
      ],
    );
  }
}
