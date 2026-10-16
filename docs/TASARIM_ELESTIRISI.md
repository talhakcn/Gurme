# Tasarım eleştirisi — 8 Ekim 2026

> ⚠️ Kısıtlı çalıştırma: tek bağlamda yapıldı. Impeccable'ın otomatik dedektörü kurulmadığı için çalışmadı (başlatıcısı ikili dosya indiriyor). Yöntem: `test/screens_test.dart` ekran görüntüleri, kodda kalıp sayımı ve Impeccable `critique` ile `craft-floor`, Taste-Skill `redesign-existing-projects` listeleri.

İncelenen ekranlar: Keşfet, Mekân, Deneyim formu, Arşiv, Listeler, Profil, Lezzet haritan.

## Nielsen puanları

| # | Ölçüt | Puan | Ana sorun |
|---|---|---|---|
| 1 | Sistem durumunun görünürlüğü | 3 | Yedek durumu yalnızca hesap ekranında görünüyor |
| 2 | Gerçek dünyayla uyum | 3 | Türkçe, defter dili iyi; "Küratör", "Karne" yer yer yapay |
| 3 | Kullanıcı kontrolü | 3 | Geri, sil, düzenle yerinde |
| 4 | Tutarlılık | 3 | Fazla tutarlı: her şey aynı şablonda |
| 5 | Hata önleme | 3 | Silme ayrı ve küçük |
| 6 | Hatırlamak yerine tanıma | 3 | Simgeler genel; "Karne 3,8" bağlamsız |
| 7 | Esneklik ve verimlilik | 2 | Hızlı ekleme var ama Keşfet'te değil Arşiv'de dipte |
| 8 | Estetik ve sade tasarım | 2 | Süs kalıpları içeriğin önüne geçiyor |
| 9 | Hatalardan kurtulma | 3 | Gerçek hata durumları denenmedi |
| 10 | Yardım | 2 | Başlarken rehberi dışında yok |
| | **Toplam** | **27/40** | İyi bir temel, kimliği yok |

## Özgünlük kararı

**Kategoriden bağımsız.** Mekân adlarını kitap ya da şarap adlarıyla değiştirince hiçbir şey değişmiyor. Tasarım bir "lezzet defteri" değil, bir "dergi kostümü" giyiyor: künye, numaralı bölümler, büyük harfli küçük başlıklar, büyük ilk harf ve altın düğme. Bunlar yapay zekânın "şık editoryal" denince ilk başvurduğu kalıplar.

Kodda sayım:

- **101** `Eyebrow`: büyük harfli, aralıklı ve turkuaz küçük başlık.
- **7** numaralı bölüm çizgisi ve her listede `01 02 03` sıra numarası.
- **48** farklı hazır Material simgesi.

## Çalışanlar

- **Ürüne özgü fikirler gerçek:**
  - "Bugün ne yesem?" ve "Neden bu: En eski kayıt · Bu hafta bu türe gitmedin".
  - Gideceğim/Gittim ikiliği.
  - Tadım karnesinin dolan kutuları.

  Bunlar başka bir uygulamada aynen bulunmaz.
- **Kısıtlı palet ve köşesiz yüzeyler** tutarlı; renk gürültüsü yok.
- **Türkçe dil düzgün:** ı/İ, tarih biçimi, "mekân" yazımı.

## Öncelikli sorunlar

1. **[P1] Her yerde büyük harfli küçük başlık (101 tane).**
   - *Neden önemli:* Bu, yapay zekâ tasarımının en tanınan izi. Impeccable bunu yasak listesine koyuyor: "başlığın kendi ağırlığı yeter". Ekran başına 6–10 tane olunca hiçbir şey öne çıkmıyor. Ayrıca 11 px ve aralıklı büyük harf okunmayı zorlaştırıyor.
   - *Çözüm:* Çoğunu silmek. Başlık tek başına dursun. Gereken üst bilgi (semt, tür) cümle düzeninde ve soluk renkle yazılsın: "Moda · Kahve".
2. **[P1] Hiçbir bilgi taşımayan numaralar.**
   - *Neden önemli:* Keşfet'teki `01–04` bölüm çizgileri ile Arşiv'deki ve Defterden'deki `01 02 03` sıra numaraları bir sıralama ifade etmiyor. Tek işlevleri süs.
   - *Çözüm:* Bölüm çizgileri ve arşiv numaraları kaldırılmalı. Numara yalnızca rotadaki durak sırasında kalmalı, çünkü orada anlam taşıyor.
3. **[P1] Yer tutucu kapaklar.**
   - *Neden önemli:* Soluk dev italik baş harf ve köşedeki Material simgesi her mekânda aynı. Kapak "bu mekânın görseli yok" demekten başka bir şey söylemiyor. Mekân sayfasında 180 pt'lik boş bir alan kaplıyor.
   - *Çözüm:* Fotoğraf yoksa kapak hiç gösterilmemeli; satırlar metinle yetinsin. Görsel kimliği tek bir özel öğe taşımalı, örneğin Gurme'ye özel çizilmiş küçük bir tür damgası.
4. **[P1] "Büyük sayı, küçük etiket" şablonu dört kez tekrar ediyor.**
   - *Neden önemli:* Bu şablon Keşfet'teki "Bu hafta", mekân künyesi, Profil ve Lezzet haritan'da yer alıyor. Az veriyle `0 / 1 / —` gösteriyor ve boş hissini artırıyor (kullanıcının "içi boş" tespiti buradan geliyor).
   - *Çözüm:* Sayılar cümleye dönsün: "Bu hafta bir yer ekledin; henüz gitmedin." Tablo yalnızca anlamlı veri varken gösterilsin.
5. **[P2] Slogan metinler ve şablon düğmeler.**
   - *Neden önemli:* "Şehrin tadı, senin hikâyen.", "Küratörün sen ol", "Bir semt, bir lezzet, bir hikâye" gibi metinler her ürüne yapıştırılabilir. Bütün düğmeler tam genişlikte ve büyük harfli; her ekranda altın bir dolgu var.
   - *Çözüm:* Sloganlar kaldırılmalı, metin kişisel ve somut olmalı. Düğmeler cümle düzeninde ve doğal genişlikte olsun. Altın yalnızca gerçekten ana eylemde kullanılsın.

## Kişiler

- **İlk kez açan kullanıcı:** Keşfet slogan ve arama düğmesiyle açılıyor. "01" ile başlayan bir öneri kartı geliyor ama defterinde henüz ne olduğu belli değil. Mekân eklemenin en hızlı yolu Arşiv'in dibinde kalıyor.
- **Görme ya da okuma güçlüğü olan kullanıcı:** 11 px, aralıklı, büyük harfli turkuaz etiketler zor okunuyor. Ekran okuyucu "sıfır bir, Kahve Durağı" diye okuyor. "Deneyimi düzenle →" gibi metin bağlantılarının dokunma alanı 44 pt'nin altında.
- **Tek elle, ayakta kullanan kullanıcı:** Mekân sayfasında asıl eylem olan "Deneyim ekle" ekranın ortasında, notların altında kalıyor.

## Küçük gözlemler

