# Gurme — Durum ve Yol Haritası

Bu dosya, projede verilen kararları, şu ana kadar yapılanları ve kalan işleri özetler. Son güncelleme: 16 Ekim 2026.
Yeni bir çalışma oturumu (insan ya da Claude) buradan okuyarak kaldığı yerden devam edebilir.

## Ürün

Gurme iki parçalı bir uygulama:

- **Kişisel lezzet defteri:** Gidilen ve gidilecek mekânlar, ziyaret notları ve fotoğraflar. Bunlardan oluşan küratör listeleri özel, bağlantıyla erişilen ya da herkese açık olarak paylaşılabiliyor.
- **Yapay zekâ destekli mekân araması:** Google Places verisini ve yorumların yapay zekâ özetini kullanan keşif özelliği. Bulunan mekân tek dokunuşla deftere eklenebilir.

Expo uygulamasında yalnızca defter ve liste paylaşımı vardı. Flutter uygulaması (`artifacts/app`) her iki parçayı da içeriyor ve Expo'nun yerini alıyor.

## Verilen kararlar

| Konu | Karar |
|---|---|
| Platform | iOS ve Android |
| Mobil teknoloji | **Flutter**. Expo uygulaması Flutter ile değiştiriliyor; Flutter uygulaması bütün özellikleri içeriyor, Expo henüz kaldırılmadı. |
| Depo yapısı | **Tek depo (monorepo).** Flutter uygulaması bu depoda. Dart API istemcisi `lib/api-spec/openapi.yaml` dosyasından otomatik üretiliyor. |
| Barındırma | **Google Cloud Run.** Proje `gurme-511606`, hizmet `gurme-api` (europe-west3), en fazla 1 örnek. Adres: `https://gurme-api-816165382305.europe-west3.run.app`. Sırlar Secret Manager'da. |
| Backend | Mevcut TypeScript/Express 5 sunucusu korunuyor. |
| Veritabanı | Postgres + Drizzle, **Neon** (havuzlu bağlantı, `sslmode=verify-full`). İleride gerekirse Cloud SQL. |
| Giriş | **Firebase Auth** (Google, Apple, e-posta). Google girişi gerçek cihazda doğrulandı; e-posta girişi kodda hazır ama gerçek hesapla denenmedi. iOS'ta Google ile giriş sunulduğu için Apple ile giriş de zorunlu; Apple Developer hesabı bekliyor. |
| Kötüye kullanım koruması | **Firebase App Check** kurulu ama henüz zorunlu değil (`APP_CHECK_ENFORCE=false`). Zorunlu olunca arama API'sini yalnızca gerçek uygulama çağırabilecek. Ayrıca sunucuda Google Places için günlük istek sınırları var. |
| Dosya depolama | **Firebase Storage**. Defter (`journal.json`) ve fotoğraflar kullanıcı başına buluta yedekleniyor; defter Postgres'e taşınmadı. |
| Defter ve hesap | **Defter hesaba bağlı.** Çıkışta defter buluta yüklenip cihazdan kaldırılıyor; yüklenemezse çıkış yapılmıyor. Başka hesabın defteri yeni hesaba hiçbir zaman aktarılmıyor. Girişsiz tutulan defter ilk giriş yapan hesaba katılıyor. |
| Reklam | **AdMob.** Esas olarak ödüllü reklam ("video izle, +1 arama"), ödül sunucuda doğrulanacak (SSV). Arama sonuçları arasında en fazla bir yerel (native) reklam olacak. Defter ekranlarında banner olmayacak. |
| Gelir | Reklam + ileride premium abonelik (reklamsız kullanım, daha fazla arama). |
| Filtreler | Alkolsüz, helal, glutensiz ve çölyak filtreleri arama ekranında. Helal seçilince alkolsüz de aranır. |

## Maliyet modeli

Kaynak: Google Places API (New) fiyatları, 2026. Fiyatlar değişebilir, güncel durum Google'ın fiyat sayfasından kontrol edilmeli.

