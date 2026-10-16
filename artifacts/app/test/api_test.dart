import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/api/api_providers.dart';
import 'package:gurme_client/gurme_client.dart';

void main() {
  test('API adresi verilmezse canlı sunucu kullanılır', () {
    // Telefonda localhost telefonun kendisidir; adres verilmeden yapılan
    // derleme arama yapamıyordu.
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      debugDefaultTargetPlatformOverride = platform;
      expect(resolveApiBaseUrl(), productionApiBaseUrl);
    }
    debugDefaultTargetPlatformOverride = null;
    expect(productionApiBaseUrl, startsWith('https://'));
  });

  test('istemci verilen API adresini kullanır', () {
    final container = ProviderContainer(
      overrides: [
        apiBaseUrlProvider.overrideWithValue('https://ornek.test/api'),
      ],
    );
    addTearDown(container.dispose);
    expect(
      container.read(apiClientProvider).dio.options.baseUrl,
      'https://ornek.test/api',
    );
  });

  test('üretilen modeller API yanıtını çözer', () {
    final list = GurmeList.fromJson({
      'id': '6f1c2d8e-1b2a-4c3d-9e8f-0a1b2c3d4e5f',
      'title': 'Kadıköy kahveleri',
      'description': '',
      'authorName': 'Semih',
      'visibility': 'unlisted',
      'items': [
        {
          'placeId': 'abc',
          'name': 'Kahve Durağı',
          'area': 'Kadıköy',
          'category': 'Kahve',
          'note': '',
        },
      ],
      'createdAt': '2026-10-06T10:00:00.000Z',
      'updatedAt': '2026-10-06T10:00:00.000Z',
    });
    expect(list.visibility, GurmeListVisibility.unlisted);
    expect(list.items.single.name, 'Kahve Durağı');
    expect(list.createdAt.toUtc(), DateTime.utc(2026, 10, 6, 10));
  });
}