- Profildeki iç bağlantılarda `↗` oku var; bu ok dış bağlantı anlamına gelir. `→` ya da `›` olmalı.
- Gidişat çizgisi tek ziyarette anlamsız; en az 3 ziyarette gösterilmeli.
- Üç satırlık nottaki büyük ilk harf kostüm gibi duruyor.
- Plus Jakarta Sans da yapay zekânın sık seçtiği yazı tiplerinden. Bodoni italik her başlıkta kullanılınca vurgu gücünü kaybediyor.
- "Lezzet haritan"da harita yok.

## Düşünülecek sorular

- Gurme bir dergi mi, yoksa senin defterin mi? Bir defter neden künye ve sayı numarası taşısın?
- Hiç süs olmasaydı ekranda ne kalırdı? Kalan şey yeterince güçlü mü?
- Gurme'yi ekran görüntüsünden tanıtacak tek bir öğe ne olabilir?

---

# İkinci tur — 8 Ekim 2026 (yeniden tasarımdan sonra)

> ⚠️ Kısıtlı çalıştırma: tek bağlamda ve otomatik dedektör olmadan yapıldı. İncelenenler: test ekran görüntüleri (14 ekran), simülatörde açılan uygulama ve kodda kalıp sayımı.

## Kodda sayım (önce → sonra)

| Kalıp | Önce | Sonra |
|---|---|---|
| Büyük harfli, aralıklı turkuaz etiket | 101 | 0 (68 küçük etiket kaldı; cümle düzeninde, soluk) |
| Numaralı bölüm çizgisi | 7 | 0 |
| Sıra numarası | her listede | yalnızca rota durakları (3) |
| Yer tutucu kapak | her mekânda | 0 |
| "Büyük sayı, küçük etiket" tablosu | 4 | 0 |
| İç bağlantıda `↗` | 4 | 0 |
| Farklı Material simgesi | 48 | 34 |
| İtalik kullanımı | 12 | 6 |

## Nielsen puanları

| # | Ölçüt | Önce | Sonra | Not |
|---|---|---|---|---|
| 1 | Sistem durumunun görünürlüğü | 3 | 3 | Yedek durumu hâlâ yalnızca hesap ekranında |
| 2 | Gerçek dünyayla uyum | 3 | 3 | Düz Türkçe cümleler; "Karne" yer yer bağlamsız |
| 3 | Kullanıcı kontrolü | 3 | 3 | |
| 4 | Tutarlılık | 3 | 3 | Tutarlı, artık şablon gibi değil |
| 5 | Hata önleme | 3 | 3 | |
| 6 | Hatırlamak yerine tanıma | 3 | 3 | |
| 7 | Esneklik ve verimlilik | 2 | 3 | Keşfet'ten hızlı ekleme; "Deneyim ekle" yukarıda |
| 8 | Estetik ve sade tasarım | 2 | 3 | Süs kalktı; ama imza öğesi yok |
| 9 | Hatalardan kurtulma | 3 | 3 | Gerçek hata durumları denenmedi |
| 10 | Yardım | 2 | 2 | Başlarken rehberi dışında yok |
| | **Toplam** | **27/40** | **29/40** | |

## Özgünlük kararı

**"Kategoriden bağımsız"dan "metinde özgün, görselde sade"ye.** Uygulamanın sesi artık kendine ait: saate göre selam, defterden çıkan cümleler, "Neden bu: en uzun süredir bekleyen, şehrinde." Dergi kostümü tamamen gitti. Görsel tarafta ise eksik yerine boşluk var: ekran görüntüsünden Gurme'yi tanıtacak tek bir imza öğesi henüz yok.

## Öncelikli sorunlar

1. **[P2] Sıfırlı cümleler.** Profil "Defterinde 2 mekân, 0 deneyim ve 1 rota var." diyor; Arşiv'de "Gidilecek · 0 deneyim" yazıyor. Sıfır yazılmamalı: "Henüz deneyim yazmadın".
2. **[P2] Liste sayfasında eylem yığını.** Görünürlük seçimi, altın "Yayınla ve paylaş", çerçeveli "Kapak olarak paylaş" ve "Listeyi düzenle" alt alta duruyor; liste özelken bile altın düğme yayınlamayı öneriyor.
3. **[P2] İmza öğesi yok.** Fotoğrafsız defterde ekranlar yalnızca yazıdan oluşuyor; bu sade ama tanınmaz. Gerçek fotoğrafları öne çıkarmak ya da Gurme'ye özel küçük bir ayrıntı (örneğin el yazısı tadında not vurgusu) seçilebilir.
4. **[P3] Genel simgeler.** Profil satırlarındaki Material simgeleri (giriş, grafik, bildirim) hâlâ hazır set; simgesiz satırlar ya da tek çizgi kalınlığında özel bir set daha tutarlı olur.

## Küçük gözlemler

- Arşiv'deki filtre kutuları ekranın sağında kesiliyor ("Öneriyoru…"); yatay kaydırma olduğu belli değil.
- Deneyim formundaki "Kişisel gözlem & ambiyans *" etiketinde "&" ve "*" kullanılıyor; "Notun" yeterli olabilir.
- Arşiv'deki altın "Mekân ekle" listenin sonunda; kayıt arttıkça görünmez olacak.

---

# Üçüncü tur — 8 Ekim 2026 (imza öğesinden sonra)

> ⚠️ Kısıtlı çalıştırma: tek bağlam, otomatik dedektör yok. İncelenenler: simülatörde örnek deneyimlerle açılan uygulama (Keşfet), test ekran görüntüleri ve kod.

## Nielsen puanları

| # | Ölçüt | 1. tur | 2. tur | 3. tur | 4 için ne gerekir |
|---|---|---|---|---|---|
| 1 | Sistem durumunun görünürlüğü | 3 | 3 | 3 | Yedek durumunun profilde görünmesi ("Son yedek: 2 dk önce"); kaydetmeden sonra kısa onay |
| 2 | Gerçek dünyayla uyum | 3 | 3 | 3 | "Karne" ve "tadım" terimlerinin tek bir terimde birleşmesi; yakın tarihlerin göreli yazılması ("geçen pazar") |
| 3 | Kullanıcı kontrolü | 3 | 3 | 3 | Silme ve durum değişikliğinde "Geri al" |
| 4 | Tutarlılık | 3 | 3 | **4** | DESIGN.md ile bütün ekranlar aynı kuralda |
| 5 | Hata önleme | 3 | 3 | 3 | Kaydedilmemiş formdan çıkarken uyarı |
| 6 | Hatırlamak yerine tanıma | 3 | 3 | 3 | Satırdaki küçük lezzet izinin ne olduğu ilk görüldüğünde anlatılmalı |
| 7 | Esneklik ve verimlilik | 2 | 3 | 3 | Arşiv'de kaydırarak eylem (Gittim, Sil); uzun basınca hızlı menü |
| 8 | Estetik ve sade tasarım | 2 | 3 | 3 | Özel simge seti, gece modu, gerçek fotoğraflar, Dynamic Type |
| 9 | Hatalardan kurtulma | 3 | 3 | 3 | Gerçek Firebase ve ağ hatalarıyla deneme; her hata metni "ne oldu + ne yapmalı" |
| 10 | Yardım | 2 | 2 | 2 | Lezzet izi, karne ve yedek için kısa ipuçları; ayarlarda "Nasıl çalışır" |
| | **Toplam** | **27** | **29** | **30/40** | |

