import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_notifier.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';
import 'package:gurme/features/lists/data/list_repository.dart';
import 'package:gurme/features/lists/data/list_sync.dart';

import 'helpers.dart';

Future<ProviderContainer> _container(FakeServer server) async {
  final container = ProviderContainer(
    overrides: [
      appDirectoryProvider.overrideWithValue(Directory.systemTemp),
      journalStorageProvider.overrideWithValue(MemoryJournalStorage()),
      ...fakeApi(server)!,
    ],
  );
  addTearDown(container.dispose);
  await container.read(journalProvider.future);
  return container;
}

String _localList(ProviderContainer c) {
  final journal = c.read(journalProvider.notifier);
  final placeId = journal.addPlace(
    (id, now) => Place(
      id: id,
      name: 'Kahve Durağı',
      district: 'Moda',
      city: 'İstanbul',
      category: 'Kahve',
      createdAt: now,
    ),
  );
  return journal.saveList(
    title: 'Rota',
    description: 'Sabah',
    city: 'İstanbul',
    items: [ListItem(placeId: placeId, note: 'Filtre kahve')],
  );
}

void main() {
  test('profilde ad yoksa liste yayınlanmaz', () async {
    final server = FakeServer((_) => (500, null));
    final c = await _container(server);
    final listId = _localList(c);

    expect(
      () => c.read(listSyncProvider).publish(listId, ListVisibility.unlisted),
      throwsA(isA<ListSyncException>()),
    );
    expect(server.requests, isEmpty);
  });

  test('ilk yayın listeyi oluşturur ve anahtarı saklar', () async {
    final server = FakeServer(
      (r) => (
        201,
        {
          ...sampleRemoteList(id: 'remote-1').toJson(),
          'ownerKey': 'secret-key',
        },
      ),
    );
    final c = await _container(server);
    final listId = _localList(c);
    c
        .read(journalProvider.notifier)
        .updateProfile((p) => p.copyWith(name: 'Semih'));

    final url = await c
        .read(listSyncProvider)
        .publish(listId, ListVisibility.public);

    expect(url, 'https://api.test/api/gurme/share/remote-1');
    final request = server.requests.single;
    expect((request.method, request.path), ('POST', '/gurme/lists'));
    final body = jsonDecode(request.data as String) as Map<String, dynamic>;
    expect(body['authorName'], 'Semih');
    expect(body['visibility'], 'public');
    expect((body['items'] as List).single['area'], 'Moda, İstanbul');
    final list = c.read(journalDataProvider).listById(listId)!;
    expect((list.remoteId, list.ownerKey), ('remote-1', 'secret-key'));
    expect(list.visibility, ListVisibility.public);
  });

  test('yayınlanmış listenin güncellemesi anahtarla gönderilir', () async {
    final server = FakeServer(
      (r) => (200, sampleRemoteList(id: 'remote-1').toJson()),
    );
    final c = await _container(server);
    final listId = _localList(c);
    final journal = c.read(journalProvider.notifier);
    journal.updateProfile((p) => p.copyWith(name: 'Semih'));
    journal.linkRemoteList(
      listId,
      remoteId: 'remote-1',
      ownerKey: 'secret-key',
      visibility: ListVisibility.public,
    );

    await c
        .read(listSyncProvider)
        .updateVisibility(listId, ListVisibility.unlisted);

    final request = server.requests.single;
    expect((request.method, request.path), ('PUT', '/gurme/lists/remote-1'));
    expect(request.headers['X-Owner-Key'], 'secret-key');
    expect(
      c.read(journalDataProvider).listById(listId)!.visibility,
      ListVisibility.unlisted,
    );
  });

  test('sunucu güncellemeyi reddederse yerel liste değişmez', () async {
    final server = FakeServer(
      (r) => (
        404,
        {'error': 'Gurme listesi bulunamadı veya liste sahibi değilsiniz'},
      ),
    );
    final c = await _container(server);
    final listId = _localList(c);
    final journal = c.read(journalProvider.notifier);
    journal.updateProfile((p) => p.copyWith(name: 'Semih'));
    journal.linkRemoteList(
      listId,
      remoteId: 'remote-1',
      ownerKey: 'k',
      visibility: ListVisibility.public,
    );

    await expectLater(
      c
          .read(listSyncProvider)
          .save(
            listId: listId,
            title: 'Yeni ad',
            description: '',
            city: '',
            items: const [],
            visibility: ListVisibility.public,
          ),
      throwsA(
        isA<ListSyncException>().having(
          (e) => e.message,
          'message',
          'Gurme listesi bulunamadı veya liste sahibi değilsiniz',
        ),
      ),
    );
    expect(c.read(journalDataProvider).listById(listId)!.title, 'Rota');
  });

  test('yerel liste silinir ve geri alınınca eski yerine döner', () async {
    final server = FakeServer((r) => (500, null));
    final c = await _container(server);
    final listId = _localList(c);
    final before = c.read(journalDataProvider).lists.map((l) => l.id).toList();

    final undo = await c.read(listSyncProvider).delete(listId);

    expect(server.requests, isEmpty);
    expect(c.read(journalDataProvider).listById(listId), isNull);
    undo!();
    expect(c.read(journalDataProvider).lists.map((l) => l.id), before);
  });

  test('yayınlanmış listenin silinmesi geri alınamaz', () async {
    final server = FakeServer((r) => (204, null));
    final c = await _container(server);
    final listId = _localList(c);
    c
        .read(journalProvider.notifier)
        .linkRemoteList(
          listId,
          remoteId: 'remote-1',
          ownerKey: 'k',
          visibility: ListVisibility.public,
        );

    expect(await c.read(listSyncProvider).delete(listId), isNull);
  });

  test('sunucuda zaten silinmiş liste yerelden de silinir', () async {
    final server = FakeServer(
      (r) => (404, {'error': 'Gurme listesi bulunamadı'}),
    );
    final c = await _container(server);
    final listId = _localList(c);
    c
        .read(journalProvider.notifier)
        .linkRemoteList(
          listId,
          remoteId: 'remote-1',
          ownerKey: 'k',
          visibility: ListVisibility.public,
        );

    await c.read(listSyncProvider).delete(listId);

    expect(server.requests.single.method, 'DELETE');
    expect(c.read(journalDataProvider).listById(listId), isNull);
  });

  test('sunucu hatasında yayınlanmış liste yerelde korunur', () async {
    final server = FakeServer(
      (r) => (500, {'error': 'Gurme listesi veritabanında silinemedi'}),
    );
    final c = await _container(server);
    final listId = _localList(c);
    c
        .read(journalProvider.notifier)
        .linkRemoteList(
          listId,
          remoteId: 'remote-1',
          ownerKey: 'k',
          visibility: ListVisibility.public,
        );

    await expectLater(
      c.read(listSyncProvider).delete(listId),
      throwsA(isA<ListSyncException>()),
    );
    expect(c.read(journalDataProvider).listById(listId), isNotNull);
  });

  test('paylaşım adresi', () {
    expect(
      shareUrl('https://x.test/api/', 'a b'),
      'https://x.test/api/gurme/share/a%20b',
    );
  });
}
