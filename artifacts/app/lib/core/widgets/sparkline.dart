import 'package:flutter/material.dart';

import '../theme/gurme_colors.dart';

/// Küçük gidişat çizgisi: değerler soldan sağa, eskiden yeniye. Son nokta
/// dolu, öncekiler halka. Değerler [min]–[max] aralığına göre çizilir.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    this.min = 1,
    this.max = 5,
    this.height = 36,
  });

  final List<double> values;
  final double min;
  final double max;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(values, min, max, context.colors),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values, this.min, this.max, this.colors);

  final List<double> values;
  final GurmePalette colors;
  final double min;
  final double max;

  static const _dot = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final span = (max - min) == 0 ? 1 : max - min;
    Offset point(int i) {
      final x = values.length == 1
          ? size.width / 2
          : _dot + (size.width - 2 * _dot) * i / (values.length - 1);
      final y =
          size.height -
          _dot -
          (size.height - 2 * _dot) * ((values[i] - min) / span).clamp(0, 1);
      return Offset(x, y);
    }

    // Orta çizgi: ölçeğin ortası, soluk.
    final mid = Paint()
      ..color = colors.line
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      mid,
    );

    final line = Paint()
      ..color = colors.ink
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(point(i).dx, point(i).dy);
    }
    canvas.drawPath(path, line);

    final ring = Paint()
      ..color = colors.paper
      ..style = PaintingStyle.fill;
    for (var i = 0; i < values.length; i++) {
      final last = i == values.length - 1;
      canvas.drawCircle(
        point(i),
        _dot,
        last ? (Paint()..color = colors.ink) : ring,
      );
      if (!last) canvas.drawCircle(point(i), _dot, line);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values ||
      old.min != min ||
      old.max != max ||
      old.colors != colors;
}