## Özgünlük kararı

**Özgün.** Lezzet izi yalnızca Gurme'de olabilecek bir işaret: her mekânın kendi deseni var, karneden doğuyor ve satırdan mekân sayfasına kadar aynı. Defter kenarı, kullanıcının sözlerini uygulamanın sözlerinden ayırıyor. Metin sesiyle birlikte ürün artık kendi karakterini taşıyor.

## Öncelikli sorunlar

1. **[P2] Lezzet izinin anlamı satırda belli değil.** Mekân sayfasında etiketli; ama Keşfet'te ilk kez gören kişi ızgaranın ne olduğunu bilmiyor. İlk görüldüğünde tek satırlık bir açıklama ya da dokununca ipucu gerekli.
2. **[P2] Hazır simgeler.** Alt sekme çubuğu ve profil satırları Material simgeleri; lezzet izinin el yapımı hissiyle çelişiyor.
3. **[P2] Geri alma yok.** Mekân ya da deneyim silinince ve durum değişince geri dönüş yolu yok.
4. **[P3] Dynamic Type yok.** iOS'ta kullanıcının yazı boyutu tercihi uygulanmıyor; temada sabit boyutlar var.
5. **[P3] Gece modu yok.** Akşam yemeği seçen birinin karanlıkta açtığı bir uygulama için eksik.

## 40/40 hakkında

40/40 "her ölçütte gerçekten mükemmel" demek; olgun ürünlerin çoğu 28–34 arasında kalır. Gerçekçi hedef **35–36**: yukarıdaki tablonun "4 için ne gerekir" sütunu bunun yol haritası. Ölçüt 9 (hatalardan kurtulma) gerçek Firebase kurulumu olmadan 4 olamaz; ölçüt 10 için kısa ipuçları yeterli.

---

# Dördüncü tur — 8 Ekim 2026 (35–36 planından sonra)

> ⚠️ Kısıtlı çalıştırma: tek bağlam, otomatik dedektör yok. İncelenenler: 56 ekran görüntüsü (normal, 2 kat yazı, gece, iPad), kod ve `docs/TASARIM_DENETIMI.md`.

| # | Ölçüt | 3. tur | 4. tur | Ne değişti |
|---|---|---|---|---|
| 1 | Sistem durumunun görünürlüğü | 3 | **4** | Profilde yedek durumu; her kayıttan sonra onay |
| 2 | Gerçek dünyayla uyum | 3 | **4** | Tek terim (karne / lezzet izi); "dün", "geçen salı" |
| 3 | Kullanıcı kontrolü | 3 | **4** | Silme ve bilgi kaybettiren durum değişikliğinde "Geri al" |
| 4 | Tutarlılık | 4 | 4 | Kendi simgeler, tek palet, iki tema |
| 5 | Hata önleme | 3 | **4** | Kaydedilmemiş form uyarısı (dört formda) |
| 6 | Hatırlamak yerine tanıma | 3 | **4** | Lezzet izi açıklaması ve dokununca ayrıntı |
| 7 | Esneklik ve verimlilik | 3 | 3 | Kaydırma ve uzun basma geldi; ama yalnızca Arşiv'de, kısayol ve widget yok |
| 8 | Estetik ve sade tasarım | 3 | 3 | Gece modu, kendi simgeler, Dynamic Type; düğmelerde hâlâ hazır simgeler, Material tarih seçici |
| 9 | Hatalardan kurtulma | 3 | 3 | Gerçek Firebase ve ağ hatalarıyla denenmedi |
| 10 | Yardım | 2 | **3** | "Gurme nasıl çalışır" ve ipuçları |
| | **Toplam** | **30** | **36/40** | |

## Kalan yol

- **7 → 4:** Kaydırma eylemlerini Keşfet ve liste satırlarına da yaymak; iOS'ta ana ekran widget'ı ya da "Bugün ne yesem?" kısayolu.
- **8 → 4:** Düğme simgelerini de kendi sete almak, Cupertino tarih seçici, gerçek fotoğraflarla görünüm kontrolü.
- **9 → 4:** Firebase kurulunca giriş, yedek ve ağ hatalarının her birinin "ne oldu + ne yapmalı" metniyle denenmesi.
- **10 → 4:** Yardımın uygulama içinde aranabilir olması gerekmez; ilk açılışta 3 adımlı tanıtım yeterli olur.

---

# Beşinci tur — bağımsız ajan (8 Ekim 2026)

> Ayrı bir ajan, önceki puanları, planı ve günlüğü görmeden yalnızca kod, DESIGN.md ve 77 ekran görüntüsüyle değerlendirdi.

**Puan: 29/40.** Ölçütler: 3, 3, 3, 2, 3, 3, 3, 3, 3, 3. Önceki turlarda kendi verdiğim 36/40 ve "temkinli" 32/40 bu ölçümün üstünde kaldı.

**Özgünlük kararı:** Bu ürün için tasarlanmış. Yapay zekâ şablonuna benzemiyor. Lezzet izi, defter kenarı ve kendi simge seti ürüne özgü bulundu. Şablonvari tek öğe olarak 62 pt'lik "GURME" başlık çubuğu gösterildi.

**Öncelikli sorunlar:**

1. **[P1] Kontrol kenarlarının kontrastı düşük.** `line` kâğıt zeminde yaklaşık 1,5:1; WCAG 1.4.11'in istediği 3:1'in altında. Gece boş karne kareleri neredeyse görünmüyor.
2. **[P1] Terim kayması.** Liste, rota ve Listelerim karışıyor. "Gittim/Gidildi" ile "Gideceğim/Gidilecek" ayrışıyor.
3. **[P1] Büyük yazıda kontroller küçülüyor.** Seçenek kutusundaki FittedBox yazıyı küçültüyor, karne kutuları 44 pt'nin altında, kart düğmeleri iki satıra bölünüyor.
4. **[P2] Aramanın giriş gerektirdiği sonradan anlaşılıyor.**
5. **[P2] Liste sayfasında not yanlış satıra bağlanıyor.** "Senin sıran" bağlantısı durum mu eylem mi, belli değil.
6. **[P3] Küçük ayrıntılar.**
   - Menüdeki "Listeye ekle" söylediği işi yapmıyor, yalnızca mekân sayfasını açıyor.
   - Karşılama kartında düz tırnak kullanılmış.
   - Yıl özetinde tek kategori varken "%100" çubuğu çiziliyor.

**Gece modu:** Arşivde sağa kaydırınca beliren arka plan `ink` renginde olduğu için gece parlak krem bir blok oluşuyor.

**Erişilebilirlik:**
- Kaydırma ve uzun basma eylemleri ekran okuyucuya özel eylem olarak sunulmuyor.
- "Tümü" ve "Senin sıran" bağlantılarının dokunma alanı küçük.

---

# Altıncı tur: ikinci bağımsız ajan (8 Ekim 2026)

> Değerlendirme, ilk bağımsız turdaki talimatların aynısıyla yapıldı. Ajan önceki raporu ve puanları görmedi; yeni ekran görüntüleri kullandı.

**Puan: 30/40.** Önceki bağımsız turda 29/40 idi. Ölçütlerin onu da 3 aldı. Tutarlılık 2'den 3'e çıktı; 4 alan ölçüt yok.

