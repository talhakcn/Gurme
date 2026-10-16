# 35/40 için plan

Durum (14 Ekim 2026): Üç bağımsız ölçüm sırasıyla 29, 30 ve 30 verdi. Her ölçümde on ölçütün hepsi 3; 4 alan ölçüt yok. 35 için en az **beş ölçütün 4'e** çıkması gerekiyor.

Bu plan, üç bağımsız raporda her ölçütün neden 3'te kaldığını karşılaştırarak hazırlandı (`docs/TASARIM_ELESTIRISI.md`, beşinci, altıncı ve yedinci turlar).

## Neden 30'da takıldık

1. **Değerlendirici yalnızca kanıt gördüğü kadar puan veriyor.** Ekran görüntüleri test ortamından geliyor. Bu ortamda giriş kapalı ve ağ yok. Yedek durumu, gerçek hata mesajları, girişli profil ve kota dolu ekran gibi şeyler görüntü setinde hiç yok. Bu yüzden 1. ve 9. ölçütlerde "gerçek ağda doğrulanamadı" deyip 3 veriyor.
2. **Her tur bir öncekinden daha küçük sorunlar buluyor.** Kelime bölünmesi, tutarsız bir bağlantı, tek seferlik bir ipucu gibi. Bunlar 4'ü engelliyor ama düzeltmek de tek başına 4 getirmiyor. 4 için "gerçekten mükemmel" bir şey gösterilmesi gerekiyor.
3. **4 iddia eden ölçütler çoğu zaman uygulamanın dışında kanıt istiyor.** Örnekler: gerçek kullanıcı denemesi, kurtarılabilen gerçek hatalar.

## Ölçüt ölçüt: 4 için ne gerekir

Hedef, kanıtla savunulabilecek beş ölçütü 4'e taşımak. Önerilen beşli şu: 1, 3, 5, 8 ve 9. Kalan beşi 3'te tutup hiçbirinin 2'ye düşmemesi yeterli.

### 1. Sistem durumunun görünürlüğü: 3'ten 4'e (önerilen)

- **Engel:** "Yedekleme ve senkron gerçek ağda doğrulanamadı."
- **Yapılacaklar:**
  - **Görüntü seti:** Ekran testlerine girişli bir kullanıcıyla hesap ve profil ekranlarını eklemek. Yedek durumunun dört hali ayrı ayrı çizilsin: yedekleniyor, son yedek, başarısız, yalnızca bu cihazda.
  - **Görünür durum:** Keşfet'te yedek hata verince küçük bir uyarı satırı ("Son yedekleme başarısız · tekrar dene"). Şu an yalnızca profilde görünüyor.
  - **Bağlantı:** Uygulama çevrimdışıyken arama ekranında baştan "İnternet bağlantısı yok" demeli; şu an "Ara"ya basınca hata veriyor.
- **İş:** küçük–orta.

### 3. Kullanıcı denetimi: 3'ten 4'e (önerilen)

- **Engel:** Geri al var, ama yalnızca silme ve durum değişikliğinde.
- **Yapılacaklar:**
  - Listeden mekân çıkarma, liste silme ve deneyim fotoğrafı silme işlemlerinde de "Geri al".
  - Arama filtrelerinde tek dokunuşla "Filtreleri temizle".
  - iOS'ta formlar alttan açılan sayfa olarak açılınca aşağı kaydırıp kapatma hareketine uyulmalı.
- **İş:** orta.

### 5. Hata önleme: 3'ten 4'e (önerilen)

- **Engel:** Ufak belirsizlikler: çift "öneriyorum" (düzeltildi), yayınlanmış listeden silme.
- **Yapılacaklar:**
  - **Form denetimi:** Gerekli alan boşken kaydet düğmesi pasif olmalı ve nedeni yazılmalı. Şu an basınca uyarı çıkıyor.
  - **Yinelenen mekân:** Arama sonucundan deftere eklerken aynı mekân defterdeyse "Bu mekân zaten defterinde · aç" gösterilmeli. Hızlı eklemede bu var, aramada yok.
  - **Tarih:** Deneyim tarihinde gelecek bir tarih seçilemesin.
- **İş:** küçük.

### 8. Estetik ve sade tasarım: 3'ten 4'e (önerilen)

- **Engeller:**
  - Profil sayfası "ince ve boş".
  - "Defterinde 3 mekân…" cümlesi üç ekranda tekrarlanıyor.
  - Fotoğrafsız defter yazıdan ibaret.
  - Paylaşım kapağı dergi kalıbındaydı (düzeltildi).
