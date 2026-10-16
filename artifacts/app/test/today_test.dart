import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/text/turkish.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_notifier.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';
import 'package:gurme/features/journal/data/today_pick.dart';
import 'package:gurme/core/clock.dart';
import 'package:gurme/features/journal/widgets/today_card.dart';

import 'helpers.dart';

// 7 Ekim 2026 Çarşamba, 19:30.
final _now = DateTime(2026, 10, 7, 19, 30);

Place _want(
  String id,
  String name, {
  required int daysAgo,
  String city = 'İstanbul',
  String category = '',
}) => Place(
  id: id,
  name: name,
  city: city,
  category: category,
  status: PlaceStatus.want,
  createdAt: _now.subtract(Duration(days: daysAgo)),
);

void main() {
  test('hafta numarası', () {
    expect(isoWeek(_now), 41);
    // 1 Ocak 2027 cuma; ISO'ya göre 2026'nın 53. haftası.
    expect(isoWeek(DateTime(2027)), 53);
    expect(formatLongDateTr(_now), '7 Ekim 2026, Çarşamba');
  });

  test('öneri sırası: şehir, bu hafta gidilmeyen tür, en eski kayıt', () {
    final data = JournalData(
      profile: const Profile(city: 'istanbul'),
      places: [
        _want('a', 'Ankara Döner', daysAgo: 90, city: 'Ankara'),
        _want('b', 'Kahve Durağı', daysAgo: 40, category: 'Kahve'),
        _want('c', 'Fırın Kırıntı', daysAgo: 10, category: 'Fırın'),
        Place(
          id: 'd',
          name: 'Gidilen Kahveci',
          category: 'Kahve',
          status: PlaceStatus.went,
          createdAt: _now,
        ),
      ],
      visits: const [
        // Bu hafta bir kahveciye gidildi.
        Visit(id: 'v', placeId: 'd', date: '2026-10-05', note: ''),
      ],
    );

    final picks = rankTodayPicks(data, _now);

    expect(picks.map((p) => p.place.id), ['c', 'b', 'a']);
    expect(picks[0].reasons, [
      'Senin şehrinde.',
      'Bu hafta bu türden bir yere gitmedin.',
    ]);
    expect(picks[1].reasons, ['Senin şehrinde.']);
    expect(picks[2].reasons, ['Gideceklerinde en uzun süredir bekliyor.']);
  });

  test('gidecek mekân yoksa öneri yok', () {
    expect(rankTodayPicks(const JournalData(), _now), isEmpty);
  });

  testWidgets('Keşfet öneriyi gösterir; "Başka öner" sıradakine geçer', (
    tester,
  ) async {
    useTallScreen(tester);
    final storage = MemoryJournalStorage(
      jsonEncode(
        JournalData(
          profile: const Profile(city: 'İstanbul'),
          places: [
            _want('b', 'Kahve Durağı', daysAgo: 34),
            _want('c', 'Fırın Kırıntı', daysAgo: 2),
          ],
        ).toJson(),
      ),
    );
    await tester.pumpWidget(
      testApp(
        storage: storage,
        overrides: [clockProvider.overrideWithValue(() => _now)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('34 gündür gideceklerinde'), findsOneWidget);
    expect(
      find.text(
        'Neden bu? Gideceklerinde en uzun süredir bekliyor. Senin şehrinde.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Başka öner'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2 gündür gideceklerinde'), findsOneWidget);

    // Mekân "gittim" olunca öneriden çıkar.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TodayCard)),
    );
    container.read(journalProvider.notifier).setStatus('c', PlaceStatus.went);
    container.read(journalProvider.notifier).setStatus('b', PlaceStatus.went);
    await tester.pumpAndSettle();
    expect(find.text('Başka öner'), findsNothing);
  });
}
