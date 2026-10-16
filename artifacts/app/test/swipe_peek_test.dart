import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/clock.dart';
import 'package:gurme/core/router/app_router.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';
import 'package:gurme/features/journal/widgets/place_widgets.dart';

import 'helpers.dart';
import 'sample_data.dart';

void main() {
  setUpAll(loadAppFonts);
  setUp(resetSwipePeek);

  Future<void> openArchive(WidgetTester tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      testApp(
        storage: MemoryJournalStorage(jsonEncode(sampleJournal.toJson())),
        overrides: [clockProvider.overrideWithValue(() => sampleNow)],
      ),
    );
    await tester.pumpAndSettle();
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(routerProvider)
        .go('/archive');
    await tester.pump();
  }

  double shift(WidgetTester tester) {
    final moved = find.descendant(
      of: find.byType(SwipeablePlaceRow).first,
      matching: find.byType(Transform),
    );
    if (moved.evaluate().isEmpty) return 0;
    return tester.widget<Transform>(moved.first).transform.getTranslation().x;
  }

  testWidgets('ilk satır bir kez kayıp geri döner', (tester) async {
    await openArchive(tester);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 500));
    expect(shift(tester), greaterThan(40), reason: 'satır açık');
    expect(
      find.descendant(
        of: find.byType(SwipeablePlaceRow).first,
        // Altındaki eylem görünür (satırın durumuna göre).
        matching: find.byWidgetPredicate(
          (w) => w is Text && (w.data == 'Gittim' || w.data == 'Gideceğim'),
        ),
      ),
      findsWidgets,
    );
    await tester.pumpAndSettle();
    expect(shift(tester), 0, reason: 'yerine döndü');

    // Aynı oturumda arşive yeniden gelinince oynamaz.
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(routerProvider)
        .go('/');
    await tester.pumpAndSettle();
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(routerProvider)
        .go('/archive');
    await tester.pump(const Duration(milliseconds: 1100));
    expect(shift(tester), 0);
  });

  testWidgets('hareketi azalt açıksa kaymaz', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures.allOn;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await openArchive(tester);
    await tester.pump(const Duration(milliseconds: 1100));
    expect(shift(tester), 0);
  });
}
