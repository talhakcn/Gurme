import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gurme_client/gurme_client.dart';

import '../../../core/text/turkish.dart';
import 'journal_models.dart';
import 'journal_storage.dart';

/// Uygulamanın kendi veri klasörü; `main()` içinde belirlenip verilir.
final appDirectoryProvider = Provider<Directory>(
  (ref) => throw UnimplementedError('appDirectoryProvider verilmedi'),
);

final journalStorageProvider = Provider<JournalStorage>(
  (ref) => FileJournalStorage(ref.watch(appDirectoryProvider)),
);

final photoStoreProvider = Provider<PhotoStore>(
  (ref) => PhotoStore(ref.watch(appDirectoryProvider)),
);

final journalProvider = AsyncNotifierProvider<JournalNotifier, JournalData>(
  JournalNotifier.new,
  // Okuma hatasında otomatik yeniden deneme yok; kullanıcı uyarılır.
  retry: (retryCount, error) => null,
);

/// Defter yüklendikten sonra ekranların okuduğu veri. Uygulama, defter
/// yüklenmeden ekranları göstermez (bkz. `JournalGate`).
final journalDataProvider = Provider<JournalData>(
  (ref) => ref.watch(journalProvider).requireValue,
);

class JournalException implements Exception {
  const JournalException(this.message);

  final String message;

  @override
  String toString() => message;
}

final _random = Random.secure();
String newId() =>
    '${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}'
    '${_random.nextInt(1 << 32).toRadixString(36)}';

class JournalNotifier extends AsyncNotifier<JournalData> {
  Future<void> _writes = Future.value();

  @override
  Future<JournalData> build() async {
    final storage = ref.watch(journalStorageProvider);
    final String? raw;
    try {
      raw = await storage.read();
    } catch (_) {
      throw const JournalException(
        'Kişisel defter açılamadı. Verilerin korunması için yeni kayıt yapılmadı.',
      );
    }
    if (raw == null) return const JournalData();
    final JournalData data;
    try {
      data = JournalData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Bozuk kaydın üzerine yazılmaz; defter hata durumunda kalır.
      throw const JournalException(
        'Kişisel defter okunamadı. Verilerin korunması için yeni kayıt '
        'yapılmadı. Uygulama verilerini silmeden önce destek alın.',
      );
    }
    unawaited(
      ref
          .read(photoStoreProvider)
          .deleteUnreferenced(data.photoPaths)
          .catchError((_) {}),
    );
    return data;
  }

  JournalData get _data => state.requireValue;

  void _set(JournalData next) {
    state = AsyncData(next);
    final json = jsonEncode(next.toJson());
    final storage = ref.read(journalStorageProvider);
    _writes = _writes.then((_) => storage.write(json)).catchError((_) {
      state = AsyncError(
        const JournalException(
          'Defter kaydedilemedi. Mevcut kayıtları korumak için uygulamayı '
          'kapatmadan önce yeniden deneyin.',
        ),
        StackTrace.current,
      );
    });
  }

  /// Defterin tamamını değiştirir; buluttan geri yükleme için.
  void replaceAll(JournalData data) => _set(data);

  /// Bekleyen yazma işlemleri bitince tamamlanır (testler için).
  Future<void> flush() => _writes;

  // Mekânlar

  String addPlace(Place Function(String id, DateTime now) create) {
    final place = create(newId(), DateTime.now());
    _set(_data.copyWith(places: [place, ..._data.places]));
    return place.id;
  }

  /// Bir listedeki mekânı "gideceğim" olarak deftere ekler. Aynı ad ve
  /// bölgeyle kayıtlı bir mekân varsa yenisini eklemez.
  ({String id, bool existed}) addFromListItem(GurmeListItem item) {
    final existing = _data.places
        .where(
          (p) => equalsTr(p.name, item.name) && equalsTr(p.area, item.area),
        )
        .firstOrNull;
    if (existing != null) return (id: existing.id, existed: true);
    final location = areaToLocation(item.area);
    final id = addPlace(
      (id, now) => Place(
        id: id,
        name: item.name,
        district: location.district,
        city: location.city,
        category: item.category.isEmpty ? 'Mekân' : item.category,
        description: item.note,
        status: PlaceStatus.want,
        createdAt: now,
      ),
    );
    return (id: id, existed: false);
  }

