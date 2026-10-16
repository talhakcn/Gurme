# Gurme — Flutter uygulaması

iOS ve Android uygulaması. Expo uygulamasının (`artifacts/mobile`) yerini alacak.

## Çalıştırma

```sh
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api
```

`API_BASE_URL` verilmezse yerel sunucu varsayılır: `http://localhost:8080/api`. Android emülatöründe bu adres `http://10.0.2.2:8080/api` olur. API sunucusunu aynı portta başlatın:

```sh
PORT=8080 pnpm --filter @workspace/api-server run dev
```

## Yapı

```text
lib/
├── main.dart, app.dart   # Türkçe yerelleştirme; defter yüklenene kadar JournalGate
├── core/
│   ├── api/       # Dio + üretilmiş istemci (gurme_client) için Riverpod sağlayıcıları
│   ├── platform/  # Paylaşım penceresi, harita bağlantısı
│   ├── router/    # go_router; alt sekmeler ve üstte açılan sayfalar
│   ├── text/      # Türkçe büyük/küçük harf, sıralama, tarih
│   ├── theme/     # Renkler, fontlar, ThemeData
│   └── widgets/   # Editoryal bileşenler (Expo'daki Editorial.tsx karşılığı)
└── features/
    ├── journal/   # Defter: modeller, yerel kayıt, Keşfet, Arşivim, mekân ve deneyim ekranları
    ├── lists/     # Listeler: sunucu deposu, eşitleme, liste ekranları
    ├── profile/   # Profil ve profil düzenleme
    └── shell/     # Alt sekme çubuğu
```

- **API istemcisi:** `lib/api-client-dart` (paket adı `gurme_client`). `openapi.yaml`'dan üretilir, elle düzenlenmez. Yeniden üretmek için depo kökünde `pnpm --filter @workspace/api-spec run codegen:dart` komutunu çalıştırın.
- **Durum yönetimi:** Riverpod. **Yönlendirme:** go_router.
- **Fontlar:** Bodoni Moda ve Plus Jakarta Sans, `assets/fonts` altında uygulamayla birlikte paketlenir (OFL lisansı).
- **Büyük harf:** Metinleri `toUpperCase()` ile değil `toUpperTr()` ile büyütün. Dart'ın yöntemi "i" harfini "I" yapar.

## Firebase (giriş, App Check, Storage, Crashlytics)

Firebase `gurme-511606` projesine bağlıdır (`flutterfire configure`, 14 Ekim 2026). İstemci yapılandırması depodadır. Sunucu Cloud Run'da çalışır; uygulama adresini derlemede alır:

```sh
flutter run --dart-define=API_BASE_URL=https://gurme-api-816165382305.europe-west3.run.app/api
```

Aşağıdaki adımlar yeni bir Firebase projesi kurulurken izlenen sıradır.

Bir kez yapılacaklar:

1. Firebase projesine iOS (`com.gurme.gurme`) ve Android (`com.gurme.gurme`) uygulamalarını ekle. Uygulama kimliği mağazaya çıktıktan sonra değişemez; değiştirilecekse bundan önce değiştir.
2. Bu klasörde:
   ```sh
   dart pub global activate flutterfire_cli
   flutterfire configure --out=lib/core/firebase/firebase_options.dart
   ```
   Komut yer tutucunun yerine gerçek yapılandırmayı yazar, `google-services.json` ve `GoogleService-Info.plist` dosyalarını ekler, Crashlytics ve Google Services gradle eklentilerini kurar.
3. Authentication'da **Google**, **Apple** ve **E-posta/Şifre** sağlayıcılarını aç.
   - Apple: Xcode'da Runner > Signing & Capabilities > **Sign in with Apple** yeteneğini ekle.
   - Google (Android): Firebase'e uygulamanın SHA-1 ve SHA-256 parmak izlerini ekle.
   - Google girişi Firebase'in tarayıcı akışıyla yapılır; ayrıca `google_sign_in` paketi gerekmez.
4. App Check: Android için **Play Integrity**, iOS için **App Attest** sağlayıcısını kaydet. Hata ayıklama sürümü debug sağlayıcısını kullanır; konsola yazılan token'ı Firebase konsolunda "Hata ayıklama token'ları"na ekle.
5. Storage'ı aç ve güvenlik kurallarını yükle. Kurallar `firebase/storage.rules` dosyasında; her kullanıcı yalnızca kendi `users/{uid}/` klasörüne erişebilir. Konsolda Storage > Rules sekmesine yapıştırılabilir ya da Firebase CLI ile yüklenebilir:
   ```sh
   firebase deploy --only storage
   ```
   (CLI için `firebase.json` içinde `"storage": {"rules": "firebase/storage.rules"}` gerekir.) Storage için App Check zorunluluğu da konsoldan açılabilir.
6. API sunucusuna `FIREBASE_PROJECT_ID` ver. Uygulamanın App Check token'ı gönderdiği doğrulandıktan sonra `APP_CHECK_ENFORCE=true` yap.

