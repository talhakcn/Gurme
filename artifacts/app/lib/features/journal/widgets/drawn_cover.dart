import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';

/// Fotoğrafı olmayan mekânın kapağındaki çizim; türden seçilir.
enum CoverMotif { cup, simit, cake, pot, skewer, glass, fish, plate }

/// Mekân türünden ("Kahve", "Esnaf lokantası"…) kapak çizimi. Tür serbest
/// yazıldığı için anahtar kelimeyle eşlenir; tanınmazsa tabak.
CoverMotif motifFor(String category) {
  final c = normalizeForMatch(category);
  bool has(List<String> words) => words.any(c.contains);
  if (has(['kahve', 'kafe', 'cafe', 'coffee', 'cay', 'kahvalti'])) {
    return CoverMotif.cup;
  }
  if (has(['firin', 'simit', 'borek', 'ekmek', 'pastane', 'unlu'])) {
    return CoverMotif.simit;
  }
  if (has(['tatli', 'baklava', 'dondurma', 'pasta', 'muhallebi', 'kunefe'])) {
    return CoverMotif.cake;
  }
  if (has(['kebap', 'kebab', 'ocakbasi', 'lahmacun', 'pide', 'izgara'])) {
    return CoverMotif.skewer;
  }
  if (has(['meyhane', 'bar', 'sarap', 'bira', 'raki', 'kokteyl'])) {
    return CoverMotif.glass;
  }
  if (has(['balik', 'deniz', 'midye'])) return CoverMotif.fish;
  if (has(['lokanta', 'esnaf', 'ev yemeg', 'corba', 'sulu'])) {
    return CoverMotif.pot;
  }
  return CoverMotif.plate;
}

/// Fotoğrafsız mekânın kapağı: defter sayfası gibi soluk satır çizgileri
/// ve türünü anlatan tek çizgili bir motif. Süs değil, mekânın türüdür;
/// gerçek fotoğraf eklenince yerini ona bırakır.
class DrawnCover extends StatelessWidget {
  const DrawnCover({
    super.key,
    required this.category,
    required this.height,
    this.width,
  });

  final String category;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: CustomPaint(
          painter: _CoverPainter(
            motif: motifFor(category),
            paper: colors.wash,
            rule: colors.line,
            // Gece `control` koyu zeminde soluk kalıyordu; motif `muted`
            // ile seçilir (gece zeminde 6:1), gündüz `control`.
            ink: Theme.of(context).brightness == Brightness.dark
                ? colors.muted
                : colors.control,
          ),
        ),
      ),
    );
  }
}

class _CoverPainter extends CustomPainter {
  const _CoverPainter({
    required this.motif,
    required this.paper,
    required this.rule,
    required this.ink,
  });

  final CoverMotif motif;
  final Color paper;
  final Color rule;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = paper);

    // Satır çizgileri: küçük kapakta seyrek, büyükte defter aralığında.
    final gap = size.height < 100 ? 16.0 : 24.0;
    final rulePaint = Paint()
      ..color = rule.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (var y = gap; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rulePaint);
    }

    // Motif 48 birimlik ızgarada çizilir; kapağın kısa kenarının yarısı.
    final side = min(size.shortestSide * 0.6, 120.0);
    final unit = side / 48;
    canvas
      ..save()
      ..translate((size.width - side) / 2, (size.height - side) / 2)
      ..scale(unit);
    // Satır çizgileri motifin arkasından geçmesin.
    canvas.drawRect(const Rect.fromLTWH(4, 4, 40, 40), Paint()..color = paper);
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      // Ekranda en az 1,5 piksel; büyük kapakta simgelerle aynı ağırlık.
      ..strokeWidth = max(1.5 / unit, 1.5)
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;
    _draw(canvas, stroke);
    canvas.restore();
  }

  void _draw(Canvas canvas, Paint stroke) {
    void line(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), stroke);
    void poly(List<(double, double)> p, {bool close = false}) {
      final path = Path()..moveTo(p.first.$1, p.first.$2);
      for (final (x, y) in p.skip(1)) {
        path.lineTo(x, y);
      }
      if (close) path.close();
      canvas.drawPath(path, stroke);
    }

    void circle(double x, double y, double r) =>
        canvas.drawCircle(Offset(x, y), r, stroke);

    switch (motif) {
      case CoverMotif.cup:
        // Fincan, kulp, tabak ve buhar.
        poly([(12, 22), (14, 36), (30, 36), (32, 22)], close: true);
        poly([(32, 25), (37, 25), (37, 31), (31, 31)]);
        line(8, 40, 38, 40);
        poly([(18, 17), (20, 14), (18, 11), (20, 8)]);
        poly([(25, 17), (27, 14), (25, 11), (27, 8)]);
      case CoverMotif.simit:
        circle(24, 24, 15);
        circle(24, 24, 6);
        for (var i = 0; i < 8; i++) {
          final a = i * pi / 4 + pi / 8;
          line(
            24 + 9.5 * cos(a),
            24 + 9.5 * sin(a),
            24 + 11.5 * cos(a),
            24 + 11.5 * sin(a),
          );
        }
      case CoverMotif.cake:
        // Dilim pasta: üçgen üst, iki kat.
        poly([(8, 36), (8, 24), (38, 16), (40, 36)], close: true);
        line(8, 30, 40, 30);
        poly([(8, 24), (40, 24)]);
        circle(36, 12, 2);
      case CoverMotif.pot:
        // Tencere, kapak, kulplar ve buhar.
        poly([(12, 22), (12, 38), (36, 38), (36, 22)], close: true);
        line(10, 22, 38, 22);
        line(7, 26, 12, 26);
        line(36, 26, 41, 26);
        line(22, 19, 26, 19);
        poly([(18, 16), (20, 13), (18, 10), (20, 7)]);
        poly([(28, 16), (30, 13), (28, 10), (30, 7)]);
      case CoverMotif.skewer:
        // Şiş: çapraz çubuk ve üç parça.
        line(8, 40, 40, 8);
        // Parçalar çubuğun üstünde: y = 48 - x.
        for (final c in [16.0, 24.0, 32.0]) {
          final y = 48 - c;
          poly([(c - 5, y), (c, y - 5), (c + 5, y), (c, y + 5)], close: true);
        }
      case CoverMotif.glass:
        // İnce belli bardak ve masa.
        poly([
          (17, 8),
          (31, 8),
          (28, 22),
          (26, 38),
          (22, 38),
          (20, 22),
        ], close: true);
        line(19, 16, 29, 16);
        line(10, 40, 38, 40);
      case CoverMotif.fish:
        poly([
          (8, 24),
          (16, 15),
          (30, 15),
          (36, 24),
          (30, 33),
          (16, 33),
        ], close: true);
        poly([(36, 24), (42, 17), (42, 31)], close: true);
        circle(15, 22, 1.5);
        line(22, 18, 22, 30);
      case CoverMotif.plate:
        // Tabak, çatal ve bıçak.
        circle(24, 24, 12);
        circle(24, 24, 7);
        line(7, 12, 7, 36);
        line(5, 12, 5, 18);
        line(9, 12, 9, 18);
        poly([(5, 18), (9, 18)]);
        poly([(41, 12), (41, 36)]);
        poly([(41, 12), (43, 16), (43, 24), (41, 24)]);
    }
  }

  @override
  bool shouldRepaint(_CoverPainter old) =>
      old.motif != motif ||
      old.paper != paper ||
      old.rule != rule ||
      old.ink != ink;
}