- Faz 3'ten önce önbellekte olmayan bir arama yaklaşık **0,25–0,37 $** tutuyordu. Maliyetin büyük kısmı her aramada 8–12 kez yapılan Place Details çağrısından (Enterprise + Atmosphere katmanı, 1000'de 25 $) geliyordu. Yapay zekâ çağrısının payı 1 sentin altında.
- Faz 3 sonrası bir arama yaklaşık **0,04–0,05 $**; önbellek isabetleri ve kayıtlı analizlerle ortalama daha da düşüyor.
- Enterprise katmanında ayda 1000 ücretsiz çağrı var.
- **Mekân fotoğrafları:** Her fotoğraf iki Google isteği: mekânın fotoğraf listesi (yalnızca `photos` alanı) ve fotoğrafın adresi. Arama bütçesinden ayrı günlük sayaç `PLACES_PHOTO_DAILY_LIMIT`, 200 istek, yani günde en fazla 100 fotoğraf. Kaba tahmin en kötü günde 1–2 $; güncel fiyatla doğrulanmadı.

### Kurallar

- Arama **iki aşamalı.** Önce yalnızca Text Search yapılır ve liste hemen gösterilir. Yapay zekâ analizi yalnızca ilk 3 mekân için ya da kullanıcı bir mekânı açtığında yapılır.
- Yapay zekâ özeti **mekân bazında** ve **Postgres'te** (`place_insights`) saklanıyor, tüm kullanıcılar aynı önbellekten yararlanıyor. Bir mekân tek seferde analiz edilir ve bütün özellikleri (alkol, helal, gluten, ambiyans) birlikte çıkarılır. Filtreler bu hazır bilgi üzerinden çalışır.
- Google'ın kullanım koşulları gereği **ham yorumlar uzun süre saklanmıyor.** Kalıcı olarak saklanacak olanlar yalnızca `place_id` ve kendi ürettiğimiz özet.
- **Google fotoğrafları da saklanmaz.** Fotoğraf adı ve adresi her istekte tazesi alınır; uygulama yalnızca oturum boyunca bellekte tutar. Fotoğrafı çekenin adı fotoğrafın üstünde gösterilir ve profiline bağlantı verir.
- Giriş yapmış her kullanıcıya **günde 3 ücretsiz yapay zekâ araması.** Önbellekten dönen aramalar bu sayıya dahil edilmez. Ödüllü reklamla ek arama hakkı kazanılabilir.
- **Bütçe:**
  - Kapalı beta: aylık 50 $ tavan.
  - Açık lansman: aylık 100–150 $.
  - Google Cloud'da bütçe uyarıları (%50, %80 ve %100'de). Kurulup kurulmadığı **teyit edilmeli**; 15 Ekim'de komut satırından doğrulanamadı.
  - **Günlük tavan sunucuda:** Google konsolunda deneme hesabında Places kotası düzenlenemediği için sınırı sunucu koyuyor. Arama ve otomatik tamamlama için `PLACES_DAILY_LIMIT` (100 istek), mekân fotoğrafları için `PLACES_PHOTO_DAILY_LIMIT` (200 istek). Sınır dolunca Google'a istek gitmez. Her kullanıcının bu ortak sınırdan günlük payı var (`PLACES_USER_DAILY_LIMIT` 30, `PLACES_PHOTO_USER_DAILY_LIMIT` 40); tek hesap ortak sınırı bitiremez. Sayaçlar Türkiye gününe göre sıfırlanır ve bellektedir; bu yüzden hizmet tek örnekle çalışır. Bütçe uyarıları harcamayı durdurmaz; asıl tavanı bu sınırlar koyar.

### Filtre güvenilirliği

- **Alkolsüz:** Google'ın `servesBeer`, `servesWine` ve `servesCocktails` alanlarına dayanıyor, görece güvenilir.
- **Helal, glutensiz, çölyak:** Bu bilgiler yalnızca yorumlardan yapay zekâyla çıkarılıyor. Google bir mekân için en fazla 5 yorum döndürüyor, bu yüzden sonuçlar tahmin niteliğinde. Arayüzde **"mekânla teyit etmeden güvenme"** uyarısı gösteriliyor. Topluluğun onayladığı mekânları ayrı bir rozetle işaretlemek henüz yapılmadı; bunun için mevcut şikâyet ve bildirim altyapısı kullanılacak.

## Yapılanlar

