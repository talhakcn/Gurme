# Tasarım planı: 30/40'tan 35–36'ya

**Durum (8 Ekim 2026): tamamlandı, puan 36/40.** Ayrıntı: `docs/TASARIM_ELESTIRISI.md` dördüncü tur, `docs/TASARIM_DENETIMI.md`.

Kaynak: `docs/TASARIM_ELESTIRISI.md` dosyasının üçüncü turu. Kullanıcı 8 Ekim 2026'da maddelerin hepsini onayladı; sırayı Claude seçti. Her adım ayrı bir commit; her adımdan sonra `dart analyze`, `flutter test` ve ekran görüntüsü kontrolü.

| Sıra | Adım | Ölçüt | Beklenen |
|---|---|---|---|
| 1 | Dil birliği | 2. Gerçek dünyayla uyum | 3 → 4 |
| 2 | Kısa ipuçları | 6. Tanıma, 10. Yardım | 3 → 4, 2 → 3 |
| 3 | Geri alma ve kaydedilmemiş form uyarısı | 3. Kontrol, 5. Hata önleme | 3 → 4, 3 → 4 |
| 4 | Yedek durumu ve kayıt onayları | 1. Görünürlük | 3 → 4 |
| 5 | Hızlı eylemler | 7. Esneklik | 3 → 4 |
| 6 | Görsel son dokunuş | 8. Estetik | 3 → 4 |

## 1. Dil birliği

- Puanlamanın adı her yerde "karne", çizimi "lezzet izi"; "tadım karnesi" kalkar.
- Yakın tarihler göreli yazılır: "Bugün", "Dün", bu hafta içi gün adı ("Pazartesi"), "Geçen hafta"; daha eskisi tam tarih. Etkinlik zaman çizelgesi tam tarihte kalır.

## 2. Kısa ipuçları

- Lezzet izi ilk kez göründüğünde Keşfet'te tek seferlik, kapatılabilir bir açıklama: "Adların yanındaki kareler lezzet izi: karnenin dört ölçütü."
- Satırdaki küçük ize dokununca ya da uzun basınca açıklama (ipucu).
- Deneyim formunda karnenin altında tek cümle: neyi puanladığın.
- Ayarlarda "Gurme nasıl çalışır": defter, karne, lezzet izi, yedek; birer cümle.
- Görülen ipuçları cihazda saklanır (tercih dosyası).

## 3. Geri alma ve uyarı

- Mekân ya da deneyim silinince alt bilgi çubuğunda "Geri al".
- Gideceğim/Gittim durumu değişince "Geri al".
- Değiştirilmiş form (mekân, deneyim, liste, profil) kaydedilmeden kapatılırsa "Değişiklikler kaybolsun mu?" sorusu.

## 4. Yedek durumu ve onaylar

- Profilde hesap satırının altında yedek durumu: "Son yedek: 2 dk önce", "Yedekleniyor…", "Yedeklenemedi · tekrar dene"; giriş yoksa "Yalnızca bu cihazda".
- Kayıtlardan sonra kısa onay: "Deneyim kaydedildi."

## 5. Hızlı eylemler

- Arşiv satırlarında sola kaydırınca "Gittim" / "Gideceğim", sağa kaydırınca "Sil" (geri alınabilir).
- Mekân satırına uzun basınca kısa menü: Deneyim ekle, Listeye ekle, Haritada aç.

## 6. Görsel son dokunuş

- Dynamic Type: sistem yazı boyutu tercihine uyum; büyük boyutta taşma kontrolü.
- Gece modu: paletin gece karşılıkları, DESIGN.md'de tema tablosu.
- Özel simge seti: alt sekme çubuğu ve profil satırları için tek çizgi kalınlığında, lezzet izinin karesine uyan simgeler.
- Bitince Impeccable `audit` ile erişilebilirlik denetimi ve dördüncü eleştiri turu.

Kapsam dışı (kullanıcıya bağlı): gerçek Firebase ile hata durumlarının denenmesi (ölçüt 9), gerçek fotoğraflar.
