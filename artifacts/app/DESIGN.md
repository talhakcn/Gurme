---
version: alpha
name: Gurme
description: Kişisel lezzet defteri ve yapay zekâ destekli mekân araması için iOS ve Android uygulaması.
omitted:
  - section: rounded
    reason: Yüzeyler köşesiz; yuvarlatma ölçeği yok.
colors:
  paper: "#F2F0EF"
  ink: "#20373B"
  teal: "#519CAB"
  tealText: "#2F7482"
  line: "#A9C8CC"
  gold: "#FFC64F"
  muted: "#57696C"
  wash: "#E7E9E7"
  pale: "#F8F5EE"
  error: "#A74A3E"
typography:
  displayLarge:
    fontFamily: Bodoni Moda
    fontSize: 44px
    lineHeight: 48px
    fontWeight: 400
  headlineLarge:
    fontFamily: Bodoni Moda
    fontSize: 37px
    lineHeight: 43px
    fontWeight: 400
  headlineMedium:
    fontFamily: Bodoni Moda
    fontSize: 29px
    lineHeight: 35px
    fontWeight: 400
  headlineSmall:
    fontFamily: Bodoni Moda
    fontSize: 22px
    lineHeight: 28px
    fontWeight: 400
  titleLarge:
    fontFamily: Bodoni Moda
    fontSize: 25px
    fontWeight: 400
    letterSpacing: 4.5px
  titleMedium:
    fontFamily: Bodoni Moda
    fontSize: 18px
    lineHeight: 28px
    fontWeight: 400
  bodyLarge:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    lineHeight: 24px
    fontWeight: 400
  bodyMedium:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    lineHeight: 23px
    fontWeight: 400
  bodySmall:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    lineHeight: 20px
    fontWeight: 400
  labelSmall:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    lineHeight: 18px
    fontWeight: 600
  labelLarge:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    lineHeight: 20px
    fontWeight: 600
spacing:
  xs: 4px
  s: 8px
  m: 12px
  l: 16px
  xl: 24px
  xxl: 32px
  xxxl: 48px
components:
  button-primary:
    backgroundColor: "{colors.gold}"
    textColor: "{colors.ink}"
    typography: "{typography.labelLarge}"
  button-secondary:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    typography: "{typography.labelLarge}"
  choice-selected:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.paper}"
  choice-unselected:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
  eyebrow:
    textColor: "{colors.muted}"
    typography: "{typography.labelSmall}"
  section-title:
    textColor: "{colors.ink}"
    typography: "{typography.headlineSmall}"
---

# Gurme

## Overview

Gurme, gidilen ve gidilecek mekânların tutulduğu kişisel bir lezzet defteri ve bu deftere mekân bulan bir arama aracıdır. Görünüm bir dergi değil, kişinin kendi defteridir: kâğıt zemin, mürekkep yazı, serifli başlıklar ve öne çıkan kendi notları. Uygulama kullanıcıyla düz cümlelerle konuşur; süs yerine içerik ve boşluk vardır. Her ekran tek bir işe odaklanır.

## Colors

- Zemin her yerde `paper`; yazı ve simgeler `ink`.
- Turkuaz metinde yalnızca `tealText` olarak kullanılır. `teal` kâğıt zeminde okunurluk eşiğinin altında kalır; yalnızca çizgi, kenar ve yüzeylerde kullanılır.
- İkincil metin `muted`.
- `gold` dikkat çeken tek renktir. Ekrandaki ana eylemin zemini ve küçük vurgu çizgileri için ayrılmıştır.
- `line` yalnızca ayırıcı çizgiler içindir. Kontrol kenarları (seçilmemiş kutu, ikincil düğme, metin alanı çizgisi, boş karne karesi) `control` rengindedir; zeminden en az 3:1 ayrılır (WCAG 1.4.11).
- `error` yalnızca hata ve silme uyarılarında kullanılır.

## Themes

Görünüm Ayarlar'dan seçilir: cihaza uy (varsayılan), gündüz ya da gece. Ekranlar renkleri `context.colors` paletinden alır; sabit gündüz renkleri (`GurmeColors`) yalnızca tema tanımında ve paylaşılan görsellerde (liste kapağı, ay ve yıl özeti) kullanılır, bu görseller gece de gündüz renginde çizilir.

