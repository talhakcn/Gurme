import '../../../core/text/turkish.dart';
import 'journal_models.dart';

/// "Bugün ne yesem?" için bir aday ve neden önerildiği.
class TodayPick {
  const TodayPick(this.place, this.reasons);

  final Place place;
  final List<String> reasons;
}

/// Gideceğin mekânları öneri sırasına dizer: önce profil şehrindekiler,
/// sonra bu hafta türüne gitmediklerin, en sonda eklenme sırası (en eski
/// önce).
List<TodayPick> rankTodayPicks(JournalData data, DateTime now) {
  final wants = data.places.where((p) => p.status == PlaceStatus.want).toList();
  if (wants.isEmpty) return const [];

  final city = data.profile.city.trim();
  final weekAgo = isoDate(now.subtract(const Duration(days: 7)));
  final categoriesThisWeek = {
    for (final v in data.visits)
      if (v.date.compareTo(weekAgo) >= 0)
        if (data.placeById(v.placeId) case final p?)
          if (p.category.isNotEmpty) toLowerTr(p.category),
  };
  final oldest = wants.reduce(
    (a, b) => b.createdAt.isBefore(a.createdAt) ? b : a,
  );

  bool inCity(Place p) => city.isNotEmpty && equalsTr(p.city, city);
  bool freshCategory(Place p) =>
      p.category.isNotEmpty &&
      !categoriesThisWeek.contains(toLowerTr(p.category));
  int score(Place p) => (inCity(p) ? 2 : 0) + (freshCategory(p) ? 1 : 0);

  wants.sort((a, b) {
    final byScore = score(b).compareTo(score(a));
    return byScore != 0 ? byScore : a.createdAt.compareTo(b.createdAt);
  });
  return [
    for (final p in wants)
      TodayPick(p, [
        // Her gerekçe tek başına bir cümle; virgülle yapıştırılınca
        // anlamsız bir dizi oluyordu.
        if (identical(p, oldest)) 'Gideceklerinde en uzun süredir bekliyor.',
        if (inCity(p)) 'Senin şehrinde.',
        if (freshCategory(p)) 'Bu hafta bu türden bir yere gitmedin.',
      ]),
  ];
}
