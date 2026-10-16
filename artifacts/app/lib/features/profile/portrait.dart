import '../../core/text/turkish.dart';
import '../journal/data/journal_models.dart';

/// Profildeki "defter portresi": kişinin gittiklerinden çıkan birkaç
/// gerçek. Sayımlar yalnızca deneyimlerden yapılır; eklenip gidilmemiş
/// mekânlar portreye girmez.
class NotebookPortrait {
  const NotebookPortrait({
    this.category,
    this.district,
    this.favorite,
    this.favoriteVisits = 0,
    this.lastVisit,
    this.lastPlace,
    this.marks = const [],
  });

  /// En çok deneyim yazılan tür ve deneyim sayısı.
  final (String, int)? category;

  /// En çok deneyim yazılan semt ve deneyim sayısı.
  final (String, int)? district;

  /// Önerilen mekânlar içinde en çok gidilen.
  final Place? favorite;
  final int favoriteVisits;

  /// En son tarihli deneyim ve mekânı.
  final Visit? lastVisit;
  final Place? lastPlace;

  /// Karnesi olan mekânların lezzet izleri; son gidilen önce, en çok 6.
  final List<(Place, TastingScores, double?)> marks;

  bool get isEmpty => lastVisit == null;

  static (String, int)? _top(Map<String, int> counts) {
    if (counts.isEmpty) return null;
    final best = counts.entries.reduce((a, b) {
      final byCount = a.value.compareTo(b.value);
      if (byCount != 0) return byCount > 0 ? a : b;
      return compareTr(a.key, b.key) <= 0 ? a : b;
    });
    return (best.key, best.value);
  }

  factory NotebookPortrait.of(JournalData data) {
    final placeOf = {for (final p in data.places) p.id: p};
    final visits = [
      for (final v in data.visits)
        if (placeOf.containsKey(v.placeId)) v,
    ]..sort((a, b) => b.date.compareTo(a.date));
    if (visits.isEmpty) return const NotebookPortrait();

    final categories = <String, int>{};
    final districts = <String, int>{};
    final visitCount = <String, int>{};
    for (final v in visits) {
      final p = placeOf[v.placeId]!;
      visitCount[p.id] = (visitCount[p.id] ?? 0) + 1;
      if (p.category.isNotEmpty) {
        categories[p.category] = (categories[p.category] ?? 0) + 1;
      }
      if (p.district.isNotEmpty) {
        districts[p.district] = (districts[p.district] ?? 0) + 1;
      }
    }

    Place? favorite;
    var favoriteVisits = 0;
    for (final p in data.places.where((p) => p.recommended)) {
      final n = visitCount[p.id] ?? 0;
      if (n > favoriteVisits) {
        favorite = p;
        favoriteVisits = n;
      }
    }

    final marks = <(Place, TastingScores, double?)>[];
    for (final id in {for (final v in visits) v.placeId}) {
      final own = visits.where((v) => v.placeId == id);
      final mark = TastingScores.averageOf([for (final v in own) v.scores]);
      if (mark.isEmpty) continue;
      final averages = [for (final v in own) ?v.scores.average];
      marks.add((
        placeOf[id]!,
        mark,
        averages.isEmpty
            ? null
            : averages.reduce((a, b) => a + b) / averages.length,
      ));
      if (marks.length == 6) break;
    }

    return NotebookPortrait(
      category: _top(categories),
      district: _top(districts),
      favorite: favorite,
      favoriteVisits: favoriteVisits,
      lastVisit: visits.first,
      lastPlace: placeOf[visits.first.placeId],
      marks: marks,
    );
  }
}
