# Çalışma günlüğü

Bu dosya, Claude ile yapılan çalışma oturumlarında neyin, neden yapıldığını tarih sırasıyla kaydeder. Projenin genel durumu ve kararları için `docs/ROADMAP.md`, tasarım dili için `artifacts/app/DESIGN.md` dosyasına bakın.

Her maddedeki kısa kod, ilgili commit'tir (`git show <kod>` ile ayrıntısı görülür). Bütün işler `claude/faz4-flutterfire` dalında.

## 7 Ekim 2026

### Proje düzeni

- **iCloud kopyaları silindi.** Depoda 47 tane `... 2.dart` / `... 2.ts` dosyası vardı. Hepsi üretilmiş kodun eski kopyalarıydı. Her biri orijinaliyle karşılaştırıldıktan sonra silindi.
- **Depo taşındı.** Proje `~/Desktop/Kişisel/Gurme/flutter_gurme` konumundan `~/Developer/Gurme/flutter_gurme` konumuna taşındı. Desktop iCloud ile eşitlendiği için iOS derlemesi imzalama adımında duruyordu. Taşımadan sonra uygulama doğrudan asıl klasörden derleniyor.
- **ROADMAP güncellendi.** Faz 2 ve Faz 3 tamamlandı olarak işaretlendi. Swift paket sürümleri sabitlendi. (`99c9edb`)

### Faz 4'ün kalanı

- **Etkinlik ve bildirimler ekranları.** İkisi de profilden açılıyor. Etkinlik, deneyimleri aylara bölünmüş bir zaman çizelgesinde gösteriyor. (`bd2b9fc`)
- **Bulut yedeği.** Giriş yapan kullanıcının defteri ve fotoğrafları Firebase Storage'a (`users/{uid}/`) otomatik yedekleniyor. Yeni cihazda girişte geri geliyor; iki cihazdaki değişiklikler birleştiriliyor. Güvenlik kuralları `artifacts/app/firebase/storage.rules` dosyasında. Kullanıcı bu yolu Postgres'te tam eşitlemeye ve Firestore'a tercih etti. Gerçek Firebase projesiyle henüz denenmedi. (`ab2a23e`)
- **Crashlytics** zaten kuruluydu; ek iş gerekmedi.

### Tasarım önerileri (`.tasarim-taslak`)

1. **Erişilebilir palet:**
   - Metinde turkuaz #2F7482 ve soluk #57696C kullanılıyor; ikisi de AA kontrast eşiğini geçiyor.
   - Küçük başlıklar 11 px.
   - Seçili kutularda onay işareti var. (`a1d1a58`)
2. **Hızlı ekleme:** Alttan açılan kısa bir sayfa. Ad, Gideceğim/Gittim ve isteğe bağlı kaynak soruluyor. Mekâna `source` alanı eklendi. (`96afa2b`)
3. **"Bugün ne yesem?":** Keşfet'te gideceklerden bir öneri. "Bugün gidiyorum" mekânı haritada açıyor, "Başka öner" sıradakine geçiyor. (`7efdaba`)
4. **Tadım karnesi:** Deneyim formunda 4 ölçüt için 1–5 puan, ortalama ve aynı mekândaki ziyaretlerin gidişatı. (`f5fc0a0`)
5. **Liste kapağı:** Liste, 1080×1920 görsel olarak paylaşılıyor. Kâğıt, mürekkep ve altın olmak üzere üç renk seçeneği var. (`9f8921f`)
6. **Lezzet haritan:** Profilde yılın özeti. Sayılar, semtler, tür dağılımı ve en çok önerilen mekân gösteriliyor; özet görsel olarak paylaşılabiliyor. (`239f3e2`)

Gece modu ve arama harita görünümünün taslak dosyası yok; ikisi yapılmadı. (`4890562`)

### Tasarımın sadeleştirilmesi

Kullanıcının isteği: "detaylıca düşünülmüş detaylardan ve basit bir tasarımdan oluşsun".

1. **Tasarım dili yazıldı.**
   - `artifacts/app/DESIGN.md` belgesi yazıldı: renkler, yazı rolleri, boşluk ölçeği, köşesiz yüzeyler, ekran başına tek ana eylem.
   - Depo köküne `CLAUDE.md` eklendi, sonraki oturumlar bu kurallara uysun diye. (`7d5b84c`)
2. **Ölçek koda işlendi.**
   - 26 farklı boşluk değeri 7 basamaklı `Space` ölçeğine indi (4, 8, 12, 16, 24, 32, 48).
   - Ekranlarda elle verilmiş 13 yazı boyutunun yerini tema rolleri aldı. (`b8444a1`)
3. **Hata düzeltildi, ekran testleri eklendi.**
   - Arama sekmesi ilk açılışta bir sağlayıcı (provider) hatası veriyordu; düzeltildi.
   - `test/screens_test.dart` 14 ekranı örnek bir defterle çiziyor. `GURME_COVER_DIR` verilirse ekranları PNG olarak kaydediyor. (`12c63b5`)
4. **Ekranlar sadeleştirildi.**
   - Keşfet'te tek altın düğme kaldı.
   - Örnek editoryal içerik, tekrarlanan düğmeler ve boş bölümler kaldırıldı.
   - Arşiv filtreleri tek satıra indi.
   - Henüz çalışmayan ziyaret görünürlüğü ve bildirim tercihi arayüzden kaldırıldı.
   - Silme eylemi küçük, kırmızı bir bağlantıya dönüştü. (`f4387c2`)
5. **Ayrıntılar.**
   - Tek üç nokta karakteri (…) kullanılıyor.
   - Seçimlerde hafif titreşim var.
   - Rakamlar sabit genişlikte.
   - Profildeki çift çizgi kaldırıldı. (`50281d6`)
6. **Boş durumlar ve belgeler.**
   - Boş durumlara sonraki adım eklendi.
   - Tasarım kararları DESIGN.md'ye işlendi. (`a1f0379`)

Bu bölümün sonunda 67 test geçiyordu; `dart analyze` temizdi.

### Sıradaki iş: uygulamaya ayrıntı katmak

Kullanıcı sadeleştirmeden sonra uygulamanın "içi boş" göründüğünü söyledi. Dört yönün hepsi seçildi; sırayla uygulanacak:

1. **Görsel kimlik:**
   - Fotoğrafı olmayan mekânlara türüne göre çizilmiş kapak: kâğıt tonunda bir karo, soluk büyük italik baş harf ve ince çizgili bir tür simgesi.
   - Kapak satırlarda küçük, mekân sayfasında ve öneri kartında büyük görünecek.
2. **Zengin içerik:**
   - Mekân sayfasında bilgi tablosu: ziyaret sayısı, son ziyaret, ortalama karne ve karne gidişat çizgisi.
   - Keşfet'te "bu hafta" özeti.
   - Boş defter için 3 adımlı başlangıç rehberi.
3. **Editoryal ayrıntılar:**
   - Keşfet'te künye (hafta ve tarih).
   - Numaralı bölüm başlıkları ve süs çizgileri.
   - Uzun notlarda büyük ilk harf.
4. **Hareket:**
   - Satırların yumuşakça belirmesi.
   - Sayan sayılar.
   - Dolan karne kutuları.
   - Kapağın satırdan mekân sayfasına akması.
   - Cihazda "hareketi azalt" ayarı açıksa bu hareketler kapalı olacak.

### Ayrıntı ekleme: yapılanlar

- **1. Görsel kimlik (tamamlandı, `0dacce1`):**
  - Fotoğrafı olmayan mekânlara türüne göre çizilmiş kapak: ton, baş harf ve simge.
  - Kapak satırlarda küçük, mekân sayfasında ve öneri kartında büyük görünüyor.
  - Listelerde ilk dört durağın kapak şeridi var.
