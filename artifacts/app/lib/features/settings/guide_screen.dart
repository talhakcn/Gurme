import 'package:flutter/material.dart';

import '../../core/widgets/editorial.dart';
import '../journal/data/journal_models.dart';
import '../journal/widgets/taste_mark.dart';

/// "Gurme nasıl çalışır": uygulamanın kavramları, kısa ve örnekli.
/// Ayarlar ve Profil'den açılır.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  static const _sections = [
    (
      'Defter',
      [
        (
          'Mekân',
          'Gittiğin ya da gitmek istediğin bir yer. Gitmek istediğin yer '
              'gideceklerinde bekler; deneyim yazınca “Gittim” olur.',
        ),
        (
          'Deneyim',
          'Bir mekâna her gidişin. Hiçbir alanı zorunlu değil: tarih bile '
              '“oradaydım” demeye yeter.',
        ),
        (
          'Öneriyorum',
          'Mekân sayfasında işaretlenir. Önerdiğin mekânlar Arşiv\'de '
              '“Öneriyorum” seçeneğiyle süzülür.',
        ),
        (
          'Altın kenar çizgisi',
          'Solunda çift altın çizgi olan metinleri sen yazdın: notların ve '
              'deneyimlerin. Uygulamanın kendi metinleri bu çizgiyi taşımaz.',
        ),
      ],
    ),
    (
      'Puanlar',
      [
        (
          'Karne',
          'Deneyimde lezzet, servis, ambiyans ve fiyatı 1–5 arası puanlarsın. '
              'Boş bıraktığın ölçüt ortalamaya katılmaz; seçili kutuya '
              'yeniden dokunursan puan kalkar.',
        ),
        (
          'Lezzet izi',
          'Karnenin dört satırlık çizimi: her satır bir ölçüt, dolu kare '
              'kadar puan. Mekânın bütün deneyimlerinin ortalamasıdır; '
              'listelerde küçük, mekân sayfasında ölçüt adlarıyla büyük '
              'görünür.',
        ),
        (
          'Tabak',
          'Deneyimde tattığın her şey ayrı bir tabaktır. Tabağın genelini '
              '1–5 arası puanlarsın; ekmek, köfte, sos gibi bileşenlerini '
              '“Beğendim”, “Fena değil” ya da “Beğenmedim” diye işaretlersin.',
        ),
        (
          'Tabak türleri',
          'Mekânın türüne göre gelir: burgercide burger ve garnitür, '
              'kahvecide kahve ve tatlı. Her türün bileşenleri hazırdır; '
              'istediğini çıkarır, kendininkini eklersin.',
        ),
      ],
    ),
    (
      'Hatırlatmalar',
      [
        (
          'Bir dahaki sefere',
          '“Bir daha söyleme” dediğin tabaklar ve beğenmediğin bileşenler '
              'mekân sayfasının üstünde, yeni deneyim yazarken de formda '
              'hatırlatılır.',
        ),
        (
          'Tabak sıralaman',
          'Aynı türdeki bütün tabaklarını mekânlar arasında sıralar: '
              'genele ya da tek bileşene göre (“en iyi köfte nerede?”). '
              'Profil\'den ve mekân sayfasından açılır.',
        ),
        (
          'Damak notu',
          'Bir türde en az beş puanlı tabağın olunca sıralamanın altında '
              'çıkar: genel puanını en çok hangi bileşenin belirlediğini '
              'söyler.',
        ),
        (
          'Bugün ne yesem?',
          'Keşfet\'te gideceklerinden birini önerir; bu hafta gittiğin '
              'türlerden farklı bir yeri seçmeye çalışır.',
        ),
      ],
    ),
    (
      'Kısayollar',
      [
        (
          'Kaydırma',
          'Mekân satırını sağa kaydırınca “Gittim” ya da “Gideceğim” olur, '
              'sola kaydırınca silinir. İkisi de alttaki “Geri al” ile '
              'geri alınır.',
        ),
        (
          'Diğer eylemler',
          'Satırın sağındaki düğme ya da satıra uzun basmak kısa menüyü '
              'açar: deneyim ekle, listeye ekle, haritada aç, düzenle, sil.',
        ),
        (
          'Liste',
          'Mekânları sırayla bir listede toplarsın. Özel kalabilir, '
              'bağlantıyla ya da herkese açık paylaşılabilir.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GurmePage(
      masthead: const Masthead(back: true),
      children: [
        const PageTitle('Gurme nasıl çalışır'),
        const SizedBox(height: Space.s),
        Text(
          'Uygulamadaki kavramlar, kısaca.',
          style: text.bodyMedium!.copyWith(
            color: Theme.of(context).textTheme.bodySmall!.color,
          ),
        ),
        for (final (section, items) in _sections) ...[
          SectionTitle(section),
          for (final (title, body) in items) ...[
            const SizedBox(height: Space.m),
            Text(title, style: text.labelLarge),
            Text(body, style: text.bodyMedium),
            // Kavram bir örnekle: mekân sayfasındaki büyük iz.
            if (title == 'Lezzet izi') ...[
              const SizedBox(height: Space.m),
              const ExcludeSemantics(
                child: TasteMark(
                  TastingScores(taste: 5, service: 3, ambiance: 4, value: 4),
                  cell: 10,
                  labels: true,
                ),
              ),
            ],
          ],
        ],
      ],
    );
  }
}
