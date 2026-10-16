import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/profile/portrait.dart';

import 'sample_data.dart';

void main() {
  test('portre deneyimlerden çıkar', () {
    final portrait = NotebookPortrait.of(sampleJournal);
    expect(portrait.category, ('Kahve', 2));
    expect(portrait.district, ('Moda', 2));
    expect(portrait.favorite?.name, 'Kahve Durağı');
    expect(portrait.favoriteVisits, 2);
    expect(portrait.lastVisit?.id, 'v3');
    expect(portrait.lastPlace?.name, 'Mahalle Lahmacuncusu');
    // Son gidilen önce; gidilmemiş Fırın Kırıntı izde yok.
    expect([for (final (p, _, _) in portrait.marks) p.id], ['p3', 'p1']);
  });

  test('deneyim yoksa portre boş', () {
    final empty = JournalData(places: sampleJournal.places);
    expect(NotebookPortrait.of(empty).isEmpty, isTrue);
  });
}