Girişten sonra, bu cihazda daha önce yayınlanmış listeler (`ownerKey`) otomatik olarak hesaba bağlanır (`POST /gurme/lists/{id}/claim`). Cihazdaki defter başka bir hesaba aitse onun listeleri devralınmaz. Defter ve fotoğraflar Firebase Storage'a yedeklenir (aşağıya bakın).

## Kişisel defter

- Mekânlar, deneyimler, listeler ve profil uygulama destek klasöründeki `journal.json` dosyasında tutulur. Biçim Expo uygulamasıyla aynıdır. Uygulama her zaman bu dosyadan çalışır; bulut yalnızca yedektir.
- Yazma işlemi önce geçici dosyaya yapılır, sonra dosya yeniden adlandırılır. Böylece yarıda kalan bir yazma eski kaydı bozmaz.
- Dosya okunamazsa uygulama hata ekranında durur ve dosyanın üzerine yazmaz.
- Fotoğraflar seçilince `photos/` klasörüne kopyalanır ve göreli yolla saklanır. Kullanılmayan fotoğraflar açılışta silinir.
- Liste yayınlanınca sunucunun verdiği düzenleme anahtarı (`ownerKey`) da bu dosyada saklanır. Giriş yapınca liste ayrıca hesaba bağlanır.

## Bulut yedeği

Giriş yapan kullanıcının defteri Firebase Storage'a yedeklenir (`lib/features/backup`). Firebase yapılandırılmamışsa ya da giriş yoksa hiçbir şey yüklenmez.

- Yedek: `users/{uid}/journal.json` ve `users/{uid}/photos/{ad}`. Fotoğraflar değişmediği için yalnızca bir kez yüklenir.
- Defter her değiştiğinde 5 saniye sonra yüklenir. Art arda yapılan değişiklikler tek yüklemede gider.
- Girişte, uygulama öne gelince ve her yüklemeden önce buluttaki sürüme bakılır. Yedek başka bir cihazdan değişmişse:
  - Bu cihazda yüklenmemiş değişiklik yoksa bulut sürümü alınır.
  - Varsa iki defter birleştirilir (`journal_merge.dart`) ve yüklenir. Aynı kayıtta bu cihazdaki sürüm, listelerde daha yeni güncellenen kalır.
- Bir hesapla ilk kez giriş yapılan cihazda:
  - Cihaz boşsa yedek fotoğraflarıyla birlikte geri yüklenir.
  - Cihazda kayıt varsa yedekle birleştirilir.
- Birleştirme hiçbir kaydı silmez. Bu yüzden bir cihazda silinen kayıt, diğer cihazda yüklenmemiş değişiklikler varken eşitlenirse geri gelebilir.
- Son eşitlemenin sürümü, defterin hangi hesaba ait olduğu ve bekleyen değişiklik bilgisi `backup_state.json` dosyasında tutulur.

### Defter hesaba bağlı

- **Çıkış:** Defter önce buluta yüklenir, sonra defter, fotoğraflar ve `backup_state.json` cihazdan kaldırılır. Yükleme başarısızsa (örneğin çevrimdışı) çıkış yapılmaz ve kullanıcıya nedeni söylenir.
- **Oturum başka yoldan kapanırsa** (süresi dolmuş, hesap silinmiş): Yedeklenmiş defter yine kaldırılır. Yedeklenmemiş değişiklik varsa defter cihazda kalır ve aynı hesapla girişte yüklenir.
- **Başka hesap:** Cihazdaki defter başka bir hesaba aitse yeni hesaba hiçbir zaman yüklenmez ya da onunla birleştirilmez. Yedeklenmişse kaldırılır ve yeni hesabın yedeği alınır. Yedeklenmemişse cihazda bekler, hesap ekranında uyarı çıkar; bu hesaptan çıkış yine yapılabilir.
- **Girişsiz defter:** Hiçbir hesaba ait olmayan defter (hiç giriş yapılmamış ya da çıkıştan sonra yazılmış) ilk giriş yapan hesapla birleştirilir.
- Hesap ekranında son eşitleme zamanı ve "Şimdi yedekle" düğmesi var. Ayarlar'daki "Defteri yedekle" dosya dışa aktarma olarak duruyor.

## Kontrol

```sh
dart analyze      # flutter analyze, yolda Türkçe karakter ("Kişisel") varsa çöküyor
flutter test
```

**iOS derlemesi:** Proje iCloud Drive ile eşitlenen bir klasördeyse (örneğin Desktop), iCloud dosyalara öznitelik (xattr) ekler. Bu yüzden `flutter build ios` ve `flutter run` komutları Flutter.framework imzalanırken "resource fork, Finder information, or similar detritus not allowed" hatasıyla durur. Depoyu iCloud dışındaki bir klasöre (örneğin `~/Developer`) taşıyın.
