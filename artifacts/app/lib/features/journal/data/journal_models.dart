import '../../../core/text/turkish.dart';

import 'package:gurme_client/gurme_client.dart';

import 'dish_models.dart';

export 'dish_models.dart';

/// Kişisel defterin veri modeli. Expo uygulamasındaki
/// `context/JournalContext.tsx` türlerinin karşılığı; JSON alan adları aynı.

const _unset = Object();

enum PlaceStatus { want, went }

enum Revisit { yes, no, undecided }

enum VisitVisibility { private, public }

enum ListVisibility { private, unlisted, public }

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}

String _string(Object? value) => value is String ? value : '';

class Place {
  const Place({
    required this.id,
    required this.name,
    this.district = '',
    this.city = '',
    this.address = '',
    this.category = '',
    this.description = '',
    this.image = '',
    this.status,
    this.recommended = false,
    required this.createdAt,
    this.googlePlaceId,
    this.source = '',
    this.lat,
    this.lng,
  });

  final String id;
  final String name;
  final String district;
  final String city;
  final String address;
  final String category;
  final String description;

  /// [PhotoStore] içindeki göreli yol; boşsa fotoğraf yok.
  final String image;
  final PlaceStatus? status;
  final bool recommended;
  final DateTime createdAt;

  /// Aramadan eklenen mekânın Google place_id'si; elle eklenenlerde `null`.
  final String? googlePlaceId;

  /// Mekânı nereden duyduğun ("Arkadaş önerisi"); boş olabilir.
  final String source;

  /// Haritadaki yeri. Aramadan eklenen mekânda Google'dan gelir; elle
  /// eklenende yoktur (`null`).
  final double? lat;
  final double? lng;

  bool get hasLocation => lat != null && lng != null;

  /// "Moda, İstanbul" biçiminde semt ve şehir.
  String get area => [district, city].where((s) => s.isNotEmpty).join(', ');

  Place copyWith({
    String? name,
    String? district,
    String? city,
    String? address,
    String? category,
    String? description,
    String? image,
    Object? status = _unset,
    bool? recommended,
    String? source,
    double? lat,
    double? lng,
  }) => Place(
    id: id,
    name: name ?? this.name,
    district: district ?? this.district,
    city: city ?? this.city,
    address: address ?? this.address,
    category: category ?? this.category,
    description: description ?? this.description,
    image: image ?? this.image,
    status: identical(status, _unset) ? this.status : status as PlaceStatus?,
    recommended: recommended ?? this.recommended,
    createdAt: createdAt,
    googlePlaceId: googlePlaceId,
    source: source ?? this.source,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
  );

  factory Place.fromJson(Map<String, dynamic> json) {
    // Eski kayıtlarda "recommend" bir statüydü; artık "went" + recommended.
    final rawStatus = json['status'];
    final legacyRecommend = rawStatus == 'recommend';
    return Place(
      id: _string(json['id']),
      name: _string(json['name']),
      district: _string(json['district']),
      city: _string(json['city']),
      address: _string(json['address']),
      category: _string(json['category']),
      description: _string(json['description']),
      image: _string(json['image']),
      status: legacyRecommend
          ? PlaceStatus.went
          : PlaceStatus.values.where((s) => s.name == rawStatus).firstOrNull,
      recommended: legacyRecommend || json['recommended'] == true,
      createdAt:
          DateTime.tryParse(_string(json['createdAt'])) ?? DateTime.now(),
      googlePlaceId: json['googlePlaceId'] is String
          ? json['googlePlaceId'] as String
          : null,
      source: _string(json['source']),
      lat: _coordinate(json['lat'], 90),
      lng: _coordinate(json['lng'], 180),
    );
  }