  /// Aramada bulunan mekânı "gideceğim" olarak deftere ekler. Aynı Google
  /// kimliğiyle ya da aynı ad ve bölgeyle kayıtlı mekân varsa onu döndürür.
  ({String id, bool existed}) addFromSearch({
    required String googlePlaceId,
    required String name,
    required String address,
    required String category,
    required String fallbackCity,
    double? lat,
    double? lng,
  }) {
    final location = locationFromAddress(address, fallbackCity);
    final area = [
      location.district,
      location.city,
    ].where((s) => s.isNotEmpty).join(', ');
    final existing = _data.places
        .where(
          (p) =>
              p.googlePlaceId == googlePlaceId ||
              (equalsTr(p.name, name) && equalsTr(p.area, area)),
        )
        .firstOrNull;
    if (existing != null) {
      // Elle eklenmiş kayıt aramada bulununca haritadaki yerini kazanır.
      if (!existing.hasLocation && lat != null && lng != null) {
        updatePlace(existing.id, (p) => p.copyWith(lat: lat, lng: lng));
      }
      return (id: existing.id, existed: true);
    }
    final id = addPlace(
      (id, now) => Place(
        id: id,
        name: name,
        district: location.district,
        city: location.city,
        address: address,
        category: category.isEmpty ? 'Mekân' : category,
        status: PlaceStatus.want,
        createdAt: now,
        googlePlaceId: googlePlaceId,
        lat: lat,
        lng: lng,
      ),
    );
    return (id: id, existed: false);
  }

  void updatePlace(String id, Place Function(Place place) update) {
    _set(
      _data.copyWith(
        places: [for (final p in _data.places) p.id == id ? update(p) : p],
      ),
    );
  }

  /// Mekânı, deneyimlerini ve listelerdeki kaydını siler. Dönen işlev
  /// silineni eski yerine geri koyar ("Geri al"); aradaki başka
  /// değişikliklere dokunmaz.
  void Function() deletePlace(String id) {
    final d = _data;
    final index = d.places.indexWhere((p) => p.id == id);
    if (index < 0) return () {};
    final place = d.places[index];
    final visits = d.visits.where((v) => v.placeId == id).toList();
    final stops = {
      for (final l in d.lists)
        if (l.contains(id))
          l.id: (
            l.items.indexWhere((i) => i.placeId == id),
            l.items.firstWhere((i) => i.placeId == id),
          ),
    };
    _set(
      d.copyWith(
        places: d.places.where((p) => p.id != id).toList(),
        visits: d.visits.where((v) => v.placeId != id).toList(),
        lists: [
          for (final l in d.lists)
            l.contains(id)
                ? l.copyWith(
                    items: l.items.where((i) => i.placeId != id).toList(),
                  )
                : l,
        ],
      ),
    );
    return () {
      final now = _data;
      if (now.places.any((p) => p.id == id)) return;
      _set(
        now.copyWith(
          places: [...now.places]
            ..insert(index.clamp(0, now.places.length), place),
          visits: [
            ...now.visits,
            for (final v in visits)
              if (!now.visits.any((n) => n.id == v.id)) v,
          ],
          lists: [
            for (final l in now.lists)
              if (stops[l.id] case (final at, final item) when !l.contains(id))
                l.copyWith(
                  items: [...l.items]
                    ..insert(at.clamp(0, l.items.length), item),
                )
              else
                l,
          ],
        ),
      );
    };
  }

  /// "Gideceğim" seçilince öneri kalkar; `null` statüyü temizler. Dönen
  /// işlev önceki durumu ve öneriyi geri getirir.
  void Function() setStatus(String id, PlaceStatus? status) {
    final before = _data.placeById(id);
    updatePlace(
      id,
      (p) => status == PlaceStatus.want
          ? p.copyWith(status: status, recommended: false)
          : p.copyWith(status: status),
    );
    return () {
      if (before == null) return;
      updatePlace(
        id,
        (p) =>
            p.copyWith(status: before.status, recommended: before.recommended),
      );
    };
  }

  /// "Öneriyorum" ayrı bir tercih; açılınca mekân "gittim" sayılır.
  void toggleRecommended(String id) => updatePlace(
    id,
    (p) => p.copyWith(status: PlaceStatus.went, recommended: !p.recommended),
  );

  // Deneyimler

  /// Yeni deneyim için [visit] kimliği boş verilir. Mekân "gittim" olur.
  String saveVisit(Visit visit) {
    final id = visit.id.isEmpty ? newId() : visit.id;
    final saved = Visit(
      id: id,
      placeId: visit.placeId,
      date: visit.date,
      title: visit.title,
      note: visit.note,
      order: visit.order,
      recommended: visit.recommended,
      revisit: visit.revisit,
      dishes: visit.dishes,
      photos: visit.photos,
      visibility: visit.visibility,
      scores: visit.scores,
      tastedDishes: visit.tastedDishes,
    );
    final d = _data;
    _set(
      d.copyWith(
        visits: [saved, ...d.visits.where((v) => v.id != id)],
        places: [
          for (final p in d.places)
            p.id == visit.placeId
                ? p.copyWith(
                    status: PlaceStatus.went,
                    recommended: visit.recommended || p.recommended,
                  )
                : p,
        ],
      ),
    );
    return id;
  }

