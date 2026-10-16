import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gurme_client/gurme_client.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_providers.dart';
import '../../journal/data/journal_models.dart';

final listRepositoryProvider = Provider<ListRepository>(
  (ref) => ListRepository(ref.watch(apiClientProvider).getGurmeApi()),
);

/// Keşfet'teki herkese açık listeler.
final publicListsProvider = FutureProvider<List<GurmeList>>(
  (ref) => ref.watch(listRepositoryProvider).publicLists(),
);

/// Bağlantıyla ya da Keşfet'ten açılan tek bir liste.
final remoteListProvider = FutureProvider.family<GurmeList, String>(
  (ref, id) => ref.watch(listRepositoryProvider).getList(id),
);

/// Kullanıcıya gösterilebilecek bir hata mesajı taşır.
class ListSyncException implements Exception {
  const ListSyncException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ListRepository {
  ListRepository(this._api);

  final GurmeApi _api;

  Future<List<GurmeList>> publicLists() =>
      _guard(() async => (await _api.listGurmeLists()).data ?? const []);

  Future<GurmeList> getList(String id) =>
      _guard(() async => (await _api.getGurmeList(id: id)).data!);

  Future<GurmeListCreated> create(GurmeListInput input) => _guard(
    () async => (await _api.createGurmeList(gurmeListInput: input)).data!,
  );

  Future<GurmeList> update(String id, String ownerKey, GurmeListInput input) =>
      _guard(
        () async => (await _api.updateGurmeList(
          id: id,
          gurmeListUpdate: GurmeListUpdate(
            title: input.title,
            description: input.description,
            authorName: input.authorName,
            visibility: input.visibility,
            items: input.items,
          ),
          headers: _owner(ownerKey),
        )).data!,
      );

  /// Liste sunucuda zaten yoksa (404) silinmiş sayılır; yerel kayıt da
  /// silinebilsin diye hata verilmez.
  Future<void> delete(String id, String ownerKey) => _guard(() async {
    try {
      await _api.deleteGurmeList(id: id, headers: _owner(ownerKey));
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
    }
  });

  // Authorization başlığı Firebase girişine ayrıldığı için anahtar ayrı
  // başlıkta gider.
  static Map<String, dynamic> _owner(String ownerKey) => {
    'X-Owner-Key': ownerKey,
  };

  /// Cihaz anahtarıyla yayınlanan listeyi giriş yapılan hesaba bağlar.
  Future<void> claim(String id, String ownerKey) =>
      _guard(() => _api.claimGurmeList(id: id, headers: _owner(ownerKey)));

  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ListSyncException(apiErrorMessage(e));
    }
  }
}

GurmeListVisibility toApiVisibility(ListVisibility v) => switch (v) {
  ListVisibility.private => GurmeListVisibility.private,
  ListVisibility.unlisted => GurmeListVisibility.unlisted,
  ListVisibility.public => GurmeListVisibility.public,
};

ListVisibility fromApiVisibility(GurmeListVisibility v) => switch (v) {
  GurmeListVisibility.private => ListVisibility.private,
  GurmeListVisibility.unlisted => ListVisibility.unlisted,
  GurmeListVisibility.public => ListVisibility.public,
};

/// Yerel listeyi sunucuya gönderilecek biçime çevirir. Mekân adı, bölge ve
/// kategori listeye kopyalanır; kişisel deneyim notları gönderilmez.
GurmeListInput listPayload({
  required String title,
  required String description,
  required List<ListItem> items,
  required List<Place> places,
  required String authorName,
  required ListVisibility visibility,
}) => GurmeListInput(
  title: title.trim(),
  description: description.trim(),
  authorName: authorName.trim(),
  visibility: toApiVisibility(visibility),
  items: [
    for (final item in items)
      () {
        final place = places.where((p) => p.id == item.placeId).firstOrNull;
        return GurmeListItem(
          placeId: item.placeId,
          name: place?.name ?? 'Mekân',
          area: place?.area ?? '',
          category: place?.category ?? '',
          note: item.note.trim(),
        );
      }(),
  ],
);

/// Sunucunun herkese açık paylaşım sayfası.
String shareUrl(String apiBaseUrl, String remoteId) {
  final base = apiBaseUrl.endsWith('/')
      ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
      : apiBaseUrl;
  return '$base/gurme/share/${Uri.encodeComponent(remoteId)}';
}
