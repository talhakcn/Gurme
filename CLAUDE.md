# Gurme

Kullanıcıyla her zaman Türkçe konuş; ara mesajlar ve tur sonu özetleri dahil. Proje durumu ve kararlar: `docs/ROADMAP.md`.

Yapılan her işi `docs/CALISMA_GUNLUGU.md` dosyasına tarih başlığı altında, commit koduyla birlikte kaydet.

## Flutter uygulaması (`artifacts/app`)

- Tasarım dili `artifacts/app/DESIGN.md` dosyasında. Ekran yazmadan ya da değiştirmeden önce oku ve uy.
- Boşluk, yazı ve renk için yalnızca adlandırılmış değerleri kullan (`Space`, `Theme.of(context).textTheme`, `context.colors`). Ekranda sayı ya da renk değeri yazma. Renkler gece moduna göre değiştiği için ekranlarda `GurmeColors` sabitlerini değil `context.colors` paletini kullan.
- Yeni ekranı `test/screens_test.dart` listesine ekle; normal, 2 kat yazı, gece ve iPad genişliğinde taşmadan çizildiği orada denenir. Pencere, alttan açılan sayfa ve bilgi çubukları `test/overlays_test.dart` içinde gündüz, gece ve iOS'ta denenir. Girişli hesap, yedek ve hata durumları `test/states_test.dart` içindedir.
- Simge gerekiyorsa `core/widgets/gurme_icons.dart` setine ekle; Material `Icons` kullanma (marka simgeleri hariç).
- Her ekranda tek ana eylem (altın düğme) olur.
- Yön "kişisel defter": metinler cümle düzeninde; büyük harfli etiket, bölüm numarası, slogan ve yer tutucu kapak yok. Sayıları tablo yerine cümleyle ver. Ayrıntısı DESIGN.md'de; yapay zekâ kalıpları listesi `docs/TASARIM_ELESTIRISI.md`.
- Büyük harf gerekirse (paylaşım görseli) `toUpperTr()` kullan, `toUpperCase()` değil.
- Tasarım skill'leri `.claude/skills/` altında (impeccable, taste-skill, emil); kaynakları `.claude/skills/KAYNAKLAR.md`.
- Kontrol: `dart analyze` (`flutter analyze` değil) ve `flutter test --no-pub` (paket güncellemesi ağda takılabiliyor).
- Ekranın görüntüsünü almak için testlerde `GURME_COVER_DIR=<klasör>` verilebilir (bkz. `test/cover_test.dart`).

## Depo

- Depo iCloud ile eşitlenen bir klasörde (Desktop, Documents) durmamalı.
- `pnpm` PATH'te yoksa `corepack pnpm` kullan. Tip kontrolü kökten: `pnpm run typecheck`.
- `pnpm-workspace.yaml` içindeki `minimumReleaseAge: 1440` kaldırılmamalı; yeni paket sürümleri yayımlandıktan 1 gün sonra kurulur.
