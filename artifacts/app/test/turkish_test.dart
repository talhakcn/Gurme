import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/text/turkish.dart';

void main() {
  test('Türkçe büyük ve küçük harf dönüşümü', () {
    expect(toUpperTr('Listelerim'), 'LİSTELERİM');
    expect(toUpperTr('Arşivim ışık'), 'ARŞİVİM IŞIK');
    expect(toLowerTr('İSTANBUL IĞDIR'), 'istanbul ığdır');
  });

  test('joinTr ve countsTr Türkçe sıralar, sıfırları atlar', () {
    expect(joinTr([]), '');
    expect(joinTr(['a']), 'a');
    expect(joinTr(['a', 'b']), 'a ve b');
    expect(joinTr(['a', 'b', 'c']), 'a, b ve c');
    expect(
      countsTr([(2, 'mekân'), (0, 'deneyim'), (1, 'rota')]),
      '2 mekân ve 1 rota',
    );
  });

  test('relativeIsoDateTr yakın tarihleri göreli yazar', () {
    final now = DateTime(2026, 10, 8, 14); // Perşembe
    expect(relativeIsoDateTr('2026-10-08', now), 'Bugün');
    expect(relativeIsoDateTr('2026-10-07', now), 'Dün');
    expect(relativeIsoDateTr('2026-10-05', now), 'Pazartesi');
    expect(relativeIsoDateTr('2026-09-29', now), 'Geçen salı');
    expect(relativeIsoDateTr('2026-09-14', now), '14 Eylül 2026');
    expect(relativeIsoDateTr('2026-10-07', now, sentence: true), 'dün');
    expect(relativeIsoDateTr('2026-09-29', now, sentence: true), 'geçen salı');
  });

  test('relativeTimeTr geçen süreyi kısa yazar', () {
    final now = DateTime(2026, 10, 8, 14, 30);
    expect(relativeTimeTr(DateTime(2026, 10, 8, 14, 29, 40), now), 'az önce');
    expect(relativeTimeTr(DateTime(2026, 10, 8, 14, 25), now), '5 dk önce');
    expect(relativeTimeTr(DateTime(2026, 10, 8, 11, 0), now), '3 saat önce');
    expect(relativeTimeTr(DateTime(2026, 10, 7, 9, 5), now), 'dün 09:05');
    expect(
      relativeTimeTr(DateTime(2026, 10, 1, 20, 0), now),
      '1 Ekim 2026 20:00',
    );
  });
}
