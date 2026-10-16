import 'package:gurme/features/journal/data/journal_models.dart';

/// Ekran ve pencere testlerinin ortak örnek defteri.
final sampleNow = DateTime(2026, 10, 7, 19, 30);

final sampleJournal = JournalData(
  profile: const Profile(
    name: 'Semih',
    handle: 'semih',
    city: 'İstanbul',
    bio: 'Kahve, fırın ve esnaf lokantası peşinde.',
  ),
  places: [
    Place(
      id: 'p1',
      name: 'Kahve Durağı',
      image: 'photos/kahve.jpg',
      district: 'Moda',
      city: 'İstanbul',
      category: 'Kahve',
      description: 'Sabahları sakin, filtre kahvesi çok iyi.',
      status: PlaceStatus.went,
      recommended: true,
      createdAt: DateTime(2026, 8, 1),
    ),
    Place(
      id: 'p2',
      name: 'Fırın Kırıntı',
      image: 'photos/simit.jpg',
      district: 'Karaköy',
      city: 'İstanbul',
      category: 'Fırın',
      description: 'Ekşi mayalı simidi için gidilir.',
      status: PlaceStatus.want,
      source: 'Arkadaş önerisi',
      createdAt: DateTime(2026, 9, 3),
    ),
    Place(
      id: 'p3',
      name: 'Mahalle Lahmacuncusu',
      image: 'photos/lahmacun.jpg',
      district: 'Yeldeğirmeni',
      city: 'İstanbul',
      category: 'Lokanta',
      description: 'Taş fırın, ince hamur, bol maydanoz.',
      status: PlaceStatus.went,
      recommended: true,
      createdAt: DateTime(2026, 9, 28),
    ),
  ],
  visits: const [
    Visit(
      id: 'v1',
      placeId: 'p1',
      date: '2026-09-14',
      title: 'O sabahki ilk fincan',
      note:
          'Filtre kahvesi hâlâ şehrin en iyisi, servis yavaş. Sabah sekizde '
          'kapıyı açan barista çekirdeği o gün kendisi seçiyor; tahinli çörek '
          'fırından yeni çıkmıştı.',
      recommended: true,
      revisit: Revisit.yes,
      scores: TastingScores(taste: 4, service: 3, ambiance: 5, value: 3),
      tastedDishes: [
        TastedDish(
          name: 'Filtre kahve',
          kind: DishKind.coffee,
          score: 5,
          parts: [
            DishPart('Kahve', DishVerdict.good),
            DishPart('Sıcaklık', DishVerdict.fine),
          ],
        ),
        TastedDish(
          name: 'Tahinli çörek',
          kind: DishKind.pastry,
          score: 3,
          parts: [
            DishPart('Hamur', DishVerdict.good),
            DishPart('İç', DishVerdict.bad),
            DishPart('Tazelik', DishVerdict.good),
          ],
          note: 'Tahini azdı.',
          never: true,
        ),
      ],
    ),
    Visit(
      id: 'v2',
      placeId: 'p1',
      date: '2026-08-02',
      title: 'İlk keşif',
      note: 'Pencere kenarı boştu; çekirdekler Etiyopya ve Kolombiya.',
      recommended: true,
      revisit: Revisit.yes,
      scores: TastingScores(taste: 4, service: 2, ambiance: 4, value: 4),
      tastedDishes: [
        TastedDish(
          name: 'Filtre kahve',
          kind: DishKind.coffee,
          score: 4,
          parts: [
            DishPart('Kahve', DishVerdict.good),
            DishPart('Sıcaklık', DishVerdict.bad),
          ],
        ),
        TastedDish(
          name: 'Türk kahvesi',
          kind: DishKind.coffee,
          score: 3,
          parts: [DishPart('Kahve', DishVerdict.fine)],
        ),
        TastedDish(
          name: 'Soğuk demleme',
          kind: DishKind.coffee,
          score: 4,
          parts: [DishPart('Kahve', DishVerdict.good)],
        ),
      ],
    ),
    Visit(
      id: 'v3',
      placeId: 'p3',
      date: '2026-10-04',
      title: 'Fırından çıkar çıkmaz',
      note:
          'Hamur kâğıt inceliğinde, kenarları hafif yanık. Ayranı köpüklü; '
          'öğle kalabalığından önce gitmek lazım.',
      order: 'Lahmacun, ayran',
      recommended: true,
      revisit: Revisit.yes,
      scores: TastingScores(taste: 5, service: 4, ambiance: 3, value: 5),
    ),
  ],
  lists: [
    CuratedList(
      id: 'l1',
      title: 'Sabah rotası',
      description: 'Şehir uyanmadan, bir fincan ve sıcak bir simitle.',
      city: 'İstanbul',
      items: const [
        ListItem(placeId: 'p1', note: 'Filtre kahve'),
        ListItem(placeId: 'p2'),
      ],
      createdAt: DateTime(2026, 9, 20),
      updatedAt: DateTime(2026, 9, 21),
    ),
  ],
);