**Özgünlük:** Bu ürün için tasarlanmış, şablon değil. Gerekçe olarak lezzet izi, defter kenarı, köşesiz yüzeyler ve sayıların cümle içinde verilmesi gösterildi. Ayarlar simgesi (sürgüler) belirsiz bulundu; iPad'de yalnızca ortalanmış tek sütun olması da eleştirildi.

**Öncelikli sorunlar:**
1. **[P1] Mekân sayfasındaki durum seçimi büyük yazıda kelimeyi bölüyor.** "Gideceği/m" diye iki satıra iniyor; seçim ortak `SegmentRow` yerine elle yazılmış bir satır.
2. **[P1] `CheckRow` ekran okuyucuya işaretli olup olmadığını söylemiyor.**
3. **[P2] "Bildirimler" çalışmayan bir yer tutucu sayfaya gidiyor.**
4. **[P2] Girişsiz kullanıcıya altın "Ara" düğmesi sunuluyor.** Kota metinleri de çelişiyor: bir yerde günlük, başka yerde saatlik.
5. **[P2] Seçili durum kutusuna dokununca durum sessizce boşalıyor ve bu geri alınamıyor.**
6. **[P3] Küçük tutarsızlıklar.** Sekme adı "Listelerim", sayfa başlığı "Listeler". Yıl özetinde tek semt için çubuk grafik çiziliyor. Tür adı cümle ortasında büyük harfle yazılıyor.

**Gece modu:**
- Bağlantıların alt çizgisi neredeyse görünmüyor (`line`, yaklaşık 1,6:1).
- Satır ayırıcılar ve küçük izdeki boş kareler zayıf.

---

# Yedinci tur: üçüncü bağımsız ajan (14 Ekim 2026)

> Önceki bağımsız turlarla aynı talimatlar kullanıldı. Ajan önceki raporları ve puanları görmedi. Ekran görüntüleri test ortamından alındı; bu ortamda Firebase girişi kapalı.

**Puan: 30/40.** Ölçütlerin onu da 3 aldı. Bağımsız ölçümlerin seyri: 29 → 30 → 30.

**Özgünlük:** Bu ürün için yazılmış, şablondan çıkmamış. En özgün an olarak "Bugün ne yesem?" kartı gösterildi. Jenerik kalanlar: Profil sayfası ince ve boş; kapak görseli dergi dilinde ("NO. 01"); yıl özeti simgesi.

**Öncelikli sorunlar:**
1. **[P1] Giriş kapalıyken "Giriş yap" satırı "Giriş yakında" çıkmazına gidiyor.** Not: Firebase artık bağlı olduğu için gerçek uygulamada giriş açık. Sorun, giriş kapalı derlemelerde geçerli.
2. **[P1] Kapak stil seçeneğinde "Mürekkep" kelimesi normal yazı boyutunda ikiye bölünüyor.**
3. **[P2] "Bu mekânı öneriyorum" hem mekânda hem deneyimde var;** hangisinin geçerli olduğu belirsiz.
4. **[P2] "Deneyimi düzenle" bağlantı gibi değil, küçük etiket gibi yazılmış.**
5. **[P3]** Kaydırma ve uzun basma yalnızca tek seferlik ipucunda anlatılıyor.
6. **[P3]** Kapak görselinde dergi dili kullanılıyor.

**Gece modu:** Seçili kutular ve dolu karne kareleri krem dolgulu; ekrandaki tek altın ana eylemle görsel ağırlık yarışıyor.

**Erişilebilirlik:**
- Lezzet izi kareleri büyük yazıda büyümüyor.
- iOS'ta uzun basma menüsü yerine bağlam menüsü bekleniyor.
- iPad'de yan gezinme çubuğu önerildi.

---

# Sekizinci tur: iki bağımsız ajan (14 Ekim 2026, 35 planının 1–6. adımlarından sonra)

> Aynı talimat iki ajana ayrı ayrı verildi. İki fark var: yeni `durum-*` görüntüleri tanıtıldı ve `TASARIM_35_PLANI.md` de yasaklı dosyalara eklendi. Görüntü seti 86 dosya. Ajanlar önceki raporları ve puanları görmedi.

**Puan: 29/40 ve 29/40, ortalama 29.** Bağımsız ölçümlerin seyri: 29 → 30 → 30 → 29.

| Ölçüt | A | B |
|---|---|---|
| 1. Durumun görünürlüğü | 3 | 3 |
| 2. Gerçek dünyayla uyum | 3 | 3 |
| 3. Kullanıcı denetimi | 3 | 3 |
| 4. Tutarlılık | **2** | **2** |
| 5. Hata önleme | 3 | 3 |
| 6. Tanıma | 3 | 3 |
| 7. Esneklik | 3 | 3 |
| 8. Estetik | 3 | 3 |
| 9. Hatalardan kurtulma | 3 | 3 |
| 10. Yardım | 3 | 3 |

**Değerlendirme:** Yeni görüntüler (durumlar, fotoğraflar, portre) olumlu karşılandı. Hata metinleri iki raporda da "iyi çalışanlar" arasında. Ancak hiçbir ölçüt 4'e çıkmadı. Tutarlılık ise iki ajanda da 2'ye düştü; gerekçe, uygulamanın kendi DESIGN.md kurallarını çiğnemesi. Görüntü seti genişledikçe değerlendiricinin göreceği kusur da artıyor.

**İki ajanın birlikte bulduğu sorunlar (kod üzerinde doğrulandı):**
1. **[P1] Gece modunda yıl özeti:** İlk tür diliminin yazısı `paper` rengi alıyor; gecede açık yazı altın zemine düşüyor, yaklaşık 1,3:1 (`year_summary_screen.dart:221`).
2. **[P1] Liste kaydetme simgesi** iki durumda da aynı (`list_detail_screen.dart:106`: `saved ? archive : archive`). Ayrıca kullanıcının kendi listesinde de görünüyor.
3. **[P2] Kota bitince "Ara" düğmesi etkin kalıyor.** Kota metni başlığı tekrarlıyor ve yolu olmayan "önceki aramalar" cümlesini içeriyor.
4. **[P2] DESIGN.md ihlalleri:**
   - Yıl özetinde uygulama metni italik ve turkuaz kenarlı.
   - Boş ve hata durumlarında altın süs çizgisi var.
   - Grafikte veri rengi olarak altın kullanılıyor.
5. **[P2] Satırlarda lezzet izi,** ad iki satıra inince sağda havada kalıyor. Puan "/5" olmadan yazılıyor (satır ve portre).
6. **[P3] Terim kayması:** "deneyim", "ziyaret" ve "kez gittin" (portre ile yeni geldi). "Yerel" etiketi belirsiz. "Glutensiz" ile "Çölyak" filtreleri birbirine karışıyor.

**Tek ajanın bulduğu sorunlar:**
- Kaydırarak silmede, deneyimi olan mekân için onay sorulmuyor (geri al var).
- "Helal" seçilince "Alkolsüz" de gizlice seçiliyor.
- Yedek hatası nedenini söylemiyor.
- iOS geri oku "‹" değil.
- iPad'de başlık düğmeleri içerik sütunundan kopuk.
- Gece modunda seçili seçenekle seçilmemiş arasındaki fark zayıf.

---

