import '../../../core/text/turkish.dart';

/// Tabağın türü. Türe göre puanlanacak bileşenler hazır gelir; kullanıcı
/// istediğini çıkarır, kendi bileşenini ekler.
enum DishKind {
  burger('Burger', ['Ekmek', 'Köfte', 'Sos', 'Peynir', 'Pişme derecesi']),
  pizza('Pizza', ['Hamur', 'Sos', 'Peynir', 'Malzeme']),
  pasta('Makarna', ['Makarna', 'Sos', 'Porsiyon']),
  kebab('Kebap / ızgara', ['Et', 'Pişme', 'Ekmek / lavaş', 'Yanındakiler']),
  pide('Pide / lahmacun', ['Hamur', 'İç', 'Pişme']),
  seafood('Balık / deniz ürünü', ['Tazelik', 'Pişme', 'Yanındakiler']),
  doner('Döner / dürüm', ['Et', 'Ekmek / lavaş', 'Sos', 'Porsiyon']),
  soup('Çorba', ['Kıvam', 'Tuz', 'Sıcaklık']),
  asian('Uzak Doğu', ['Lezzet', 'Pirinç / erişte', 'Tazelik', 'Acı']),
  sandwich('Sandviç / tost', ['Ekmek', 'İç', 'Sıcaklık']),
  salad('Salata', ['Tazelik', 'Sos', 'Porsiyon']),
  main('Ana yemek', ['Lezzet', 'Pişme', 'Porsiyon']),
  starter('Başlangıç / meze', ['Tazelik', 'Lezzet']),
  breakfast('Kahvaltı', ['Tazelik', 'Çeşit', 'Ekmek']),
  pastry('Hamur işi', ['Hamur', 'İç', 'Tazelik']),
  coffee('Kahve', ['Kahve', 'Süt', 'Sıcaklık']),
  dessert('Tatlı', ['Tat', 'Kıvam', 'Şeker dengesi']),
  side('Garnitür', ['Çıtırlık', 'Tuz']),
  drink('İçecek', ['Tat', 'Sıcaklık']),
  other('Diğer', []);

  const DishKind(this.label, this.parts);

  final String label;

  /// Bu türde varsayılan olarak puanlanan bileşenler.
  final List<String> parts;

  static DishKind byName(Object? name) =>
      values.where((k) => k.name == name).firstOrNull ?? other;
}

/// Mekânın türünden ("Burger", "Kahve", "Ocakbaşı"…) o mekânda
/// beklenebilecek tabak türleri. Tür serbest yazıldığı için anahtar
/// kelimeyle eşlenir; "Diğer" her zaman sondadır.
/// Tür adından tabak türleri çıkarılabiliyor mu? Tanınmayan tür (yazım
/// hatası, alışılmadık ad) genel türlere düşer; formda uyarılır.
bool isKnownCategory(String category) {
  if (category.trim().isEmpty) return true;
  const fallback = [
    DishKind.main,
    DishKind.starter,
    DishKind.side,
    DishKind.dessert,
    DishKind.drink,
    DishKind.other,
  ];
  final kinds = dishKindsFor(category);
  return kinds.length != fallback.length ||
      [for (var i = 0; i < kinds.length; i++) kinds[i] == fallback[i]]
          .contains(false);
}

/// Formda önerilen türler; her biri [dishKindsFor] içinde tanınır.
const categorySuggestions = [
  'Kahve',
  'Fırın',
  'Lokanta',
  'Kebapçı',
  'Meyhane',
  'Balıkçı',
  'Kahvaltı',
  'Tatlıcı',
  'Burger',
  'Pizza',
  'Dönerci',
  'Pideci',
  'Çorbacı',
  'Uzak Doğu',
];

