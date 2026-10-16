import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/router/app_router.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';
import 'sample_data.dart';

void main() {
  // iOS'ta sayfalar ekranın sol kenarından sağa kaydırılarak kapanır.
  // go_router sayfa türünü algılayamadığında geçişsiz sayfa açıyordu ve bu
  // hareket hiçbir sayfada çalışmıyordu.
  for (final path in ['/place/p1', '/settings', '/account', '/guide']) {
    testWidgets('iOS: $path kenardan kaydırarak kapanır', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        testApp(
          storage: MemoryJournalStorage(jsonEncode(sampleJournal.toJson())),
        ),
      );
      await tester.pumpAndSettle();
      final router = ProviderScope.containerOf(
        tester.element(find.byType(Navigator).first),
      ).read(routerProvider);
      router.push(path);
      await tester.pumpAndSettle();
      expect(router.state.uri.toString(), path);

      final gesture = await tester.startGesture(const Offset(5, 400));
      for (var i = 0; i < 20; i++) {
        await gesture.moveBy(const Offset(15, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(router.state.uri.toString(), '/');
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