# Dokuzuncu tur: iki bağımsız ajan (15 Ekim 2026, sekizinci tur düzeltmeleri ve görsellerden sonra)

> Sekizinci turdaki talimat kullanıldı. Tek fark: `kapaklar.png` (çizilmiş kapaklar) tanıtıldı. Görüntü seti 87 dosya.

**Puan: 30/40 ve 31/40, ortalama 30,5.** Bağımsız ölçümlerin seyri: 29 → 30 → 30 → 29 → 30,5.

| Ölçüt | A | B |
|---|---|---|
| 1. Durumun görünürlüğü | 3 | 3 |
| 2. Gerçek dünyayla uyum | 3 | **4** |
| 3. Kullanıcı denetimi | 3 | 3 |
| 4. Tutarlılık | 3 | 3 |
| 5. Hata önleme | 3 | 3 |
| 6. Tanıma | 3 | 3 |
| 7. Esneklik | 3 | 3 |
| 8. Estetik | 3 | 3 |
| 9. Hatalardan kurtulma | 3 | 3 |
| 10. Yardım | 3 | 3 |

**Değerlendirme:** Tutarlılık iki ajanda da 2'den 3'e döndü. Bağımsız ölçümlerde ilk kez bir ölçüt 4 aldı: B, dil için "gerçekten bu ürüne yazılmış" dedi. İki ajan da tasarımı özgün buldu; çizilmiş kapaklar ve simge seti bunun kanıtları arasında sayıldı.

**İki ajanın birlikte bulduğu sorunlar:**
1. **DESIGN.md çelişkisi:** Kural "fotoğraf yoksa yer tutucu çizilmez" diyor, kod çizilmiş kapak gösteriyor. Kapaklar eklenirken belge güncellenmemiş.
2. **Sunucu hatası iletisi genel:** "Arama sırasında bir hata oluştu."
3. **Kota bilgisi tekrarlanıyor:** Hem düğmenin altında hem boş durumda yazıyor.
4. **Gece modunda seçili seçenek kutusu zayıf ayrışıyor.**
5. **iPad:** Tek sütun var ve sekme çubuğu tam genişliğe yayılıyor; yan menü öneriliyor.

**Yalnızca A'nın bulduğu sorunlar:**
- **[P1]** 200% yazıda satırdaki mekân adı, 64 pt'lik kapak yüzünden kelimenin ortasından bölünüyor ("Lahmacuncus/u").
- Places sınırı dolunca "Ara" düğmesi altın kalıyor.
- "3,6. 67 gündür" cümlesinde iki sayı yan yana geliyor.
- Kota "gece yarısı", sunucu sınırı "yarın sabah" diyor; yenilenme zamanı iki mesajda farklı.

**Yalnızca B'nin bulduğu sorunlar:**
- **[P1]** Mekân sayfasında ölçütler 4/3/5/4 (ortalaması 4,0), cümlede "ortalama 3,6" yazıyor. Ölçüt başına yuvarlama farkı.
- **[P1]** Arama sonucu ve hatası formun altında kalıyor; arama bitince oraya kaydırılmıyor.
- Gece modunda bilgi çubuğu zemine karışıyor.
- Mekân formunda "Kaydet" düğmesi en altta.
- Geri al süresi (6 sn) kısa.
- Girişsiz aramada "Giriş yap" iki kez var.

---

# Onuncu tur: iki bağımsız ajan (15 Ekim 2026, ertelenen sorunlar, satır kapaklarının kaldırılması ve iPad düzeninden sonra)

> Dokuzuncu turdaki talimat kullanıldı. Görüntü seti 91 dosya (`tur11`). Tek fark: iPad görüntülerinde yan menü ve Arşiv'deki liste–ayrıntı düzeni tanıtıldı.

**Puan: 30/40 ve 28/40, ortalama 29.** Bağımsız ölçümlerin seyri: 29 → 30 → 30 → 29 → 30,5 → 29.

| Ölçüt | A | B |
|---|---|---|
| 1. Durumun görünürlüğü | 3 | 3 |
| 2. Gerçek dünyayla uyum | 3 | 3 |
| 3. Kullanıcı denetimi | 3 | 3 |
| 4. Tutarlılık | 3 | **2** |
| 5. Hata önleme | 3 | 3 |
| 6. Tanıma | 3 | **2** |
| 7. Esneklik | 3 | 3 |
| 8. Estetik | 3 | 3 |
| 9. Hatalardan kurtulma | 3 | 3 |
| 10. Yardım | 3 | 3 |

**Değerlendirme:** Puan düştü. Önceki turda B'nin 4 verdiği dil ölçütü yeniden 3 oldu. B, tutarlılık ve tanımayı 2'ye indirdi. Düşüşün bir kısmı bu turdaki değişikliklerden geliyor:
- Formlara eklenen ikinci "kaydet" (başlıktaki ✓) tutarsızlık sayıldı.
- Gece modunda turkuaza çevrilen seçili kutu, iki ajana göre altın ana eylemle yarışıyor.
- Kota metnindeki "daha önce yapılmış bir arama da yok" cümlesi önbellek mantığını kullanıcıya sızdırıyor.

İki ajan da iPad liste–ayrıntı düzenini, arama hata durumlarını ve özgünlüğü olumlu buldu.

**İki ajanın birlikte bulduğu sorunlar:**
1. **[P2] Büyük yazıda lezzet izi:** Mekân sayfasında %200 yazıda etiket ile kareler arasında boşluk yok ("Fiyat / değer■■■■", `taste_mark.dart`).
2. **[P2] Arşiv'de kalıcı hareket talimatı:** "Sağa kaydır… Sola kaydır… Uzun bas…" satırı gizli hareketleri telafi ediyor. Uzun basma menüsünde "Sil" ve "Gittim" yok.
3. **[P3] Kendi listende "Kaydedilenlere ekle":** Yer imi yalnızca başkasının listesinde anlamlı (`list_detail_screen.dart:107`).
4. **Gece:** Seçili kutunun açık turkuazı öne çıkıyor; çizilmiş kapaklar gece çok soluk.

**Yalnızca A'nın bulduğu sorunlar:**
- **[P1]** Dosyaya dışa aktarma var, geri yükleme yok; "yedek" sözü sahte bir güvence veriyor.
- **[P1]** Alttan açılan menüler sekme çubuğunu perdelemiyor (`useRootNavigator` yok).
- Tutarlılık kırıkları: Etkinlik'te deneyim başlıkları italik değil, "Fotoğrafı kaldır" stili, hesap ekranında düğme genişlikleri, girişli hesap satırında giriş simgesi.
- Kota boş durumunda önbellek mantığı sızıyor.
- Keşfet'te "Son eklediklerin" Arşiv'i tekrarlıyor.

**Yalnızca B'nin bulduğu sorunlar:**
- **[P1]** Lezzet izi kareleri yuvarlanmış değeri çiziyor: 4,5 beş dolu kare, sayı 4,5.
- **[P2]** Formda çift kaydet (başlıktaki ✓ ve alttaki düğme).
- "Sonuç yok" ekranında filtre yoksa eylem yok.
- 2x'te Keşfet ipucu kartı ilk ekranı kaplıyor.

# On birinci tur: iki bağımsız ajan (15 Ekim 2026, tabak puanlama ve bileşen penceresi düzeltmesinden sonra)

