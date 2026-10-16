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
import 'package:gurme/features/journal/widgets/taste_mark.dart';

import 'helpers.dart';
import 'sample_data.dart';

/// Sayfaların üstünde açılan katmanlar (pencere, alttan açılan sayfa,
/// bilgi çubuğu, tarih seçici) gündüz ve gecede hatasız çizilir.
/// GURME_COVER_DIR verilirse ekran görüntüsü kaydedilir.
void main() {
  setUpAll(() async {
    await loadAppFonts();
    await loadSamplePhotos();
  });

  final overlays = <String, (String, Future<void> Function(WidgetTester))>{
    'hizli-ekle': (
      '/archive',
      (t) async {
        await _scrollTo(t, find.text('Mekân ekle'));
        await t.tap(find.text('Mekân ekle'));
      },
    ),
    'menu': (
      '/archive',
      (t) async {
        await t.longPress(find.text('Fırın Kırıntı'));
      },
    ),
    'geri-al': (
      '/archive',
      (t) async {
        await t.drag(find.text('Fırın Kırıntı'), const Offset(500, 0));
      },
    ),
    'onay-penceresi': (
      '/place/p1/edit',
      (t) async {
        await _scrollTo(t, find.text('Mekânı sil'));
        await t.tap(find.text('Mekânı sil'));
      },
    ),
    'tarih': (
      '/place/p1/visit/v1',
      (t) async {
        await t.tap(find.text('14 Eylül 2026'));
      },
    ),
    // Adı "-ios" ile biten katmanlar iOS görünümünde açılır.
    'tarih-ios': (
      '/place/p1/visit/v1',
      (t) async {
        await t.tap(find.text('14 Eylül 2026'));
      },
    ),
    'onay-penceresi-ios': (
      '/place/p1/edit',
      (t) async {
        await _scrollTo(t, find.text('Mekânı sil'));
        await t.tap(find.text('Mekânı sil'));
      },
    ),
    'ipucu': (
      '/',
      (t) async {
        await _scrollTo(t, find.byType(TasteMark));
        await t.tap(find.byType(TasteMark).first);
      },
    ),
  };

  for (final brightness in Brightness.values) {
    for (final MapEntry(key: name, value: (path, open)) in overlays.entries) {
      final suffix = brightness == Brightness.dark ? '-gece' : '';
      testWidgets(
        'katman çizilir: $name$suffix',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
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
          ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
              .read(routerProvider)
              .go(path);
          await tester.pumpAndSettle();
          await open(tester);
          // Katmanın giriş hareketi dokunuştan sonraki karede başlar; o kare
          // çizilmeden beklenirse görüntüde katman yoktu. 500 ms açılması
          // için yeterli; ipucu gibi kendiliğinden kapanan katmanlar da
          // görüntüde kalır.
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          expect(tester.takeException(), isNull);
          if (name.endsWith('-ios')) {
            expect(
              find.byWidgetPredicate(
                (w) =>
                    w.runtimeType.toString() == 'CupertinoDatePicker' ||
                    w.runtimeType.toString() == 'CupertinoAlertDialog',
              ),
              findsOneWidget,
            );
          }

          final out = Platform.environment['GURME_COVER_DIR'];

          if (out != null) {
            await tester.runAsync(() async {
              final layer =
                  tester.binding.renderViews.first.debugLayer! as OffsetLayer;
              final image = await layer.toImage(
                Offset.zero & tester.view.physicalSize,
                pixelRatio: 1.5,
              );
              final png = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await File('$out/katman-$name$suffix.png')
                  .writeAsBytes(png!.buffer.asUint8List());
            });
          }
        },
        variant: name.endsWith('-ios')
            ? TargetPlatformVariant.only(TargetPlatform.iOS)
            : const DefaultTestVariant(),
      );
    }
  }
}

/// Sayfa satırları göründükçe kurulduğu için önce kaydırılır: öğe
/// kurulana kadar aşağı kaydırılır, sonra görünür alana getirilir.
Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 20 && finder.evaluate().isEmpty; i++) {
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
}