  /// Deneyimi siler; dönen işlev onu eski yerine geri koyar.
  void Function() deleteVisit(String id) {
    final index = _data.visits.indexWhere((v) => v.id == id);
    if (index < 0) return () {};
    final visit = _data.visits[index];
    _set(
      _data.copyWith(visits: _data.visits.where((v) => v.id != id).toList()),
    );
    return () {
      final now = _data;
      if (now.visits.any((v) => v.id == id)) return;
      if (!now.places.any((p) => p.id == visit.placeId)) return;
      _set(
        now.copyWith(
          visits: [...now.visits]
            ..insert(index.clamp(0, now.visits.length), visit),
        ),
      );
    };
  }

  // Listeler

  /// Yeni liste için [id] verilmez. Güncellenen liste en üste taşınır.
  String saveList({
    String? id,
    required String title,
    required String description,
    required String city,
    required List<ListItem> items,
    ListVisibility? visibility,
  }) {
    final d = _data;
    final now = DateTime.now();
    final prior = id == null ? null : d.listById(id);
    final list = prior == null
        ? CuratedList(
            id: id ?? newId(),
            title: title,
            description: description,
            city: city,
            items: items,
            createdAt: now,
            updatedAt: now,
            visibility: visibility ?? ListVisibility.private,
          )
        : prior.copyWith(
            title: title,
            description: description,
            city: city,
            items: items,
            updatedAt: now,
            visibility: visibility,
          );
    _set(d.copyWith(lists: [list, ...d.lists.where((l) => l.id != list.id)]));
    return list.id;
  }

  /// Bir mekânı yerel listeye ekler ya da listeden çıkarır.
  void togglePlaceInList(String listId, String placeId) {
    final list = _data.listById(listId);
    if (list == null) return;
    saveList(
      id: list.id,
      title: list.title,
      description: list.description,
      city: list.city,
      items: list.contains(placeId)
          ? list.items.where((i) => i.placeId != placeId).toList()
          : [...list.items, ListItem(placeId: placeId)],
    );
  }

  void _updateList(String id, CuratedList Function(CuratedList l) update) =>
      _set(
        _data.copyWith(
          lists: [for (final l in _data.lists) l.id == id ? update(l) : l],
        ),
      );

  void linkRemoteList(
    String id, {
    required String remoteId,
    required String ownerKey,
    required ListVisibility visibility,
  }) => _updateList(
    id,
    (l) => l.copyWith(
      remoteId: remoteId,
      ownerKey: ownerKey,
      visibility: visibility,
    ),
  );

  void setListVisibility(String id, ListVisibility visibility) =>
      _updateList(id, (l) => l.copyWith(visibility: visibility));

  /// Listeyi siler; dönen işlev onu eski yerine (kaydedilmişse kaydıyla)
  /// geri koyar.
  void Function() deleteList(String id) {
    final index = _data.lists.indexWhere((l) => l.id == id);
    if (index < 0) return () {};
    final list = _data.lists[index];
    final wasSaved = _data.savedListIds.contains(id);
    _set(
      _data.copyWith(
        lists: _data.lists.where((l) => l.id != id).toList(),
        savedListIds: _data.savedListIds.where((x) => x != id).toList(),
      ),
    );
    return () {
      final now = _data;
      if (now.lists.any((l) => l.id == id)) return;
      _set(
        now.copyWith(
          lists: [...now.lists]..insert(index.clamp(0, now.lists.length), list),
          savedListIds: wasSaved ? [...now.savedListIds, id] : now.savedListIds,
        ),
      );
    };
  }

  void toggleSaved(String id) {
    final ids = _data.savedListIds;
    _set(
      _data.copyWith(
        savedListIds: ids.contains(id)
            ? ids.where((x) => x != id).toList()
            : [...ids, id],
      ),
    );
  }

  void toggleRemoteSaved(GurmeList list) {
    final saved = _data.savedRemoteLists;
    _set(
      _data.copyWith(
        savedRemoteLists: saved.any((l) => l.id == list.id)
            ? saved.where((l) => l.id != list.id).toList()
            : [list, ...saved],
      ),
    );
  }

  // Profil

  void updateProfile(Profile Function(Profile profile) update) =>
      _set(_data.copyWith(profile: update(_data.profile)));
}