Aynı sabit talimat; görüntü klasörü `tur12` (97 dosya). İnceleme listesine yeni ekranlar eklendi: `deneyim-tabak`, `siralama`, `katman-tabak-ekle`.

| Ölçüt | A | B |
|---|---|---|
| 1. Sistem durumu | 3 | 3 |
| 2. Gerçek dünya | 3 | 3 |
| 3. Kontrol | 3 | 3 |
| 4. Tutarlılık | 3 | 2 |
| 5. Hata önleme | 3 | 3 |
| 6. Tanıma | 2 | 2 |
| 7. Esneklik | 3 | 3 |
| 8. Estetik | 3 | 3 |
| 9. Hatalardan kurtulma | 3 | 3 |
| 10. Yardım | 3 | 3 |
| **Toplam** | **29** | **28** |

Ortalama 28,5 (önceki tur 29). Seyir: 29 → 30 → 30 → 29 → 30,5 → 29 → 28,5.

**Değerlendirme:** Tabak puanlama iki ajana göre de ürünün en değerli kısmı oldu ("Bir dahaki sefere" notu, tabak geçmişi, sıralama). Puanı aşağı çeken, aynı özelliğin forma getirdiği yük: deneyim formu iki ekrandan üç ekrana uzadı.

**İki ajanın birlikte bulduğu sorunlar:**
1. **[P1] Deneyim formu uzun, "öneri" kavramı çakışıyor:** "Önerdiğin ürünler" alanı tabak kartlarıyla, "Bu deneyime göre öneriyorum" ise "Tekrar gider misin?" ve mekândaki öneriyle çakışıyor. Burger kartında 5 bileşen × 3 tam genişlikte düğme var.
2. **[P2] Tabak kartı yoğun:** Bileşen başına üç büyük düğme yerine satır içi küçük üçlü seçim.
3. **[P2] "Sonuç yok" çıkmazı:** Filtre yoksa bir sonraki adım sunulmuyor.
4. **Gizli hareketler ve sözlük:** Uzun basma ve kaydırma yalnızca ipucuyla öğretiliyor; "karne" ve "lezzet izi" ancak Ayarlar'ın en altındaki sözlükte açıklanıyor.
5. **Gece:** Seçili kutunun gece dili gündüzden farklı.

**Yalnızca A'nın bulduğu sorunlar:**
- **[P1]** Ekran okuyucuda başlık işareti (`header: true`) yok; arama hataları ve kota canlı bölge olarak duyurulmuyor.
- **[P2]** Puan dili: "Lezzet 4", "Ortalama karnen 3,6", "Karne 3,8" yan yana; tabak özetindeki "1/2" muğlak.
- Puanın yeniden dokununca silindiği anlatılmıyor.
- "Kahve sıralamam" ile "Kahve sıralaman" farkı.
- Filtre kutuları 390 pt'de tek kutu alta düşecek biçimde kırılıyor.

**Yalnızca B'nin bulduğu sorunlar:**
- **[P1]** Listelerdeki küçük lezzet izi anlaşılmıyor; yalnızca sayı gösterilsin.
- **[P2]** Liste satırlarında görsel yok. Not: kullanıcı satır kapaklarını bilerek kaldırttı; bu öneri uygulanmayacak.
- Arama hakkı bitince "Ara" düğmesi basılabilir kalıyor.
- "+ Mekân ekle" Keşfet'te bağlantı, Arşiv'de altın düğme.
- Gece ayırıcı çizgileri yaklaşık 2:1 kontrastta; karne kareleri parlak.

# On ikinci tur: iki bağımsız ajan (15 Ekim 2026, on birinci tur düzeltmeleri ve yeni içerikten sonra)

Aynı sabit talimat; görüntü klasörü `tur13` (101 dosya). İnceleme listesine rehber sayfası eklendi.

| Ölçüt | A | B |
|---|---|---|
| 1. Sistem durumu | 3 | 3 |
| 2. Gerçek dünya | 3 | 3 |
| 3. Kontrol | 3 | 3 |
| 4. Tutarlılık | 3 | 3 |
| 5. Hata önleme | 3 | 4 |
| 6. Tanıma | 4 | 3 |
| 7. Esneklik | 3 | 3 |
| 8. Estetik | 3 | 3 |
| 9. Hatalardan kurtulma | 3 | 3 |
| 10. Yardım | 3 | 4 |
| **Toplam** | **31** | **32** |

Ortalama 31,5; şimdiye kadarki en yüksek (önceki tur 28,5). Seyir: 29 → 30 → 30 → 29 → 30,5 → 29 → 28,5 → 31,5.

**Değerlendirme:** İlk kez 4 puanlar geldi: A tanımaya ("Bir dahaki sefere" döngüsü, önceki tabak çipleri), B hata önlemeye ve yardıma (rehber, bağlamsal açıklamalar). Tutarlılık iki ajanda da 3. İkisi de "Bir dahaki sefere" döngüsünü ürünün asıl ayırt edici değeri saydı.

**İki ajanın birlikte bulduğu sorunlar:**
1. **Gece seçili kutu:** `chosen` #2B4F57 zemine 1,9:1; seçim neredeyse yalnızca onay işaretiyle anlaşılıyor (önceki turda kaldırılan açık kenar bu turda geri istendi).
2. **"…" simgesi büyük yazıda büyümüyor** (20 pt sabit); A'ya göre geri ve düzenle simgeleri de.
3. **"Mekân ekle" ağırlığı:** Keşfet'te ikincil, Arşiv'de altın (B: kural koyun; A: altın düğme kalıbı her ekranda tekrar ediyor).
4. **Deneyim formu hâlâ ağır:** A sıra (karne üstte, bileşenler bağlantı arkasında) ister; B her açılışta görünen yardım metinlerinin ilk kullanımdan sonra kısalmasını ister.

**Yalnızca A'nın bulduğu sorunlar:**
- **[P2]** Örnek metin her mekânda kahve odaklı ("O sabahki ilk fincan" burgercide de).
- **[P2]** Tek tabaklık sıralama gösteriliyor; en az 3 tabakla açılsın.
- Gece yıl özetindeki çubuklar krem; `mark` kuralıyla çelişiyor.
- Profilde mekân adı kesiliyor; yıl özetinde "keşfettin" sayısına gidilmemiş mekân giriyor.

**Yalnızca B'nin bulduğu sorunlar:**
- **[P1]** Dışa aktarılan yedek geri yüklenemiyor (ertelenmiş iş).
- **[P2]** ↑/↓ okları tabak kartında aç/kapa, liste formunda sıralama: aynı simge iki anlam.
- **[P2]** "Bugün gidiyorum" haritayı açıyor ama etiketi söylemiyor.
- Kota ve sunucu sınırı durumlarında "elle ekle" çıkışı yok; rehberde düz tırnak.
- B gece fotoğrafların kısılmadığını yazdı; kod (`nightPhotoDim`, bütün kapaklar) ve A kısıldığını doğruluyor. Kısma bilerek hafif (%14).

# On üçüncü tur: iki bağımsız ajan (16 Ekim 2026, on ikinci tur düzeltmeleri ve dosyadan geri yüklemeden sonra)

