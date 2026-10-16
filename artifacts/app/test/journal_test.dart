import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_notifier.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';

Future<ProviderContainer> _container(MemoryJournalStorage storage) async {
  final container = ProviderContainer(
    overrides: [
      appDirectoryProvider.overrideWithValue(Directory.systemTemp),
      journalStorageProvider.overrideWithValue(storage),
    ],
  );
  addTearDown(container.dispose);
  await container
      .read(journalProvider.future)
      .catchError((_) => const JournalData());
  return container;
}

Place _place(String id, DateTime now, {String name = 'Kahve Durağı'}) => Place(
  id: id,
  name: name,
  district: 'Moda',
  city: 'İstanbul',
  createdAt: now,
);

void main() {
  test('arama sonucu defterdeki kayıtla eşleşir', () {
    final at = DateTime(2026, 10, 1);
    final data = JournalData(
      places: [
        Place(
          id: 'g',
          name: 'Kahve Durağı',
          createdAt: at,
          googlePlaceId: 'G1',
        ),
        Place(id: 'e', name: 'Çiya Sofrası', createdAt: at),
        Place(id: 'b', name: 'Başka Yer', createdAt: at, googlePlaceId: 'G9'),
      ],
    );
    expect(data.placeForVenue('G1', 'Farklı ad')?.id, 'g');
    // Elle eklenmiş kayıt adıyla (büyük harf ve şapka fark etmez) bulunur.
    expect(data.placeForVenue('G2', 'ÇİYA SOFRASI')?.id, 'e');
    // Google kimliği başka olan kayıt adı tutsa da eşleşmez.
    expect(data.placeForVenue('G3', 'Başka Yer'), isNull);
  });

  test('konum JSON ile gidip gelir; bozuk değer yok sayılır', () {
    final at = DateTime.utc(2026, 10, 1);
    final place = Place(
      id: 'a',
      name: 'Kahve Durağı',
      createdAt: at,
      lat: 40.98,
      lng: 29.03,
    );
    final back = Place.fromJson(place.toJson());
    expect((back.lat, back.lng), (40.98, 29.03));
    expect(back.hasLocation, isTrue);
    final bad = Place.fromJson({...place.toJson(), 'lat': 120, 'lng': 'doğu'});
    expect(bad.hasLocation, isFalse);
    // Konumu olmayan kayıtta alan yazılmaz; eski kayıtlarla aynı biçim.
    expect(
      Place(id: 'b', name: 'X', createdAt: at).toJson().containsKey('lat'),
      isFalse,
    );
  });

  test('aramadan eklenen mekân konumunu alır; elle eklenen kazanır', () async {
    final storage = MemoryJournalStorage();
    final container = await _container(storage);
    final journal = container.read(journalProvider.notifier);
    final manual = journal.addPlace(
      (id, now) => Place(
        id: id,
        name: 'Çiya Sofrası',
        district: 'Kadıköy',
        city: 'İstanbul',
        createdAt: now,
      ),
    );
    final found = journal.addFromSearch(
      googlePlaceId: 'G1',
      name: 'Çiya Sofrası',
      address:
          'Caferağa, Güneşlibahçe Sk. No:43, 34710 Kadıköy/İstanbul, Türkiye',
      category: 'Lokanta',
      fallbackCity: 'İstanbul',
      lat: 40.99,
      lng: 29.02,
    );
    expect(found, (id: manual, existed: true));
    final data = container.read(journalDataProvider);
    expect(data.placeById(manual)!.lat, 40.99);

    final added = journal.addFromSearch(
      googlePlaceId: 'G2',
      name: 'Kahve Durağı',
      address: 'Caferağa, Moda Cd. No:12, 34710 Kadıköy/İstanbul, Türkiye',
      category: 'Kahve',
      fallbackCity: 'İstanbul',
      lat: 40.98,
      lng: 29.03,
    );
    expect(container.read(journalDataProvider).placeById(added.id)!.lng, 29.03);
  });

  group('JournalData JSON', () {
    test('Expo uygulamasının kayıt biçimini okur', () {
      final data = JournalData.fromJson({
        'places': [
          {
            'id': 'p1',
            'name': 'Eski Kahveci',
            'district': 'Moda',
            'city': 'İstanbul',
            'category': 'Kahve',
            'description': '',
            'status': 'recommend',
            'createdAt': '2026-05-01T10:00:00.000Z',
          },
        ],
        'visits': [
          {
            'id': 'v1',
            'placeId': 'p1',
            'date': '2026-05-02',
            'title': '',
            'note': 'Güzel',
            'recommended': true,
          },
        ],
        'lists': [
          {
            'id': 'l1',
            'title': 'Rota',
            'description': '',
            'city': '',
            'items': [
              {'placeId': 'p1', 'note': ''},
            ],
            'createdAt': '2026-05-01T10:00:00.000Z',
            'updatedAt': '2026-05-01T10:00:00.000Z',
            'remoteId': 'r1',
            'ownerKey': 'k1',
            'visibility': 'unlisted',
          },
        ],
        'savedListIds': ['l1'],
        'savedRemoteLists': [sampleRemoteList().toJson()],
        'profile': {'name': 'Semih', 'privateJournal': true},
      });

      final place = data.places.single;
      expect(
        place.status,
        PlaceStatus.went,
        reason: 'eski "recommend" statüsü',
      );
      expect(place.recommended, isTrue);
      // Alan yoksa cevapsız; "Belki" ile karışmaz.
      expect(data.visits.single.revisit, isNull);
      expect(data.visits.single.photos, isEmpty);
      expect(data.lists.single.remoteId, 'r1');
      expect(data.lists.single.visibility, ListVisibility.unlisted);
      expect(data.savedRemoteLists.single.title, 'Kadıköy kahveleri');
      expect(data.profile.name, 'Semih');
    });

    test('kaydedip geri okuyunca aynı veri çıkar', () {
      final now = DateTime.utc(2026, 10, 6, 12);
      final data = JournalData(
        places: [
          _place(
            'p1',
            now,
          ).copyWith(status: PlaceStatus.want, image: 'photos/a.jpg'),
        ],
        visits: [
          const Visit(
            id: 'v1',
            placeId: 'p1',
            date: '2026-10-06',
            note: 'Not',
            photos: ['photos/b.jpg'],
          ),
        ],
        lists: [
          CuratedList(
            id: 'l1',
            title: 'Rota',
            items: const [ListItem(placeId: 'p1', note: 'Neden')],
            createdAt: now,
            updatedAt: now,
          ),
        ],
        profile: const Profile(name: 'Semih', city: 'İstanbul'),
      );
      final again = JournalData.fromJson(
        jsonDecode(jsonEncode(data.toJson())) as Map<String, dynamic>,
      );
      expect(again.toJson(), data.toJson());
      expect(again.photoPaths, {'photos/a.jpg', 'photos/b.jpg'});
    });
  });

  group('JournalNotifier', () {
    test('değişiklikler kalıcı kayda yazılır', () async {
      final storage = MemoryJournalStorage();
      final container = await _container(storage);
      final journal = container.read(journalProvider.notifier);

      final id = journal.addPlace(_place);
      await journal.flush();

      final saved = JournalData.fromJson(
        jsonDecode(storage.contents!) as Map<String, dynamic>,
      );
      expect(saved.places.single.id, id);
    });

    test('mekân silinince deneyimleri ve liste kayıtları da silinir', () async {
      final container = await _container(MemoryJournalStorage());
      final journal = container.read(journalProvider.notifier);
      final placeId = journal.addPlace(_place);
      journal.saveVisit(
        Visit(id: '', placeId: placeId, date: '2026-10-06', note: 'Not'),
      );
      final listId = journal.saveList(
        title: 'Rota',
        description: '',
        city: '',
        items: [ListItem(placeId: placeId)],
      );

      journal.deletePlace(placeId);

      final data = container.read(journalDataProvider);
      expect(data.places, isEmpty);
      expect(data.visits, isEmpty);
      expect(data.listById(listId)!.items, isEmpty);
    });

    test('statü ve öneri kuralları', () async {
      final container = await _container(MemoryJournalStorage());
      final journal = container.read(journalProvider.notifier);
      final id = journal.addPlace(_place);
      Place place() => container.read(journalDataProvider).placeById(id)!;

      journal.toggleRecommended(id);
      expect(place().status, PlaceStatus.went);
      expect(place().recommended, isTrue);

      journal.setStatus(id, PlaceStatus.want);
      expect(
        place().recommended,
        isFalse,
        reason: '"Gideceğim" öneriyi kaldırır',
      );

      journal.setStatus(id, null);
      expect(place().status, isNull);

      journal.saveVisit(
        Visit(
          id: '',
          placeId: id,
          date: '2026-10-06',
          note: 'Not',
          recommended: true,
        ),
      );
      expect(
        place().status,
        PlaceStatus.went,
        reason: 'deneyim yazılınca gidilmiş sayılır',
      );
      expect(place().recommended, isTrue);
    });

    test('listedeki mekân deftere bir kez eklenir', () async {
      final container = await _container(MemoryJournalStorage());
      final journal = container.read(journalProvider.notifier);
      final item = sampleRemoteList().items.single;

      final first = journal.addFromListItem(item);
      final second = journal.addFromListItem(item);

      expect(first.existed, isFalse);
      expect(second, (id: first.id, existed: true));
      final place = container.read(journalDataProvider).placeById(first.id)!;
      expect((place.district, place.city), ('Moda', 'İstanbul'));
      expect(place.status, PlaceStatus.want);
    });

    test('bozuk kayıt okunmaz ve üzerine yazılmaz', () async {
      final storage = MemoryJournalStorage('{bozuk');
      final container = await _container(storage);

      expect(container.read(journalProvider).hasError, isTrue);
      expect(storage.contents, '{bozuk');
    });
  });

  test('alanı semt ve şehre ayırır', () {
    expect(areaToLocation('Moda, Kadıköy, İstanbul'), (
      district: 'Moda, Kadıköy',
      city: 'İstanbul',
    ));
    expect(areaToLocation('Moda'), (district: 'Moda', city: ''));
  });
}
