import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/text/turkish.dart';
import '../../core/theme/gurme_colors.dart';
import '../../core/widgets/editorial.dart';
import '../../core/widgets/gurme_icons.dart';

// Yönetim panelinin küçük parçaları. Panel yalnızca yöneticinin gözü için;
// yine de uygulamanın dili: sayılar cümlede ya da adıyla yan yana.

int adminInt(Object? v) => v is num ? v.toInt() : 0;

DateTime? adminDate(Object? v) =>
    v is String ? DateTime.tryParse(v)?.toLocal() : null;

/// "Bugün 14:20", "Dün 09:05" ya da "6 Ekim 2026".
String adminWhen(DateTime? time, DateTime now) {
  if (time == null) return '—';
  final hm =
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(time.year, time.month, time.day)).inDays;
  return switch (days) {
    0 => 'Bugün $hm',
    1 => 'Dün $hm',
    _ => formatDateTr(time),
  };
}

/// Arama sonucunun adı.
String outcomeLabel(String outcome) => switch (outcome) {
  'ok' => 'Google',
  'cached' => 'Önbellek',
  'quota' => 'Hak bitti',
  'budget' => 'Sayaç doldu',
  'blocked' => 'Kapalı hesap',
  'error' => 'Hata',
  _ => outcome,
};

/// Ad solda, değer sağda; altı çizgili satır.
class AdminRow extends StatelessWidget {
  const AdminRow(this.label, this.value, {super.key, this.onTap, this.detail});

  final String label;
  final String value;
  final String? detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final row = Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(vertical: Space.s),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.bodyMedium),
                if (detail case final d? when d.isNotEmpty)
                  Text(d, style: text.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: Space.m),
          Text(
            value,
            style: text.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
          ),
          // Başka sayfaya götüren satır okla belli olur.
          if (onTap != null) ...[
            const SizedBox(width: Space.s),
            GurmeIcon(GurmeGlyph.next, size: 14, color: context.colors.muted),
          ],
        ],
      ),
    );
    if (onTap == null) return MergeSemantics(child: row);
    return Semantics(
      button: true,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

/// Günlük sayacın doluluğu: ad, "42 / 100" ve çubuk. %80'i geçince altın,
/// dolunca hata rengi.
class AdminMeter extends StatelessWidget {
  const AdminMeter({
    super.key,
    required this.label,
    required this.used,
    required this.limit,
    this.detail,
  });

  final String label;
  final int used;
  final int limit;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final ratio = limit == 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);
    final color = ratio >= 1
        ? context.colors.error
        : ratio >= 0.8
        ? context.colors.gold
        : context.colors.mark;
    return Semantics(
      label: '$label: $used / $limit',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label, style: text.bodyMedium)),
                Text(
                  '$used / $limit',
                  style: text.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: Space.xs),
            Container(
              height: 8,
              color: context.colors.wash,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: ratio,
                child: Container(color: color),
              ),
            ),
            if (detail case final d? when d.isNotEmpty) ...[
              const SizedBox(height: Space.xs),
              Text(d, style: text.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

/// Son yedi günün sütunları; en yüksek gün çubuğu doldurur.
class AdminDays extends StatelessWidget {
  const AdminDays({super.key, required this.days, required this.value});

  final List<Map<String, dynamic>> days;
  final int Function(Map<String, dynamic> day) value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final values = [for (final d in days) value(d)];
    final top = values.fold(0, (a, b) => a > b ? a : b);
    const height = 72.0;
    return Semantics(
      label: [
        for (final (i, d) in days.indexed)
          '${formatIsoDateTr(d['day'] as String? ?? '')}: ${values[i]}',
      ].join(', '),
      excludeSemantics: true,
      // Yükseklik içerikten gelir: büyük yazıda etiketler taşmaz.
      child: SizedBox(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (i, d) in days.indexed) ...[
              if (i > 0) const SizedBox(width: Space.xs),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${values[i]}', style: text.bodySmall),
                    const SizedBox(height: 2),
                    Container(
                      height: top == 0
                          ? 1
                          : (values[i] / top * height).clamp(1.0, height),
                      color: i == days.length - 1
                          ? context.colors.mark
                          : context.colors.line,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _weekday(d['day'] as String? ?? ''),
                      style: text.bodySmall,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _weekday(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    const names = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return names[date.weekday - 1];
  }
}

/// Yükleniyor, hata ya da içerik; hata bölümün içinde ve yeniden denenir.
List<Widget> adminAsync<T>(
  AsyncValue<T> value, {
  required VoidCallback retry,
  required List<Widget> Function(T data) data,
}) => value.when(
  skipLoadingOnRefresh: true,
  loading: () => const [SkeletonBlock(), SkeletonBlock(), SkeletonBlock()],
  error: (e, _) => [
    EmptyState(
      icon: null,
      secondary: true,
      title: 'Yüklenemedi.',
      detail: e.toString(),
      action: 'Yeniden dene',
      onPressed: retry,
    ),
  ],
  data: data,
);