List<DishKind> dishKindsFor(String category) {
  final c = normalizeForMatch(category);
  bool has(List<String> words) => words.any(c.contains);
  final kinds = switch (c) {
    _ when has(['burger', 'hamburger']) => [
      DishKind.burger,
      DishKind.side,
      DishKind.dessert,
      DishKind.drink,
    ],
    _ when has(['pizza', 'italyan', 'makarna']) => [
      DishKind.pizza,
      DishKind.pasta,
      DishKind.starter,
      DishKind.dessert,
      DishKind.drink,
    ],
    _ when has(['doner', 'durum', 'tantuni', 'kokorec']) => [
      DishKind.doner,
      DishKind.side,
      DishKind.drink,
    ],
    // "Çin" tek başına; "çin " ile aramak "piçin" gibi kelimelere karışırdı.
    _
        when c == 'cin' ||
            has([
              'sushi',
              'ramen',
              'uzak dogu',
              'uzakdogu',
              'japon',
              'cin mutfagi',
              'kore',
              'tayland',
              'asya',
            ]) =>
      [DishKind.asian, DishKind.starter, DishKind.soup, DishKind.drink],
    _ when has(['corba', 'iskembe', 'kelle paca']) => [
      DishKind.soup,
      DishKind.main,
      DishKind.dessert,
      DishKind.drink,
    ],
    _ when has(['tost', 'sandvic', 'bufe']) => [
      DishKind.sandwich,
      DishKind.drink,
    ],
    _ when has(['salata', 'vegan', 'vejetaryen']) => [
      DishKind.salad,
      DishKind.main,
      DishKind.soup,
      DishKind.drink,
    ],
    _ when has(['kahvalti']) => [
      DishKind.breakfast,
      DishKind.pastry,
      DishKind.coffee,
      DishKind.drink,
    ],
    _ when has(['kahve', 'kafe', 'cafe', 'coffee']) => [
      DishKind.coffee,
      DishKind.dessert,
      DishKind.pastry,
      DishKind.drink,
    ],
    _ when has(['firin', 'simit', 'borek', 'pastane', 'unlu']) => [
      DishKind.pastry,
      DishKind.dessert,
      DishKind.coffee,
      DishKind.drink,
    ],
    _ when has(['tatli', 'baklava', 'dondurma', 'muhallebi', 'kunefe']) => [
      DishKind.dessert,
      DishKind.coffee,
      DishKind.drink,
    ],
    _ when has(['lahmacun', 'pide']) => [
      DishKind.pide,
      DishKind.kebab,
      DishKind.starter,
      DishKind.dessert,
      DishKind.drink,
    ],
    _ when has(['kebap', 'kebab', 'ocakbasi', 'izgara', 'kofte']) => [
      DishKind.kebab,
      DishKind.pide,
      DishKind.starter,
      DishKind.dessert,
      DishKind.drink,
    ],
    _ when has(['balik', 'deniz', 'midye']) => [
      DishKind.seafood,
      DishKind.starter,
      DishKind.main,
      DishKind.dessert,
      DishKind.drink,
    ],
    _ when has(['meyhane', 'meze']) => [
      DishKind.starter,
      DishKind.seafood,
      DishKind.main,
      DishKind.drink,
    ],
    _ when has(['lokanta', 'esnaf', 'ev yemeg', 'sulu']) => [
      DishKind.main,
      DishKind.soup,
      DishKind.starter,
      DishKind.dessert,
      DishKind.drink,
    ],
    _ => [
      DishKind.main,
      DishKind.starter,
      DishKind.side,
      DishKind.dessert,
      DishKind.drink,
    ],
  };
  return [...kinds, DishKind.other];
}

/// Bileşen hakkında üç seçenekli yargı. Masada hızlı işaretlensin diye
/// 1–5 değil.
enum DishVerdict {
  good('Beğendim', 'Beğendin'),
  fine('Fena değil', 'Fena değil'),
  bad('Beğenmedim', 'Beğenmedin');

  const DishVerdict(this.label, this.summary);

  /// Formdaki seçenek.
  final String label;

  /// Özetlerdeki karşılığı ("Köfte: Beğenmedin").
  final String summary;

  /// Sıralamada kullanılan değer: beğendim 1, fena değil ½, beğenmedim 0.
  double get weight => switch (this) {
    good => 1,
    fine => 0.5,
    bad => 0,
  };

  static DishVerdict? byName(Object? name) =>
      values.where((v) => v.name == name).firstOrNull;
}

class DishPart {
  const DishPart(this.name, [this.verdict]);

  final String name;