  /// Geçerli aralıkta bir sayı; değilse `null` (bozuk kayıt haritayı
  /// bozmaz).
  static double? _coordinate(Object? raw, double limit) => switch (raw) {
    final num n when n.isFinite && n.abs() <= limit => n.toDouble(),
    _ => null,
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'district': district,
    'city': city,
    'address': address,
    'category': category,
    'description': description,
    'image': image,
    'status': status?.name,
    'recommended': recommended,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'googlePlaceId': googlePlaceId,
    'source': source,
    'lat': ?lat,
    'lng': ?lng,
  };
}

/// Tadım karnesi: her ölçüt 1–5, 0 puanlanmamış demek.
class TastingScores {
  const TastingScores({
    this.taste = 0,
    this.service = 0,
    this.ambiance = 0,
    this.value = 0,
  });

  final int taste;
  final int service;
  final int ambiance;
  final int value;

  static const labels = ['Lezzet', 'Servis', 'Ambiyans', 'Fiyat / değer'];

  List<int> get all => [taste, service, ambiance, value];

  bool get isEmpty => all.every((s) => s == 0);

  /// Her ölçütün, puanlandığı ziyaretlerdeki yuvarlanmış ortalaması.
  /// Bir mekânın bütün ziyaretlerinden tek bir karne çıkarır.
  static TastingScores averageOf(Iterable<TastingScores> scores) {
    final means = meansOf(scores);
    return TastingScores(
      taste: means[0].round(),
      service: means[1].round(),
      ambiance: means[2].round(),
      value: means[3].round(),
    );
  }

  /// Her ölçütün yuvarlanmamış ortalaması ([labels] sırasıyla); puanlanmamış
  /// ölçüt 0. Mekân sayfası bunu yazar: genel ortalamayla çelişmez.
  static List<double> meansOf(Iterable<TastingScores> scores) {
    double mean(int Function(TastingScores) pick) {
      final rated = [
        for (final s in scores)
          if (pick(s) > 0) pick(s),
      ];
      return rated.isEmpty ? 0 : rated.reduce((a, b) => a + b) / rated.length;
    }

    return [
      mean((s) => s.taste),
      mean((s) => s.service),
      mean((s) => s.ambiance),
      mean((s) => s.value),
    ];
  }

  /// En yüksek puanlı ölçütün adı (küçük harfle); ölçütler eşitse ya da
  /// karne boşsa `null`. Satırda izin yanına yazılır: iz bilgi taşır.
  String? get strongest {
    final rated = [
      for (final (i, s) in all.indexed)
        if (s > 0) (i, s),
    ];
    if (rated.length < 2) return null;
    final top = rated.map((r) => r.$2).reduce((a, b) => a > b ? a : b);
    final best = rated.where((r) => r.$2 == top).toList();
    return best.length == 1 ? toLowerTr(labels[best.single.$1]) : null;
  }

  /// Puanlanan ölçütlerin ortalaması; hiçbiri puanlanmadıysa `null`.
  double? get average {
    final rated = all.where((s) => s > 0).toList();
    return rated.isEmpty ? null : rated.reduce((a, b) => a + b) / rated.length;
  }

  /// [index] sırasındaki ölçütü değiştirir ([labels] sırası).
  TastingScores withScore(int index, int score) {
    final next = [...all]..[index] = score;
    return TastingScores(
      taste: next[0],
      service: next[1],
      ambiance: next[2],
      value: next[3],
    );
  }

  factory TastingScores.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return const TastingScores();
    int read(String key) {
      final v = json[key];
      return v is int && v >= 0 && v <= 5 ? v : 0;
    }

    return TastingScores(
      taste: read('taste'),
      service: read('service'),
      ambiance: read('ambiance'),
      value: read('value'),
    );
  }

  Map<String, dynamic> toJson() => {
    'taste': taste,
    'service': service,
    'ambiance': ambiance,
    'value': value,
  };
}

/// "3,5".
String formatScore(double score) =>
    score.toStringAsFixed(1).replaceAll('.', ',');