- **Yapılacaklar:**
  - **Profil:** Bağlantı listesi yerine kişinin defterinden bir portre olmalı. İçerik: en sık gittiği tür, en çok önerdiği mekân, son deneyimi ve lezzet izlerinin küçük bir kolajı.
  - **Tekrar eden cümle:** Bu özet yalnızca Keşfet'te kalsın; Profil ve Ayarlar başka bir şey söylesin.
  - **Fotoğraf:** Örnek defterde en az iki mekâna gerçek fotoğraf eklemek. Görüntü seti fotoğraflı satırları ve mekân sayfasını göstersin; şu an hiç fotoğraflı ekran yok.
  - **iPad:** İki sütunlu düzen. Liste solda, seçilen mekân sağda.
- **İş:** orta–büyük. En çok değer katacak madde bu.

### 9. Hatalardan kurtulma: 3'ten 4'e (önerilen)

- **Engel:** "Gerçek ağ ve kimlik hataları test edilemedi."
- **Yapılacaklar:**
  - **Görüntü seti:** Arama hatalarının her biri çizilsin: giriş gerekli, kota doldu, Places günlük sınırı, ağ yok, sunucu hatası, sonuç yok.
  - **Hata metinleri:** Hepsi "ne oldu + ne yapmalı" biçiminde olsun. Ağ hatasında arama kutusu dolu kalsın ve tek dokunuşla yeniden denensin.
  - **Yedek ve giriş:** Giriş iptal edilince ve Firebase hatası alınınca anlaşılır mesaj çıksın; yedek hatası da kendi mesajıyla geri gelsin.
- **İş:** küçük–orta.

### 3'te kalması beklenenler

- **2. Gerçek dünyayla uyum:** "Lezzet izi" kendini anlatmıyor. Mekân sayfasında büyük izin üstüne başlık ve tek cümlelik açıklama koymak 3'ü sağlamlaştırır.
- **4. Tutarlılık:**
  - "Mekân ekle" bir yerde bağlantı, başka yerde düğme.
  - iOS'ta uzun basma menüsü Material.

  iOS bağlam menüsüne (`CupertinoContextMenu`) geçmek 4'e yaklaştırır.
- **6. Tanıma:** İpuçları ve Arşiv satırı eklendi. 3 güvende.
- **7. Esneklik:** Kaydırma, uzun basma ve hızlı ekleme var. 4 için son aramalar, Arşiv'de sıralama seçenekleri ve iOS ana ekran kısayolu gerekir.
- **10. Yardım:** Yardım Ayarlar'ın dibinde. 4 için bağlam içinde "?" açıklamaları (karne, lezzet izi, liste görünürlüğü) gerekir.

## Ölçümü daha güvenilir yapmak

- **Görüntü seti genişlemeli.** Girişli kullanıcı, yedek durumları, hata durumları, fotoğraflı mekânlar ve alttan açılan sayfalar eklenmeli. Cupertino katmanları şu an görüntüde çıkmıyor; yakalama yöntemi düzeltilmeli. Değerlendirici görmediğini puanlamıyor.
- **İki ajan, ortalama.** Tek ajanın puanında ±1 sapma olabiliyor. Son ölçümde aynı talimatla iki ajan çalıştırılıp ortalama alınmalı.
- **Gerçek kullanım.** Uygulamayı bir iki hafta gerçek mekânlarla kullanmak ve bulunan sorunları not etmek. Bu, değerlendiricinin 4 vermek için aradığı "gerçek kanıt"ı sağlar. Ayrıca 2–3 kişiye beş görev yaptırılan kısa bir kullanılabilirlik denemesi yapılabilir.

## Önerilen sıra

| Adım | İş | Ölçüt | Kim |
|---|---|---|---|
| 1 | Görüntü setini genişletmek: girişli kullanıcı, yedek durumları, hata durumları, Cupertino yakalama | 1, 9 | Claude |
| 2 | Hata ve çevrimdışı durumların metinleri ve yeniden deneme | 9, 1 | Claude |
| 3 | Form denetimi, aramada yinelenen mekân, gelecek tarih | 5 | Claude |
| 4 | Geri almayı listelere ve fotoğraflara yaymak | 3 | Claude |
| 5 | Profili defter portresine çevirmek; tekrarlanan cümleyi kaldırmak | 8 | Claude |
| 6 | Örnek deftere fotoğraf; fotoğraflı ekranlar | 8 | Claude (görsel lisansı için kullanıcı onayı) |
| 7 | Bir iki hafta gerçek kullanım ve not | 2, 8, 10 | Kullanıcı |
| 8 | İki bağımsız ajanla son ölçüm | — | Claude |

1–6. adımlar birkaç oturumluk iş. Gerçekçi beklenti: 1–6. adımlardan sonra 33–34, gerçek kullanım bulgularıyla birlikte 35. Bu bir garanti değil, çünkü değerlendirici 4'ü bilinçli olarak az veriyor.
