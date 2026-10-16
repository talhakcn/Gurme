import 'package:flutter/material.dart';

import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../data/journal_models.dart';

/// Lezzet izi: tadım karnesinin dört ölçütü, her biri beş karelik bir satır.
/// Deneyim formundaki karneyle aynı düzen; her mekânın izi farklıdır ve
/// Gurme'nin imzasıdır. Puanı olmayan karne için hiçbir şey çizilmez.
class TasteMark extends StatelessWidget {
  const TasteMark(
    this.scores, {
    super.key,
    this.cell = 6,
    this.labels = false,
    this.exact,
  });

  final TastingScores scores;

  /// Bir karenin kenarı; satırda küçük, mekân sayfasında büyük.
  final double cell;

  /// Satırların solunda ölçüt adları ve sağında puan (mekân sayfası).
  final bool labels;

  /// Ölçütlerin yuvarlanmamış ortalamaları; verilirse sağdaki puan ve ekran
  /// okuyucu bunu söyler ("2,5"). Kareler tam kısmı dolu çizer; yarım ve
  /// üstü artan son kareyi yarı doldurur: 4,5 beş dolu kare görünmez.
  final List<double>? exact;

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) return const SizedBox.shrink();
    // Kareler yazıyla birlikte büyür; büyük yazıda iz cüce kalmaz.
    final cell = MediaQuery.textScalerOf(context).scale(this.cell);
    final gap = cell * 0.3;
    final text = Theme.of(context).textTheme;

    Widget row(int index, int score) {
      final value = exact?[index] ?? score.toDouble();
      final full = value.floor();
      final half = value - full >= 0.5;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++) ...[
            if (i > 1) SizedBox(width: gap),
            // Boş kare çerçeveli: iki temada da zeminden 3:1 ayrılır.
            Container(
              width: cell,
              height: cell,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: i <= full ? context.colors.mark : null,
                border: i <= full
                    ? null
                    : Border.all(color: context.colors.control),
              ),
              child: half && i == full + 1
                  ? FractionallySizedBox(
                      widthFactor: 0.5,
                      heightFactor: 1,
                      child: ColoredBox(color: context.colors.mark),
                    )
                  : null,
            ),
          ],
        ],
      );
    }

    // Büyük yazıda ölçüt adı karelerin üstüne geçer; yan yana sığmaz.
    final stacked = labels && MediaQuery.textScalerOf(context).scale(10) > 13;
    Widget value(int i, int score) => SizedBox(
      width: MediaQuery.textScalerOf(context).scale(24),
      child: Text(
        _value(i, score),
        textAlign: TextAlign.right,
        style: text.bodySmall!.copyWith(color: context.colors.ink),
      ),
    );

    final rows = [
      for (final (i, score) in scores.all.indexed) ...[
        if (i > 0) SizedBox(height: labels ? Space.s : gap),
        if (stacked) ...[
          Text(TastingScores.labels[i], style: text.bodySmall),
          const SizedBox(height: Space.xs),
          Row(children: [row(i, score), const Spacer(), value(i, score)]),
        ] else if (labels)
          Row(
            children: [
              Expanded(
                child: Text(TastingScores.labels[i], style: text.bodySmall),
              ),
              // Ad ile kareler hiçbir boyutta birbirine değmez.
              const SizedBox(width: Space.m),
              row(i, score),
              const SizedBox(width: Space.m),
              value(i, score),
            ],
          )
        else
          row(i, score),
      ],
    ];

    final description = [
      'Lezzet izi',
      for (final (i, score) in scores.all.indexed)
        if (score > 0) '${TastingScores.labels[i]} ${_value(i, score)}',
    ].join(', ');
    final mark = Semantics(
      label: description,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
    // Satırdaki küçük iz dokununca ne olduğunu söyler; etiketli büyük
    // halin buna ihtiyacı yok.
    return labels
        ? mark
        : Tooltip(
            message: description,
            triggerMode: TooltipTriggerMode.tap,
            // Dokunma alanı izin çevresine taşar; iz küçük kalır.
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.xs,
                vertical: Space.s,
              ),
              child: mark,
            ),
          );
  }

  /// Ölçütün yazılan puanı: tam sayıysa "4", değilse "2,5".
  String _value(int i, int score) {
    if (score == 0) return '–';
    final value = exact?[i];
    if (value == null || value == value.roundToDouble()) return '$score';
    return formatScore(value);
  }
}