class Visit {
  const Visit({
    required this.id,
    required this.placeId,
    required this.date,
    this.title = '',
    required this.note,
    this.order = '',
    this.recommended = false,
    this.revisit,
    this.dishes = '',
    this.photos = const [],
    this.visibility = VisitVisibility.private,
    this.scores = const TastingScores(),
    this.tastedDishes = const [],
  });

  final String id;
  final String placeId;

  /// YYYY-MM-DD.
  final String date;
  final String title;
  final String note;
  final String order;
  final bool recommended;

  /// "Tekrar gider misin?"; `null` cevapsız ("Belki" ile aynı değil).
  final Revisit? revisit;
  final String dishes;

  /// [PhotoStore] içindeki göreli yollar, en fazla 4.
  final List<String> photos;
  final VisitVisibility visibility;
  final TastingScores scores;

  /// Tadılan tabaklar, eklenme sırasıyla. Eski kayıtlarda boş; onların
  /// "ne tattın" metni [order]'da durur.
  final List<TastedDish> tastedDishes;

  factory Visit.fromJson(Map<String, dynamic> json) => Visit(
    id: _string(json['id']),
    placeId: _string(json['placeId']),
    date: _string(json['date']),
    title: _string(json['title']),
    note: _string(json['note']),
    order: _string(json['order']),
    recommended: json['recommended'] == true,
    revisit: Revisit.values.where((r) => r.name == json['revisit']).firstOrNull,
    dishes: _string(json['dishes']),
    photos: [
      for (final p in (json['photos'] as List? ?? const []))
        if (p is String) p,
    ],
    visibility: _enumByName(
      VisitVisibility.values,
      json['visibility'],
      VisitVisibility.private,
    ),
    scores: TastingScores.fromJson(json['scores']),
    tastedDishes: [
      for (final d in (json['tastedDishes'] as List? ?? const []))
        if (d is Map<String, dynamic>) TastedDish.fromJson(d),
    ].where((d) => d.name.trim().isNotEmpty).toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'placeId': placeId,
    'date': date,
    'title': title,
    'note': note,
    'order': order,
    'recommended': recommended,
    'revisit': revisit?.name,
    'dishes': dishes,
    'photos': photos,
    'visibility': visibility.name,
    'scores': scores.toJson(),
    'tastedDishes': [for (final d in tastedDishes) d.toJson()],
  };
}

class ListItem {
  const ListItem({required this.placeId, this.note = ''});

  final String placeId;
  final String note;

  ListItem copyWith({String? note}) =>
      ListItem(placeId: placeId, note: note ?? this.note);

  factory ListItem.fromJson(Map<String, dynamic> json) =>
      ListItem(placeId: _string(json['placeId']), note: _string(json['note']));

  Map<String, dynamic> toJson() => {'placeId': placeId, 'note': note};
}

class CuratedList {
  const CuratedList({
    required this.id,
    required this.title,
    this.description = '',
    this.city = '',
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.ownerKey,
    this.visibility = ListVisibility.private,
  });

  final String id;
  final String title;
  final String description;
  final String city;
  final List<ListItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Yayınlandıysa sunucudaki liste kimliği.
  final String? remoteId;

  /// Yayınlanan listeyi güncellemek ve silmek için sunucunun verdiği anahtar.
  /// Defterle birlikte cihazda ve kullanıcının bulut yedeğinde durur; giriş
  /// yapan kullanıcının listeleri ayrıca hesaba bağlanır.
  final String? ownerKey;
  final ListVisibility visibility;

  bool get isPublished => remoteId != null;

  bool contains(String placeId) => items.any((i) => i.placeId == placeId);

  CuratedList copyWith({
    String? title,
    String? description,
    String? city,
    List<ListItem>? items,
    DateTime? updatedAt,
    Object? remoteId = _unset,
    Object? ownerKey = _unset,
    ListVisibility? visibility,
  }) => CuratedList(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    city: city ?? this.city,
    items: items ?? this.items,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    remoteId: identical(remoteId, _unset) ? this.remoteId : remoteId as String?,
    ownerKey: identical(ownerKey, _unset) ? this.ownerKey : ownerKey as String?,
    visibility: visibility ?? this.visibility,
  );