Aynı sabit talimat; görüntü klasörü `tur14` (101 dosya). İki ajan da bir kez kullanım sınırı, B bir kez de bilgisayarın uykuya geçmesi yüzünden yarıda kaldı; aynı talimat ve görüntülerle yeniden çalıştırıldı.

| Ölçüt | A | B |
|---|---|---|
| 1. Sistem durumu | 3 | 3 |
| 2. Gerçek dünya | 3 | 3 |
| 3. Kontrol | 3 | 3 |
| 4. Tutarlılık | 3 | 3 |
| 5. Hata önleme | 3 | 3 |
| 6. Tanıma | 3 | 3 |
| 7. Esneklik | 3 | 3 |
| 8. Estetik | 3 | 3 |
| 9. Hatalardan kurtulma | 3 | 3 |
| 10. Yardım | 4 | 4 |
| **Toplam** | **31** | **31** |

Ortalama 31 (önceki tur 31,5). Seyir: 29 → 30 → 30 → 29 → 30,5 → 29 → 28,5 → 31,5 → 31.

**Değerlendirme:** Puan yerinde kaldı. İki ajan da yardıma 4 verdi (rehber ve bağlamsal yardım satırları). Geçen tur 4 alan tanıma ve hata önleme 3'e döndü; ikisi de satırdaki küçük lezzet izini "öğrenilmesi gereken kod" saydı. Dosyadan geri yükleme ve gece seçili kutu artık sorun olarak geçmiyor.

**İki ajanın birlikte bulduğu sorunlar:**
1. **[P1] Satırdaki lezzet izi okunmuyor:** 4×5 kare ölçüt adları olmadan anlaşılmıyor; satırda sayı (ve en güçlü ölçüt ya da tek çubuk), dört ölçütlü iz yalnızca mekân sayfasında.
2. **[P1/P2] Tabak kartı ağır:** açılınca 5 bileşen × 3 kenarlı düğme; sütun başlıklarını bir kez yazmak ya da seçilmemişleri kenarsız yapmak.
3. **Gece yıl özeti:** "Lokanta" dilimi açık gri, turkuazla hiyerarşisi zayıf.
4. **İpucu kartları** Keşfet ve Arşiv'in üstünde içeriği itiyor.