### Faz 1 — Backend'in Replit'ten ayrılması ve hata düzeltmeleri (tamamlandı)

Dal: `claude/exciting-carson-3vqtgf`

- **Arama hataları (`artifacts/api-server/src/routes/search.ts`):**
  - Yapay zekâ çağrısı başarısız olunca alkolsüz aramalar boş dönüyordu ve bu hatalı sonuç 7 gün önbellekte kalıyordu. Artık analiz edilemeyen mekânlar özetsiz ("basic") gösteriliyor ve bu sonuç önbelleğe yazılmıyor.
  - Yalnızca "gizli keşif" mekânı kaldığında `classicPlace!` erişimi çöküyordu, düzeltildi.
  - Geniş arama sonuçları yanlışlıkla "spesifik eşleşme" sayılıyordu, düzeltildi.
  - Geçici konum (geocoding) hataları artık kalıcı olarak önbelleğe yazılmıyor.
  - `placeId` URL'ye kodlanarak ekleniyor. Hata yanıtları artık sunucunun iç hata mesajını dışarı vermiyor.
- **Koruma:**
  - IP bazlı hız sınırları eklendi. Tüm API için 15 dakikada 300 istek, arama için saatte 20, otomatik tamamlama için dakikada 60, liste oluşturma için saatte 20.
  - Tarayıcıdan erişim (CORS) `ALLOWED_ORIGINS` ortam değişkeniyle sınırlandı.
  - İstek gövdesi 100 KB ile sınırlandı. `trust proxy` Cloud Run için ayarlandı.
- **Altyapı:**
  - Replit dosyaları, mockup-sandbox klasörü, Replit Gemini entegrasyonu ve kullanılmayan paketler kaldırıldı.
  - Cloud Run için `artifacts/api-server/Dockerfile` eklendi.
  - pnpm 10.34.6 sürümü sabitlendi. `README.md` yazıldı.
- **Doğrulama:**
  - Tip kontrolü ve derleme hatasız.
  - Duman testi geçti: sağlık kontrolü yanıt veriyor, hatalı istek 400 dönüyor, izinsiz adresten gelen tarayıcı isteği reddediliyor, 21. arama isteği 429 ile engelleniyor.
  - Dockerfile adımları temiz bir klasörde çalıştırılıp doğrulandı, ancak imajın kendisi Docker servisi olmadığı için derlenmedi.

### Faz 3 — Aramanın yeniden tasarımı (tamamlandı)

