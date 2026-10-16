import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/text/turkish.dart';
import '../../journal/data/journal_notifier.dart';
import '../../journal/data/journal_storage.dart';

/// Son aramaların cihazdaki kaydı (`recent_searches.json`).
final recentSearchesStorageProvider = Provider<JournalStorage>(
  (ref) => FileJournalStorage(
    ref.watch(appDirectoryProvider),
    name: 'recent_searches.json',
  ),
);

final recentSearchesProvider =
    NotifierProvider<RecentSearchesController, List<RecentSearch>>(
      RecentSearchesController.new,
    );

typedef RecentSearch = ({String query, String city});

/// Son beş arama, yeniden eskiye. Arama hakkı günlük sınırlı olduğu için
/// aynı kelimeyi ve yeri yeniden yazmak gerekmez.
class RecentSearchesController extends Notifier<List<RecentSearch>> {
  static const max = 5;

  @override
  List<RecentSearch> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final raw = await ref.read(recentSearchesStorageProvider).read();
    if (raw == null) return;
    try {
      final loaded = [
        for (final e in jsonDecode(raw) as List)
          (
            query: (e as Map)['query'] as String,
            city: e['city'] as String? ?? '',
          ),
      ];
      // Okuma sürerken eklenen arama kaybolmaz.
      state = _merge(state, loaded);
    } on Object {
      // Bozuk kayıt: liste boş başlar, zararı yok.
    }
  }

  static String _key(RecentSearch s) =>
      '${normalizeForMatch(s.query.trim())}|${normalizeForMatch(s.city.trim())}';

  static List<RecentSearch> _merge(
    List<RecentSearch> first,
    List<RecentSearch> rest,
  ) {
    final seen = <String>{};
    return [
      for (final s in [...first, ...rest])
        if (s.query.trim().isNotEmpty && seen.add(_key(s))) s,
    ].take(max).toList();
  }

  Future<void> add(String query, String city) async {
    state = _merge([(query: query.trim(), city: city.trim())], state);
    await ref
        .read(recentSearchesStorageProvider)
        .write(
          jsonEncode([
            for (final s in state) {'query': s.query, 'city': s.city},
          ]),
        );
  }
}
