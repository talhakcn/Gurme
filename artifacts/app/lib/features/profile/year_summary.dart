import '../../core/text/turkish.dart';
import '../journal/data/dish_summary.dart';
import '../journal/data/journal_models.dart';

/// Bir dönemin defter özeti: bütün yıl ya da yılın bir ayı ([month]).
class YearSummary {
  const YearSummary({
    required this.year,
    required this.places,
    required this.visits,
    required this.lists,
    required this.districts,
    required this.categories,
    this.month,
    this.favorite,
    this.favoriteVisits = 0,
    this.favoriteLists = 0,
    this.dish,
    this.dishPlace,
    this.visitedPlaces = 0,
    this.recommended = 0,
    this.topDistricts = const [],
    this.topPlaces = const [],
    this.topDishes = const [],
    this.monthlyVisits = const [],
    this.placeNames = const {},
  });

  final int year;

  /// 1–12; `null` ise özet bütün yılın.
  final int? month;

  bool get isMonth => month != null;

  /// "2026" ya da "Ekim 2026".
  String get periodLabel =>
      month == null ? '$year' : '${monthNameTr(month!)} $year';

  /// O dönem deneyim yazılan mekânlar; [places] içinde, yalnızca eklenip
  /// gidilmeyenler hariç.
  final int visitedPlaces;

  /// Dönemin tabağı: o dönem tadılanlar içinde genel puanı en yüksek olan
  /// (4 ve üstü); eşitlikte daha çok tadılan.
  final DishSummary? dish;
  final Place? dishPlace;

  /// O dönem eklenen ya da ziyaret edilen mekânlar.
  final int places;
  final int visits;

  /// O dönem oluşturulan ya da güncellenen listeler.
  final int lists;

  /// O dönem gidilen mekânlardan önerdiklerin.
  final int recommended;

  /// Ziyaret sayısına göre semtler; en çok 3 tane, kalanı "Diğer".
  final List<(String, int)> districts;

  /// Ziyaretlerin türlere dağılımı; en çok 3 tür, kalanı "Diğer".
  final List<(String, int)> categories;

  /// Adı olan semtler, ziyaret sayısına göre; en çok 5 tane ("Diğer" yok).
  final List<(String, int)> topDistricts;

  /// En çok gidilen mekânlar ve deneyim sayıları; en çok 5 tane.
  final List<(Place, int)> topPlaces;

  /// Puanı 4 ve üstü tabaklar, puana göre; en çok 3 tane.
  final List<DishSummary> topDishes;

  /// Yıllık özette ay ay deneyim sayısı (12 eleman); aylıkta boş.
  final List<int> monthlyVisits;

  /// [topDishes] tabaklarının mekân adları, mekân kimliğine göre.
  final Map<String, String> placeNames;

  String? placeName(String placeId) => placeNames[placeId];

  /// Önerdiğin mekânlar içinde o dönem en çok gittiğin.
  final Place? favorite;
  final int favoriteVisits;
  final int favoriteLists;

  bool get isEmpty => places == 0 && visits == 0 && lists == 0;

  /// En çok deneyim yazılan ay (1–12); yıllık özette, deneyim varsa.
  int? get busiestMonth {
    if (monthlyVisits.isEmpty) return null;
    var best = 0;
    for (var i = 1; i < monthlyVisits.length; i++) {
      if (monthlyVisits[i] > monthlyVisits[best]) best = i;
    }
    return monthlyVisits[best] == 0 ? null : best + 1;
  }

  static List<(String, int)> _sorted(Map<String, int> counts) =>
      counts.entries.map((e) => (e.key, e.value)).toList()..sort((a, b) {
        final byCount = b.$2.compareTo(a.$2);
        return byCount != 0 ? byCount : compareTr(a.$1, b.$1);
      });

  static List<(String, int)> _top(Map<String, int> counts) {
    final sorted = _sorted(counts);
    final top = sorted.take(3).toList();
    final rest = sorted.skip(3).fold(0, (sum, e) => sum + e.$2);
    return [...top, if (rest > 0) ('Diğer', rest)];
  }

  /// [month] verilirse yalnızca o ayın özeti.
  factory YearSummary.of(JournalData data, int year, {int? month}) {
    final prefix = month == null
        ? '$year-'
        : '$year-${month.toString().padLeft(2, '0')}-';
    bool inPeriod(DateTime date) {
      final local = date.toLocal();
      return local.year == year && (month == null || local.month == month);
    }

    final visits = data.visits.where((v) => v.date.startsWith(prefix));
    final placeOf = {for (final p in data.places) p.id: p};
    final visitCount = <String, int>{};
    for (final v in visits) {
      visitCount[v.placeId] = (visitCount[v.placeId] ?? 0) + 1;
    }
    final visited = visitCount.keys.where(placeOf.containsKey).toSet();
    final placeIds = {
      ...visited,
      for (final p in data.places)
        if (inPeriod(p.createdAt)) p.id,
    };

    final districts = <String, int>{};
    final categories = <String, int>{};
    for (final v in visits) {
      final p = placeOf[v.placeId];
      if (p == null) continue;
      final d = p.district.isEmpty ? 'Semtsiz' : p.district;
      districts[d] = (districts[d] ?? 0) + 1;
      final c = p.category.isEmpty ? 'Türsüz' : p.category;
      categories[c] = (categories[c] ?? 0) + 1;
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

    final topPlaces =
        [for (final id in visited) (placeOf[id]!, visitCount[id]!)]
          ..sort((a, b) {
            final byCount = b.$2.compareTo(a.$2);
            return byCount != 0 ? byCount : compareTr(a.$1.name, b.$1.name);
          });

    final dishes =
        [
          for (final d in summarizeDishes(visits))
            if (!d.never && (d.score ?? 0) >= 4) d,
        ]..sort((a, b) {
          final byScore = b.score!.compareTo(a.score!);
          return byScore != 0 ? byScore : b.times.compareTo(a.times);
        });
    final dish = dishes.firstOrNull;

    final monthly = List.filled(12, 0);
    if (month == null) {
      for (final v in visits) {
        final m = int.tryParse(
          v.date.length >= 7 ? v.date.substring(5, 7) : '',
        );
        if (m != null && m >= 1 && m <= 12) monthly[m - 1]++;
      }
    }

    return YearSummary(
      year: year,
      month: month,
      dish: dish,
      dishPlace: dish == null ? null : placeOf[dish.placeId],
      places: placeIds.length,
      visitedPlaces: visited.length,
      visits: visits.length,
      recommended: visited.where((id) => placeOf[id]!.recommended).length,
      lists: data.lists
          .where((l) => inPeriod(l.createdAt) || inPeriod(l.updatedAt))
          .length,
      districts: _top(districts),
      categories: _top(categories),
      topDistricts: [
        for (final d in _sorted(districts).take(5))
          if (d.$1 != 'Semtsiz') d,
      ],
      topPlaces: topPlaces.take(5).toList(),
      topDishes: dishes.take(3).toList(),
      monthlyVisits: month == null ? monthly : const [],
      placeNames: {
        for (final d in dishes.take(3))
          if (placeOf[d.placeId] case final p?) p.id: p.name,
      },
      favorite: favorite,
      favoriteVisits: favoriteVisits,
      favoriteLists: favorite == null
          ? 0
          : data.lists.where((l) => l.contains(favorite!.id)).length,
    );
  }
}