| Rol | Gündüz | Gece |
|---|---|---|
| paper | #F2F0EF | #152024 |
| ink | #20373B | #ECE7E1 |
| teal | #519CAB | #519CAB |
| tealText | #2F7482 | #7CC0CD |
| line | #A9C8CC | #56707A |
| gold | #FFC64F | #FFC64F |
| onGold | #20373B | #20373B |
| muted | #57696C | #9BAEB1 |
| wash | #E7E9E7 | #213036 |
| pale | #F8F5EE | #1B282C |
| error | #A74A3E | #E58C7E |
| raised | #20373B | #2A3B40 |
| scrim | ink %25 | siyah %60 |
| control | #688A8F | #6A8489 |
| onRaised | #F2F0EF | #ECE7E1 |
| chosen | #20373B | #519CAB |
| mark | #20373B | #519CAB |

- Altın zemin üstündeki yazı her iki temada da koyudur (`onGold`).
- Gece kâğıdında kontrastlar: ink 13,5, muted 7,2, tealText 8,1, error 6,6; ayırıcı çizgi (`line`) 3,2.
- Gece fotoğraflar hafifçe (%14) kısılır; koyu zeminde parlak bir delik açmaz.
- Dolu puan kareleri ve grafik çubukları `mark` rengindedir: gece turkuaz, çünkü krem dolgu geniş ve parlak bloklara dönüşür.

## Typography

- Başlıklar ve mekân adları Bodoni Moda (`display*`, `headline*`), diğer bütün metinler Plus Jakarta Sans.
- Bir ekranda en fazla bir `displayLarge` bulunur: ekranın konusu (Keşfet girişi, mekân adı, karne puanı).
- Alıntı ve özetler `titleMedium` (italik Bodoni), metin alanlarına yazılan metin `bodyLarge` kullanır.
- Yazı boyutu ekranda değiştirilmez; gereken boyut yoksa önce temaya rol olarak eklenir.
- İtalik Bodoni yalnızca kullanıcının kendi sözleri içindir: deneyim başlığı ve mekân notu.
- Bütün metinler cümle düzenindedir; büyük harfle ve harf aralığıyla yazılmış etiket kullanılmaz. Küçük etiket (`labelSmall`, `muted`) yalnızca alan adı ve üst bilgi içindir ("Moda · Kahve").
- Bölüm başlığı `headlineSmall` Bodonidir; sayfa başlığının üstüne etiket konmaz.
- Düğme ve bağlantı yazısı `labelLarge`.
- Sayılar mümkünse cümle içinde verilir ("Defterinde 3 mekân var; 2 tanesine henüz gitmedin."); büyük sayı ve küçük etiketten oluşan tablolar kullanılmaz. Sıfır olan sayı cümleye yazılmaz ("2 mekân ve 1 rota"; "0 deneyim" değil); sıralama için `countsTr` ve `joinTr` kullanılır.
- Alıntılar Türkçe tırnakla (“ ”), kısaltılan metinler tek üç nokta karakteriyle (…) yazılır.
- Rakamlar sabit genişliktedir; puan ve sayaç sütunları kaymaz.

## Layout

- Boşluklar yalnızca `spacing` ölçeğinden seçilir. Sayfa kenar boşluğu `l`, bölümler arası `xl`.
- Her ekranda en fazla bir ana eylem vardır ve yalnızca o `gold` zeminlidir. Diğer eylemler ikincil düğme ya da bağlantıdır.
- Bölümleri başlık ve üstündeki `xxxl` boşluk ayırır; numara ve süs çizgisi kullanılmaz. Liste satırları ince `line` çizgiyle ayrılır; kart ve gölge yoktur.
- Sıra numarası yalnızca sıranın anlam taşıdığı yerde (rota durakları) kullanılır. Alt çizgisi olan bir satırın hemen ardından ayırıcı gelmez.
- İçeriği olmayan bölüm gösterilmez. Boş ekranda tek bir sonraki adım önerilir.
- Henüz çalışmayan bir özellik arayüzde yer almaz.
- **Geniş ekran:** 600 pt ve üstünde sekmeler alt çubuk yerine soldaki yan menüdedir (aynı simgeler ve yazılar, vurgu zemini yok). Yan menü dışında 880 pt ve üstünde (yatay iPad) Arşiv liste–ayrıntı düzenine geçer: solda liste, sağda seçili mekân; seçili satır `wash` zemin ve solda `ink` çizgiyle belli olur, ilk kayıt kendiliğinden açıktır. Logo ekranda bir kez durur. Ayrıntı sütunu ekranın ana eylemini taşıdığı için listedeki "Mekân ekle" ikincil düğmedir. Diğer sayfalar okunur genişlikte ortalanır.