- **2. Zengin içerik (tamamlandı, bu adımın commit'i):**
  - Mekân sayfasında künye: ziyaret, son ziyaret, karne, defterde geçen süre ve karne gidişat çizgisi.
  - Keşfet'te 3 adımlı "Başlarken" rehberi ve "Bu hafta" özeti.
  - Yeni ekler için ayrı test yazılmadı; mevcut 68 test geçiyor.
- **3. Editoryal ayrıntılar (tamamlandı):**
  - Keşfet'in üstünde künye: "Hafta 41 · 7 Ekim 2026, Çarşamba".
  - Bölümler arasında italik numaralı çizgiler.
  - Sayfa sonunda defterin kısa özeti.
  - 120 karakteri aşan notlarda büyük ilk harf.
  - Öneri kartındaki gün dilimi "Bu akşam" oldu; künyedeki günü tekrar etmiyor.
  - Mekân künyesindeki hücre başlıkları tek satır.
- **4. Hareket (tamamlandı):**
  - Mekân satırları sırayla, hafifçe kayarak belirir.
  - Profil, yıl özeti ve mekân künyesindeki sayılar sayarak gelir.
  - Karne kutuları dolarak renklenir.
  - Kapak satırdan mekân sayfasına akar.
  - "Hareketi azalt" açıksa hiçbiri oynamaz.
  - Sorun ve çözüm: Arka plandaki sekmeler açık kaldığı için aynı mekânın kapağı iki sekmede bulunup geçişi bozuyordu. Kapak geçişi ve animasyonlar artık yalnızca görünen sekmede çalışıyor. Bu durum için test eklendi; toplam 70 test geçiyor.

Ayrıntı ekleme planının dört adımı da tamamlandı.

## 8 Ekim 2026

### Tasarımı özgünleştirme: skill'lerin kurulumu

Kullanıcının tespiti: tasarım "yapay zekâ tasarımı" gibi duruyor. Aralıklı büyük harfli turkuaz başlıklar, numaralı bölüm çizgileri, büyük ilk harf, serif ve altın şablonu gibi kalıplar bir arada şablon hissi veriyor.

- skills.sh'de aday skill'ler araştırıldı. Depoları açılıp doğrulandı.
- Projenin `.claude/skills/` klasörüne kuruldu:
  - **Impeccable:** `critique`, `audit`, `distill`, `typeset` ve diğer komutlar.
  - **Taste-Skill:** `redesign-existing-projects` ve `design-taste-frontend`.
  - **Emil Kowalski:** `emil-design-eng`, `apple-design` ve `review-animations`.
- Kaynaklar, commit kodları ve lisanslar `.claude/skills/KAYNAKLAR.md` dosyasında.
- Impeccable'ın ikili dosya indiren başlatıcısı güvenlik nedeniyle kurulmadı.
- Sleek ücretli bir API'ye bağlı olduğu için seçilmedi.
- **Eleştiri yapıldı** (`docs/TASARIM_ELESTIRISI.md`):
  - Puan: 27/40.
  - Karar: "kategoriden bağımsız", yani dergi kostümü giyen bir şablon.
  - Ana sorunlar: 101 büyük harfli küçük başlık, bilgi taşımayan numaralar, yer tutucu kapaklar, dört kez tekrar eden "büyük sayı" şablonu, slogan metinler.
  - Dedektör çalışmadı; eleştiri ekran görüntüleri ve kod sayımıyla yapıldı.

### Yeniden tasarım: kişisel defter (1. adım, Keşfet)

Kullanıcının kararları:
- Konsept: kişisel defter.
- Fotoğraf yoksa kapak gösterilmeyecek.
- Eleştirideki 5 sorunun hepsi düzeltilecek; önce Keşfet'te denenecek.

Yapılanlar:
- **Küçük başlıklar:** Büyük harf ve harf aralığı kaldırıldı; cümle düzeninde ve soluk renkte. Değişiklik tek bileşende (`Eyebrow`) yapıldığı için bütün ekranlara yayıldı.
- **Düğmeler, bağlantılar ve seçim kutuları:** Cümle düzenine geçti. Bağlantıların dokunma alanı en az 44 pt.
- **Numaralar:** `SectionRule` silindi; yerine Bodoni bölüm başlığı (`SectionTitle`) geldi. Mekân satırlarından ve liste kartlarından sıra numarası kaldırıldı.
- **Kapaklar:** Çizilmiş baş harf ve simge karoları silindi. `PlaceCover` artık yalnızca gerçek fotoğrafı gösteriyor. Liste kartlarındaki kapak şeridinin yerine durak adları geldi ("Kahve Durağı → Fırın Kırıntı").
- **Keşfet:**
  - Künye, slogan ve arama düğmesi kaldırıldı.
  - Üstte saate göre selam ("İyi akşamlar, Semih.") ve defterin tek cümlelik özeti var ("Defterinde 3 mekân var; 2 tanesine henüz gitmedin. Bu hafta 1 yeni yer ekledin.").
  - "Bu hafta" sayı tablosu cümleye döndü.
  - Öneri kartında mekânın notu italik olarak öne çıkıyor.
  - "+ Mekân ekle" bağlantısı eklendi.
- **Testler:** Büyük harfli metin arayan testler güncellendi; `place_cover_test` silindi. 69 test geçiyor, `dart analyze` temiz.
- Kalanlar bir sonraki adımda yapıldı (aşağıda).

### Yeniden tasarım: kişisel defter (2. adım, bütün ekranlar)

- **Sayı tabloları cümleye döndü:**
  - Mekân künyesi: "1 kez gittin, en son 14 Eylül 2026. Ortalama karnen 3,8. 67 gündür defterinde."
  - Profil: "Defterinde 3 mekân, 1 deneyim ve 1 rota var."
  - Yıl özeti: "Bu yıl 3 mekân keşfettin, 1 deneyim yazdın, 1 rota çizdin."
  - Sayan sayılar (`CountUp`) kaldırıldı.
- **Başlık üstü etiketler kaldırıldı:** 10 sayfa başlığının üstündeki küçük etiket ("Kişisel profil", "Küratörün sen ol" gibi) silindi. Profildeki baş harf kutusu da kaldırıldı.
- **Sloganlar kaldırıldı:** "Bir semt, bir lezzet, bir hikâye", "Küratör" ve "hikâyen" gibi metinlerin yerine düz cümleler geldi. Açıklaması olmayan listelerde yer tutucu metin gösterilmiyor.
- **Diğer küçük düzeltmeler:**
  - Büyük ilk harf (`InitialText`) silindi.
  - Gidişat çizgisi artık en az 3 puanlı ziyaret olunca gösteriliyor.
  - İç bağlantılardaki `↗` ve `→` okları kaldırıldı; satır sonlarında `›` var.
  - Arama sonuçlarındaki sıra numarası kaldırıldı. Numara yalnızca rota duraklarında kaldı.
- **Mekân sayfası:**
  - "Deneyim ekle" deneyimlerin üstüne taşındı.
  - Ad italik değil; altında adres ve tür var.
- **Kullanılmayan kod silindi:** Kapak tonları (`tintGold`, `tintTeal`, `tintSand`) ve `CountUp`.
- **Belgeler:**
  - `DESIGN.md` "kişisel defter" kurallarına göre yeniden yazıldı. Lint sonucu: 0 hata; uyarı sayısı öncekiyle aynı.
  - `CLAUDE.md` güncellendi.
- **Kontrol:** 69 test geçiyor, `dart analyze` temiz.

### Eleştirinin ikinci turu

- Uygulama iPhone 17 simülatöründe yeniden açıldı.
- Eleştiri tekrarlandı: puan **27/40 → 29/40**. Ayrıntılar `docs/TASARIM_ELESTIRISI.md` dosyasının "İkinci tur" bölümünde.
- Kalan sorunlar: sıfırlı cümleler, liste sayfasında eylem yığını, imza öğesi eksikliği, genel simgeler.

### İkinci tur düzeltmeleri

- **Sıfırlı cümleler:**
  - `joinTr` ("a, b ve c") ve `countsTr` yardımcıları eklendi; sıfır olan sayılar cümleye yazılmıyor.
  - Profil artık "Defterinde 2 mekân ve 1 rota var." diyor.
  - Etkilenen diğer yerler: yıl özeti, ayarlar ve Arşiv satırları ("0 deneyim" yazmıyor).
- **Liste sayfası:**
  - Sıra değişti: başlık, açıklama, "Listeyi düzenle", duraklar ve en altta "Paylaş" bölümü.
  - Tek altın düğme var: liste özelken "Kapak görseli olarak paylaş", değilse "Yayınla ve paylaş" (kapak paylaşımı bağlantıya döner).
  - Başlık üstündeki şehir etiketi kaldırıldı.
- 70 test geçiyor, `dart analyze` temiz.

### İmza öğesi: lezzet izi ve defter kenarı

Kullanıcı önerilen iki imzayı birlikte seçti.

- **Lezzet izi:**
  - Yeni dosya `features/journal/widgets/taste_mark.dart`. Tadım karnesinin dört ölçütü, her biri beş karelik bir satır olarak çiziliyor.
  - Model tarafında `TastingScores.averageOf` mekânın bütün ziyaretlerinin ölçüt ortalamasını hesaplıyor.
  - Mekân satırlarında adın yanında küçük görünüyor; mekân sayfasında ölçüt adları ve puanlarıyla büyük.
  - Ekran okuyucu "Lezzet izi, Lezzet 4, Servis 3…" diye okuyor.
- **Defter kenarı:**
  - `MarginNote`, kullanıcının kendi yazdığı metnin soluna çift ince altın çizgi koyuyor.
  - Kullanıldığı yerler: mekân notu, deneyim başlığı ve notu, öneri kartındaki not ve listedeki notlar (`NoteQuote`).
  - Mekân notu italik Bodoni oldu.
- DESIGN.md'ye iki bileşen işlendi.
- `test/taste_mark_test.dart` eklendi. 72 test geçiyor, `dart analyze` temiz.

### Örnek deneyimler ve eleştirinin üçüncü turu

- **Örnek deneyimler:** Simülatördeki deftere kullanıcının isteğiyle 4 örnek deneyim eklendi; 3'ü Kahve Durağı'na, 1'i Fırın Kırıntı'ya, karneleriyle birlikte. Yalnızca simülatör verisi değişti, depoda değil. Eski defterin yedeği scratchpad klasöründe `journal.yedek.json` olarak duruyor.
- **Eleştiri:** Puan **30/40** oldu. Özgünlük kararı artık "özgün". 40'a giden yol tablosu `docs/TASARIM_ELESTIRISI.md` dosyasının "Üçüncü tur" bölümünde.

### 35–36 planı (`docs/TASARIM_PLANI.md`)

Kullanıcı eleştirideki maddelerin hepsini onayladı ve sırayı Claude'a bıraktı. Plan altı adım: dil birliği, ipuçları, geri alma ve uyarı, yedek durumu, hızlı eylemler, görsel son dokunuş.

- **1. Dil birliği (tamamlandı):**
  - "Tadım karnesi" her yerde "karne" oldu.
  - `relativeIsoDateTr` eklendi: "Bugün", "Dün", gün adı, "Geçen salı"; daha eskisi tam tarih.
  - Mekân sayfasındaki deneyim tarihleri ve künye cümlesi ("en son dün") göreli yazılıyor.
  - Etkinlik ekranı ve form tam tarihte kaldı.
  - 73 test geçiyor.
- **2. Kısa ipuçları (tamamlandı):**
  - `features/hints/hints.dart`: kapatılan ipuçları `hints.json` dosyasında saklanıyor. `HintNote` bir kez gösterilip "Anladım" ile kapanıyor.
  - Keşfet'te karnesi olan bir mekân görününce lezzet izinin ne olduğunu anlatan tek seferlik bir not çıkıyor.
  - Satırdaki küçük ize dokununca ayrıntısı görünüyor: "Lezzet izi, Lezzet 4, Servis 3…".
  - Deneyim formunda karnenin altına tek cümlelik açıklama eklendi.
  - Ayarlar'a "Gurme nasıl çalışır" bölümü eklendi (defter, karne, lezzet izi, altın kenar, rota). Ayarlar'ın bölümleri de yeni başlık düzenine geçti.
  - `test/hints_test.dart` eklendi. Test yardımcısına `hints` parametresi eklendi; aynı sağlayıcı iki kez geçersiz kılınınca uygulama boş açılıyordu. 75 test geçiyor.
- **3. Geri alma ve kaydedilmemiş form uyarısı (tamamlandı):**
  - `deletePlace`, `deleteVisit` ve `setStatus` artık geri alma işlevi döndürüyor. Geri alınan kayıt eski yerine dönüyor (mekânın deneyimleri ve rotadaki sırası dahil); aradaki başka değişikliklere dokunulmuyor.
  - Bilgi çubuğu teması eklendi (mürekkep zemin, altın "Geri al"); yardımcıları `showUndo` ve `showNotice`.
  - Deneyim silmede onay penceresi kaldırıldı, yerine "Geri al" geldi. Mekân silmede onay penceresi kaldı, "Geri al" eklendi. "Gideceğim" seçilip öneri kalkarsa da "Geri al" çıkıyor.
  - `core/widgets/discard_guard.dart`: mekân, deneyim, liste ve profil formları değişmişse çıkışta soruyor. Değişmemiş formda iOS'taki kenardan kaydırarak geri dönme hareketi çalışmaya devam ediyor.
  - Hata düzeltmesi: başlıktaki geri düğmesi `context.pop()` kullandığı için `PopScope`'u atlıyordu; artık `maybePop` kullanıyor.
  - `test/undo_test.dart` eklendi (4 test). 79 test geçiyor.
- **4. Yedek durumu ve kayıt onayları (tamamlandı):**
  - Profilde, defter cümlesinin altında yedek durumu görünüyor. Olası metinler: "Defterin yalnızca bu cihazda.", "Yedekleniyor…", "Son yedek: 5 dk önce." ve hata varsa kırmızı "Son yedekleme başarısız oldu." ile "Tekrar dene".
  - Hesap ekranı da aynı cümleyi (`backupLine`) kullanıyor. Göreli saat için `relativeTimeTr` eklendi.
  - Kayıt onayları eklendi: mekân, deneyim, liste ve profil kaydedilince altta kısa bir bilgi ("Deneyim kaydedildi.", "Deftere eklendi." gibi) çıkıyor.
  - 81 test geçiyor.
- **5. Hızlı eylemler (tamamlandı):**
  - Arşiv'de bir satırı sağa kaydırınca durumu değişiyor ("Gittim" ya da "Gideceğim"); sola kaydırınca mekân siliniyor. İkisinde de "Geri al" çıkıyor. Yayınlanmış bir rotadaki mekân kaydırılarak silinmiyor, önce uyarı gösteriliyor.
  - Mekân satırına uzun basınca kısa bir menü açılıyor: Deneyim ekle, Listeye ekle, Haritada aç, Mekânı düzenle. Menü açılırken hafif bir titreşim var.
  - `test/quick_actions_test.dart` eklendi. 84 test geçiyor.
- **6a. Dynamic Type (tamamlandı):**
  - Ekran testleri artık her ekranı normal yazı boyutunda ve 2 kat büyük yazıyla çiziyor; toplam 28 ekran testi var. Hiçbir ekranda taşma yok.
  - Bulunan sorunlar ve düzeltmeleri:
    - Uzun bölüm başlıkları sağdaki ekle sıkışınca kelimenin ortasından bölünüyordu ("Deneyimleri / n"). `SectionTitle` artık sığmayan eki alt satıra indiriyor.
    - Düğme, seçim kutusu ve onay satırı simgeleri yazıyla birlikte büyüyor.
    - "GURME" logosu sistem yazı boyutuyla büyümüyor.
  - Yazı büyütmesi, denenmiş olan 2 kat sınırında tutuluyor (`MediaQuery.withClampedTextScaling`).
- **6b. Gece modu (tamamlandı):**
  - `GurmePalette` (gündüz ve gece) bir tema uzantısı olarak eklendi; ekranlar renkleri `context.colors` üzerinden alıyor. 28 dosyadaki sabit renkler bir betikle palete çevrildi; etkilenen `const` ifadeleri kaldırıldı ve `dart fix` ile geri konabilenler geri kondu.
  - Gece kâğıdı #152024, yazı #ECE7E1. Bütün metin renkleri kontrast eşiğini geçiyor.
  - Uygulama cihazın gündüz/gece ayarını izliyor. Paylaşılan yıl özeti görseli gece de gündüz renginde çiziliyor.
  - Bulunup düzeltilen hatalar:
    - Flutter tema yazı stillerine kendi rengini eklediği için altın düğmelerin yazısı gece açık renk çıkıyordu. Düğme artık yazı stilinden yalnızca yazı tipini alıyor; rengi düğmeden geliyor (`onGold`).
    - Bölüm başlığındaki ekler sağa yaslanmıyordu; bağlantılar tüm genişliği kaplıyordu.
  - Kullanılmayan `activeColor` parametresi kaldırıldı.
  - Ekran testleri her ekranı üç biçimde çiziyor: normal, 2 kat yazı ve gece (42 ekran testi). Toplam 112 test geçiyor.
  - DESIGN.md'ye tema tablosu eklendi; CLAUDE.md'deki renk kuralı güncellendi.
- **6c. Kendi simge setimiz (tamamlandı):**
  - `core/widgets/gurme_icons.dart` eklendi: 24 birimlik ızgarada, 1,5 birim çizgili, kare uçlu ve sivri birleşimli 9 simge. Paket eklenmedi, `CustomPainter` ile çiziliyor.
  - Simgeler: pusula, büyüteç, ayraç, rota, kişi, giriş, yıl özeti (lezzet izinden bir parça), zaman çizelgesi, çan.
  - Alt sekme çubuğunda seçili sekmenin simgesi dolu çiziliyor. Profil satırları da bu simgeleri kullanıyor.
  - `test/gurme_icons_test.dart` eklendi; `GURME_COVER_DIR` verilirse simge sayfasını kaydediyor. 113 test geçiyor.
- **6d. Teknik denetim (Impeccable `audit`) ve düzeltmeler:**
  - Rapor `docs/TASARIM_DENETIMI.md` dosyasında; puan 14/20, düzeltmelerden sonra tahminen 16/20.
  - Düzeltilenler:
    - iPad ve yatay ekranda içerik 640 pt genişlikte ortalanıyor.
    - Uyarı pencereleri iOS'ta sistem görünümünde açılıyor.
    - Küçük fotoğraflar gösterildikleri boyutta çözülüyor.
  - Ekran testlerine iPad çeşidi eklendi: 14 ekran × 4 çeşit = 56 ekran testi. Toplam 127 test geçiyor.
- **Eleştirinin dördüncü turu:** Puan **36/40**. Planın hedefi (35–36) tuttu.

### Kapsamlı denetim ve gece modu ayarı

Kullanıcının isteği: puanı dürüst ölçümle 35'in üstüne taşımak, gece modunu açılıp kapanan bir ayar yapmak, gece modundaki sorunları bulmak ve uygulamayı kapsamlı bir denetimden geçirmek. Önceki 36/40 puanının iyimser olduğu kabul edildi; temkinli yeniden değerlendirme 32/40.

- **Gece modu sorunları:**
  - Bulma yöntemi: `test/overlays_test.dart` eklendi. Hızlı ekleme sayfası, uzun basma menüsü, geri al çubuğu, onay penceresi, tarih seçici ve ipucu gündüz, gece ve iOS'ta çiziliyor.
  - Perde: mürekkep %25 olarak tanımlıydı ve mürekkep gece açık renk olduğu için sayfayı karartacağına grileştiriyordu. Palete `scrim` eklendi.
  - Tarih seçici Material 3'ün yuvarlak köşeli varsayılan görünümündeydi; köşesiz tema eklendi. Pencere ve alttan açılan sayfa temaları da eklendi.
  - Yıl özeti gece modunda parlak bir blok gibi duruyordu. Artık temaya uyuyor; paylaşılacak gündüz kopyası görünenin altında çiziliyor ve görsel o kopyadan alınıyor.
  - Liste kapağı 2 kat yazıda taşıyordu; kapak sabit boyutlu bir görsel olduğu için yazı büyütmesinden muaf tutuldu.
- **Gece modu ayarı:** Ayarlar > Görünüm: Cihaza uy / Gündüz / Gece. Tercih `appearance.json` dosyasında saklanıyor. Test dosyası: `test/appearance_test.dart`.
- **Denetim bulguları ve düzeltmeler:**
  - Formlarda başlık üstü etiketler kaldırıldı. Mekân formu düzenleme modunda bile "Defterine yeni bir adres" diyordu, düzeltildi. "Küratör" dili ve alan adlarındaki "*" işaretleri kalktı.
  - Listeler'deki "Keşfet" alt sekmesi ana sekmeyle karışıyordu; adı "Herkese açık" oldu. Sekmeler eşit genişlikte ve 44 pt.
  - Arşiv filtreleri kesilmek yerine alt satıra iniyor.
  - Karne puanı ölçeğiyle yazılıyor ("5 üzerinden 3,8"). Satırdaki lezzet izinin yanında ortalama var; izin dokunma alanı büyütüldü.
  - Simge seti 31 simgeye çıktı; uygulamada marka simgeleri dışında hazır simge kalmadı.
  - iOS'ta Cupertino tarih seçici ve sistem uyarı penceresi kullanılıyor.
  - İlk açılışta Keşfet'te "Gurme nedir" notu çıkıyor. Kaydırma eylemleri Keşfet satırlarına da eklendi.
  - `GurmePage` tembel çizime geçti (`CustomScrollView` ve `SliverList`).
- 149 test geçiyor, `dart analyze` temiz.

### Bağımsız ölçüm

- Özellik turu yayımlandı (claude.ai artifact, "Gurme özellik turu"): her özellik gündüz ve gece ekran görüntüsüyle.
- Bağımsız ajan puanı **29/40** verdi. Ayrıntılar `docs/TASARIM_ELESTIRISI.md` dosyasının beşinci turunda.
- Hedef olan 35'e ulaşılamadı. Benim kendi puanlarım (36 ve temkinli 32) bağımsız ölçümün üstündeydi.

### Bağımsız eleştirinin bulgularının düzeltilmesi

- **Kontrast:** Palete `control` rolü eklendi (gündüz #688A8F, 3,3:1; gece #6A8489, 4,2:1). Seçilmemiş kutular, ikincil düğmeler, metin alanı çizgileri ve boş karne kareleri artık bu renkte. Satırdaki lezzet izinin boş kareleri çerçeveli.
- **Gece modu:** Arşivdeki kaydırma arka planı artık `raised` ve `onRaised` renklerinde; gece parlak blok oluşmuyor.
- **Terimler:**
  - Arayüzde her yerde "liste" kullanılıyor: "Listelerin", "Şehrinden bir liste", "İlk listeni oluştur", profilde "1 liste". Liste kapağındaki "KÜRATÖR ROTASI" yazısı "GURME LİSTESİ" oldu.
  - Durum etiketleri düğmelerle aynı: "Gittim" ve "Gideceğim".
- **Büyük yazı:**
  - Seçenek kutusundaki küçültme (FittedBox) kaldırıldı. Yazı 1,2 katın üstündeyse yan yana seçenekler ve öneri kartının düğmeleri alt alta diziliyor.
  - Karne kutuları büyütüldü; dokunma alanı 44 pt. Bağlantıların en küçük genişliği de 44 pt.
- **Arama:** Girişsiz kullanıcıya formun üstünde "Yapay zekâ araması için giriş gerekir" notu ve "Giriş yap" bağlantısı gösteriliyor.
- **Liste sayfası:**
  - Durak notu artık satırın içinde, ayırıcı çizginin üstünde.
  - Sıralama iki seçenekli bir seçim: "Senin sıran" / "A–Z".
  - Bölüm başlığı "Mekânlar".
- **Uzun basma menüsü:** "Listeye ekle" doğrudan liste seçiciyi açıyor.
- **Ekran okuyucu:** Kaydırma eylemleri özel eylem olarak sunuluyor ("Gittim olarak işaretle", "Sil").
- **Diğer:**
  - Karşılama notunda Türkçe tırnak kullanıldı.
  - Yıl özetinde tek tür varsa "%100" çubuğu yerine cümle yazılıyor.
  - Başlık çubuğu 62 pt'den 52 pt'ye indi.
  - Seçenek satırlarında kutular eşit yükseklikte.
- 151 test geçiyor.

### İkinci bağımsız ölçüm

- İkinci bağımsız ajan **30/40** verdi; bir önceki bağımsız ölçüm 29/40 idi. Bulgular `docs/TASARIM_ELESTIRISI.md` dosyasının altıncı turunda.
- Gözlem: Bu değerlendirici 4 puanı çok seyrek veriyor. Önceki turun bütün bulguları düzeltildiği halde puan yalnızca 1 arttı, çünkü her tur yeni ve daha küçük sorunlar buluyor.

### İkinci bağımsız ölçümün bulgularının düzeltilmesi

Kullanıcı ilk seçeneği seçti: bulgular düzeltilsin, puan hedef olarak kalsın ve sonraki büyük adımda (Firebase kurulduktan, gerçek fotoğraflar eklendikten sonra) yeniden ölçülsün.

- **Mekân durumu:**
  - Ortak `SegmentRow` bileşenine geçti; büyük yazıda seçenekler alt alta diziliyor.
  - Seçili duruma yeniden dokunmak bir şey yapmıyor.
  - Her durum değişikliğinden sonra "Geri al" çıkıyor.
- **Ekran okuyucu:** `CheckRow` işaretli olup olmadığını duyuruyor (`Semantics(checked)`); `LinkLabel` bağlantı olarak duyuruluyor.
- **Bildirimler:** Çalışmayan bildirim sayfası, rotası ve profil satırı kaldırıldı.
- **Arama:**
  - Giriş sistemi açıkken ve kullanıcı girmemişse ana düğme "Giriş yap ve ara" oluyor. Firebase kurulmamışken arama girişsiz çalışmaya devam ediyor.
  - Kota metni tek cümle: "günlük arama hakkın sınırlıdır".
- **Gece modu:**
  - Bağlantı alt çizgisi `control` renginde.
  - Gece ayırıcı rengi #3F565B oldu.
  - İzdeki boş karelerin çerçevesi kalınlaştı.
- **Diğer:**
  - Sayfa başlıkları sekme adlarıyla aynı: "Arşivim", "Listelerim".
  - Yıl özetinde tek semt varsa grafik yerine cümle yazılıyor; tür adı cümle içinde küçük harfle geçiyor.
  - Selamı tekrarlayan "Bu akşam" etiketi ve kullanılmayan `partOfDayTr` kaldırıldı.
- 151 test geçiyor, `dart analyze` temiz.

## 14 Ekim 2026

### Google Cloud ve Firebase kurulumu (kullanıcı, ayrı oturumda)

Kullanıcının raporu (gizli değerler hariç):
- **Google Cloud:**
  - Proje `gurme-511606`; faturalandırma bağlı, 300 $ deneme kredisi var.
  - Aylık ₺1.000'lik bütçe tanımlı; uyarılar %50, %90 ve %100'de geliyor.
- **Places API (New):**
  - Açık. Anahtar `gurme-places-server` yalnızca Places API (New)'u çağırabiliyor.
  - Günlük kota deneme hesabında düzenlenemedi. Yerine, 24 saatte 1.000 isteği aşınca gelen bir e-posta uyarısı kuruldu.
- **Yapay zekâ:** Gemini anahtarı ücretsiz katmanda. DeepSeek anahtarı açıldı; bakiye yüklenmedi.
- **Neon Postgres:** Proje `gurme` (Frankfurt). 9 tablo oluşturuldu.
- **Firebase:**
  - Blaze planında; iOS ve Android uygulamaları `com.gurme.gurme`.
  - E-posta ve Google girişi açık; Apple açılmadı.
  - App Check yapılmadı. Storage bucket'ı US-EAST1'de, kurallar henüz yüklenmedi.

### Sunucuda Places koruması

- **Günlük sınır:** `search/places-budget.ts` eklendi. Google Places'e günde en fazla `PLACES_DAILY_LIMIT` istek gidiyor; varsayılan 100, gün Türkiye saatine göre.
  - Arama, konum bulma, mekân ayrıntısı ve otomatik tamamlama aynı sayacı paylaşıyor.
  - Sınır dolunca Google'a istek gitmiyor. Arama 503 ve `places_budget` koduyla "yarın yeniden dene" diyor; otomatik tamamlama boş dönüyor.
  - Sayaç bellekte olduğu için Cloud Run `--max-instances=1` ile çalıştırılmalı.
- **Bulunan hata:** Serbest yazılan semt için sunucu Geocoding API'yi çağırıyordu, ama anahtar yalnızca Places'e izinli; bu çağrı reddedilecekti. Konum bulma artık Places Text Search ile yapılıyor.
- **Testler:** `places-budget.test.ts` eklendi. Sunucunun 28 testi geçiyor, tip kontrolü temiz.
- **Firebase CLI:** Storage kurallarını yükleyebilmesi için `artifacts/app/firebase.json` ve `.firebaserc` (proje `gurme-511606`) eklendi.

### Firebase bağlandı, sunucu Cloud Run'da

- **Firebase:**
  - `flutterfire configure` çalıştı; iOS ve Android uygulamaları `gurme-511606`'ya bağlı. macOS Ruby 2.6 için `xcodeproj` 1.25.1 kullanıcı klasörüne kuruldu, çünkü yeni sürümü derlenemeyen `nkf` istiyor.
  - Storage kuralları `firebase deploy --only storage` ile yüklendi.
- **Google ile giriş (iOS):**
  - `Info.plist`'e `REVERSED_CLIENT_ID` ve kodlanmış uygulama kimliği şemaları eklendi.
  - Girişten dönüşte "Page Not Found" çıkıyordu: OAuth dönüş adresi go_router'a gidiyordu. `FlutterDeepLinkingEnabled=false` (iOS) ve `flutter_deeplinking_enabled=false` (Android) ayarlandı; go_router'a tanınmayan adreste Keşfet'e dönme eklendi.
- **Doğrulama:** Google girişi, kalıcı oturum ve bulut yedeği ("Son yedek: 8 dk önce") simülatörde gerçek Firebase ile doğrulandı.
- **Secret Manager:**
  - Beş gizli değer var: `DATABASE_URL`, `GOOGLE_PLACES_API_KEY`, `GEMINI_API_KEY`, `DEEPSEEK_API_KEY`, `ADMIN_API_KEY`.
  - Her biri biçim ve gerçek istekle denendi. Değerler hiçbir yerde gösterilmedi.
  - `DATABASE_URL` `sslmode=verify-full` ile güncellendi.
- **Cloud Run:**
  - `gurme-api` hizmeti `europe-west3` bölgesinde: https://gurme-api-816165382305.europe-west3.run.app
  - Ayarlar: en az 0, en fazla 1 kopya; 512 MiB bellek. Gizli değerler Secret Manager'dan geliyor. Ortam değişkenleri `FIREBASE_PROJECT_ID`, `APP_CHECK_ENFORCE=false` ve `PLACES_DAILY_LIMIT=100`.
  - İmaj Cloud Build'de derleniyor (`artifacts/api-server/cloudbuild.yaml`). Yüklenen dosyalar `.gcloudignore` ile sınırlı.
  - `/api/healthz` 200 dönüyor; girişsiz arama 401 `auth_required`.
- **Uygulama:** `--dart-define=API_BASE_URL=https://gurme-api-816165382305.europe-west3.run.app/api` ile çalışıyor.

### İlk gerçek arama ve Firebase ayar dosyaları

- **İlk gerçek arama:** Kullanıcı simülatörde canlı sunucuyla arama yaptı. İlk 3 mekânın yorum analizi hemen geliyor, diğerleri mekân açılınca analiz ediliyor; bu, maliyeti sınırlamak için bilerek böyle tasarlandı. Kullanıcı bir sorun görmedi.
- **Firebase ayar dosyaları depoya alındı:** Kullanıcı önerimi onayladı; Firebase'in önerdiği yol bu.
  - Alınan dosyalar: `firebase_options.dart`, `GoogleService-Info.plist`, `google-services.json`, Gradle ve Xcode değişiklikleri, `Info.plist` adres şemaları.
  - İçerikleri yalnızca istemci yapılandırması.
  - ROADMAP'teki gizli değer kuralına bu istisna yazıldı.

### Üçüncü bağımsız ölçüm

- **Hesap ekranı:** Başlık sabit "Hesabın"; e-posta normal boyutta yazılıyor (`fe8957d`).
- **Ölçüm:** Üçüncü bağımsız ajan **30/40** verdi. Seyir 29 → 30 → 30; puan bu değerlendiricide 30'da duruyor. Bulgular `docs/TASARIM_ELESTIRISI.md` dosyasının yedinci turunda.

### Üçüncü bağımsız ölçümün bulgularının düzeltilmesi

- **Seçenek satırı:** `SegmentRow` en uzun kelimeyi gerçek yazı tipiyle ölçüyor; kutuya sığmıyorsa seçenekler alt alta diziliyor. Kapaktaki "Mürekke/p" bölünmesi böylece düzeldi. Test dosyası: `test/segment_row_test.dart`.
- **Gece seçili kutu:** Krem değil `raised` zemin, kalın açık kenar ve ✓; altın ana eylemle yarışmıyor.
- **Giriş kapalı derleme:** "Giriş yap" satırı gösterilmiyor; Ayarlar'da da giriş yerine dosyaya dışa aktarma öneriliyor.
- **Deneyim formu:** "Bu deneyime göre öneriyorum" ve altında "mekân da önerdiklerine eklenir" açıklaması.
- **Mekân sayfası:** "Deneyimi düzenle" artık `LinkLabel`.
- **Arşiv:** Kaydırma ve uzun basma kalıcı bir satırda yazıyor.
- **Lezzet izi:** Kareleri yazı boyutuyla büyüyor.
- **Liste kapağı:** Cümle düzeninde yazılıyor; "NO. 01" ve büyük harfler kalktı; "durak" yerine "mekân" kullanılıyor.
- **Test süresi:** `flutter test` paket güncellemesinde ağda takılabiliyor; `--no-pub` ile çalıştırılmalı.
- 153 test geçiyor.

### 35 planı, adım 1: fotoğraflı görüntü seti

- **Lisanslı fotoğraflar:** Wikimedia Commons'tan üç fotoğraf alındı. Lisanslar CC0 ve CC BY 2.0; "aynı lisansla paylaş" (SA) şartı olanlar bilerek seçilmedi.
  - Fotoğraflar `test/fixtures/photos/` klasöründe, 800 piksele küçültülmüş halde: kahve, simit, lahmacun.
  - Kaynaklar ve yazarlar `LICENSE.md` dosyasında. Fotoğraflar uygulamayla dağıtılmıyor; yalnızca testlerde kullanılıyor.
- **Örnek defter:** Üç mekânın da fotoğrafı var. Görüntü setinde artık Keşfet'teki öneri kartında, satırlarda ve mekân sayfasında fotoğraf görünüyor.
- **Test tuzağı:** Widget testlerinde dosyadan görsel yükleme "sahte zaman" içinde başladığı için hiç bitmiyor ve `pumpAndSettle` sonsuza kadar bekliyordu.
  - Çözüm: Fotoğraflar `setUpAll` içinde gerçek zamanda çözülüyor; `photoImageOverrideProvider` ile eşzamanlı veriliyor.
  - Uygulama normalde yine dosyadan okuyor.
- 153 test geçiyor.

### 35 planı, adım 1 ve 2: durum görüntüleri ve hata ekranları

- **`test/states_test.dart`:** Görüntü setinde bulunmayan 9 durumu çiziyor ve her birinde beklenen metni doğruluyor. Kaydedilen dosyalar `durum-*.png`.
  - Girişli hesap.
  - Profilde yedekleniyor ve yedek hatası.
  - Girişsiz arama.
  - Kota doldu, Places sınırı doldu, ağ yok, sunucu hatası ve sonuç yok.
- **Testlerde giriş ve yedek:** `FakeAuthService` ortak yardımcılara taşındı ve başlangıç kullanıcısı alabiliyor. Yedek durumu sabit bir denetleyiciyle veriliyor.
- **Hata ekranları:**
  - Sunucuya hiç ulaşılamazsa `network` kodu dönüyor ve "İnternete bağlanılamadı." deniyor; aranan kelime ve filtreler yerinde kalıyor.
  - Places sınırında "Arama bugünlük durdu." gösteriliyor.
- **Görüntülerden çıkan kusurlar düzeltildi:**
  - Boş durum düğmesi her eylemde "+" simgesi taşıyordu.
  - Ağ hatası ekranında iki altın düğme vardı. Arama ekranındaki hata ve boş sonuç düğmeleri artık ikincil; `EmptyState`'e `icon` ve `secondary` parametreleri eklendi.
- 162 test geçiyor.

### 35 planı, adım 3 ve 4: hata önleme ve geri alma

- **Form denetimi:**
  - Mekân, deneyim ve liste formlarında gerekli alan boşken kayıt düğmesi pasif kalıyor ve altında nedeni yazıyor; örneğin "Kaydetmek için mekânın adını yaz.".
  - Bunun için yeni `SaveButton` bileşeni eklendi. Eskiden basınca uyarı çıkıyordu.
- **Gelecek tarih:** Deneyim tarihi bugünden ileri seçilemiyor.
- **Yinelenen mekân:**
  - Arama sonucu artık elle eklenmiş, aynı adlı kayıtla da eşleşiyor (`JournalData.placeForVenue`).
  - Defterdeki mekânların sonuç kartında "Defterinde" yazıyor.
- **Geri al:**
  - Liste silme: yalnızca bu cihazdaki liste için. Yayınlanmış liste sunucudan da silindiği için geri alınamıyor ve onay penceresi bunu söylüyor.
  - Liste formunda mekân çıkarma: mekânın notu da geri geliyor.
  - Deneyim formunda fotoğraf kaldırma.
- 165 test geçiyor.

### 35 planı, adım 5: defter portresi

- **Profil artık bir portre.** Bölümün adı "Defterinden"; içeriği deneyimlerden hesaplanıyor (`NotebookPortrait`):
  - En sık gidilen tür, en çok bulunulan semt ve en çok önerilen mekân. Telefonda iki sütun, büyük yazıda tek sütun.
  - Lezzet izleri kolajı: karnesi olan mekânlar, son gidilen önce, en çok 6 tane. Her biri mekân sayfasına gidiyor.
  - Son deneyim: defter kenarıyla başlığı, mekânı, göreli tarihi ve notu.
  - Deneyim yoksa portrenin nasıl oluşacağını anlatan tek bir cümle gösteriliyor.
- **Tekrar eden cümle:** "Defterinde 3 mekân…" profilden ve Ayarlar'dan kaldırıldı; yalnızca Keşfet'te duruyor.
- **Örnek defter:** İki deneyim eklendi; Kahve Durağı'na ikinci ziyaret ve Mahalle Lahmacuncusu'na ilk ziyaret. Lahmacuncu artık "Gittim" ve önerilen.
- 167 test geçiyor.

### Sekizinci turun bulguları düzeltildi

İki bağımsız ajan 29 ve 29 verdi (`docs/TASARIM_ELESTIRISI.md`, sekizinci tur). İkisinin birlikte bulduğu altı sorun düzeltildi:

1. **Yıl özeti, gece modu:** Grafikte altın yerine mürekkep tonları kullanılıyor (ink, muted, line, wash). İlk iki dilimin yazısı kâğıt renginde ve iki temada da okunuyor. Altın yalnızca ana eylemde kaldı.
2. **Liste kaydetme simgesi:** İki durumda da aynı simge çiziliyordu. Artık yer imi kullanılıyor; kayıtlıyken dolu (`Masthead.rightFilled`). İpucu metni "Kaydedilenlere ekle / çıkar".
   - Kendi listeyi "Kaydedilenler" sekmesine sabitlemek mevcut bir özellik olduğu için düğme gizlenmedi.
3. **Kota:**
   - Hak bitince "Ara" düğmesi ikincil görünüme geçiyor ama kapanmıyor, çünkü sunucu önbellekteki aramaları kota dolduğunda da döndürüyor.
   - Düğmenin altında "gece yarısı yenilenir" yazıyor.
   - Kota ekranındaki tekrar eden sunucu cümlesi kaldırıldı.
4. **DESIGN.md ihlalleri:**
   - Boş durumlardaki altın süs çizgisi kaldırıldı.
   - Yıl özetindeki "En çok önerdiğin" bloğunda italik ve turkuaz kenar kaldırıldı.
5. **Lezzet izi:** Satırlarda iz ve puan adın altına, bilgi satırının başına taşındı; ad iki satıra inse de kaymıyor. Puan ölçeğiyle yazılıyor ("4,3 / 5"); portrede de öyle.
6. **Terimler:**
   - Sayımlarda her yerde "deneyim" kullanılıyor; "ziyaret" ve "kez gittin" kaldırıldı.
   - "Yerel" etiketi "Paylaşılmadı" oldu.
   - Kural DESIGN.md'ye eklendi.

Tek ajanın bulduğu sorunlar bu turda ele alınmadı: kaydırarak silmede onay, helal seçilince alkolsüzün de seçilmesi, yedek hatasının nedeni, iOS geri oku ve iPad başlığı.

167 test geçiyor.

### Sekizinci turda tek ajanın bulduğu beş sorun

1. **Kaydırarak silme:** Deneyimi olan bir mekân sola kaydırılınca önce onay soruluyor ("Mekânı sil?"), formdaki gibi. Deneyimi olmayan kayıt eskisi gibi onaysız siliniyor; geri alma var.
2. **Filtreler:**
   - Helal'in alkolsüzü de kapsaması bilinçli bir kural (sunucu da öyle süzüyor). Artık filtrelerin altında yazıyor: "Helal seçince alkolsüz mekânlar aranır."
   - "Çölyak" etiketi "Çölyağa uygun" oldu. Glutensiz seçenekten farkı açıklanıyor; birleştirilmedi, çünkü sunucu ayrı bir sinyal (`celiacSafe`) arıyor.
3. **Yedek hatası:** Hata artık nedenini söylüyor (`backupErrorMessage`): bağlantı, oturum, kota ya da genel hata. Her durumda "Değişikliklerin cihazda duruyor." ekleniyor. Profil ve hesap ekranı aynı cümleyi gösteriyor.
4. **iOS geri işareti:** Sete `backChevron` (‹) eklendi; set 32 simge oldu. Başlık çubuğu iOS'ta bunu, Android'de oku kullanıyor.
5. **iPad başlığı:** Başlık çubuğunun çizgisi tam genişlikte; düğmeler içerik sütununun (640 pt) kenarlarına hizalanıyor.
   - İlk denemede `Stack` logo kadar daraldı ve düğmeler logonun üstüne bindi. `StackFit.expand` da logoyu sol üste itti.
   - Doğru çözüm, `Stack`'in üstündeki kutuya tam genişlik vermek oldu. Görüntüyle doğrulandı; ayrıca `test/masthead_test.dart` eklendi.

171 test geçiyor.

### Uygulamaya görsel: üç kaynak (15 Ekim 2026)

Kullanıcının gözlemi: gerçek defterinde fotoğraf olmadığı için uygulama yazıdan ibaret görünüyor. Kullanıcı üç yolu da seçti.

1. **Kendi fotoğrafın:** Mekânın kapağı yoksa deneyimlerindeki en son fotoğraf kapak oluyor (`PlaceCover.photoOf`).
2. **Çizilmiş kapak (`DrawnCover`):** Fotoğrafı olmayan mekânda defter sayfası gibi soluk satır çizgileri ve türüne göre tek çizgili bir motif çiziliyor.
   - Motifler: fincan, simit, dilim pasta, tencere, şiş, bardak, balık, tabak (`motifFor`).
   - Simge setiyle aynı çizgi dili; altın kullanılmıyor.
   - Motif sayfası: `test/drawn_cover_test.dart` → `kapaklar.png`.
3. **Google fotoğrafı:**
   - **Sunucu:** Yeni uç `GET /api/places/:placeId/photo` (`place-photos.ts`). İki istek yapıyor: önce mekânın fotoğraf listesi (yalnızca `photos` alanı), sonra fotoğrafın kısa ömürlü adresi.
   - **Bütçe:** Arama bütçesinden ayrı bir günlük sayaç var: `PLACES_PHOTO_DAILY_LIMIT`, varsayılan 200 istek, yani 100 fotoğraf.
   - **Google'ın koşulları:** Fotoğraf adı ve adresi saklanmıyor. Fotoğrafı çekenin adı fotoğrafın üstünde gösteriliyor ve profiline bağlantı veriyor.
   - **Uygulama:** Fotoğraf yalnızca atfın sığdığı büyük kapaklarda isteniyor: mekân sayfası, "Bugün ne yesem?" ve arama sonucunun mekân sayfası. Satırlarda istenmiyor.
   - **Bellek:** Sonuç oturum boyunca bellekte tutuluyor (`googlePhotoProvider`).
   - **Koşullar:** Yalnızca uygulama `API_BASE_URL` ile derlendiyse ve giriş yapılmışsa isteniyor.
- Kapak sırası: mekânın fotoğrafı → deneyimdeki fotoğraf → Google fotoğrafı (büyük kapakta) → çizilmiş kapak.
- Sunucuda 32, uygulamada 176 test geçiyor.

### Sunucu yayını: mekân fotoğrafları (15 Ekim 2026)

Kullanıcının onayıyla yeni sunucu sürümü Cloud Run'a yayınlandı.

- **İmaj:** `europe-west3-docker.pkg.dev/gurme-511606/gurme/api:b1c0b4a`. Cloud Build'de 2 dakikada derlendi.
- **Sürüm:** `gurme-api-00002-v8h`, trafiğin %100'ü.
- **Yeni ortam değişkeni:** `PLACES_PHOTO_DAILY_LIMIT=200`.
- **Doğrulama:**
  - `healthz` 200 dönüyor.
  - Fotoğraf ucu girişsiz isteğe 401 veriyor; yol karakteri içeren kimlik de reddediliyor.
  - `max-instances` 1. `PLACES_DAILY_LIMIT` 100.
  - Beş sır hâlâ Secret Manager'dan geliyor; değerleri gösterilmedi.
- **Doğrulandı (15 Ekim 2026, 11:38):** Simülatörde kullanıcının aramadan eklediği "Viyana Kahvesi Ayasofya" için "Bugün ne yesem?" kartında Google fotoğrafı çıktı; atıf "Fotoğraf: … · Google" görünüyor.
- **Önceden doğrulanmamış olan:** Girişli bir istekle gerçek bir Google fotoğrafının gelmesi.
  - Kullanıcının defterindeki iki mekân elle eklendiği için Google kaydı yok; onlarda çizilmiş kapak görünüyor.
  - Deneme yolu: Arama → bir sonuç → mekân sayfası.
- Yayın komutları `docs/ROADMAP.md` dosyasının çalışma notlarına eklendi.

### Dokuzuncu turun bulguları düzeltildi

İki bağımsız ajan 30 ve 31 verdi, ortalama 30,5 (`docs/TASARIM_ELESTIRISI.md`, dokuzuncu tur). Şunlar düzeltildi:

1. **DESIGN.md:** "Yer tutucu çizilmez" kuralı, kapak sırasını anlatan kuralla değiştirildi: mekân fotoğrafı → deneyim fotoğrafı → Google → çizilmiş kapak. Kapaklar eklenirken bu güncelleme unutulmuştu.
2. **[P1] Puan tutarsızlığı:** Mekân sayfasında ölçütler yuvarlanmış tam sayıyla yazılıyordu (4/3/5/4; ortalaması 4,0). Hemen altındaki cümle ise "ortalama 3,6" diyordu.
   - Kareler yine yuvarlanmış değeri çiziyor; yanındaki sayı artık yuvarlanmamış ortalamayı yazıyor (2,5 gibi).
   - Yeni: `TastingScores.meansOf`, `TasteMark.exact`.
3. **[P1] Büyük yazıda isim bölünmesi:** 64 pt'lik satır kapağı mekân adını kelimenin ortasından böldürüyordu ("Lahmacuncus/u"). Büyük yazıda kapak satırdan kaldırıldı.
4. **[P1] Arama sonucu ekran dışında:** Arama başlayınca ve bitince sonucun başına kaydırılıyor (`Scrollable.ensureVisible`). Hareketi azalt açıksa kaydırma animasyonsuz.
5. **Küçükler:**
   - Places sınırı dolunca "Ara" düğmesi ikincil oluyor.
   - Sınır mesajı da "gece yarısı yeniden açılır" diyor; iki sayaç da İstanbul gününe göre sıfırlanıyor.
   - "3,6. 67 gündür defterinde" yerine "Defterine 67 gün önce ekledin." yazıyor.

Ertelenenler sonraki iki bölümde düzeltildi.

178 test geçiyor.

### Ertelenen küçük sorunlar ve satır kapakları

Kullanıcının isteğiyle liste satırlarındaki küçük kapaklar kaldırıldı. Mekân sayfasındaki ve "Bugün ne yesem?" kartındaki kapaklar aynen duruyor. Satırdan sayfaya kapak geçişi (Hero) da kalktı.

Dokuzuncu turdan ertelenen küçük sorunlar:
1. **Sunucu hatası:** Kodsuz 5xx yanıtı artık `server` kodu alıyor. Ekranda "Arama şu an yapılamıyor. Sunucuda geçici bir sorun var. Birkaç dakika sonra tekrar dene…" yazıyor; sunucunun genel iletisi gösterilmiyor.
2. **Kota tekrarı:** Hak bitip arama da gelmediyse bilgi yalnızca boş durumda yazıyor ("Bugünkü 3 ücretsiz araman bitti."). Düğmenin altındaki satır o durumda gizleniyor.
3. **Girişsiz arama:** Üstteki ipucu kutusundaki "Giriş yap" bağlantısı kaldırıldı; girişe götüren tek düğme "Giriş yap ve ara".
4. **Gece kontrastı:**
   - Seçili seçenek kutusu gece turkuaz zemin ve gece kâğıdı renginde yazı (8:1).
   - Bilgi çubuğunun üstünde 2 px mürekkep çizgi var; gece zeminden ayrılıyor.
5. **Geri al süresi:** 6 saniyeden 10 saniyeye çıktı.
6. **Formlar:**
   - Mekân ve deneyim formunun başlığında onay simgeli "Kaydet" düğmesi var. Alttaki düğmeyle aynı koşulla pasifleşiyor.
   - Fotoğraf adımı yukarı alındı. Mekân formunda tanımın ardından "Kapak fotoğrafı (isteğe bağlı)" geliyor. Deneyim formunda fotoğraflar tarihin hemen ardından geliyor ve kapak olacağı yazıyor.

DESIGN.md bu kurallarla güncellendi. Arşiv satırında kapak çizilmediğini doğrulayan bir test eklendi; 179 test geçiyor.

Sunucunun kendi iletileri ("Arama sırasında bir hata oluştu.", Places sınırında "Yarın yeniden dene") değişmedi. Uygulama bunları göstermiyor; değiştirmek yeniden yayın gerektirir.

### iPad: yan menü ve liste–ayrıntı düzeni

- **Yan menü:** Ekran 600 pt ve daha genişse (iPad, yatay telefon) sekmeler alttaki çubuk yerine soldaki menüde (`NavigationRail`, `home_shell.dart`). Simgeler ve yazılar aynı; seçili sekme dolu simgeyle belli.
- **Arşiv liste–ayrıntı:** Yan menü dışında 880 pt ve daha geniş alan kalınca (yatay iPad) Arşiv iki sütun oluyor. Solda liste (380 pt), sağda seçili mekânın sayfası.
  - İlk kayıt kendiliğinden açık; satıra dokununca sayfa değişmeden sağda açılıyor (`PlaceSelection`).
  - Seçili satır soluk zemin ve solda mürekkep çizgiyle belli.
  - Sağ sütunda geri düğmesi ve logo yok; logo ekranda bir kez duruyor.
  - Ekranın ana eylemi sağdaki "Deneyim ekle"; listedeki "Mekân ekle" bu düzende ikincil.
  - Dikey iPad'de ayrıntı sütunu çok daralacağı için Arşiv tek sütun kalıyor.
- **Hata düzeltmesi:** Satır kapağı kaldırıldıktan sonra satırlar içerik kadar daralıyordu; alt çizgi yarıda kalıyordu. Satır artık tam genişlikte. Testler bunu yakalamadı, iPad ekran görüntüsünden fark edildi.
- **Simülatörde bulunanlar (iPad Pro 11 inç):** Menünün ayırıcı çizgisi durum çubuğunun içinden geçiyordu; menünün zemini de çizgiyi örtüyordu. Çizgi artık durum çubuğunun altından başlıyor ve zeminin önünde çiziliyor.
- `useTallScreen` artık telefon genişliğinde (500 pt); daha genişte sekmeler yan menüye geçiyor.
- Yeni `wide_layout_test.dart`: telefon, dikey ve yatay iPad, yan menüden sekme geçişi. 183 test geçiyor.

### Onuncu turun bulguları düzeltildi

İki bağımsız ajan 30 ve 28 verdi, ortalama 29 (`docs/TASARIM_ELESTIRISI.md`, onuncu tur). Düşüşün bir kısmı önceki bölümdeki değişikliklerden geliyordu; önce onlar geri alındı:
1. **Formdaki ikinci kaydet:** Başlıktaki ✓ kaldırıldı; kaydet yalnızca formun sonunda.
2. **Gece seçili kutu:** Açık turkuaz blok altın ana eylemle yarışıyordu. Şimdi koyu turkuaz zemin (`chosen`, #2B4F57) ve açık turkuaz kenar.
3. **Kota metni:** "Daha önce yapılmış bir arama…" cümleleri önbellek mantığını sızdırıyordu; kaldırıldı.

Sonra ortak ve önemli bulgular:
4. **Lezzet izi:**
   - Büyük yazıda ölçüt adı karelerin üstüne geçiyor; normal boyutta ad ile kareler arasında boşluk var.
   - Mekân sayfasında buçuklu puan son kareyi yarım dolduruyor (4,5 artık beş dolu kare değil).
5. **Arşiv'deki kalıcı talimat:** Bir kez gösterilen ipucuna çevrildi. Uzun basma menüsüne "Gittim/Gideceğim olarak işaretle" ve kırmızı "Sil" eklendi; kaydırma, menü ve ekran okuyucu aynı işlevleri kullanıyor (`togglePlaceStatus`, `confirmPlaceDelete`, `deletePlaceWithUndo`).
6. **Kendi listende kaydet:** Sağ üstte artık düzenle simgesi var; alttaki "Listeyi düzenle" bağlantısı kaldırıldı. "Kaydedilen" sekmesi yalnızca başkalarının listelerini gösteriyor.
7. **Alttan açılan menüler** kök gezginde açılıyor; perde sekme çubuğunu da örtüyor.
8. **Gece çizilmiş kapak:** Motif gece `muted` renginde; daha seçilir.

DESIGN.md güncellendi. Yeni testler: yarım kare, büyük yazıda üst üste düzen, menüdeki Gittim ve Sil, bir kez gösterilen hareket ipucu. 187 test geçiyor.

Ertelenen: dışa aktarılan dosyadan geri yükleme (yalnızca A'nın P1'i; ayrı iş).

## 15 Ekim 2026

### Deneyim formunda zorunlu alan kalmadı

Yalnızca "Notun" zorunluydu, ama en altta durduğu için bütün form zorunlu görünüyordu. Artık hiçbir alan zorunlu değil; başlığın altında tek satırla söyleniyor. Boş not mekân sayfasında boşluk bırakmıyor.

### Tabak puanlama

Önce tasarım tuvalinde dört ekran çizildi (deneyim formu, tabak ekle, mekân sayfası, sıralama); kullanıcı onayladı. "İdare" yerine "Fena değil" seçildi.

- **Model:** `Visit.tastedDishes` (`TastedDish`: ad, tür, genel puan 0–5, bileşenler, not, "bir daha söyleme"). Bileşen yargısı üç seçenekli (`DishVerdict`). Eski kayıtların "Ne tattın?" metni `order`'da kalıyor; formda yalnızca doluysa "Ne tattın? (eski not)" olarak görünüyor.
- **Türler:** `dishKindsFor(category)` mekânın türünden (aramada kullanılan kelime ya da elle yazılan tür) tabak türlerini seçiyor. Google verisi saklanmıyor. Yorumlardaki öne çıkanlar yalnızca mekân bu oturumdaki arama sonuçlarında varsa öneriliyor; deftere yazılmıyor.
- **Mekân sayfası:** "Bir dahaki sefere" (söylenmeyecek tabaklar, beğenilmeyen bileşenler, en beğenilen tabak) ve "Tabakların" (aynı adlı tabaklar bütün deneyimlerden toplanıyor, bileşenlerde çoğunluk yargısı ve "2/2" sayısı).
- **Sıralama:** `/dishes/:kind`; genel puana ya da tek bileşene göre. "Damak notu" en az 5 puanlı tabak ve her iki tarafta en az 2 tabak olunca çıkıyor.
- **Ortak:** `textInputDialog`, `FilterChipsRow.allLabel`.

9 yeni test (`test/dish_test.dart`, sıralama ekranı görüntü testinde). 197 test geçiyor.

Profil'e "Tabak sıralamaların" bölümü eklendi: tabak kaydı olan her tür için bir satır, en çok tabağı olandan.

Yapılmayacak (kullanıcı kararı): aramadan gelmeyen mekânlar için sunucuda isteğe bağlı yorum analizi. "Yorumlarda öne çıkanlar" yalnızca aynı oturumdaki aramadan gelen mekânlarda kalıyor.

### Simülatörde çökme: bileşen penceresi

Kullanıcı iPhone simülatöründe kırmızı hata ekranı gördü (`'_dependents.isEmpty': is not true`). Sebep `textInputDialog`: metin denetleyicisi pencere kapanır kapanmaz siliniyordu, oysa alan kapanış animasyonunda hâlâ çiziliyordu ("A TextEditingController was used after being disposed"); ardından gelen hata kırmızı ekranı açtı. Denetleyici pencerenin kendi durumuna taşındı. Hatayı yeniden üreten akış testleri eklendi (`test/dish_flow_test.dart`: pencere vazgeç/ekle, alt sayfayı dışına dokunarak kapatma, kart aç/kapa, çıkar/geri al, kaydetmeden çıkma, Profil'den sıralama). 202 uygulama testi, 32 sunucu testi ve tip denetimi geçiyor.

### On birinci turun bulguları ve yeni içerik

Kullanıcı bütün bulguların düzeltilmesini ve uygulamaya içerik eklenmesini istedi. Liste satırlarına küçük görsel (kullanıcı kaldırttı) ve üst çubuğa ikinci kaydet (önceki turda tutarsızlık sayıldı) bilerek uygulanmadı.

**Form ve tabak kartı**
- Öneri tek yerde: deneyim formundan "Bu deneyime göre öneriyorum" ve "Önerdiğin ürünler" kalktı (eski kayıtlarda dolu ise "eski not" olarak görünür, işaret korunur). "Kararsızım" yerine "Belki"; üç seçenek tek satıra sığıyor.
- Bileşenler sığdığında tek satır (`VerdictRow`): ad solda, üç küçük seçenek sağda; büyük yazıda eski alt alta düzen. Kapalı kart özeti kısaldı (tür, puan, işaretli bileşen sayısı).
- Özetlerde "1/2" yerine "2 tadımda 1 kez". Karneye "seçili kutuya yeniden dokunursan puan kalkar" eklendi.

**Arama ve Arşiv**
- Hak bitince "Ara" kapanıyor. "Sonuç yok" ekranında "Aradığın yeri biliyorsan elle ekle". Sonuç ve hatalar ekran okuyucuya duyuruluyor.
- Diyet ve durum filtreleri tek satırda yatay kaydırılıyor. Arşiv'e sıralama (son eklenen, ada göre, karneye göre) "Sırala ve süz" bölümünde.

**Gizli hareketler ve kavramlar**
- Mekân satırında "Diğer eylemler" düğmesi (yeni simge: üç kare, set 33 simge). Keşfet'teki tekrar eden hareket ipucu çıktı.
- "Gurme nasıl çalışır" ayrı rehber sayfası (`/guide`), Profil ve Ayarlar'dan. Mekân sayfasında lezzet izinin ne olduğu tek cümleyle yazıyor.
- Sayfa ve bölüm başlıkları ekran okuyucuda başlık (`PageTitle`, `SectionTitle`; `container: true`, yoksa bütün bölüm tek başlığa karışıyordu).

**Gece ve platform**
- Ayırıcı çizgi #56707A (3,2:1). Dolu puan kareleri yeni `mark` rengi (gece turkuaz). Seçili kutu iki temada dolu blok. Gece fotoğraflar %14 kısılıyor.
- `bodySmall` 13 pt. Düğmeler büyük yazıda iç boşlukla uzuyor. iOS'ta Material dokunma dalgası yok.
- Keşfet'te "Mekân ekle" Arşiv'deki gibi düğme.

**Yeni içerik**
- Tabak türleri: Döner / dürüm, Çorba, Uzak Doğu, Sandviç / tost, Salata; mekân türü eşleşmeleri genişledi.
- Keşfet'te "En sevdiğin tabaklar", yıl özetinde "Yılın tabağı".
- Rehber dört bölüm: Defter, Puanlar, Hatırlatmalar, Kısayollar.

212 test geçiyor (yeni: `test/content_test.dart`).

### On ikinci turun bulguları

Kullanıcı bütün bulguların düzeltilmesini istedi; ertelenen dosyadan geri yükleme de yapıldı.

- **Dosyadan geri yükle** (Ayarlar): `file_selector` 1.1.0 eklendi (Flutter ekibinin paketi; kendisi ve gelen üç alt paket bir aydan eski, 1 gün kuralına uyuyor). Dosyada ne olduğu gösterilip onay isteniyor, `mergeJournals` ile birleştiriliyor, "Geri al" eski defteri koyuyor. Gurme yedeği olmayan dosya açıklanıyor. Dosya seçimi `backupFilePickerProvider` üzerinden; testlerde sahte.
- **Gece seçili kutu:** `chosen` #426F7C: zeminden 3,0:1, üstündeki yazı 4,5:1; kenar eklenmedi (önceki tur "odak halkası" demişti).
- **Simgeler büyük yazıda** en çok 1,5 kat büyüyor (`iconScale`): üst çubuk, "Diğer eylemler", tabak kartı.
- **Tabak kartı** aç/kapa için yeni `expand` simgesi (dönen köşeli işaret); ↑/↓ yalnızca sıralamada. Set 34 simge.
- **"Mekân ekle"** her yerde ikincil düğme. **"Bugün gidiyorum"** harita simgesi ve ekran okuyucu ipucu taşıyor; kartın gece çerçevesi `control`.
- **Deneyim formu:** sıra tarih → karne → fotoğraf → tabaklar → başlık ve not. Yardım cümleleri yalnızca ilk üç deneyime kadar; sonra karnede tek kısa satır. Örnek metinler mekân türüne göre (`visitExamples`) ve italik. Bileşenler "Bileşenleri işaretle (n)" bağlantısının arkasında.
- **Sıralama** en az 3 tabakla (`minRankedDishes`); Profil ve mekân sayfası buna uyuyor.
- **Yıl özeti:** çubuklar `mark` rengi; "X mekâna gittin, Y yeni yeri deftere ekledin" ayrımı.
- **Profil kolajı:** kutucuk 108 pt (uzun ad kesilmiyor), altında tek satır açıklama. Satırdaki lezzet izi bir adım büyük (hücre 6).
- **Arama:** kota ve sunucu sınırı durumlarında da "elle ekle" çıkışı.
- **Rehber:** Türkçe tırnaklar, lezzet izine örnek.
- **Alt sayfalar** tutma çubuğu taşıyor.

Bilerek yapılmayanlar: girişsizken kalan arama hakkı (arama zaten girişi gerektiriyor, ipucu bunu söylüyor); haritadan dönüşte "Gittin mi?" sorusu (öneri, sorun değil).

217 test geçiyor (yeni: `test/restore_test.dart`).

### On üçüncü turun bulguları

Kullanıcı bütün bulguların düzeltilmesini istedi. Satırdaki lezzet izi için önerilen yol seçildi: iz kalıyor, yanına puan ve en güçlü ölçüt yazılıyor (`TastingScores.strongest`; eşitlikte ya da tek ölçütte yazılmaz).

- **Tabak kartı tablo oldu** (`VerdictTable`): seçenek adları bir kez sütun başlığı, satırlarda karne kutusu ölçüsünde kutular; seçili kutu `mark` dolgulu ve onaylı. Büyük yazıda eski alt alta düzen.
- **Gece tek "seçili" rengi:** `chosen` gece de `teal` (#519CAB), seçili yazı iki temada da `paper`.
- **Kelime ortasından bölünme yok** (`WordSafeText`): sayfa ve satır başlıklarında en uzun kelime sığmazsa başlık küçülüyor.
- **Seçenek şeritleri** (`ChoiceStrip`): görünmeyen seçenek varsa sağ kenar soluyor.
- **İpuçları** Keşfet ve Arşiv'de içeriğin altında.
- **Gidişat cümlesi:** "Bu mekânda puanladığın 2 deneyim: 3,5 → 3,8".
- **Terimler:** Arşiv "3 mekân", mekân sayfası "2 deneyim"; formlarda "(isteğe bağlı)" kalmadı; "Fotoğrafı kaldır" ve "Tabağı çıkar" ortak `RemoveLink` (sola yaslı, `error`).
- **Arama:** kota bitince nedeni "Ara"nın hemen altında; aşağıdaki boş durum tekrarlamıyor, yalnızca "elle ekle".
- **Yıl özeti:** ikinci dilim `mark`'ın kâğıda karışmış tonu (gündüz %25, gece %40; açık yazıya 5,3:1); dilim yazı rengi zeminin parlaklığına göre.
- **Ayarlar:** geri yükleme için yeni `restore` simgesi (set 35).
- **Bugün kartı** düğmelerinde iç boşluk; **uzun basma menüsü** sonunda "Vazgeç", büyük yazıda kaydırılabilir.

219 test geçiyor.

### On dördüncü turdan yedi düzeltme

Puan üç turdur 30,5–31,5 arasında; kullanıcıyla ölçüm döngüsünü bırakıp yalnızca net hataları düzeltme ve ardından gerçek kullanıma geçme kararı alındı.

1. **"Tekrar gider misin?" cevapsız olabiliyor:** `Visit.revisit` artık `Revisit?`; yeni deneyimde seçimsiz, seçili seçeneğe yeniden dokununca kalkıyor. Alanı olmayan eski kayıtlar cevapsız okunuyor. Mekân sayfası cevapsızda satırı göstermiyor.
2. **Bileşen tablosu:** seçilen karar bileşen adının altında yazıyor.
3. **"Bir dahaki sefere":** "Tahinli çörek: beğenmediğin iç" (tabak adıyla).
4. **Karne puanı ölçeğiyle:** "3,8 / 5".
5. **Gece onay kutusu** işaretliyken `mark` (turkuaz).
6. **Kalan arama hakkı arama yapmadan:** sunucudaki `/me/quota` çağrılıyor (`SearchRepository.quota`, `SearchController.loadQuota`); girişliyken arama ekranı açılınca bir kez.
7. **Bugün kartı:** "Bugün gidiyorum" yerine "Yol tarifi" (harita simgesiyle; dar ekranda tek satır). Profil ve yıl özetinde "En çok önerdiğin" yerine "Önerdiklerinden en çok gittiğin".

220 test geçiyor (yeni: `test/quota_preview_test.dart`).

## 16 Ekim 2026

### Kod incelemesi ve defterin hesaba bağlanması

Bulut oturumunda (Claude Code, web) dalın tamamı incelendi; backend testleri geçici bir Postgres 16 ile, Flutter testleri Flutter 3.47.1 ile çalıştırıldı. Kullanıcının kararı: **defter hesaba bağlı olsun.** (`1e5b6dc`)

- **Defter hesaba bağlı:**
  - Çıkışta defter önce buluta yüklenir, sonra defter, fotoğraflar ve eşitleme kaydı cihazdan kaldırılır. Yükleme başarısızsa çıkış yapılmaz.
  - Oturum başka yoldan kapanırsa yedeklenmiş defter yine kaldırılır; yedeklenmemiş değişiklik cihazda kalır.
  - Başka hesabın defteri yeni hesaba yüklenmez ya da birleştirilmez. Önceden aynı cihazda A çıkıp B girince, B'nin yedeği yoksa A'nın defteri ve fotoğrafları B'nin bulutuna yükleniyordu.
  - Girişte listeler yalnızca defter bu hesabınsa ya da girişsizse devralınır. Önceden A'nın yayınladığı listeler B'nin hesabına geçiyordu.
- **Var olan bir hata bulundu ve düzeltildi:** `BackupController._load()` eşitleme kaydının ilk okunan halini döndürüyordu. Sonuçları:
  - İlk girişten sonra silinen kayıtlar her eşitlemede birleştirmeyle geri geliyordu.
  - Uygulama yeniden açıldıktan sonra yapılan değişiklikler buluta yüklenmiyordu.
  İkisi için de test yazıldı; eski kodla başarısız olduğu doğrulandı.
- **Sunucu, listeler:** Hesaba bağlanmış liste başka hesaba devredilemez (`claim`) ve yalnızca o hesapla düzenlenir. Anahtar tek başına yalnızca hesaba bağlanmamış listelerde geçer.
- **Sunucu, kota:** Arama hakkı Google'a gitmeden düşülür, başarısızsa ya da sonuç önbellekten geldiyse geri verilir. Önceden aynı anda gönderilen 10 arama, hak 3 olduğu hâlde Google'a 10 istek olarak gidiyordu.
- **Sunucu, Google payı:** Places sayaçlarına kullanıcı başına günlük pay eklendi (`PLACES_USER_DAILY_LIMIT` 30, `PLACES_PHOTO_USER_DAILY_LIMIT` 40). Önceden tek hesap mekân analiziyle (istek başına 5 Place Details) ortak 100'lük sınırı bitirip aramayı herkes için durdurabiliyordu. Payı biten kullanıcı `429 user_places_budget` alır; arama ekranında kendi mesajı var.

Backend'de 46 test (Postgres dahil), uygulamada 227 test geçiyor. Yeni ortam değişkenlerinin varsayılanları var; Cloud Run'da ek ayar gerekmiyor, yalnızca yeni sürümün yayınlanması gerekiyor.

### Telefonda ilk deneme ve bulunan hatalar

Uygulama kullanıcının iPhone'una ücretsiz Apple kimliğiyle Xcode üzerinden kuruldu (`flutter run --release`). Kurulumda takılınan yer: telefonda Geliştirici Modu kapalıydı; Flutter bunu "No Xcode build settings have been found" diye gösteriyordu, asıl hata `xcodebuild -showBuildSettings -destination 'id=…'` ile görüldü.

Kullanıcının telefonda bulduğu hatalar (`7887af8`):

- **iOS'ta kenardan kaydırarak geri gitme hiçbir sayfada çalışmıyordu.** go_router uygulama türünü algılayamadığı için sayfaları geçişsiz (`NoTransitionPage`) açıyordu. Bütün rotalar artık `MaterialPage` ile açılıyor; iOS'ta Cupertino geçişi ve geri hareketi geldi. Kaydedilmemiş formda hareket yine kapalı, geri düğmesi uyarıyı gösteriyor.
- **Filtre şeritleri kaydırılamıyordu.** `ChoiceStrip`, sağda gizli seçenek olup olmadığına göre solma maskesini ağaca ekleyip kaldırıyordu; kaydırma alanı yeniden kurulduğu için sürükleme kesiliyor, şerit başa dönüyordu. Arama filtreleri, arşiv süzgeçleri ve tabak sıralaması bu bileşeni kullanıyor; hepsi düzeldi.
- **"Beğendim / Fena değil / Beğenmedim" alt alta görünüyordu.** `SegmentRow`, en uzun kelime onay işaretiyle sığmayınca alt alta diziyordu. Araya sıkışık bir düzen eklendi: dar kenar, onay işareti yazının üstünde. Üç yargı 335 pt ve üstünde (bütün iPhone'lar) yan yana; büyük yazıda yine alt alta.

233 test geçiyor (yeni: `test/navigation_test.dart`, `test/choice_strip_test.dart`, `segment_row_test.dart` içinde telefon genişliği).

### Seçili kutularda tik ve yıl özeti paylaşımı

Kullanıcının isteğiyle (`68a864e`):

- **Seçenek kutularında onay işareti kaldırıldı.** Seçim dolu blok ve yazı rengiyle belli oluyor. Karne kutuları ve onay satırları (kutunun kendisi işaret olduğu için) olduğu gibi kaldı. DESIGN.md güncellendi.
- **Yıl özeti artık hikâye boyutunda bir kapakla paylaşılıyor.** Önceki görsel ekrandaki özetin kopyasıydı: kenar boşluğu yoktu (yazılar kenara yapışıyor, sayılar kesiliyordu), boyutu içeriğe göre değişiyordu (örnekte 1080×1645) ve üzerinde ne Gurme ne de paylaşanın adı vardı. Yeni kapak (`YearCover`) liste kapağıyla aynı dilde: 1080×1920, Kâğıt / Mürekkep / Altın, üstte GURME ve "Yılın özeti", büyük yıl ve "defterimden", birinci tekil kişiyle özet cümlesi, semtler ("Diğer" sıralanmaz), defterin karakteri, yılın mekânı ve tabağı, altta paylaşanın adı. Ekranda ayrıntılı özet kalıyor; altında kapak önizlemesi, renk seçimi ve paylaş düğmesi.

240 test geçiyor (yeni: `test/year_cover_test.dart`, kalabalık ve sade yıl, üç renk).

### On beşinci tur tasarım ölçümü

İki bağımsız ajan **31 ve 34** verdi, ortalama **32,5**; şimdiye kadarki en yüksek (önceki tur 30,5). Talimat artık `docs/TASARIM_OLCUM_TALIMATI.md` dosyasında; görüntü seti 108 dosya. Bulgular `docs/TASARIM_ELESTIRISI.md`, on beşinci tur.

### Aylık özet ve çok sayfalı yıllık paylaşım

Kullanıcının isteğiyle (`9af080d`):

- **Ayın özeti** (Profil → "Bu ayın özeti", `/profile/month`). Son 12 aydan kaydı olan aylar üstte seçilir; bu ay her zaman listede. Ekranda ayın ayrıntılı özeti, altında tek sayfalık hikâye kapağı: eski yıl kapağının biçimi, büyük ay adı ve "defterimden". Tek türün "%100" çubuğu kapakta gösterilmiyor.
- **Yılın özeti artık bir set.** En çok 8 sayfa, her biri 1080×1920:
  1. Açılış.
  2. Sayılarla: gittiğim mekân, deneyim, yeni yer, önerdiğim, liste.
  3. Ay ay: 12 çubuk; en yoğun ay altın renkli ve cümleyle söyleniyor.
  4. Semtlerim: ilk beş.
  5. Defterimin karakteri: tür çubukları.
  6. En çok gittiklerim: ilk beş.
  7. Yılın tabakları: puanı 4 ve üstü ilk üç.
  8. Kapanış: yılın mekânı, tabağı, en yoğun ayı ve semti.

  Verisi olmayan sayfa atlanıyor. Ekranda set kaydırılarak önizleniyor, altında sayfa göstergesi var. "Hepsini paylaş (8 görsel)" bütün sayfaları sırasıyla tek paylaşımda veriyor (`shareBoundaryImages`; Instagram hikâyesi, WhatsApp ve benzeri uygulamalar birden çok görsel alıyor). "Bu sayfayı paylaş" yalnızca görüneni paylaşıyor. Sayfaların hepsi önizlemenin altında çizili duruyor, görüntüleri bu yüzden alınabiliyor.
- `YearSummary` ay dönemini de hesaplıyor: ay ay sayı, ilk beş semt ve mekân, ilk üç tabak. Ortak kapak parçaları `cover_kit.dart` dosyasında; `year_cover.dart` yerine `summary_cover.dart` ve `year_story.dart` geldi.

### On beşinci turun bulguları

Ortak bulgular (`d8db14c`):

- Listeler sekmesi büyük yazıda kelime bölmüyor.
- Yıl ekranında semt adının yeri yazı boyutuyla büyüyor.
- Mekân formunda tür önerileri var, tanınmayan tür için uyarı çıkıyor ("Bu türü tanımadım…").
- Üç arama sınırı aynı biçimde gösteriliyor.
- "Bir daha söyleme" hata rengiyle yazılmıyor.
- Liste görünürlüğü yalnızca liste sayfasında seçiliyor.
- Kapakta "kez gittim" yerine "deneyim" yazıyor.

Tek ajan bulguları (`837d502`):

- Çıkış yapmak onay istiyor. Geri alınabilen liste silme onay istemiyor.
- Metinler: "Mekân silinsin mi?", "Gittiğin gün". Giriş hatasında ham kod gösterilmiyor.
- Liste formu:
  - "+ Mekân ekle" 44 pt ve düğme olarak duyuruluyor.
  - Not alanının adı "Neden bu listede?", çift çizgi kaldırıldı.
- Boyutu verilen her simge büyük yazıyla büyüyor.
- 2x yazıda deneyim puanının açıklaması alta iniyor.
- Liste kapağında ham adres yerine "Bağlantısı gönderide" yazıyor.
- Gece tür diliminin yazı rengi karşıtlığa göre seçiliyor.
- Seçili kutunun yazısı kalın.
- Kesme işaretleri tek türde.
- **Katman görüntüleri:** Test, giriş hareketinin ilk karesini beklemeden görüntü alıyordu. Bu yüzden pencere, tarih seçici ve "Geri al" çubuğu görüntülerde yoktu; artık görünüyorlar.

275 test geçiyor. Yeni testler: `summary_cover_test.dart` (ay kapağı, yıl setinin her sayfası, üç renk) ve ay özeti testleri.

### On altıncı tur tasarım ölçümü ve düzeltmeleri

İki bağımsız ajan **31 ve 38** verdi, ortalama **34,5**; önceki tur 32,5. Ayrıntı `docs/TASARIM_ELESTIRISI.md` dosyasında, on altıncı tur. Bütün bulgular düzeltildi; her birine görüntü üzerinde ikinci kez bakıldı.

- `e285b46`:
  - "Kaydedilen" 2x yazıda hâlâ bölünüyordu. Önceki düzeltme, ölçeği sınırın tam üstüne kurduğu için yuvarlamada kaybediyordu. Şimdi bir piksel pay bırakılıyor. Çizilen satırı denetleyen test eski kodda başarısız oluyor, yenisinde geçiyor.
  - Hızlı eklemede yazılanlar ayrıntılı forma taşınıyor.
  - Lezzet izi kesin puanı söylüyor.
  - Yıl setinde "Diğer" sıralanmıyor; sayılar cümle olarak yazılıyor.
  - Ekleme eylemleri tek biçimde.
  - Deneyimlerde "Öneriyorum" tekrar etmiyor.
- `b26e085`:
  - Metinler düzeltildi: "Neden bu?", kapasite, rehber, liste formu, ay özeti, karne satırı.
  - Arama hatasında tek ana eylem var.
  - Giriş kapalı derlemede çıkmaz yol yok.
  - Son beş arama hatırlanıyor.
- Son commit:
  - Şerit kenarı soluyor, harf ortasından kesilmiyor.
  - Arşivin ilk satırı bir kez hafifçe kayıp geri dönüyor; "hareketi azalt" açıksa kaymıyor.
  - Uzun tabak tablosunda başlıklar her beş satırda yineleniyor.
  - İpucu baloncuğu temalı.
  - 2x karnede ölçüt adı karelerin üstünde.
  - Profildeki son not yazı boyutuyla uzuyor.
  - Sayfa noktalarının dokunma alanı 36×44 pt.
  - Liste formunda not alanının alt çizgisi geri geldi, satır ayırıcısı kalktı.

### Harita görünümü (ilk aşama)

Kullanıcının onayıyla Google Maps SDK eklendi (`google_maps_flutter` 2.19).

- **Anahtarlar:** Depoda değil, yerelde duruyor. Yerel dosyalar git dışında.
  - iOS: `ios/Flutter/Secrets.xcconfig` (`MAPS_API_KEY=…`) → Info.plist `GMSApiKey` → `AppDelegate`.
  - Android: `android/local.properties` (`MAPS_API_KEY=…`) → manifest.
- **Anahtar kontrolü:** Dart tarafı `gurme/maps` kanalıyla anahtar olup olmadığını soruyor. Anahtar yoksa harita yerine "Harita bu derlemede kapalı" yazıyor. Android anahtarı henüz yok; Java kurulu olmadığı için imza parmak izi alınamadı, sonraya bırakıldı.
- **Konum verisi:** Mekâna `lat` ve `lng` eklendi.
  - Aramadan eklenen mekân konumunu Google'dan alıyor.
  - Elle eklenmiş kayıt aramada bulununca konum kazanıyor.
  - Elle eklenenlerin konumu için ikinci aşamada sunucudaki mevcut Places konum çağrısı kullanılacak.
- **Ekranlar:** Arşivde ve arama sonuçlarında "Haritada gör". Harita listenin üstünde açılıyor; işaretin balonuna dokununca mekân ya da sonuç sayfası açılıyor.
- **Doğrulanmayan:** iOS ve Android derlemesi bu ortamda denenemedi (Xcode ve Android SDK yok). iOS eklentisi CocoaPods istiyor; Mac'te CocoaPods kurulu olmalı.

### Telefonda "İnternete bağlanılamadı"

Telefonda `flutter run` adres verilmeden çalıştırılınca uygulama `localhost:8080`'e bağlanıyordu. Telefonda localhost telefonun kendisi olduğu için arama her seferinde ağ hatası veriyordu. Artık adres verilmezse canlı sunucu (Cloud Run) kullanılıyor; yerel sunucu için `API_BASE_URL=local`. Google fotoğrafları da varsayılan olarak açık, testlerde kapalı.

Aynı denemede iOS harita derlemesi başarılı oldu (CocoaPods kuruldu). App Check API'si projede açık değil (403); sunucuda App Check zorunlu olmadığı için aramayı engellemiyor.

### Yönetim, ilk aşama: liste bildirme ve kaldırma

Herkese açık listeler başkalarının gördüğü içerik. App Store (yönerge 1.2) bu içeriğin bildirilebilmesini, kaldırılabilmesini ve kötüye kullanan hesabın engellenebilmesini istiyor.

- **Yetki:** Ayrı bir yönetici hesabı yok. Firebase hesabına `admin: true` özel yetkisi veriliyor (`artifacts/api-server/scripts/set-admin.ts`). Sunucu bu yetkiyi ID token'dan okuyor. `ADMIN_API_KEY` yalnızca acil durum için kaldı.
- **Veritabanı:**
  - Yeni tablo `list_reports`. Hesap başına bir listeye bir bildirim yapılabiliyor.
  - `gurme_lists` tablosuna `hidden_at` ve `hidden_by`, `users` tablosuna `publishing_blocked_at` eklendi.
  - Hepsi boş olabilen ek alanlar; eski sunucu sürümü de çalışmaya devam eder.
- **Uçlar:**
  - `POST /gurme/lists/:id/report`: giriş ister; kendi liste bildirilemez.
  - `GET /admin/me` ve `GET /admin/list-reports`.
  - `POST /admin/lists/:id/moderation`: hide, restore ya da dismiss.
  - `POST /admin/users/:uid/publishing`.
- **Kaldırılan liste:**
  - Keşifte görünmüyor; paylaşım sayfası 410 dönüp "Liste kaldırıldı" diyor.
  - Sahibi ve yönetici listeyi görebiliyor; sahibi düzenleyince kaldırma kalkmıyor.
  - Yayını kapatılan hesap yalnızca özel liste tutabiliyor ("publishing_blocked").
- **Uygulama:**
  - Başkasının listesinde "Bu listeyi bildir".
  - Profil'de yalnızca yöneticiye görünen "Yönetim": bildirilen listeler, yayından kaldır ve geri al, bildirimi kapat, sahibinin yayınını kapat ya da aç.
- **Testler:**
  - Sunucu: 51 test. Bunların 5'i yeni ve gerçek Postgres'te çalışıyor. Test dosyaları aynı veritabanını paylaştığı için artık sırayla çalışıyor (`--test-concurrency=1`).
  - Uygulama: 287 test.
- **Yapılamayan:** Dart istemcisi yeniden üretilemedi (Docker Hub ve Maven Central erişim sınırı). Yeni uçlar uygulamada doğrudan Dio ile çağrılıyor.

### Yönetim paneli genişletildi

Kullanıcının isteği: "Hemen hemen her şeyi buradan görebilmek istiyorum."

- **Yeni veri:**
  - `search_log` tablosu: her arama kelimesi, yeri, süzgeçleri, sonucu (Google, önbellek, hak bitti, sayaç doldu, kapalı hesap, hata) ve sonuç sayısıyla kaydediliyor. Kayıt yanıtı bekletmiyor; 90 günden eskiler günde bir siliniyor.
  - `users.search_blocked_at`: yönetici bir hesabın aramasını kapatabiliyor. Arama, mekân analizi, mekân ayrıntısı ve fotoğraf `search_blocked` ile duruyor.
  - Giriş yapan her hesap kullanıcılar tablosunda görünüyor, yalnızca arama yapanlar değil; satır saatte en çok bir kez yazılıyor.
  - Places ve fotoğraf sayaçlarının bugünkü durumu okunabiliyor.
- **Uçlar (hepsi yönetici yetkisi ister):**
  - `GET /admin/overview`, `GET /admin/users`, `GET /admin/users/:id`.
  - `POST /admin/users/:id/bonus`, `POST /admin/users/:id/search`.
  - `GET /admin/searches`, `GET /admin/lists`.
  - Mekân bildirimi inceleme uçları (`/feedback/admin/…`) artık yönetici hesabını da kabul ediyor.
- **Uygulamada Yönetim:**
  - **Genel bakış:** Bekleyen bildirimler, bugünün cümlesi, Google sayaçları (%80'de altın, dolunca kırmızı), en çok harcayan kullanıcı, son 7 günün arama ve yeni kullanıcı sütunları, bugünkü aramaların sonuçları, kullanıcı ve liste sayıları, sunucu durumu (sürüm, giriş, App Check, Places, yapay zekâ, çalışma süresi).
  - **Kullanıcılar:** E-posta ile arama, süzgeçler (tümü, bugün açan, kısıtlanan). Kullanıcı sayfasında bugünkü hak, analiz ve Google isteği, +1, +3 ya da +5 arama hakkı, aramayı ve yayını kapatma ya da açma, listeleri, son 14 günü ve son aramaları.
  - **Aramalar:** En çok aranan kelimeler ve yerler (7 gün), sonuca göre süzülen son aramalar.
  - **Listeler:** Paylaşılan, herkese açık, bağlantıyla ya da kaldırılan listeler, sahibinin e-postası ve bildirim sayısıyla; aç, sahibini gör, kaldır ya da geri al.
  - **Bildirimler:** Liste bildirimleri ve mekân bildirimleri. Kabul edilen mekân bildirimi arama sonuçlarına yansıyor.
- **Testler:**
  - Sunucu: 56 test, 5'i yeni ve Postgres'te.
  - Uygulama: 291 test. Panelin dört ekranına görüntü üzerinden bakıldı. Seçili bölüm şeridin kenarında soluk kaldığı için bölümler sarılan düzene alındı; başka sayfaya götüren satırlara ok eklendi.

### Kullanıcının yapması gerekenler

Kurulum (Google Cloud, Firebase, Neon, Secret Manager) Ekim 2026'da tamamlandı. Güncel liste `docs/ROADMAP.md` dosyasında, "Kalan işler → Sizin yapmanız gerekenler" başlığında.

### Notlar

- Simülatör, Xcode 27'de ayrı bir Simulator uygulaması yerine **DeviceHub** içinde görüntüleniyor.
- `pnpm` PATH'te yok; `corepack pnpm` kullanılıyor.
- macOS'ta `timeout` komutu yok.
- Testte gerçek dosya okuyan font yükleme `testWidgets` içinde takılıyor; `setUpAll` içinde yapılmalı.

### GitHub'a yükleme

- **Proje GitHub'a yüklendi.** `gurme-main.zip` içindeki 560 dosya boş `talhakcn/Gurme` deposunun `main` dalına tek commit olarak gönderildi. Yüklemeden önce `.env`, anahtar ve gizli bilgi dosyası arandı, bulunmadı. Depo daha sonra kullanıcı tarafından herkese açık yapıldı. (`01c6525`)
