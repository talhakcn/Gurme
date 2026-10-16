# Gurme

Mekân keşfetme ve kişisel lezzet defteri uygulaması. (Eski adı: Seyyah Gurme.)

## Yapı

pnpm workspace monorepo, TypeScript.

```text
artifacts/
├── api-server/         # Express 5 API sunucusu (Google Cloud Run)
├── app/                # Flutter uygulaması (iOS, Android)
└── mobile/             # Expo uygulaması (Flutter ile değiştirilecek)
lib/
├── api-spec/           # OpenAPI 3.1 tanımı + Orval ve Dart codegen ayarları
├── api-client-dart/    # Üretilmiş Dart istemcisi (Flutter uygulaması için)
├── api-client-react/   # Üretilmiş React Query istemcisi
├── api-zod/            # Üretilmiş Zod şemaları
└── db/                 # Drizzle ORM şeması + Postgres bağlantısı
scripts/                # Yardımcı betikler
```

## Gereksinimler

- Node.js 24
- pnpm 10 (`corepack enable` ile `package.json` içindeki sürüm kullanılır)
- PostgreSQL 16

## Komutlar

- `pnpm install` — bağımlılıkları kur
- `pnpm run typecheck` — tüm workspace için tip kontrolü (her zaman kökten çalıştırın)
- `pnpm run build` — tip kontrolü + tüm paketlerin derlenmesi
- `pnpm --filter @workspace/api-server run dev` — API sunucusunu geliştirme modunda çalıştır
- `pnpm --filter @workspace/db run push` — şemayı veritabanına uygula (geliştirme)
- `pnpm --filter @workspace/api-server run test` — backend testleri; `TEST_DATABASE_URL` verilirse Postgres entegrasyon testleri de çalışır
- `pnpm --filter @workspace/api-spec run codegen` — `openapi.yaml` değişince istemci ve şemaları yeniden üret
- `pnpm --filter @workspace/api-spec run codegen:dart` — Dart istemcisini yeniden üret (Docker ve Flutter SDK gerekir)

Flutter uygulaması için bkz. `artifacts/app/README.md`.

## API sunucusu ortam değişkenleri

| Değişken | Zorunlu | Açıklama |
|---|---|---|
| `PORT` | Evet | Dinlenecek port (Cloud Run otomatik verir) |
| `DATABASE_URL` | Evet | Postgres bağlantı adresi |
| `GOOGLE_PLACES_API_KEY` | Arama için | Places API (New) ve Geocoding anahtarı |
| `GEMINI_API_KEY` | Hayır | Mekân analizleri için Gemini anahtarı |
| `DEEPSEEK_API_KEY` | Hayır | Tanımlıysa önce DeepSeek denenir, hata olursa Gemini |
| `ADMIN_API_KEY` | Yönetim uçları için | `/api/feedback/admin/*` için Bearer anahtarı |
| `FIREBASE_PROJECT_ID` | Üretimde evet | Tanımlıysa arama, analiz ve geri bildirim uçları Firebase girişi ister; günlük kota uygulanır. Boşsa giriş ve kota kapalıdır (yalnızca geliştirme). |
| `APP_CHECK_ENFORCE` | Hayır | `true` ise `/api/search`, `/api/places` ve `/api/autocomplete` için Firebase App Check token'ı (`X-Firebase-AppCheck`) zorunlu |
| `ALLOWED_ORIGINS` | Hayır | Tarayıcıdan erişime izin verilen adresler, virgülle ayrılmış. Üretimde boşsa tarayıcı istekleri kabul edilmez (mobil uygulamalar etkilenmez) |
| `PLACES_DAILY_LIMIT` | Hayır | Google Places'e günde gönderilebilecek toplam istek (arama, mekân, otomatik tamamlama; varsayılan 100) |
| `PLACES_USER_DAILY_LIMIT` | Hayır | Bir kullanıcının bu toplamdan günde harcayabileceği istek (varsayılan 30) |
| `PLACES_PHOTO_DAILY_LIMIT` | Hayır | Mekân fotoğrafları için günlük toplam istek (varsayılan 200; fotoğraf başına 2) |
| `PLACES_PHOTO_USER_DAILY_LIMIT` | Hayır | Bir kullanıcının fotoğraf sayacından günlük payı (varsayılan 40) |
| `LOG_LEVEL` | Hayır | pino log seviyesi (varsayılan `info`) |

AI anahtarı yoksa arama yine çalışır; mekânlar AI özeti olmadan ("basic") döner.

## Maliyet ve kötüye kullanım koruması

- Tüm `/api` için IP başına 15 dakikada 300 istek.
- `/api/search`: IP başına saatte 20 arama. `/api/autocomplete`: dakikada 60.
- Liste oluşturma: IP başına saatte 20.
- Giriş yapmış kullanıcıya günde 3 ücretsiz arama (Türkiye saatiyle gece yarısı yenilenir). Hak Google'a gitmeden düşülür, arama başarısız olursa geri verilir; aynı anda gönderilen aramalar kotayı aşamaz. Önbellekten dönen aramalar sayılmaz; hakkı biten kullanıcı yalnızca önbellekteki sonuçları alır. Mekân analizi istekleri günde en fazla 40.
- Google Places sayaçları ortak; her kullanıcının ayrıca günlük payı var (`PLACES_USER_DAILY_LIMIT`, `PLACES_PHOTO_USER_DAILY_LIMIT`). Böylece tek hesap ortak sınırı bitirip aramayı herkes için durduramaz. Payı biten kullanıcı `429 user_places_budget` alır.
- Liste sahibi anahtarı `X-Owner-Key` başlığıyla da gönderilebilir; giriş yapmış kullanıcı kendi listelerini anahtarsız düzenler. Eski anahtarlı listeler `POST /api/gurme/lists/{id}/claim` ile hesaba bağlanır. Hesaba bağlanmış liste başka hesaba devredilemez ve yalnızca o hesapla düzenlenir; anahtar tek başına yalnızca hesaba bağlanmamış listelerde geçer.
- Google Cloud konsolunda Places API için günlük kota ve bütçe uyarısı ayrıca tanımlanmalıdır.

## Cloud Run'a dağıtım

İmaj depo kökünden derlenir:

```sh
docker build -f artifacts/api-server/Dockerfile -t gurme-api .
# Apple Silicon üzerinde: docker build --platform linux/amd64 ...
```

Ya da doğrudan Cloud Build ile:

```sh
gcloud builds submit --tag REGION-docker.pkg.dev/PROJE/gurme/api -f artifacts/api-server/Dockerfile .
gcloud run deploy gurme-api --image REGION-docker.pkg.dev/PROJE/gurme/api --region REGION
```

Gizli değerler (API anahtarları, `DATABASE_URL`) Secret Manager üzerinden verilmelidir.

## TypeScript ve composite projeler

Her paket `tsconfig.base.json`'u genişletir (`composite: true`). Kök `tsconfig.json` kütüphaneleri proje referansı olarak listeler; bu yüzden tip kontrolü her zaman kökten `pnpm run typecheck` ile yapılmalıdır. A paketi B'ye bağlıysa A'nın `tsconfig.json` dosyasındaki `references` dizisinde B yer almalıdır.
