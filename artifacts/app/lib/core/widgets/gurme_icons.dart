import 'package:flutter/material.dart';

/// Gurme'nin kendi simgeleri: 24 birimlik ızgarada, 1,5 birim çizgi, kare
/// uç ve sivri birleşim. Lezzet izinin karesiyle aynı dili konuşur; sekme
/// çubuğunda ve profil satırlarında hazır simgelerin yerini alır.
enum GurmeGlyph {
  discover,
  search,
  archive,
  lists,
  profile,
  signIn,
  year,
  activity,
  notifications,
  // Eylemler
  add,
  write,
  edit,
  share,
  image,
  pin,
  map,
  listAdd,
  save,
  backup,
  flag,
  settings,
  calendar,
  // Sistem
  back,

  /// iOS'ta geri: sola bakan köşeli işaret (‹), oksuz.
  backChevron,
  next,
  up,
  down,
  close,
  check,
  checkboxOn,
  checkboxOff,
  info,

  /// Satırdaki "diğer eylemler": yan yana üç küçük kare.
  more,

  /// Dosyadan geri yükleme: tepsiye inen ok (dışa aktarmanın tersi).
  restore,

  /// Açılıp kapanan bölüm: aşağı bakan köşeli işaret; açıkken döner.
  /// Sıralamadaki oklarla (up/down) karışmasın diye ayrı.
  expand,
}

/// Simgelerin büyük yazıyla büyüme katsayısı: yazı ölçeği, en çok 1,5.
/// Simge yazıyla birlikte okunur; 2 katta küçük kalmasın, düzeni de
/// taşırmasın.
double iconScale(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);

class GurmeIcon extends StatelessWidget {
  const GurmeIcon(
    this.glyph, {
    super.key,
    this.size,
    this.filled = false,
    this.color,
  });

  final GurmeGlyph glyph;

  /// Verilmezse çevredeki simge temasının boyutu (sekme çubuğu 20).
  /// Verilen boyut büyük yazıyla [iconScale] kadar büyür; simge yanındaki
  /// yazıyla birlikte okunur.
  final double? size;

  /// Seçili sekmede dolu çizilir.
  final bool filled;