## Elevation & Depth

Yüzeyler düzdür: gölge ve yükselti yoktur. Katman gerekiyorsa (alttan açılan sayfa) üst kenarda kalın bir `ink` çizgi ve yarı saydam `ink` perde kullanılır; perde sekme çubuğu dahil bütün ekranı örter.

## Shapes

Bütün yüzeyler, düğmeler ve kutular köşesizdir.

## Components

- **Ana düğme:** `gold` zemin, `ink` yazı.
- **İkincil düğme:** Kâğıt zemin, `line` kenar.
- **Seçenek kutusu:** Seçiliyken `chosen` renkli dolu bir bloktur ve kenarı zeminiyle aynı renktir; onay işareti taşımaz (seçim dolgu ve yazı rengiyle belli olur): gündüz mürekkep, gece puan kareleriyle aynı turkuaz (`mark`); üstündeki yazı iki temada da kâğıt rengidir. Gece tek bir "seçili" rengi vardır. İki temada aynı dil; seçim yalnızca renk tonuyla anlatılmaz, boş çerçeve ile dolu blok arasındaki farkla da okunur. Yan yana sığmayan seçenekler önce dar kenar ve aralıkla yan yana denenir, o da sığmazsa alt alta dizilir. Seçenekler dar ekranda tek satırda yatay kaydırılır (`ChoiceStrip`); görünmeyen seçenek varsa sağ kenar solar.
- **Metin alanı:** Yalnızca alt çizgisi vardır. Odaklanınca çizgi `ink` olur.
- **Onay satırı:** Evet/hayır tercihleri ("Bu mekânı öneriyorum") her ekranda aynı onay satırıyla sorulur.
- **Paylaşılan görseller:** Liste kapağı, ayın özeti ve yılın özeti aynı dildedir (ortak parçalar `features/profile/cover_kit.dart`): 1080×1920 (hikâye boyutu), Kâğıt / Mürekkep / Altın renk seçenekleri, üstte "GURME" ve ne olduğu ("Lezzet listesi", "Ayın özeti", "Yılın özeti"), altta paylaşanın adı. Ayın özeti tek sayfadır. Yılın özeti en çok 8 sayfalık bir settir (açılış, sayılar, ay ay, semtler, defterin karakteri, en çok gidilenler, yılın tabakları, kapanış); verisi olmayan sayfa sete girmez, her sayfanın üstünde "Yılın özeti · 2 / 8" yazar. Set tek paylaşımda sırasıyla gider (hikâye ya da çoklu gönderi); tek sayfa da paylaşılabilir. Görsele dokunulamadığı için adres yazılmaz; bağlantı paylaşımın metninde gider. Görseli paylaşan kendi defterini anlattığı için kapak cümleleri birinci tekil kişiyle yazılır ("Bu yıl 6 mekâna gittim"). "Diğer" gibi toplama satırları kapakta sıralanmaz. Yazılar sistem yazı boyutuyla büyümez; uzun adlar kısaltılır, kapak taşmaz.
- **Mekân görseli:** Kapak sırası: mekâna eklenen fotoğraf, deneyimlerdeki en son fotoğraf, Google fotoğrafı, türünden çizilmiş kapak. Kullanıcının kendi fotoğrafı her zaman önce gelir. Kapak yalnızca mekân sayfasında ve "Bugün ne yesem?" kartında görünür; liste satırlarında küçük kapak yoktur, satır ad ve lezzet iziyle taranır. Google fotoğrafı yalnızca çekeninin adının sığdığı büyük kapaklarda gösterilir; adı her zaman yazılır. Çizilmiş kapak defter çizgileri üstünde tek çizgili bir motiftir (simgelerle aynı çizgi dili, gündüz `control`, gece `muted` renginde; altın kullanılmaz); süs değil, mekânın türünü söyler.
- **Bağlantı:** `labelLarge`, altı `control` renginde çizili; sonunda ok yoktur. Dokunma alanı en az 44 pt.
- **Ekleme eylemleri:** Bir listeye ya da deftere yeni öğe ekleyen ana yol, artı simgeli ikincil düğmedir ("Mekân ekle", "Tabak ekle"). Kart içindeki küçük eklemeler bağlantıdır ("Bileşen ekle"). Metinde "+" karakteri kullanılmaz.
- **Yatay şerit:** Devamı olan şeridin sağ kenarı solar; son 12 pt tamamen saydamdır. Kesilen kutu harf ortasından sert bir çizgiyle bitmez.
- **Bildirme ve yönetim:** Başkasının listesinin sonunda "Bu listeyi bildir" bağlantısı; nedenler seçenek kutusu, not isteğe bağlı. Yönetim bölümü yalnızca yönetici yetkisi olan hesapta, Profil'de görünür. Geri alınamayan ya da başkasını etkileyen işlemler (yayından kaldırma, yayını kapatma) tehlike bağlantısıyla yazılır ve onay ister.
- **Harita:** Liste yerine değil, listenin üstünde açılır ("Haritada gör" / "Haritayı kapat"); liste her zaman yerinde kalır. İşaretler turkuaz, işletme etiketleri gizli; gece koyu stil. Yeri bilinmeyen mekânlar sayıyla söylenir. Harita anahtarı olmayan derlemede harita yerine "Harita bu derlemede kapalı" yazar.
- **İpucu baloncuğu:** Bilgi çubuğuyla aynı görünür: `raised` zemin, üstte mürekkep çizgi, köşesiz.
- **Satır sonu oku:** Sayfa içi geçişlerde `muted` renkli `›`; çapraz ok (`↗`) yalnızca uygulama dışına giden bağlantı içindir.
- **Lezzet izi (imza):** Tadım karnesinin dört ölçütü, her biri beş karelik bir satır olarak `ink` (dolu) ve `wash` (boş) karelerle çizilir (dolu kare `mark`); deneyim formundaki karneyle aynı düzendir. Mekân sayfasında ilk göründüğü yerde tek cümleyle ne olduğu yazar. Satırda izin yanında puan ve, tek ve belirginse, en güçlü ölçüt yazar ("3,6 / 5 · en iyi: ambiyans"); bilgiyi metin taşır. Mekânın bütün ziyaretlerinin ölçüt ortalamasından çıkar. Satırlarda adın altında küçük, mekân sayfasında ölçüt adları ve puanlarıyla büyük görünür. Mekân sayfasında kareler tam kısmı dolu çizer, yarım ve üstü artan son kareyi yarı doldurur; yanındaki sayı yuvarlanmamış ortalamadır. Büyük yazıda ölçüt adı karelerin üstüne geçer. Karnesi olmayan mekânda çizilmez; yerine başka bir işaret konmaz.
- **Defter kenarı:** Kullanıcının kendi yazdığı metin (mekân notu, deneyim başlığı ve notu, listedeki "Neden bu listede?") solunda çift ince `gold` çizgi taşır. Uygulamanın kendi metinleri bu çizgiyi taşımaz.
- **Rota:** Durakları sırayla, okla birleştirilmiş adlarla gösterilir ("Kahve Durağı → Fırın Kırıntı").
- **Hareket:** Kısa ve sakindir (160–600 ms, yavaşlayarak biten eğri). Liste satırları sırayla, hafifçe kayarak belirir. Cihazda "hareketi azalt" açıksa hiçbiri oynamaz.
- **Silme:** Formun sonunda ortalanmış, küçük, `error` renkli bir bağlantıdır. Silinen şey alttaki bilgi çubuğunda "Geri al" ile geri getirilebilir; bu yüzden onay penceresi yalnızca başka kayıtları da götüren silmede (mekân: deneyimleri ve rota kayıtları) açılır.
- **Bilgi çubuğu:** `raised` zemin, köşesiz, üstte 2 px `ink` çizgi (gece zeminden ayrılsın diye); eylemi `gold`. Bilgi kaybettiren her eylemden sonra "Geri al" sunar ve okuyup karar verecek kadar (10 saniye) açık kalır.
- **Simgeler:** Uygulamadaki bütün simgeler Gurme'nin kendi setidir (`GurmeIcon`, 35 simge; iOS'ta geri işareti köşeli): 24 birim ızgara, 1,5 birim çizgi, kare uç, sivri birleşim. Seçili sekme dolu çizilir. Açılıp kapanan bölüm dönen köşeli işaretle (`expand`) gösterilir; yukarı/aşağı oklar yalnızca sıralamayı değiştirir. Üst çubuk, satır ve kart simgeleri büyük yazıyla en çok 1,5 kat büyür. Hazır simge yalnızca marka simgelerinde (Apple, Google) kullanılır; yeni simge gerekirse önce sete eklenir.
- **Hızlı eylemler:** Mekân satırının sağındaki "Diğer eylemler" düğmesi (üç kare) ya da satıra uzun basmak kısa menüyü açar (deneyim ekle, listeye ekle, haritada aç, düzenle, Gittim/Gideceğim, `error` renkli Sil). Keşfet ve Arşiv satırlarında sağa kaydırma durumu değiştirir (`ink` zemin), sola kaydırma siler (`error` zemin); ikisi de geri alınabilir. Kaydırmanın her eylemi menüde de vardır; hareketler bir kez ipucuyla anlatılır, kalıcı talimat yazılmaz.
- **Platform:** iOS'ta uyarı pencereleri ve tarih seçici sistemin kendi görünümündedir; Android'de Material, köşesiz.
- **Terimler:** Mekân toplulukları her yerde "liste" diye anılır (rota değil). Durum her yerde aynı fiille yazılır: "Gittim", "Gideceğim". Bir mekâna gidişin kaydı her yerde "deneyim"dir; sayımlar "2 deneyim" diye yazılır ("ziyaret", "kez gittin" kullanılmaz). Yayınlanmamış liste "Paylaşılmadı" diye anılır.
- **Başlıklar:** Sayfa ve satır başlıkları kelime ortasından bölünmez; en uzun kelime sığmıyorsa başlık o kelime sığacak kadar küçülür (`WordSafeText`).
- **İpuçları:** Bir kez gösterilen ipuçları içeriğin altında durur; ekranı açan önce kendi defterini görür.
- **Çıkarma:** Formun bir parçasını çıkaran eylem ("Fotoğrafı kaldır", "Tabağı çıkar") sola yaslı, `error` renkli bağlantıdır (`RemoveLink`). Alttan açılan eylem menüsünün sonunda "Vazgeç" durur.
- **Büyük yazı:** Yazı 1,2 katın üstüne büyütülünce yan yana seçenekler ve kart düğmeleri alt alta dizilir; yazı küçültülerek sığdırılmaz.
- **Karne puanı:** Her zaman ölçeğiyle yazılır ("5 üzerinden 3,8", "Karne 3,8 / 5"). Satırdaki lezzet izinin yanında ortalama puan durur.
- **Kaydedilmemiş form:** Değişmiş bir formdan çıkarken "Değişiklikler kaybolsun mu?" sorulur; değişmemiş formda geri hareketi engellenmez.
- **Kendi listen:** Sağ üstte düzenle simgesi durur (mekân sayfasındaki gibi). Kaydetme yalnızca başkalarının listeleri içindir; "Kaydedilen" sekmesinde kendi listelerin yer almaz.
- **Form:** Kaydet tek yerdedir: formun sonundaki ana eylem. Deneyim formunun sırası: tarih, karne, fotoğraf, tabaklar, başlık ve not. Yardım cümleleri ilk birkaç deneyimde görünür, sonra tek kısa satıra iner. Örnek metin italiktir ve mekânın türüne göre seçilir (burgercide kahve örneği yazmaz). Deneyim formunda hiçbir alan zorunlu değildir; bunu başlığın altındaki tek satır söyler, alanlara tek tek "isteğe bağlı" yazılmaz.
- **Tabak puanlama:** Deneyimde her tabak bir karttır: genel puan karnedeki 1–5 karelerle, bileşenler üç seçenekle (Beğendim / Fena değil / Beğenmedim) işaretlenir; hiçbiri zorunlu değildir. Bileşen sığdığında tek satırdır: ad solda, üç küçük seçenek sağda; büyük yazıda ad üstte, seçenekler altta tam genişlikte. Bileşenler karne gibi bir tablodur: seçenek adları bir kez sütun başlığıdır, satırlarda 36 pt kutular durur, seçili kutu `mark` dolgulu ve onaylıdır, seçilen karar bileşen adının altında da yazar; büyük yazıda her bileşenin adı üstte, seçenekler altta. Bileşenler "Bileşenleri işaretle" bağlantısının arkasındadır; işaretli bileşen varsa açık gelir. Kartlardan yalnızca biri açıktır, diğerleri tek satırlık özete (tür, puan, işaretli bileşen sayısı) kapanır. Özetlerde sayım cümleyle yazılır ("3 tadımda 2 kez"), kesirle değil. Tür sıralaması en az üç tabakla gösterilir. Tabak türleri mekânın türünden gelir (burgercide kahve çıkmaz), "Diğer" her zaman sondadır; türe göre bileşenler hazır gelir. Mekân sayfasında "Bir dahaki sefere" notu (`wash` zemin, üstte 2 px `ink`) ve "Tabakların" özeti deneyimlerin üstünde durur; tabak yoksa ikisi de çizilmez.
- **Altın düğme:** Ekranın asıl eylemine (Yol tarifi, Deneyim ekle, Ara, Kaydet) ya da boş durumun tek eylemine verilir. "Mekân ekle" listelerin altında her yerde ikincil düğmedir. Uygulama dışına çıkaran eylem (harita) simgesiyle bunu söyler.
- **Cevapsız seçim:** İsteğe bağlı tek seçimli sorular ("Tekrar gider misin?") başlangıçta seçimsizdir; seçili seçeneğe yeniden dokununca seçim kalkar. Cevapsız, "Belki" sayılmaz.
- **Öneri:** Tek yerde, mekân sayfasında sorulur. Deneyim formunda öneri sorusu ve "önerdiğin ürünler" alanı yoktur; beğenilen tabaklar tabak puanlarından okunur.
- **Ekran okuyucu:** Sayfa başlıkları (`PageTitle`) ve bölüm başlıkları kendi düğümünde başlık olarak işaretlenir. Arama sonucu ya da hatası gelince ekran okuyucuya duyurulur.
- **Kavramlar:** "Gurme nasıl çalışır" rehberi ayrı bir sayfadır; Profil ve Ayarlar'dan açılır. Kavram ilk göründüğü yerde de bir cümleyle açıklanır.
- **Alt sayfa:** Üstte tutma çubuğu (`control`) taşır; aşağı çekilerek kapandığı belli olur.
- **Yedek:** Dışa aktarılan dosya Ayarlar'dan geri yüklenir: önce dosyada ne olduğu gösterilir, onaylanınca defterle birleştirilir (hiçbir kayıt silinmez), "Geri al" ile geri alınır.
- **Dokunma:** iOS'ta dokunuşta Material dalgası yoktur. Seçim yapan kontroller (seçenek kutusu, onay satırı, karne kutuları) hafif bir titreşim verir.

## Do's and Don'ts

- Metni büyük harfe çevirme; gerekirse (paylaşım görseli) `toUpperCase()` değil `toUpperTr()` kullan.
- Başlığın üstüne küçük etiket, bölümlere numara, metne büyük ilk harf koyma.
- Slogan yazma ("Şehrin tadı, senin hikâyen."); kullanıcıya defterindeki gerçek bilgiyle seslen.
- `teal` rengini metin için kullanma.
- Bir ekranda birden fazla `gold` zeminli düğme kullanma.
