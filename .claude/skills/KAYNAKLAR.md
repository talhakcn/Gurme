# Kurulu skill'ler ve kaynakları

8 Ekim 2026'da elle kopyalandı (`npx skills add` kullanılmadı).

| Klasör | Kaynak | Commit | Lisans |
|---|---|---|---|
| impeccable | github.com/pbakaus/impeccable (`.claude/skills/impeccable`) | 778c8a7 | Apache 2.0 |
| redesign-skill, taste-skill | github.com/Leonxlnx/taste-skill | b482f7a | MIT |
| emil-design-eng, apple-design, review-animations | github.com/emilkowalski/skills | e8a175d | MIT |

Impeccable'ın `scripts/` klasörü kasıtlı olarak kopyalanmadı: başlatıcısı ilk çalıştırmada GitHub'dan bir ikili dosya indirip çalıştırıyor. Skill bu durumda PRODUCT.md ve DESIGN.md'yi doğrudan okuyarak çalışır.

Bu skill'ler web odaklı yazılmış; ilkeleri Flutter'a uyarlanarak kullanılır.