  factory CuratedList.fromJson(Map<String, dynamic> json) {
    final remoteId = json['remoteId'];
    final ownerKey = json['ownerKey'];
    return CuratedList(
      id: _string(json['id']),
      title: _string(json['title']),
      description: _string(json['description']),
      city: _string(json['city']),
      items: [
        for (final item in (json['items'] as List? ?? const []))
          if (item is Map<String, dynamic>) ListItem.fromJson(item),
      ],
      createdAt:
          DateTime.tryParse(_string(json['createdAt'])) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(_string(json['updatedAt'])) ?? DateTime.now(),
      remoteId: remoteId is String && remoteId.isNotEmpty ? remoteId : null,
      ownerKey: ownerKey is String && ownerKey.isNotEmpty ? ownerKey : null,
      visibility: _enumByName(
        ListVisibility.values,
        json['visibility'],
        ListVisibility.private,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'city': city,
    'items': [for (final item in items) item.toJson()],
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'remoteId': remoteId,
    'ownerKey': ownerKey,
    'visibility': visibility.name,
  };
}

class Profile {
  const Profile({
    this.name = '',
    this.handle = '',
    this.bio = '',
    this.city = '',
    this.interests = '',
    this.areas = '',
    this.defaultVisitVisibility = VisitVisibility.private,
    this.notifications = false,
  });

  final String name;
  final String handle;
  final String bio;
  final String city;
  final String interests;
  final String areas;
  final VisitVisibility defaultVisitVisibility;
  final bool notifications;

  Profile copyWith({
    String? name,
    String? handle,
    String? bio,
    String? city,
    String? interests,
    String? areas,
    VisitVisibility? defaultVisitVisibility,
    bool? notifications,
  }) => Profile(
    name: name ?? this.name,
    handle: handle ?? this.handle,
    bio: bio ?? this.bio,
    city: city ?? this.city,
    interests: interests ?? this.interests,
    areas: areas ?? this.areas,
    defaultVisitVisibility:
        defaultVisitVisibility ?? this.defaultVisitVisibility,
    notifications: notifications ?? this.notifications,
  );

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    name: _string(json['name']),
    handle: _string(json['handle']),
    bio: _string(json['bio']),
    city: _string(json['city']),
    interests: _string(json['interests']),
    areas: _string(json['areas']),
    defaultVisitVisibility: _enumByName(
      VisitVisibility.values,
      json['defaultVisitVisibility'],
      VisitVisibility.private,
    ),
    notifications: json['notifications'] == true,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'handle': handle,
    'bio': bio,
    'city': city,
    'interests': interests,
    'areas': areas,
    'defaultVisitVisibility': defaultVisitVisibility.name,
    'notifications': notifications,
  };
}

class JournalData {
  const JournalData({
    this.places = const [],
    this.visits = const [],
    this.lists = const [],
    this.savedListIds = const [],
    this.savedRemoteLists = const [],
    this.profile = const Profile(),
  });

  final List<Place> places;
  final List<Visit> visits;
  final List<CuratedList> lists;

  /// Kaydedilen kendi listelerin.
  final List<String> savedListIds;

  /// Kaydedilen topluluk listelerinin çevrimdışı kopyaları.
  final List<GurmeList> savedRemoteLists;
  final Profile profile;

  Place? placeById(String id) => places.where((p) => p.id == id).firstOrNull;

  /// Arama sonucundaki mekânın defterdeki kaydı: önce Google kimliğiyle,
  /// yoksa elle eklenmiş (Google kimliği olmayan) aynı adlı kayıtla.
  Place? placeForVenue(String googlePlaceId, String name) {
    final byId = places.where((p) => p.googlePlaceId == googlePlaceId);
    if (byId.firstOrNull case final place?) return place;
    final key = normalizeForMatch(name);
    return places
        .where(
          (p) => p.googlePlaceId == null && normalizeForMatch(p.name) == key,
        )
        .firstOrNull;
  }