- `search.ts` `src/search` altında modüllere bölündü (`google-places`, `filters`, `ranking`, `insights`, `insight-store`, `community`, `search-service`). Route yalnızca zod doğrulaması yapıyor.
- **Maliyet:** Text Search yorumları ve `servesBeer/Wine/Cocktails` alanlarını tek çağrıda alıyor (Enterprise + Atmosphere, 1000'de 40 $). Arama başına 8–12 Place Details çağrısı kalktı. Önbellekte olmayan bir arama ~0,25–0,37 $ yerine **~0,04–0,05 $**.
- **Uçlar:**
  - `POST /search`: tek Text Search, analizsiz hızlı liste. Kayıtlı analizi olan mekânlar onu içerir; `pendingInsights` ilk 3 analizsiz mekânı verir.
  - `POST /search/insights`: en fazla 5 mekân için analiz. Filtreye uymadığı anlaşılan mekânlar `excludedPlaceIds` ile döner.
  - `GET /places/{placeId}`: aramanın dışında açılan mekân sayfası.
  - `GET /autocomplete` artık OpenAPI'de tanımlı.
- Yapay zekâ analizi sorgudan bağımsız, mekân başına bir kez yapılıyor ve `place_insights` tablosunda tutuluyor; 30 günde yenileniyor. Ham yorumlar saklanmıyor; Google içeriği yalnızca boyutu sınırlı, 1 saatlik bellek önbelleğinde.
- Filtreler: alkolsüz, helal, glutensiz, çölyak. Yorum tahminine dayananlar `filterStatus` `likely`/`unverified` ile döner.
- Sorgu normalleştirme (Türkçe büyük/küçük harf, harf sadeleştirme). Kısa anahtar kelimeler tam kelime eşleşir ("bar", "Barış"ı alkollü saymaz). Eşzamanlı analiz istekleri aynı mekân için tek çağrıyı paylaşır.
- Hız sınırları: saatte 20 arama, 60 analiz.
- Testler: `pnpm --filter @workspace/api-server test` (node:test + tsx). `TEST_DATABASE_URL` verilirse gerçek Postgres'te entegrasyon testleri de çalışır.
- Not: spec'teki `yes`/`no` enum değerleri tırnak içinde olmalı. openapi-generator YAML 1.1 kullandığı için tırnaksız değerleri `true`/`false` okuyor.

### Faz 2 — Hesap sistemi ve kota (tamamlandı)

Backend:

- Firebase ID token ve App Check `firebase-admin` ile doğrulanıyor. `FIREBASE_PROJECT_ID` tanımlı değilse giriş ve kota kapalı, sunucu anonim çalışıyor (geliştirme). App Check (`X-Firebase-AppCheck`) arama, mekân ve otomatik tamamlama uçlarında; `APP_CHECK_ENFORCE=true` ise zorunlu.
- `users` ve `daily_usage` tabloları. Giriş yapmış kullanıcıya günde 3 ücretsiz arama (Türkiye saatiyle gece yarısı yenilenir). Hak tek SQL ifadesiyle düşülüyor, eşzamanlı isteklerde aşılmıyor. Önbellekten dönen aramalar sayılmıyor; hakkı biten kullanıcı önbellekteki sonucu alıyor, yeni arama `429 quota_exceeded`. Mekân analizi günde 40 istekle sınırlı. `bonus_searches` ödüllü reklam (Faz 5) için hazır.
- Kota durumu `SearchResponse` içinde ve `GET /me/quota` ucunda.
- Geri bildirim uçları girişle çalışıyor. `GET /feedback/:installationId` yalnızca kurulumun sahibine yanıt veriyor. Şikâyet eşiği kişi başına sayılıyor.
- Listeler: `owner_user_id`. Sahibi anahtarsız düzenleyip siliyor; `X-Owner-Key` başlığı eklendi (eski `Authorization: Bearer <anahtar>` da hesaba bağlanmamış listelerde çalışıyor). Cihaz anahtarlı listeler `POST /gurme/lists/{id}/claim` ile hesaba bağlanıyor. Hesaba bağlanmış liste başka hesaba devredilemez ve yalnızca o hesapla düzenleniyor (16 Ekim). Herkese açık liste dökümü en yeni 100 ile sınırlı.

Flutter:

- Firebase Auth (Google, Apple, e-posta) ve hesap ekranı. Giriş sonrası cihazdaki listeler otomatik olarak hesaba bağlanıyor.
- Kota aşımı ve "Arama için giriş yap" mesajları.
- Firebase bağlı (proje `gurme-511606`). Google girişi, kalıcı oturum ve bulut yedeği gerçek cihazda doğrulandı. Firebase'in istemci yapılandırması depoda. Kurulum adımları `artifacts/app/README.md` dosyasında.

### Altyapı kurulumu (tamamlandı, 8–15 Ekim 2026)

- **Google Cloud ve Firebase:** Proje `gurme-511606`, Firebase Blaze planı. Storage `gs://gurme-511606.firebasestorage.app`.
- **Secret Manager:** `DATABASE_URL`, `GOOGLE_PLACES_API_KEY`, `GEMINI_API_KEY`, `DEEPSEEK_API_KEY`, `ADMIN_API_KEY`. Değerleri hiçbir yere yazılmadı. Cloud Run'ın hizmet hesabına (`816165382305-compute@…`) bu sırlar için okuma izni verildi. Bu, varsayılan Compute hizmet hesabı; geniş yetkileri olabileceği için ileride yalnızca bu işe ayrılmış bir hesaba geçmek iyi olur.
- **Cloud Run:**
  - İmaj Cloud Build'de derleniyor ve Artifact Registry'deki `gurme` deposunda tutuluyor.
  - Ortam değişkenleri: `FIREBASE_PROJECT_ID`, `APP_CHECK_ENFORCE=false`, `NODE_ENV=production`, `PLACES_DAILY_LIMIT=100`, `PLACES_PHOTO_DAILY_LIMIT=200`.
  - Son sürüm `gurme-api-00002-v8h` (15 Ekim 2026).
- **Doğrulananlar:**
  - Sağlık kontrolü yanıt veriyor; girişsiz arama 401 dönüyor.
  - Simülatörde gerçek arama yapıldı; ilk 3 mekânın analizi geldi.
  - Google girişi, kalıcı oturum ve bulut yedeği çalışıyor.
- **Sunucu değişiklikleri:** Konum araması Geocoding API yerine Places Text Search ile yapılıyor; böylece anahtar tek API'ye kısıtlı kalıyor. Google Places günlük sınırları (`places-budget.ts`) eklendi.

### Faz 4 — Flutter uygulaması (devam ediyor)

- **Proje iskeleti ve Dart istemcisi:**
  - Uygulama `artifacts/app` klasöründe. Riverpod, go_router, Dio.
  - Tema Expo'daki renk ve yazı stillerinden aktarıldı. Fontlar uygulamayla birlikte paketleniyor.
  - Dart istemcisi `lib/api-client-dart` klasöründe (paket `gurme_client`, kök sınıf `GurmeClient`). `openapi-generator` v7.25.0 (dart-dio, json_serializable) **Docker üzerinden** çalışıyor, Java gerekmiyor. Üretim komutu: `pnpm --filter @workspace/api-spec run codegen:dart`. Paket adı `gurme_api` olamaz: spec'teki `gurme` etiketi zaten `GurmeApi` sınıfını üretiyor.
  - API adresi verilmezse canlı sunucu (Cloud Run). Başka sunucu için `--dart-define=API_BASE_URL=...`, bilgisayardaki geliştirme sunucusu için `API_BASE_URL=local`.
  - Dart'ın `toUpperCase()` yöntemi Türkçeye duyarsız. Bunun yerine `toUpperTr()` kullanılmalı.
  - `flutter analyze`, yolda "Kişisel" gibi Türkçe karakter olunca çöküyor. Yerine `dart analyze` kullanılmalı.
- **Defter ve liste ekranları:**
  - Keşfet, Arşivim (filtreler), mekân sayfası ve düzenleme, deneyim düzenleme, Listelerim (benim/kaydedilen/keşfet), liste sayfası ve düzenleme, paylaşılan liste, profil ve profil düzenleme.
  - Defter cihazda `journal.json` dosyasında, Expo'yla aynı biçimde tutuluyor. Fotoğraflar uygulama klasörüne kopyalanıyor.
  - Expo'daki şu hatalar Flutter'a taşınmadı: onay pencereleri her platformda çalışıyor; fotoğraflar kalıcı; sunucuda zaten silinmiş liste (404) yerelden de silinebiliyor.
  - Ziyaret tarihi tarih seçiciyle seçiliyor.
  - Expo'daki işlevsiz "bildir" düğmeleri alınmadı.
- **Yapay zekâ araması ve filtre paneli:**
  - İki aşamalı API: liste hemen gösteriliyor, ilk mekânların analizi ardından yükleniyor; filtreye uymayanlar listeden düşüyor. Eski aramanın geç gelen yanıtları yok sayılıyor.
  - Konum alanı otomatik tamamlamalı, profildeki şehir varsayılan.
  - Helal, glutensiz ve çölyak açıkken "doğrulanmamış, mekânla teyit edin" uyarısı.
  - Mekân sayfası (`/venue/:placeId`) ve "Deftere ekle". Eklenen mekân `googlePlaceId` saklıyor; aynı mekân ikinci kez eklenmiyor.
- **Etkinlik:** Profilden açılıyor; deneyimleri aylara bölünmüş bir zaman çizelgesinde gösteriyor. Bildirimler ekranı, topluluk bildirimleri olmadığı için kaldırıldı.
- **Crashlytics:** `firebase_setup.dart` hataları topluyor; sürüm derlemelerinde açık, geliştirme derlemesinde kapalı.
- **Bulut yedeği:** Giriş yapan kullanıcının defteri ve fotoğrafları Firebase Storage'a (`users/{uid}/`) otomatik yedekleniyor. Yeni cihazda girişte geri geliyor; iki cihazda yapılan değişiklikler birleştiriliyor. Postgres'te tam eşitleme yerine bu yol seçildi: backend değişmiyor, maliyet düşük. Ayrıntılar `artifacts/app/README.md` dosyasında, güvenlik kuralları `artifacts/app/firebase/storage.rules` dosyasında.
- **Tasarım önerileri (1–6):**
  - Erişilebilir palet: metinde turkuaz #2F7482 ve soluk #57696C (AA), 11 px küçük başlıklar, onay işaretli seçili kutular.
  - Keşfet'te "Bugün ne yesem?" önerisi.
  - Alttan açılan hızlı mekân ekleme sayfası; mekâna kaynak alanı.
  - Deneyimde tadım karnesi (4 ölçüt, ortalama, gidişat).
  - Listeyi 1080×1920 kapak görseli olarak paylaşma.
  - Profilde "Lezzet haritan": ayın özeti (tek sayfa) ve yılın özeti (en çok 8 sayfalık paylaşım seti, tek seferde sosyal medyaya).
- **Tasarım sadeleştirmesi:** Tasarım dili `artifacts/app/DESIGN.md` dosyasında. Boşluk (`Space`) ve yazı ölçeği koda işlendi, ekranlar ekran görüntüleri üzerinden sadeleştirildi, henüz çalışmayan ziyaret görünürlüğü ve bildirim tercihleri arayüzden kaldırıldı.
- **Görseller (15 Ekim 2026):** Mekân kapağı sırasıyla:
  1. Mekâna eklenen fotoğraf.
  2. Deneyimlerdeki en son fotoğraf.
  3. Google fotoğrafı. Yalnızca atfın sığdığı büyük kapaklarda (mekân sayfası, "Bugün ne yesem?", arama sonucunun sayfası) ve aramadan eklenen mekânlarda istenir.
  4. Türünden çizilmiş kapak: defter çizgileri üstünde fincan, simit, pasta, tencere, şiş, bardak, balık ya da tabak.

  Sunucuda yeni uç: `GET /api/places/:placeId/photo`. Giriş ister, mekân kimliği denetlenir.
- **Tasarım turları (7–15 Ekim 2026):** Ayrıntı `docs/TASARIM_*.md` dosyalarında ve `docs/CALISMA_GUNLUGU.md` günlüğünde.
  - "Kişisel defter" tasarım dili: lezzet izi (4×5 karelik karne çizimi), kullanıcının sözlerinin solunda çift altın çizgi, cümle içinde sayılar.
  - Gece modu, Ayarlar'dan açılıp kapanıyor (gündüz, gece, cihaza uy).
  - 32 simgelik kendi simge seti; büyük yazı (Dynamic Type) desteği; iPad'de okunur sütun, yan menü ve Arşiv'de liste–ayrıntı düzeni.
  - Geri al (silme, durum, listeler, fotoğraflar), kaydedilmemiş form uyarısı, kaydırma ve uzun basma eylemleri.
  - Arama hata ekranları (giriş, kota, günlük sınır, ağ yok, sunucu hatası, sonuç yok) ve nedenini söyleyen yedek hatası.
  - Profilde "defter portresi".
  - **Bağımsız ölçüm:** Nielsen'in 10 ölçütüyle ve 40 üzerinden, önceki raporları görmeyen ajanlarla yapılıyor. Sonuçlar 29, 30, 30 ve son turda iki ajanla 29 / 29 oldu; bulguların hepsi düzeltildi. 35 hedefi için plan `docs/TASARIM_35_PLANI.md` dosyasında.
- **Testler:** Uygulamada 291 test.
  - `screens_test` 17 ekranı dört çeşitte çiziyor: normal, büyük yazı, gece ve iPad.
  - `overlays_test` katmanları, `states_test` durum ekranlarını çiziyor.
  - Görüntüler `GURME_COVER_DIR` verilince kaydediliyor. Örnek defterde lisanslı fotoğraflar var (`test/fixtures/photos/LICENSE.md`).
- **Ayarlar:** Görünüm (gece modu), defterin yedeği ve dışa aktarma (JSON, fotoğraflar hariç), konum, veri kaynakları ve "Gurme nasıl çalışır".
- Depo `~/Developer/Gurme/flutter_gurme/gurme-kaynak-kodlari` klasörüne taşındı. Desktop iCloud ile eşitlendiği için iOS derlemesi imzalama adımında duruyor ve iCloud depoya `... 2.dart` gibi çakışma kopyaları bırakıyordu. Depo iCloud ile eşitlenen bir klasöre geri konmamalı.

## Bilinen açık sorunlar

### Backend

- **Herkese açık listeler:** İçerik denetimi yok. Döküm en yeni 100 listeyle sınırlı, gerçek sayfalama yok.
- **Bellek önbellekleri ve sayaçlar:** Arama sonuçları, Google yanıtları ve konum önbellekleri boyut sınırlı ama bellekte; sunucu yeniden başlayınca kayboluyor. Kalıcı olan yalnızca `place_insights`. Places günlük sayaçları da bellekte: sunucu gün içinde yeniden başlarsa sayaç sıfırlanır ve o gün sınır aşılabilir. Hizmet bu yüzden tek örnekle çalışıyor; kalıcı çözüm, sayaçları Postgres'e taşımak.
- **Kurulum kimliği:** Expo'da `Math.random` ile üretiliyordu. Flutter'da güvenli rastgele kaynak kullanılmalı; geri bildirim artık hesaba bağlı olduğu için risk düşük.

### Mobil (Expo)

Expo uygulaması (`artifacts/mobile`) Flutter'a geçiş tamamlanınca kaldırılacak. Bilinen hatalar (web'de onay pencereleri ve fotoğraflar, 404 liste, gereksiz konum izni, Replit bağımlılığı) Flutter'da tekrarlanmadı.

