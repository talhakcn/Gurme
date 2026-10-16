import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/clock.dart';
import 'package:gurme/core/router/app_router.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';
import 'sample_data.dart';

/// Ana ekranlar örnek bir defterle taşmadan çizilir. GURME_COVER_DIR
/// verilirse her ekran PNG olarak kaydedilir (tasarım gözden geçirme).
const _screens = {
  'kesfet': '/',
  'arama': '/search',
  'arsiv': '/archive',
  'listeler': '/lists',
  'profil': '/profile',
  'mekan': '/place/p1',
  'deneyim': '/place/p1/visit/v1',
  'mekan-formu': '/place/p1/edit',
  'liste': '/list/l1',
  'liste-formu': '/list/l1/edit',
  'hesap': '/account',
  'ayarlar': '/settings',
  'etkinlik': '/activity',
  'ay': '/profile/month',
  'yil': '/profile/year',
  'kapak': '/list/l1/cover',
  'siralama': '/dishes/coffee',
  'rehber': '/guide',
};

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await loadSamplePhotos();
  });

  // Normal, 2 kat yazı (iOS'ta en büyük erişilebilir boyutlara yakın) ve
  // gece modu.
  for (final (suffix, scale, brightness, width) in [
    ('', 1.0, Brightness.light, 390.0),
    ('-2x', 2.0, Brightness.light, 390.0),
    ('-gece', 1.0, Brightness.dark, 390.0),
    ('-ipad', 1.0, Brightness.light, 1024.0),
  ]) {
    for (final MapEntry(key: screen, value: path) in _screens.entries) {
      final name = '$screen$suffix';
      testWidgets('ekran taşmadan çizilir: $name', (tester) async {
        tester.view.physicalSize = Size(width, 2400);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        await tester.pumpWidget(
          testApp(
            storage: MemoryJournalStorage(jsonEncode(sampleJournal.toJson())),
            overrides: [
              clockProvider.overrideWithValue(() => sampleNow),
              samplePhotoOverride(),
            ],
          ),
        );
        await tester.pumpAndSettle();
        final container = ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        );
        container.read(routerProvider).go(path);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        final out = Platform.environment['GURME_COVER_DIR'];
        if (out != null) {
          await tester.runAsync(() async {
            final render = tester.renderObject<RenderRepaintBoundary>(
              find.byType(RepaintBoundary).first,
            );
            final image = await render.toImage(pixelRatio: 1.5);
            final png = await image.toByteData(format: ui.ImageByteFormat.png);
            await File('$out/ekran-$name.png')
                .writeAsBytes(png!.buffer.asUint8List());
          });
        }
      });
    }
  }

  // Kelime ortasından bölünme ölçümle değil, çizilen satırla denetlenir:
  // ikinci satır varsa sol alt köşedeki konum 0 olmaz.
  testWidgets('büyük yazıda listeler sekmeleri tek satırda', (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await tester.pumpWidget(
      testApp(
        storage: MemoryJournalStorage(jsonEncode(sampleJournal.toJson())),
        overrides: [clockProvider.overrideWithValue(() => sampleNow)],
      ),
    );
    await tester.pumpAndSettle();
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(routerProvider)
        .go('/lists');
    await tester.pumpAndSettle();
    for (final label in ['Listelerim', 'Kaydedilen']) {
      final render = tester.renderObject<RenderParagraph>(
        find.text(label).last,
      );
      final bottomLeft = render.getPositionForOffset(
        Offset(0, render.size.height - 1),
      );
      expect(bottomLeft.offset, 0, reason: '$label tek kelime, tek satır');
    }
  });
}