  CuratedList? listById(String id) =>
      lists.where((l) => l.id == id).firstOrNull;

  Visit? visitById(String id) => visits.where((v) => v.id == id).firstOrNull;

  List<Visit> visitsFor(String placeId) =>
      visits.where((v) => v.placeId == placeId).toList();

  bool isRemoteSaved(String remoteId) =>
      savedRemoteLists.any((l) => l.id == remoteId);

  /// Defterde kayıtlı tüm fotoğrafların göreli yolları.
  Set<String> get photoPaths => {
    for (final p in places)
      if (p.image.isNotEmpty) p.image,
    for (final v in visits) ...v.photos,
  };

  JournalData copyWith({
    List<Place>? places,
    List<Visit>? visits,
    List<CuratedList>? lists,
    List<String>? savedListIds,
    List<GurmeList>? savedRemoteLists,
    Profile? profile,
  }) => JournalData(
    places: places ?? this.places,
    visits: visits ?? this.visits,
    lists: lists ?? this.lists,
    savedListIds: savedListIds ?? this.savedListIds,
    savedRemoteLists: savedRemoteLists ?? this.savedRemoteLists,
    profile: profile ?? this.profile,
  );

  factory JournalData.fromJson(Map<String, dynamic> json) {
    List<T> listOf<T>(String key, T Function(Map<String, dynamic>) parse) => [
      for (final e in (json[key] as List? ?? const []))
        if (e is Map<String, dynamic>) parse(e),
    ];
    final profile = json['profile'];
    return JournalData(
      places: listOf('places', Place.fromJson),
      visits: listOf('visits', Visit.fromJson),
      lists: listOf('lists', CuratedList.fromJson),
      savedListIds: [
        for (final id in (json['savedListIds'] as List? ?? const []))
          if (id is String) id,
      ],
      savedRemoteLists: listOf('savedRemoteLists', GurmeList.fromJson),
      profile: profile is Map<String, dynamic>
          ? Profile.fromJson(profile)
          : const Profile(),
    );
  }

  Map<String, dynamic> toJson() => {
    'version': 1,
    'places': [for (final p in places) p.toJson()],
    'visits': [for (final v in visits) v.toJson()],
    'lists': [for (final l in lists) l.toJson()],
    'savedListIds': savedListIds,
    'savedRemoteLists': [for (final l in savedRemoteLists) l.toJson()],
    'profile': profile.toJson(),
  };
}

/// "Moda, Kadıköy, İstanbul" -> semt "Moda, Kadıköy", şehir "İstanbul".
({String district, String city}) areaToLocation(String area) {
  final parts = area
      .split(',')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();
  return parts.length > 1
      ? (
          district: parts.sublist(0, parts.length - 1).join(', '),
          city: parts.last,
        )
      : (district: area.trim(), city: '');
}

/// Google'ın Türkçe adres biçiminden semt ve şehir:
/// "Caferağa, Moda Cd. No:12, 34710 Kadıköy/İstanbul, Türkiye"
/// -> semt "Kadıköy", şehir "İstanbul". Bulunamazsa [fallbackCity].
({String district, String city}) locationFromAddress(
  String address,
  String fallbackCity,
) {
  final parts = address
      .split(',')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty && p != 'Türkiye' && p != 'Turkey')
      .toList();
  for (final part in parts.reversed) {
    final slash = part.indexOf('/');
    if (slash == -1) continue;
    final district = part
        .substring(0, slash)
        .replaceFirst(RegExp(r'^\d+\s*'), '')
        .trim();
    final city = part.substring(slash + 1).trim();
    if (city.isNotEmpty) return (district: district, city: city);
  }
  return (district: '', city: fallbackCity.trim());
}