## Kalan işler

### Sizin yapmanız gerekenler

Google Cloud, Firebase, Neon ve Secret Manager kurulumu tamamlandı. Kalanlar:

1. **Bütçe uyarılarını teyit etmek:** Google Cloud Billing'de %50, %80 ve %100 uyarıları.
2. **Apple Developer hesabı:** Apple ile giriş (iOS'ta zorunlu) ve App Check için App Attest.
3. **Android:** Firebase'e SHA parmak izlerini eklemek ve App Check için Play Integrity'yi açmak. Ardından `APP_CHECK_ENFORCE=true`.
4. **Yönetimi açmak:**
   1. Neon'a yeni tabloları ve sütunları yüklemek (`pnpm --filter @workspace/db run push`; `list_reports`, `search_log`, ek kullanıcı ve liste sütunları).
   2. Sunucuyu yeniden yayınlamak.
   3. Kendi hesabına yönetici yetkisi vermek: `artifacts/api-server/scripts/set-admin.ts`.
5. **Gerçek kullanım:** Uygulamayı bir iki hafta gerçek mekânlarla kullanıp takılınan yerleri not etmek (`docs/TASARIM_35_PLANI.md`, adım 7).

### Faz 4 — Flutter uygulamasının kalanı

- **Yönetim, kalan:** Girişsiz liste yayınını kapatmak; girişsiz yayınlanan listenin sahibi engellenemiyor, yalnızca liste kaldırılabiliyor. Places sayaçları Postgres'e taşınınca panelde günler arası harcama da görünür; şu an yalnızca bugünkü bellek sayacı var.
- **Dart istemcisini yeniden üretmek:** `codegen:dart`. Bildirim ve yönetim uçları openapi.yaml'da var, ama Dart istemcisi Docker Hub ve Maven Central erişim sınırı yüzünden yeniden üretilemedi. Uygulama bu uçları şimdilik `moderation_repository.dart` içinde doğrudan Dio ile çağırıyor.

- **Harita görünümü (sıradaki iş, kullanıcı onayladı):** Arama sonuçlarını ve defteri haritada göstermek. Google Maps SDK (iOS/Android) kullanılacak. Google'ın iOS belgesine göre yerel harita gösterimi ücretsiz; fiyat sayfası teyit edilmeli. Arama sonuçlarının konumu zaten geliyor (`location` alanı). Para tutabilecek tek kalem, elle eklenen mekânların adresten konuma çevrilmesi (Geocoding); her mekân için bir kez yapılıp saklanacak. Statik harita ve Sokak Görünümü kullanılmayacak. Android ve iOS için paket adıyla sınırlandırılmış ayrı anahtarlar gerekiyor.
- **Tasarım 35 hedefi:** Gerçek kullanım notlarından sonra iki bağımsız ajanla son ölçüm (`docs/TASARIM_35_PLANI.md`).
- **App Check'i zorunlu yapmak:** Apple ve Android adımlarından sonra.
- **Places sayaçlarını Postgres'e taşımak:** Böylece hizmet birden çok örnekle çalışabilir.
- Tasarım dili korunacak:
  - Fontlar: Bodoni Moda ve Plus Jakarta Sans.
  - Renkler: kâğıt #F2F0EF, mürekkep #20373B, turkuaz #519CAB, altın #FFC64F.
- Geçiş bitince Expo uygulamasının (`artifacts/mobile`) kaldırılması.

### Faz 5 — Gelir

- AdMob ödüllü reklam ve sunucu tarafı doğrulama (SSV). Backend'de `bonus_searches` hazır.
- Arama sonuçlarında bir yerel (native) reklam.
- Onay ekranları: KVKK ve GDPR için Google UMP SDK, iOS'ta izleme izni (ATT).
- Premium abonelik (reklamsız kullanım, daha fazla arama).

### Faz 6 — Yayın

- Gizlilik politikası ve kullanım koşulları. Politikada şunlar yazmalı: aramalar (kelime, yer, sonuç) yönetim paneli için 90 gün saklanıyor; liste bildirimleri bildirenin hesabıyla tutuluyor.
- App Store ve Google Play gizlilik beyanları, yaş derecelendirmesi.
- Önce kapalı beta (TestFlight ve Play iç test kanalı), ardından açık lansman.


## Çalışma notları

- **Gizli değerler** yalnızca Secret Manager'da durur. API anahtarları depoya ya da sohbete yazılmamalı.
  - İstisna: Firebase'in istemci yapılandırması (`firebase_options.dart`, `GoogleService-Info.plist`, `google-services.json`). Firebase'in önerdiği gibi depodadır; içindeki istemci anahtarı her uygulamada bulunur, koruma güvenlik kuralları ve App Check ile sağlanır.
- Tip kontrolü her zaman kökten yapılmalı: `pnpm run typecheck`.
- **Flutter kontrolü:** `dart analyze` ve `flutter test --no-pub`. `--no-pub` olmadan paket güncellemesi ağda takılabiliyor.
- **Telefonda ya da simülatörde çalıştırma:** `flutter run` yeterli; canlı sunucuya bağlanır. Yerel sunucuyla: `flutter run --dart-define=API_BASE_URL=local` (Google fotoğrafları o zaman kapalı).
- `pnpm-workspace.yaml` dosyasındaki `minimumReleaseAge: 1440` ayarı bilerek konuldu: yeni yayımlanan paket sürümleri 1 gün geçmeden kurulmaz. Kaldırılmamalı.
- Cloud Run imajı depo kökünden derlenir:
  ```sh
  docker build -f artifacts/api-server/Dockerfile .
  ```
  Apple Silicon üzerinde `--platform linux/amd64` eklenmeli.
- Yayın, Cloud Build ve Cloud Run ile yapılır (depo kökünden; etiket olarak commit kısaltması):
  ```sh
  IMG=europe-west3-docker.pkg.dev/gurme-511606/gurme/api:$(git rev-parse --short HEAD)
  gcloud builds submit --project gurme-511606 --region europe-west3 \
    --config artifacts/api-server/cloudbuild.yaml --substitutions _IMAGE=$IMG .
  gcloud run deploy gurme-api --project gurme-511606 --region europe-west3 --image $IMG
  ```
  Ortam değişkenleri ve Secret Manager bağlantıları sürümler arasında korunur; yeni değişken `--update-env-vars` ile eklenir. Hizmet `--max-instances=1` ile çalışır, çünkü Places sayaçları bellektedir.
- Flutter, Docker, simülatör ve emülatör gerektiren işler geliştiricinin kendi bilgisayarında çalışan bir Claude Code oturumunda yapılmalı. Bunun için Claude Desktop uygulaması ya da `claude remote-control` komutu kullanılabilir.