  /// `null`: bileşen listede ama işaretlenmedi.
  final DishVerdict? verdict;

  factory DishPart.fromJson(Map<String, dynamic> json) => DishPart(
    json['name'] is String ? json['name'] as String : '',
    DishVerdict.byName(json['verdict']),
  );

  Map<String, dynamic> toJson() => {'name': name, 'verdict': verdict?.name};
}

/// Bir deneyimde tadılan tek tabak.
class TastedDish {
  const TastedDish({
    required this.name,
    this.kind = DishKind.other,
    this.score = 0,
    this.parts = const [],
    this.note = '',
    this.never = false,
  });

  final String name;
  final DishKind kind;

  /// Tabağın geneli 1–5; 0 puanlanmamış.
  final int score;
  final List<DishPart> parts;
  final String note;

  /// "Bir daha söyleme": mekâna yeniden deneyim eklerken hatırlatılır.
  final bool never;

  /// Aynı tabağı farklı deneyimlerde eşlemek için ad ("Klasik Burger" ile
  /// "klasik burger" aynı tabak).
  String get key => normalizeForMatch(name.trim());

  TastedDish copyWith({
    String? name,
    DishKind? kind,
    int? score,
    List<DishPart>? parts,
    String? note,
    bool? never,
  }) => TastedDish(
    name: name ?? this.name,
    kind: kind ?? this.kind,
    score: score ?? this.score,
    parts: parts ?? this.parts,
    note: note ?? this.note,
    never: never ?? this.never,
  );

  factory TastedDish.fromJson(Map<String, dynamic> json) {
    final score = json['score'];
    return TastedDish(
      name: json['name'] is String ? json['name'] as String : '',
      kind: DishKind.byName(json['kind']),
      score: score is int && score >= 0 && score <= 5 ? score : 0,
      parts: [
        for (final p in (json['parts'] as List? ?? const []))
          if (p is Map<String, dynamic>) DishPart.fromJson(p),
      ].where((p) => p.name.isNotEmpty).toList(),
      note: json['note'] is String ? json['note'] as String : '',
      never: json['never'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'kind': kind.name,
    'score': score,
    'parts': [for (final p in parts) p.toJson()],
    'note': note,
    'never': never,
  };
}

/// Deneyim formundaki örnek metinler, mekânın türüne göre: burgercide
/// "O sabahki ilk fincan" yazmaz.
({String title, String note}) visitExamples(
  String category,
) => switch (dishKindsFor(category).first) {
  DishKind.burger => (
    title: 'Akşam burgeri',
    note: 'Köfte sulu muydu, ekmek taze miydi…',
  ),
  DishKind.pizza || DishKind.pasta => (
    title: 'Odun fırını akşamı',
    note: 'Hamur, sos, kenarlar…',
  ),
  DishKind.coffee => (
    title: 'O sabahki ilk fincan',
    note: 'Kahve, süt, ortam…',
  ),
  DishKind.breakfast => (
    title: 'Pazar kahvaltısı',
    note: 'Tazelik, çeşit, çay…',
  ),
  DishKind.kebab ||
  DishKind.pide ||
  DishKind.doner => (title: 'Öğle kebabı', note: 'Et, pişme, lavaş…'),
  DishKind.seafood => (
    title: 'Deniz kenarında akşam',
    note: 'Tazelik, pişme, meze…',
  ),
  DishKind.dessert ||
  DishKind.pastry => (title: 'Tatlı molası', note: 'Kıvam, şeker, tazelik…'),
  DishKind.starter => (title: 'Meze sofrası', note: 'Mezeler, servis, ortam…'),
  DishKind.soup => (title: 'Sıcak bir kâse', note: 'Kıvam, tuz, ekmek…'),
  DishKind.asian => (title: 'Uzak Doğu akşamı', note: 'Lezzet, acı, tazelik…'),
  DishKind.sandwich => (title: 'Hızlı bir öğle', note: 'Ekmek, iç, sıcaklık…'),
  DishKind.salad => (title: 'Hafif bir öğün', note: 'Tazelik, sos, porsiyon…'),
  _ => (title: 'Bir öğle yemeği', note: 'Tat, atmosfer, küçük ayrıntılar…'),
};
