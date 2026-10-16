import 'dart:convert';

import '../../journal/data/journal_models.dart';

extension JournalEmptiness on JournalData {
  /// Defterde kullanıcının girdiği hiçbir şey yok.
  bool get isBlank =>
      places.isEmpty &&
      visits.isEmpty &&
      lists.isEmpty &&
      savedListIds.isEmpty &&
      savedRemoteLists.isEmpty &&
      _isDefault(profile);
}

bool _isDefault(Profile profile) =>
    jsonEncode(profile.toJson()) == jsonEncode(const Profile().toJson());

/// İki cihazın defterini birleştirir; hiçbir kayıt kaybolmaz.
///
/// Aynı kimlikli mekân ve deneyimde bu cihazdaki ([local]) sürüm, listede
/// daha yeni güncellenen kalır. Bir cihazda silinen kayıt diğerinde
/// duruyorsa birleştirmeden sonra geri gelir; veri kaybından iyidir.
JournalData mergeJournals(JournalData local, JournalData remote) {
  List<T> union<T>(
    List<T> mine,
    List<T> theirs,
    String Function(T item) id, [
    T Function(T mine, T theirs)? pick,
  ]) {
    final others = {for (final item in theirs) id(item): item};
    final result = <T>[];
    for (final item in mine) {
      final other = others.remove(id(item));
      result.add(other == null || pick == null ? item : pick(item, other));
    }
    return result..addAll(others.values);
  }

  return JournalData(
    places: union(local.places, remote.places, (p) => p.id),
    visits: union(local.visits, remote.visits, (v) => v.id),
    lists: union(
      local.lists,
      remote.lists,
      (l) => l.id,
      (mine, theirs) =>
          theirs.updatedAt.isAfter(mine.updatedAt) ? theirs : mine,
    ),
    savedListIds: {...local.savedListIds, ...remote.savedListIds}.toList(),
    savedRemoteLists: union(
      local.savedRemoteLists,
      remote.savedRemoteLists,
      (l) => l.id,
    ),
    profile: _isDefault(local.profile) ? remote.profile : local.profile,
  );
}
