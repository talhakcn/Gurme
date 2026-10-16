import '../../../core/text/turkish.dart';
import 'journal_models.dart';

/// Bir bileşenin aynı tabağın bütün tadımlarındaki çoğunluk yargısı.
class PartSummary {
  const PartSummary(this.name, this.verdict, this.count, this.total);

  final String name;
  final DishVerdict verdict;

  /// [verdict] kaç kez verildi, bileşen kaç kez işaretlendi.
  final int count;
  final int total;

  /// Sıralama için ortalama değer (beğendim 1, fena değil ½, beğenmedim 0).
  double get weight => verdict.weight;

  /// "Beğendin" ya da "Beğendin · 3 tadımda 2 kez". Sayıya ek getirilmez
  /// ("2'sinde" gibi), cümle her sayıyla doğru okunur.
  String get text => total > 1
      ? '${verdict.summary} · $total tadımda $count kez'
      : verdict.summary;
}

/// Aynı mekânda aynı adla tadılan tabak, bütün deneyimlerden.
class DishSummary {
  DishSummary({
    required this.placeId,
    required this.name,
    required this.kind,
    required this.times,
    required this.score,
    required this.parts,
    required this.never,
    required this.partWeights,
  });

  final String placeId;

  /// En son yazıldığı biçimiyle ad.
  final String name;
  final DishKind kind;

  /// Kaç deneyimde tadıldı.
  final int times;

  /// Puanlandığı tadımlarda genel puanın ortalaması; hiç puanlanmadıysa `null`.
  final double? score;
  final List<PartSummary> parts;

  /// En son tadımda "Bir daha söyleme" işaretlendiyse.
  final bool never;

  /// Bileşen adına göre (küçük harf, aksansız) ortalama yargı değeri.
  final Map<String, double> partWeights;

  PartSummary? part(String name) {
    final key = normalizeForMatch(name);
    return parts.where((p) => normalizeForMatch(p.name) == key).firstOrNull;
  }
}

/// Deneyimleri tarih sırasıyla (eskiden yeniye) gezip tabakları
/// mekân + ad çiftine göre toplar.
List<DishSummary> summarizeDishes(Iterable<Visit> visits) {
  final sorted = [...visits]..sort((a, b) => a.date.compareTo(b.date));
  final groups = <(String, String), List<TastedDish>>{};
  for (final v in sorted) {
    for (final d in v.tastedDishes) {
      if (d.key.isEmpty) continue;
      (groups[(v.placeId, d.key)] ??= []).add(d);
    }
  }
  return [
    for (final MapEntry(key: (placeId, _), value: dishes) in groups.entries)
      _summarize(placeId, dishes),
  ];
}

DishSummary _summarize(String placeId, List<TastedDish> dishes) {
  final latest = dishes.last;
  final scored = [
    for (final d in dishes)
      if (d.score > 0) d.score,
  ];
  // Bileşenler ilk görüldükleri sırayla; adlar en son yazılış biçimiyle.
  final names = <String, String>{};
  final verdicts = <String, List<DishVerdict>>{};
  for (final d in dishes) {
    for (final p in d.parts) {
      final key = normalizeForMatch(p.name);
      if (key.isEmpty) continue;
      names[key] = p.name.trim();
      if (p.verdict != null) (verdicts[key] ??= []).add(p.verdict!);
    }
  }
  final parts = <PartSummary>[];
  final weights = <String, double>{};
  for (final key in names.keys) {
    final list = verdicts[key];
    if (list == null) continue;
    // Çoğunluk; eşitlikte ortadaki yargı ("Fena değil") kazanır.
    DishVerdict? best;
    var bestCount = 0;
    for (final v in [DishVerdict.fine, DishVerdict.good, DishVerdict.bad]) {
      final n = list.where((x) => x == v).length;
      if (n > bestCount) (best, bestCount) = (v, n);
    }
    parts.add(PartSummary(names[key]!, best!, bestCount, list.length));
    weights[key] =
        list.map((v) => v.weight).reduce((a, b) => a + b) / list.length;
  }
  return DishSummary(
    placeId: placeId,
    name: latest.name.trim(),
    kind: latest.kind,
    times: dishes.length,
    score: scored.isEmpty
        ? null
        : scored.reduce((a, b) => a + b) / scored.length,
    parts: parts,
    never: latest.never,
    partWeights: weights,
  );
}

/// Bir türün sıralaması ancak bu kadar tabakla gösterilir; tek tabaklık
/// sıralama bir şey söylemez.
const minRankedDishes = 3;

/// Bir türün sıralaması: [part] boşsa genel puana, doluysa o bileşenin
/// ortalama yargısına göre; eşitlikte genel puan. Ölçüsü olmayan tabak
/// sıralamaya girmez.
List<DishSummary> rankDishes(
  Iterable<DishSummary> dishes,
  DishKind kind, {
  String part = '',
}) {
  final key = normalizeForMatch(part);
  final ofKind = dishes.where((d) => d.kind == kind);
  final ranked = [
    for (final d in ofKind)
      if (key.isEmpty ? d.score != null : d.partWeights.containsKey(key)) d,
  ];
  ranked.sort((a, b) {
    if (key.isNotEmpty) {
      final byPart = b.partWeights[key]!.compareTo(a.partWeights[key]!);
      if (byPart != 0) return byPart;
    }
    return (b.score ?? 0).compareTo(a.score ?? 0);
  });
  return ranked;
}

/// Sıralamada seçilebilecek bileşenler: o türde işaretlenmiş olanlar,
/// en çok işaretlenenden aza.
List<String> rankableParts(Iterable<DishSummary> dishes, DishKind kind) {
  final counts = <String, int>{};
  final names = <String, String>{};
  for (final d in dishes.where((d) => d.kind == kind)) {
    for (final p in d.parts) {
      final key = normalizeForMatch(p.name);
      counts[key] = (counts[key] ?? 0) + 1;
      names[key] ??= p.name;
    }
  }
  final keys = counts.keys.toList()
    ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  return [for (final k in keys) names[k]!];
}

/// "Damak notu": genel puanı en çok hangi bileşen belirliyor? Bileşeni
/// beğendiğin ve beğenmediğin tabakların genel puan ortalamaları
/// karşılaştırılır. Az kayıtla yanlış sonuç çıkarmamak için en az beş
/// puanlı tabak ve her iki tarafta en az iki tabak gerekir.
({String part, double liked, double disliked})? palateNote(
  Iterable<DishSummary> dishes,
  DishKind kind,
) {
  final scored = [
    for (final d in dishes)
      if (d.kind == kind && d.score != null) d,
  ];
  if (scored.length < 5) return null;
  ({String part, double liked, double disliked})? best;
  for (final name in rankableParts(scored, kind)) {
    final liked = <double>[];
    final disliked = <double>[];
    for (final d in scored) {
      switch (d.part(name)?.verdict) {
        case DishVerdict.good:
          liked.add(d.score!);
        case DishVerdict.bad:
          disliked.add(d.score!);
        default:
      }
    }
    if (liked.length < 2 || disliked.length < 2) continue;
    double mean(List<double> xs) => xs.reduce((a, b) => a + b) / xs.length;
    final candidate = (
      part: name,
      liked: mean(liked),
      disliked: mean(disliked),
    );
    if (candidate.liked - candidate.disliked < 1) continue;
    if (best == null ||
        candidate.liked - candidate.disliked > best.liked - best.disliked) {
      best = candidate;
    }
  }
  return best;
}