**Yalnızca A'nın bulduğu sorunlar:**
- **[P2]** Karnedeki gidişat cümlesi "2 puanlı deneyimin" "2 puan almış" diye okunuyor.
- **[P2]** "3 kayıt" (DESIGN'a göre deneyim/mekân), mekân formunda "(isteğe bağlı)", "Fotoğrafı kaldır" alt çizgisiz.
- Gece iki ayrı "seçili" turkuazı (`chosen` ve `mark`).
- Kota durumunda kapalı "Ara"nın nedeni düğmenin yanında değil.

**Yalnızca B'nin bulduğu sorunlar:**
- **[P1]** %200'de satır başlığı kelime ortasından kırılıyor ("Mahalle Lahmacuncus / u").
- **[P2]** Yatay kaydırılan çip şeritlerinde kaydırılabildiği belli değil (kesik "Öneriyoru").
- **[P2]** Ayarlar'da dışa aktar ve geri yükle aynı yukarı ok.
- %200'de Bugün kartı düğmeleri metne yapışık; uzun basma menüsünde "Vazgeç" yok; "Fotoğrafı kaldır" nötr renkte.
- B yine gece fotoğrafların kısılmadığını yazdı; kod kısıldığını doğruluyor (%14, bilerek hafif).

# On dördüncü tur: iki bağımsız ajan (16 Ekim 2026, on üçüncü tur düzeltmelerinden sonra)

Aynı sabit talimat; görüntü klasörü `tur15` (101 dosya).

| Ölçüt | A | B |
|---|---|---|
| 1. Sistem durumu | 3 | 3 |
| 2. Gerçek dünya | 3 | 4 |
| 3. Kontrol | 3 | 3 |
| 4. Tutarlılık | 3 | 3 |
| 5. Hata önleme | 3 | 3 |
| 6. Tanıma | 3 | 2 |
| 7. Esneklik | 3 | 3 |
| 8. Estetik | 3 | 3 |
| 9. Hatalardan kurtulma | 4 | 3 |
| 10. Yardım | 3 | 3 |
| **Toplam** | **31** | **30** |

Ortalama 30,5 (önceki tur 31). Seyir: 29 → 30 → 30 → 29 → 30,5 → 29 → 28,5 → 31,5 → 31 → 30,5.

**Değerlendirme:** Son üç tur 30,5–31,5 aralığında; puan bu yöntemle doygunluğa ulaştı. Her turda düzeltilen bulgunun yerine aynı ağırlıkta yeni ve kimi zaman bir önceki turla çelişen bulgu geliyor:
- Bileşen seçimi üç turda üç biçim istendi: tam genişlik düğmeler (çok kalabalık), satır içi küçük düğmeler (hâlâ kalabalık), başlıklı kutu tablosu (bu tur: "onay kutusu gibi", "başlıklar kaydırınca kayboluyor").
- Gece seçili kutu: açık kenar (odak halkası gibi), kenarsız koyu (zemine yakın), turkuaz (bu turda sorun sayılmadı).

Yöntemin sınırı: değerlendiriciler uygulamayı kullanamıyor, yalnızca görüntü ve koda bakıyor. ROADMAP'teki "gerçek kullanım" adımı (bir iki hafta gerçek mekânlarla kullanıp takılınan yerleri not etmek) bundan sonra daha çok bilgi verir.

**İki ajanın birlikte bulduğu sorunlar:**
1. **Bileşen tablosu:** kutular onay kutusu gibi okunuyor (tek seçim); başlıklar uzun listede kayboluyor. İkisi de satırda seçili kararın adının yazılmasını ya da üç parçalı seçimi öneriyor.
2. **Deneyim formu uzun, kaydet en sonda.**
3. **Yardım metni yükü ve öğrenilmesi gereken kavramlar** (lezzet izi, altın kenar).
4. **Gece altın düğme** büyük ve parlak.

**Yalnızca A'nın bulduğu sorunlar:**
- "Beğenmediğin: iç" tabak adı olmadan belirsiz; profilde "En çok önerdiğin … 2 deneyim" yanlış okunuyor.
- Deneyim formunda büyük "3,8" ölçeksiz; düzenlemede gidişat bu deneyimi de içeriyor.
- Gece onay kutusu krem (seçili kutu ve puan kareleri turkuaz).
- Kaydırma etiketi yalnızca "Gittim" (durum mu eylem mi belli değil).

**Yalnızca B'nin bulduğu sorunlar:**
- **[P1]** "Tekrar gider misin?" başlangıçta "Belki" seçili; cevapsız durum yok.
- Kalan arama hakkı boştayken görünmüyor.
- Karne ekran okuyucuda 20 ayrı düğme (ölçüt başına ayarlanabilir öğe önerisi).
- "Bugün gidiyorum" 390 pt'de iki satıra kırılıyor; her ekrandaki "GURME" bandı başlığı tekrarlıyor.
- Alt sayfanın üst çizgisi gece parlak krem.

# On beşinci tur: iki bağımsız ajan (16 Ekim 2026, telefonda ilk denemenin düzeltmelerinden sonra)

Talimat bu turdan itibaren `docs/TASARIM_OLCUM_TALIMATI.md` dosyasında; iki ajana aynısı verildi. Görüntü klasörü `tur16` (108 dosya; yeni: `yil-kapagi-*`, `durum-arama-kisisel-sinir`). Bu turdan önce yapılanlar: iOS'ta kenardan geri kaydırma, yatay şeritlerin kaydırılması, yargıların telefonda yan yana dizilmesi, seçili kutuda tikin kaldırılması, yıl özetinin hikâye boyutunda kapakla paylaşılması, defterin hesaba bağlanması.

| Ölçüt | A | B |
|---|---|---|
| 1. Sistem durumu | 3 | 4 |
| 2. Gerçek dünya | 3 | 3 |
| 3. Kontrol | 3 | 4 |
| 4. Tutarlılık | 3 | 3 |
| 5. Hata önleme | 3 | 3 |
| 6. Tanıma | 3 | 3 |
| 7. Esneklik | 3 | 3 |
| 8. Estetik | 3 | 3 |
| 9. Hatalardan kurtulma | 4 | 4 |
| 10. Yardım | 3 | 4 |
| **Toplam** | **31** | **34** |

Ortalama **32,5** (önceki tur 30,5; şimdiye kadarki en yüksek). Seyir: 29 → 30 → 30 → 29 → 30,5 → 29 → 28,5 → 31,5 → 31 → 30,5 → 32,5. "Hatalardan kurtulma" iki ajanda da 4; B ayrıca sistem durumu, kontrol ve yardıma 4 verdi. İkisi de tasarımı "bu ürün için yapılmış" buldu.

**Ölçüm sorunu (ikisi de yazdı):** Onay penceresi, tarih seçici ve "Geri al" bilgi çubuğu `katman-*` görüntülerinde çıkmıyor, yalnızca alttaki ekran var (A'ya göre ipucu ve hızlı ekleme sayfası da). Ajanlar bunları kodda doğruladı. Görüntü yakalama yöntemi düzeltilmeli.

**İki ajanın birlikte bulduğu sorunlar:**
1. **Büyük yazıda kelime bölünmesi:** Listelerim sekmesinde "Kaydedil / en"; yıl ekranında "Yelde…" kısalıyor.
2. **Mekân türü serbest metin:** Tabak türleri ve çizilmiş kapak bu metinden anahtar kelimeyle çıkarılıyor; yazım farkı sessizce "Diğer"e düşüyor.
3. **Yıl kapağında "14 kez gittim":** Kural sayımın "deneyim" olarak yazılmasını istiyor (A ayrıca kapakta "Diğer %18"i yazdı).
4. **Arama sınırı durumları farklı düzenlerde** (kota, günlük sınır, kişisel sınır).
5. **"Bir daha söyleme" hata renginde.**
6. **Liste görünürlüğü iki yerde seçiliyor** (formda ve liste sayfasında); formdaki ipucu, liste özelken görünmeyen "Yayınla ve paylaş" düğmesine gönderiyor.

**Yalnızca A'nın bulduğu sorunlar:**
- Gece yıl ekranındaki karakter çubuğunda "Kahve" yazısı 2,76:1.
- Liste formundaki "+ Mekân ekle" küçük etiket, dokunma alanı yaklaşık 34 pt; satırlarda çift çizgi.
- "Çıkış yap" onay sormuyor (defter cihazdan kaldırılıyor).
- 11 simge sabit boyutta, büyük yazıyla büyümüyor.
- "Ziyaret tarihi", "Mekânı sil?" gibi çeviri kokan ifadeler; yedek mesajında ham hata kodu.

**Yalnızca B'nin bulduğu sorunlar:**
- 2x yazıda deneyim formunun puan satırı sıkışıyor.
- Liste kapağında ham adres ("api.gurme.app/api/gurme/share/…") iki satıra bölünüyor.
- Geri alınabilen liste silmede yine onay penceresi açılıyor.
- Rehberde düz ve kıvrık kesme işareti karışık; liste notu iki ayrı adla anılıyor.
- Gece seçili kutudaki yazı ince görünüyor.

Bu turun bulgularının hepsi düzeltildi (`d8db14c`, `837d502`). Katman görüntüleri artık pencereyi, tarih seçiciyi ve bilgi çubuğunu gösteriyor.

# On altıncı tur: iki bağımsız ajan (16 Ekim 2026, aylık ve yıllık paylaşımdan sonra)

Talimat `docs/TASARIM_OLCUM_TALIMATI.md`. Görüntü klasörü `tur17`, 139 dosya; yeni olanlar: `ay-kapagi-*`, `yil-seti-*` ve düzeltilmiş `katman-*` görüntüleri. Önceki raporlar ajanların erişebileceği klasörden çıkarıldı.

| Ölçüt | A | B |
|---|---|---|
| 1. Sistem durumu | 3 | 4 |
| 2. Gerçek dünya | 3 | 4 |
| 3. Kontrol | 3 | 4 |
| 4. Tutarlılık | 3 | 3 |
| 5. Hata önleme | 3 | 4 |
| 6. Tanıma | 3 | 4 |
| 7. Esneklik | 3 | 3 |
| 8. Estetik | 3 | 4 |
| 9. Hatalardan kurtulma | 4 | 4 |
| 10. Yardım | 3 | 4 |
| **Toplam** | **31** | **38** |

Ortalama **34,5**; önceki tur 32,5. Seyir: … → 30,5 → 32,5 → 34,5. İki ajan arasındaki 7 puanlık fark, değerlendirenden kaynaklanan oynamanın büyük olduğunu gösteriyor. A önceki turla aynı puanı verdi. İkisi de tasarımı ürüne özel buldu, P1 bulgu yok.

**A'nın bulguları:**
- [P2] Hızlı eklemeden ayrıntılı forma geçince yazılanlar kayboluyor.
- [P2] 2x yazıda "Kaydedile / n". Önceki turun düzeltmesi yuvarlama yüzünden işe yaramamış; görüntüde doğrulandı.
- [P2] Satırdaki lezzet izinin ipucu ve ekran okuyucu etiketi yuvarlanmış puan söylüyor.
- [P3] Yıl setinde "Diğer" satırı ve büyük sayı tablosu var; DESIGN.md ikisini de yasaklıyor.
- [P3] Hızlı eklemede iki tutma çubuğu var, bağlantı tema dışı.
- [P3] Ekleme eylemleri üç biçimde.
- [P3] Her deneyimde "Öneriyorum" yazıyor; "Söyleme:" italik.
- [P3] Bozuk metinler: "Neden bu", kapasite, "Adresleri seç", rehber, "Ayımı paylaş", karne satırı.
- Ayrıca: ipucu baloncuğu tema dışı; 2x karnede ölçüt adı yanda kalıyor; profildeki son deneyim notu kesiliyor; sayfa noktaları küçük.

**B'nin bulguları:**
- [P2] Filtre şeritleri harf ortasından kesiliyor.
- [P2] Arama hatasında iki ana eylem var ("Ara" ve "Tekrar dene").
- [P3] Kaydırma hareketi yalnızca tek seferlik ipucuyla anlatılıyor.
- [P3] Son aramalar yok.
- [P3] Giriş kapalı derlemede arama çıkmaz yola gönderiyor.
- [P3] Uzun tabak kartında sütun başlıkları kayboluyor.
