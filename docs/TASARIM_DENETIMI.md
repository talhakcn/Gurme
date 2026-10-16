# Teknik tasarım denetimi (Impeccable `audit`, yerel uygulama) — 8 Ekim 2026

Kaynaktan yapıldı (Flutter, iOS ve Android). Ölçüt: Impeccable `audit.native.md` ve `ios.md`. Kanıtlar: kod taraması, `test/screens_test.dart` (normal, 2 kat yazı, gece), simülatör.

## Puan

| # | Boyut | Puan | Ana bulgu |
|---|---|---|---|
| 1 | Erişilebilirlik | 3 | Etiketler, 2 kata kadar Dynamic Type, "hareketi azalt" ve iki temada kontrast tamam; satırdaki küçük lezzet izinin dokunma alanı 44 pt'nin altında |
| 2 | Performans | 3 | Sayfalar tembel olmayan `ListView(children:)`; 64 pt küçük fotoğraf 1200 px çözülüyor |
| 3 | Görünüm ve tema | 4 | Bütün renkler temaya bağlı palette; gece modu ekran testleriyle denetleniyor |
| 4 | Platform uyumu | 2 | iOS'ta Material uyarı penceresi ve tarih seçici; hazır simgelerle kendi simgelerimiz karışık |
| 5 | Uyarlanabilirlik | 2 | iPad ve yatay ekran destekleniyor ama sayfalar tüm genişliğe yayılıyor |
| | **Toplam** | **14/20** | **İyi** |

## Platform uyumu kararı

**Geçer, ama sınırda.** Kenardan kaydırarak geri dönme çalışıyor (iOS'ta varsayılan Cupertino sayfa geçişi), güvenli alanlar korunuyor, sekme çubuğu 5 bölümle sınırlı. Ancak uyarı pencereleri ve tarih seçici Android görünümünde; iOS kullanıcısı bunları yabancı bulur.

## Bulgular

1. **[P1] iPad'de sayfalar tüm genişliğe yayılıyor**
   - Yer: `core/widgets/editorial.dart`, `GurmePage`.
   - Etki: 1000 pt genişliğinde satırlar okunmuyor; yatay iPhone'da da aynı sorun var.
   - Öneri: İçeriği okunur bir genişlikte (yaklaşık 640 pt) ortalamak. (`/impeccable adapt`)
2. **[P2] Uyarı pencereleri ve tarih seçici iOS'ta Material**
   - Yer: `confirmDialog`, `infoDialog`, `visit_edit_screen.dart`.
   - Öneri: `AlertDialog.adaptive` ve iOS'ta Cupertino tarih seçici. (`/impeccable adapt`)
3. **[P2] Küçük fotoğraflar büyük çözülüyor**
   - Yer: `JournalPhoto`, `cacheWidth: 1200`.
   - Etki: 64 pt'lik satır fotoğrafı için gereksiz bellek ve işlemci kullanımı.
   - Öneri: Çözme genişliği gösterim boyutundan hesaplanmalı. (`/impeccable optimize`)
4. **[P2] Uzun listeler tembel değil**
   - Yer: `GurmePage` `ListView(children:)`. Arşiv'de bütün satırlar bir anda kuruluyor; her satır karne ortalamasını yeniden hesaplıyor.
   - Etki: Yüzlerce kayıtta kaydırma yavaşlar. (`/impeccable optimize`)
5. **[P3] Simge karışıklığı**
   - Sekme çubuğu ve profil kendi simgelerimizi, düğmeler ise hazır Material simgelerini kullanıyor (paylaş, kalem, artı).
   - Öneri: Sık kullanılan düğme simgelerini de sete eklemek. (`/impeccable polish`)
6. **[P3] Satırdaki lezzet izinin dokunma alanı küçük.** Simge yaklaşık 30×24 pt. (`/impeccable adapt`)

## Olumlu bulgular

- Renk, boşluk ve yazı yalnızca adlandırılmış değerlerden geliyor; gece modu ilk günden test kapsamında.
- Dynamic Type 2 kata kadar taşmasız; bu, her ekran için testlerle güvence altında.
- "Hareketi azalt" bütün hareketlerde dikkate alınıyor.
- Kaydedilmemiş form uyarısı kenardan kaydırmayı yalnızca gerektiğinde durduruyor.

## Denetimden sonra düzeltilenler (aynı gün)

- **[P1] iPad genişliği:** `GurmePage` içeriği en fazla 640 pt genişlikte ortalıyor. Ekran testlerine 1024 pt'lik iPad çeşidi eklendi.
- **[P2] Uyarı pencereleri:** `AlertDialog.adaptive` kullanılıyor; iOS'ta sistemin kendi düğmeleri çıkıyor ve silme düğmesi kırmızı.
- **[P2] Küçük fotoğraflar:** Görseller gösterildikleri boyutta çözülüyor.
- **Kalanlar:** tembel liste (P2), Cupertino tarih seçici (P2), düğme simgelerinin sete eklenmesi (P3), lezzet izinin dokunma alanı (P3).
- Düzeltmelerden sonraki tahmini puan: platform uyumu 3, uyarlanabilirlik 3, toplam **16/20**.
