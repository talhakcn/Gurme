import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../journal/data/journal_models.dart';
import '../../journal/data/journal_notifier.dart';
import 'list_repository.dart';

final listSyncProvider = Provider<ListSync>(ListSync.new);

/// Yerel listelerin sunucuyla eşitlenmesi: yayınlama, görünürlük,
/// düzenleme ve silme. Hatalar [ListSyncException] olarak gelir.
class ListSync {
  ListSync(this._ref);

  final Ref _ref;

  JournalData get _data => _ref.read(journalDataProvider);
  JournalNotifier get _journal => _ref.read(journalProvider.notifier);
  ListRepository get _repo => _ref.read(listRepositoryProvider);

  CuratedList _list(String id) =>
      _data.listById(id) ??
      (throw const ListSyncException('Liste bulunamadı.'));

  String _authorName(String action) {
    final name = _data.profile.name.trim();
    if (name.isEmpty) {
      throw ListSyncException(
        '$action için profilinde görünen bir ad belirle.',
      );
    }
    return name;
  }

  static String _ownerKey(CuratedList list) =>
      list.ownerKey ??
      (throw const ListSyncException(
        'Bu listenin düzenleme anahtarı bu cihazda yok.',
      ));

  /// Listeyi ilk kez yayınlar ya da yayınlanmış kopyasını günceller.
  /// Paylaşım adresini döndürür.
  Future<String> publish(String listId, ListVisibility visibility) async {
    final list = _list(listId);
    final author = _authorName('Listeyi yayımlamak');
    if (visibility == ListVisibility.private) {
      throw const ListSyncException(
        'Özel listeye bağlantı oluşturulamaz. Bağlantı ile erişim veya '
        'herkese açık seç.',
      );
    }
    final payload = listPayload(
      title: list.title,
      description: list.description,
      items: list.items,
      places: _data.places,
      authorName: author,
      visibility: visibility,
    );
    final String remoteId;
    if (list.remoteId case final existing?) {
      await _repo.update(existing, _ownerKey(list), payload);
      _journal.setListVisibility(listId, visibility);
      remoteId = existing;
    } else {
      final created = await _repo.create(payload);
      _journal.linkRemoteList(
        listId,
        remoteId: created.id,
        ownerKey: created.ownerKey,
        visibility: visibility,
      );
      remoteId = created.id;
    }
    _ref.invalidate(publicListsProvider);
    return shareUrl(_ref.read(apiBaseUrlProvider), remoteId);
  }

  /// Yayınlanmış listenin yalnızca görünürlüğünü değiştirir.
  Future<void> updateVisibility(
    String listId,
    ListVisibility visibility,
  ) async {
    final list = _list(listId);
    final remoteId = list.remoteId;
    if (remoteId == null) return;
    final author = _authorName('Görünürlüğü güncellemek');
    await _repo.update(
      remoteId,
      _ownerKey(list),
      listPayload(
        title: list.title,
        description: list.description,
        items: list.items,
        places: _data.places,
        authorName: author,
        visibility: visibility,
      ),
    );
    _journal.setListVisibility(listId, visibility);
    _ref.invalidate(publicListsProvider);
  }

  /// Liste düzenleyicisinden kaydeder. Liste yayınlanmışsa önce sunucu
  /// güncellenir; sunucu reddederse yerel kayıt da değişmez.
  Future<String> save({
    String? listId,
    required String title,
    required String description,
    required String city,
    required List<ListItem> items,
    required ListVisibility visibility,
  }) async {
    final current = listId == null ? null : _data.listById(listId);
    if (current?.remoteId case final remoteId?) {
      final author = _authorName('Yayınlanmış listeyi güncellemek');
      await _repo.update(
        remoteId,
        _ownerKey(current!),
        listPayload(
          title: title,
          description: description,
          items: items,
          places: _data.places,
          authorName: author,
          visibility: visibility,
        ),
      );
      _ref.invalidate(publicListsProvider);
    }
    return _journal.saveList(
      id: listId,
      title: title,
      description: description,
      city: city,
      items: items,
      visibility: visibility,
    );
  }

  /// Giriş yapıldığında cihaz anahtarıyla yayınlanmış listeleri hesaba
  /// bağlar; böylece başka cihazdan da düzenlenebilirler. Başarısız olanlar
  /// sonraki girişte yeniden denenir. Bağlanan liste sayısını döndürür.
  Future<int> claimAll() async {
    var claimed = 0;
    for (final list in _data.lists) {
      final remoteId = list.remoteId;
      final ownerKey = list.ownerKey;
      if (remoteId == null || ownerKey == null) continue;
      try {
        await _repo.claim(remoteId, ownerKey);
        claimed++;
      } on ListSyncException {
        // Liste sunucuda yoksa ya da bağlantı yoksa geç.
      }
    }
    return claimed;
  }

  /// Listeyi ve varsa yayınlanmış kopyasını siler. Sunucudan silinemezse
  /// yerel kayıt korunur.
  /// Listeyi siler. Yalnızca bu cihazdaki bir listeyse geri alma işlevi
  /// döner; yayınlanmış liste sunucudan da silindiği için `null`.
  Future<void Function()?> delete(String listId) async {
    final list = _list(listId);
    if (list.remoteId case final remoteId?) {
      await _repo.delete(remoteId, _ownerKey(list));
      _ref.invalidate(publicListsProvider);
      _journal.deleteList(listId);
      return null;
    }
    return _journal.deleteList(listId);
  }
}
