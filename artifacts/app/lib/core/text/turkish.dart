/// Türkçe büyük harf dönüşümü. Dart'ın `toUpperCase()` yöntemi dile duyarsız
/// olduğu için "i" harfini "I" yapar ("Listelerim" -> "LISTELERIM").
String toUpperTr(String text) =>
    text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

/// Türkçe küçük harf dönüşümü ("İ" -> "i", "I" -> "ı").
String toLowerTr(String text) =>
    text.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

/// Büyük/küçük harf ve baştaki/sondaki boşluklar önemsenmeden eşitlik.
bool equalsTr(String a, String b) => toLowerTr(a.trim()) == toLowerTr(b.trim());

const _alphabet = 'abcçdefgğhıijklmnoöprsştuüvyz';

/// Türkçe alfabe sırasıyla karşılaştırma (ç c'den, ı i'den önce gelir).
int compareTr(String a, String b) {
  final x = toLowerTr(a);
  final y = toLowerTr(b);
  final length = x.length < y.length ? x.length : y.length;
  for (var i = 0; i < length; i++) {
    final cx = x[i];
    final cy = y[i];
    if (cx == cy) continue;
    final ix = _alphabet.indexOf(cx);
    final iy = _alphabet.indexOf(cy);
    if (ix != -1 && iy != -1) return ix - iy;
    return cx.compareTo(cy);
  }
  return x.length - y.length;
}

const _folded = {
  'ç': 'c',
  'ğ': 'g',
  'ı': 'i',
  'ö': 'o',
  'ş': 's',
  'ü': 'u',
  'â': 'a',
  'î': 'i',
  'û': 'u',
};

/// Yinelenen kayıt aramak için: küçük harf, Türkçe harfler sadeleşmiş,
/// harf ve rakam dışındaki karakterler tek boşluk.
String normalizeForMatch(String text) {
  final lower = toLowerTr(text.trim());
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_folded[char] ?? char);
  }
  return buffer
      .toString()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .trim();
}

const _months = [
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

/// "6 Ekim 2026". Tarih yoksa "Tarih yok".
String formatDateTr(DateTime? date) {
  if (date == null) return 'Tarih yok';
  final local = date.toLocal();
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}

const _weekdays = [
  'Pazartesi',
  'Salı',
  'Çarşamba',
  'Perşembe',
  'Cuma',
  'Cumartesi',
  'Pazar',
];

/// Saate göre selam: "Günaydın", "İyi günler", "İyi akşamlar", "İyi geceler".
String greetingTr(DateTime time) {
  final h = time.hour;
  return h >= 5 && h < 11
      ? 'Günaydın'
      : h >= 11 && h < 17
      ? 'İyi günler'
      : h >= 17 && h < 23
      ? 'İyi akşamlar'
      : 'İyi geceler';
}

/// ISO 8601 hafta numarası (haftalar pazartesi başlar).
int isoWeek(DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day);
  // Haftanın perşembesi hangi yıldaysa hafta o yıla aittir.
  final thursday = day.add(Duration(days: 4 - day.weekday));
  final firstDay = DateTime.utc(thursday.year);
  return thursday.difference(firstDay).inDays ~/ 7 + 1;
}

/// "7 Ekim 2026, Çarşamba".
String formatLongDateTr(DateTime date) =>
    '${formatDateTr(date)}, ${_weekdays[date.weekday - 1]}';

/// Ayın adı: 1 → "Ocak".
String monthNameTr(int month) => _months[month - 1];

/// Ayın kısa adı: 1 → "Oca" (grafik eksenleri için).
String monthShortTr(int month) => _months[month - 1].substring(0, 3);

/// "Ekim 2026".
String formatMonthTr(DateTime date) =>
    '${_months[date.month - 1]} ${date.year}';

/// "2026-10-06" biçimindeki ziyaret tarihini okunur hale getirir.
String formatIsoDateTr(String value) {
  final parsed = DateTime.tryParse(value);
  return parsed == null
      ? (value.isEmpty ? 'Tarih yok' : value)
      : formatDateTr(parsed);
}

/// Yakın tarihleri göreli yazar: "Bugün", "Dün", son bir haftada gün adı
/// ("Salı"), ondan önceki hafta "Geçen salı"; daha eskisi tam tarih.
/// [sentence] `true` ise cümle içinde kullanılmak üzere küçük harfle başlar
/// ("en son dün"); tam tarih olduğu gibi kalır.
String relativeIsoDateTr(String value, DateTime now, {bool sentence = false}) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return formatIsoDateTr(value);
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(parsed.year, parsed.month, parsed.day);
  final days = today.difference(day).inDays;
  final weekday = _weekdays[day.weekday - 1];
  final relative = switch (days) {
    0 => 'Bugün',
    1 => 'Dün',
    >= 2 && <= 6 => weekday,
    >= 7 && <= 13 => 'Geçen ${toLowerTr(weekday)}',
    _ => null,
  };
  if (relative == null) return formatDateTr(parsed);
  return sentence ? toLowerTr(relative) : relative;
}

/// Bugünün tarihi, "2026-10-06".
String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Parçaları Türkçe sıralar: "a", "a ve b", "a, b ve c".
String joinTr(List<String> parts) => switch (parts.length) {
  0 => '',
  1 => parts.first,
  _ => '${parts.sublist(0, parts.length - 1).join(', ')} ve ${parts.last}',
};

/// Sıfır olmayan sayıları "3 mekân, 1 deneyim ve 1 rota" diye sıralar.
String countsTr(List<(int, String)> counts) => joinTr([
  for (final (n, noun) in counts)
    if (n > 0) '$n $noun',
]);

/// Geçen süreyi kısa yazar: "az önce", "5 dk önce", "2 saat önce",
/// "dün 14:05"; daha eskisi tarih ve saat.
String relativeTimeTr(DateTime time, DateTime now) {
  final local = time.toLocal();
  final clock =
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
  final diff = now.difference(local);
  if (diff.inMinutes < 1) return 'az önce';
  if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  return switch (today.difference(day).inDays) {
    0 => '${diff.inHours} saat önce',
    1 => 'dün $clock',
    _ => '${formatDateTr(local)} $clock',
  };
}