  /// Verilmezse çevredeki simge temasının rengi.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final side = switch (size) {
      final size? => size * iconScale(context),
      null => theme.size ?? 24,
    };
    return SizedBox.square(
      dimension: side,
      child: CustomPaint(
        painter: _GlyphPainter(
          glyph,
          color ?? theme.color ?? DefaultTextStyle.of(context).style.color!,
          filled,
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.glyph, this.color, this.filled);

  final GurmeGlyph glyph;
  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    // İşaretli kutudaki onay, dolu kareden oyularak çizilir; oyma yalnızca
    // bu katmanı etkiler.
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.scale(size.width / 24);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    void shape(Path path) => canvas.drawPath(path, filled ? fill : stroke);
    void square(double x, double y, double side, {bool solid = false}) =>
        canvas.drawRect(Rect.fromLTWH(x, y, side, side), solid ? fill : stroke);
    void line(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), stroke);
    void poly(List<(double, double)> points, {bool close = false}) {
      final path = Path()..moveTo(points.first.$1, points.first.$2);
      for (final (x, y) in points.skip(1)) {
        path.lineTo(x, y);
      }
      if (close) path.close();
      canvas.drawPath(path, stroke);
    }

    void bookmark() => shape(
      Path()
        ..moveTo(6, 3)
        ..lineTo(18, 3)
        ..lineTo(18, 21)
        ..lineTo(12, 16)
        ..lineTo(6, 21)
        ..close(),
    );

    switch (glyph) {
      case GurmeGlyph.discover:
        // Pusula: eşkenar dörtgen, ortasında kare.
        final diamond = Path()
          ..moveTo(12, 3)
          ..lineTo(21, 12)
          ..lineTo(12, 21)
          ..lineTo(3, 12)
          ..close();
        if (filled) {
          canvas.drawPath(
            Path.combine(
              PathOperation.difference,
              diamond,
              Path()..addRect(const Rect.fromLTWH(10.5, 10.5, 3, 3)),
            ),
            fill,
          );
        } else {
          canvas.drawPath(diamond, stroke);
          square(10.5, 10.5, 3, solid: true);
        }
      case GurmeGlyph.search:
        canvas.drawCircle(
          const Offset(10.5, 10.5),
          6.5,
          stroke..strokeWidth = filled ? 2.25 : 1.5,
        );
        line(15.5, 15.5, 20.5, 20.5);
      case GurmeGlyph.archive:
        // Ayraç.
        bookmark();
      case GurmeGlyph.lists:
        // Rota: sıralı duraklar.
        for (final y in [4.5, 10.5, 16.5]) {
          square(3.5, y, 3, solid: filled);
          line(10, y + 1.5, 20.5, y + 1.5);
        }
      case GurmeGlyph.profile:
        canvas.drawCircle(const Offset(12, 8), 4, filled ? fill : stroke);
        shape(
          Path()
            ..moveTo(4, 21)
            ..lineTo(4, 18.5)
            ..quadraticBezierTo(4, 14, 12, 14)
            ..quadraticBezierTo(20, 14, 20, 18.5)
            ..lineTo(20, 21)
            ..close(),
        );
      case GurmeGlyph.signIn:
        // Kapıya giren ok.
        canvas.drawPath(
          Path()
            ..moveTo(14, 4)
            ..lineTo(20, 4)
            ..lineTo(20, 20)
            ..lineTo(14, 20),
          stroke,
        );
        line(3.5, 12, 14, 12);
        canvas.drawPath(
          Path()
            ..moveTo(10, 8)
            ..lineTo(14, 12)
            ..lineTo(10, 16),
          stroke,
        );
      case GurmeGlyph.year:
        // Lezzet izinden bir parça: dört kare, üçü dolu.
        square(4, 4, 6.5, solid: true);
        square(13.5, 4, 6.5, solid: true);
        square(4, 13.5, 6.5, solid: true);
        square(13.5, 13.5, 6.5);
      case GurmeGlyph.activity:
        // Zaman çizelgesi: dikey çizgi ve üç kayıt.
        line(6, 3.5, 6, 20.5);
        for (final (y, end) in [(6.0, 20.5), (12.0, 17.0), (18.0, 19.0)]) {
          square(4.5, y - 1.5, 3, solid: true);
          line(10, y, end, y);
        }
      case GurmeGlyph.notifications:
        // Çan: köşeli gövde ve dil.
        canvas.drawPath(
          Path()
            ..moveTo(6.5, 17)
            ..lineTo(6.5, 10.5)
            ..quadraticBezierTo(6.5, 5, 12, 5)
            ..quadraticBezierTo(17.5, 5, 17.5, 10.5)
            ..lineTo(17.5, 17),
          stroke,
        );
        line(4, 17, 20, 17);
        line(10.5, 20.5, 13.5, 20.5);
      case GurmeGlyph.add:
        line(12, 5, 12, 19);
        line(5, 12, 19, 12);
      case GurmeGlyph.write:
        // Satırlar ve kalem: not yazmak.
        line(4, 6.5, 14, 6.5);
        line(4, 11.5, 11, 11.5);
        line(4, 16.5, 7.5, 16.5);
        poly([
          (11, 20),
          (11, 17.5),
          (17.5, 11),
          (20, 13.5),
          (13.5, 20),
        ], close: true);
      case GurmeGlyph.edit:
        poly([
          (5, 19),
          (5, 15.5),
          (15, 5.5),
          (18.5, 9),
          (8.5, 19),
        ], close: true);
        line(12.5, 8, 16, 11.5);
      case GurmeGlyph.share:
        poly([(8.5, 9), (5, 9), (5, 20), (19, 20), (19, 9), (15.5, 9)]);
        line(12, 3.5, 12, 14);
        poly([(8, 7.5), (12, 3.5), (16, 7.5)]);
      case GurmeGlyph.image:
        canvas.drawRect(const Rect.fromLTWH(4, 5, 16, 14), stroke);
        poly([(4, 16), (9, 11), (13, 15), (16, 12), (20, 16)]);
        square(14.5, 7.5, 2, solid: true);
      case GurmeGlyph.pin:
        canvas.drawCircle(const Offset(12, 9.5), 5, stroke);
        line(12, 14.5, 12, 21);
        square(11, 8.5, 2, solid: true);
      case GurmeGlyph.map:
        poly([
          (3.5, 6), (9, 4), (15, 6), (20.5, 4), //
          (20.5, 18), (15, 20), (9, 18), (3.5, 20),
        ], close: true);
        line(9, 4, 9, 18);
        line(15, 6, 15, 20);
      case GurmeGlyph.listAdd:
        line(4, 7, 15, 7);
        line(4, 12, 15, 12);
        line(4, 17, 10, 17);
        line(17.5, 14, 17.5, 21);
        line(14, 17.5, 21, 17.5);
      case GurmeGlyph.save:
        bookmark();
        if (!filled) {
          line(12, 7, 12, 12);
          line(9.5, 9.5, 14.5, 9.5);
        }
      case GurmeGlyph.backup:
        line(12, 15, 12, 4.5);
        poly([(7.5, 9), (12, 4.5), (16.5, 9)]);
        poly([(4.5, 14), (4.5, 19.5), (19.5, 19.5), (19.5, 14)]);
      case GurmeGlyph.flag:
        line(6, 3.5, 6, 20.5);
        poly([(6, 4.5), (18, 4.5), (15, 8.5), (18, 12.5), (6, 12.5)]);
      case GurmeGlyph.settings:
        // Ayar sürgüleri; düğmeler kare.
        for (final (y, x) in [(7.0, 14.0), (12.0, 8.0), (17.0, 16.0)]) {
          line(4, y, 20, y);
          square(x - 2, y - 2, 4, solid: true);
        }
      case GurmeGlyph.calendar:
        canvas.drawRect(const Rect.fromLTWH(4, 6, 16, 14), stroke);
        line(4, 10.5, 20, 10.5);
        line(8.5, 3.5, 8.5, 7.5);
        line(15.5, 3.5, 15.5, 7.5);
      case GurmeGlyph.back:
        line(5, 12, 19, 12);
        poly([(11, 6), (5, 12), (11, 18)]);
      case GurmeGlyph.backChevron:
        poly([(15, 6), (9, 12), (15, 18)]);
      case GurmeGlyph.next:
        poly([(9, 6), (15, 12), (9, 18)]);
      case GurmeGlyph.up:
        line(12, 5, 12, 19);
        poly([(6, 11), (12, 5), (18, 11)]);
      case GurmeGlyph.down:
        line(12, 5, 12, 19);
        poly([(6, 13), (12, 19), (18, 13)]);
      case GurmeGlyph.close:
        line(6, 6, 18, 18);
        line(18, 6, 6, 18);
      case GurmeGlyph.check:
        poly([(5, 12.5), (10, 17.5), (19, 7)]);
      case GurmeGlyph.checkboxOn:
        canvas.drawRect(const Rect.fromLTWH(4, 4, 16, 16), fill);
        canvas.drawPath(
          Path()
            ..moveTo(7.5, 12)
            ..lineTo(10.5, 15)
            ..lineTo(16.5, 9),
          Paint()
            ..color = const Color(0x00000000)
            ..blendMode = BlendMode.clear
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.square,
        );
      case GurmeGlyph.checkboxOff:
        canvas.drawRect(const Rect.fromLTWH(4.75, 4.75, 14.5, 14.5), stroke);
      case GurmeGlyph.info:
        canvas.drawCircle(const Offset(12, 12), 8.5, stroke);
        line(12, 11, 12, 16.5);
        square(11.25, 7, 1.5, solid: true);
      case GurmeGlyph.restore:
        poly([(5, 14), (5, 19), (19, 19), (19, 14)]);
        line(12, 4, 12, 14.5);
        poly([(8, 10.5), (12, 14.5), (16, 10.5)]);
      case GurmeGlyph.expand:
        poly([(6, 9), (12, 15), (18, 9)]);
      case GurmeGlyph.more:
        square(4.5, 10.5, 3, solid: true);
        square(10.5, 10.5, 3, solid: true);
        square(16.5, 10.5, 3, solid: true);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.color != color || old.filled != filled;
}
