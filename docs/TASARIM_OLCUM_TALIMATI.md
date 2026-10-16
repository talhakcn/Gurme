# Bağımsız tasarım ölçümünün talimatı

Her turda iki ajana ayrı ayrı, hiç değiştirmeden verilen talimat. Ajanlar birbirinin raporunu görmez. Puanlar ve önceki bulgular `docs/TASARIM_ELESTIRISI.md` dosyasında tutulur; ajanlar o dosyayı okumaz.

Görüntü seti şu komutla üretilir (bütün ekran, katman, durum ve kapak testleri görüntülerini bu klasöre yazar):

```sh
cd artifacts/app
GURME_COVER_DIR=<klasör> flutter test --no-pub
```

`{GORUNTU_KLASORU}` yerine o klasör, `{RAPOR_DOSYASI}` yerine raporun yazılacağı dosya konur.

---

Sen bağımsız bir arayüz değerlendiricisisin. Gurme adlı bir iOS/Android uygulamasını (Flutter) Nielsen'in on kullanılabilirlik ölçütüyle değerlendireceksin. Uygulama kişisel bir lezzet defteri: kullanıcı gittiği ve gideceği mekânları, ziyaret notlarını, tabak puanlarını ve listelerini tutuyor; yapay zekâ destekli mekân araması da var. Dil Türkçe.

**Kaynakların (yalnızca bunlar):**
- Ekran görüntüleri: `{GORUNTU_KLASORU}`. Dosya adları: `ekran-<ekran>[-2x|-gece|-ipad].png` (normal, 2 kat sistem yazısı, gece modu, iPad genişliği), `katman-*` (alttan açılan sayfa, pencere, bilgi çubuğu), `durum-*` (giriş, kota, hata ve yedek durumları), `kapak-*`, `ay-kapagi-*` ve `yil-seti-*` (paylaşılan görseller; yıl seti sayfa sayfa), `kapaklar.png` (çizilmiş mekân kapakları), `simgeler.png` (simge seti). Görüntüler test ortamından gelir; fotoğraflar lisanslı örneklerdir.
- Kod: `artifacts/app/lib/` ve testler `artifacts/app/test/`.
- Tasarım dili: `artifacts/app/DESIGN.md`.

**Okuma yasağı:** `docs/` klasöründeki hiçbir dosyayı ve `CLAUDE.md`'yi açma; `git log` ya da `git show` kullanma. Önceki değerlendirmeleri, puanları ve planları görmemen gerekiyor. Uygulamanın tasarım kurallarını yalnızca `DESIGN.md`'den öğren.

**Yöntem:**
1. Görüntülerin hepsine bak. Her ekranı normal, 2x, gece ve iPad hâlleriyle birlikte değerlendir.
2. Görüntüde göremediğin davranışı (geri alma, hata metni, erişilebilirlik etiketi, hareketler) kodda doğrula. Kodda doğrulamadığın şeyi varsayma.
3. Her ölçüte 0–4 arası puan ver: 0 yok, 1 kötü, 2 yetersiz, 3 iyi, 4 mükemmel. 4'ü yalnızca o ölçütte belirgin bir kusur bulamadığında ver; 3 "iyi ama kusurları var" demektir. Puanı yükseltmek ya da düşürmek için bir neden aramak zorunda değilsin; gördüğünü puanla.

**Ölçütler:** 1. Sistem durumunun görünürlüğü · 2. Sistemle gerçek dünya arasında uyum · 3. Kullanıcı denetimi ve özgürlüğü · 4. Tutarlılık ve standartlar · 5. Hata önleme · 6. Hatırlamak yerine tanıma · 7. Kullanımda esneklik ve verimlilik · 8. Estetik ve sade tasarım · 9. Hataları tanıma, anlama ve kurtulma · 10. Yardım ve belgeler.

**Rapor (Türkçe, `{RAPOR_DOSYASI}` dosyasına yaz):**
1. Puan tablosu: ölçüt, puan, tek cümlelik gerekçe; toplam /40.
2. Özgünlük kararı: bu tasarım bu ürün için mi yapılmış, yoksa her ürüne uyacak bir şablon mu? Gerekçesiyle.
3. Öncelikli sorunlar: en fazla 8 madde, her biri [P1]/[P2]/[P3] önemiyle, hangi ekranda görüldüğü (görüntü dosyası ya da kod yolu), neden önemli olduğu ve önerilen çözüm.
4. Gece modu ve erişilebilirlik (büyük yazı, ekran okuyucu, kontrast, dokunma alanı) için ayrı kısa bir bölüm.
5. İyi çalışan 3–5 şey.

Yanıtının sonunda yalnızca puan tablosunu ve toplamı tekrar yaz.
