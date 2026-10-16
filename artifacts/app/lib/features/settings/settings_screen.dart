import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/text/turkish.dart';
import '../../core/widgets/editorial.dart';
import '../../core/widgets/gurme_icons.dart';
import 'appearance.dart';
import '../account/data/auth_service.dart';
import '../backup/data/backup_controller.dart';
import '../backup/data/backup_file.dart';
import '../backup/data/journal_merge.dart';
import '../journal/data/journal_models.dart';
import '../journal/data/journal_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Defteri JSON dosyası olarak sistem paylaşım penceresine verir.
  /// Fotoğraflar dosyaya dahil değildir.
  Future<void> _backup(BuildContext context, WidgetRef ref) async {
    final data = ref.read(journalDataProvider);
    final dir = Directory('${ref.read(appDirectoryProvider).path}/exports');
    final box = context.findRenderObject() as RenderBox?;
    try {
      await dir.create(recursive: true);
      final file = File(
        '${dir.path}/gurme-defter-${isoDate(DateTime.now())}.json',
      );
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data.toJson()),
      );
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'Gurme defter yedeği',
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yedek dosyası hazırlanamadı.')),
        );
      }
    }
  }

  /// Dışa aktarılmış dosyayı defterle birleştirir; hiçbir kayıt silinmez.
  /// Önce dosyada ne olduğu gösterilip onay istenir; "Geri al" birleştirmeden
  /// önceki defteri geri koyar.
  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final String? raw;
    try {
      raw = await ref.read(backupFilePickerProvider)();
    } catch (_) {
      showNotice(messenger, 'Dosya açılamadı.');
      return;
    }
    if (raw == null || !context.mounted) return;

    JournalData? imported;
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) imported = JournalData.fromJson(json);
    } catch (_) {}
    if (imported == null ||
        (imported.places.isEmpty && imported.lists.isEmpty)) {
      await infoDialog(
        context,
        title: 'Bu bir Gurme yedeği değil',
        message:
            'Dosyada mekân ya da liste bulunamadı. Ayarlar\'daki “Dosya '
            'olarak dışa aktar” ile hazırlanan dosyayı seç.',
      );
      return;
    }
    final file = imported;
    final ok = await confirmDialog(
      context,
      title: 'Yedek deftere eklensin mi?',
      message:
          'Dosyada ${file.places.length} mekân, ${file.visits.length} '
          'deneyim ve ${file.lists.length} liste var. Defterindekilerle '
          'birleştirilir; hiçbir kayıt silinmez. Fotoğraflar dosyada '
          'olmadığı için gelmez.',
      confirm: 'Birleştir',
      destructive: false,
    );
    if (!ok) return;
    final journal = ref.read(journalProvider.notifier);
    final before = ref.read(journalDataProvider);
    journal.replaceAll(mergeJournals(before, file));
    showUndo(messenger, 'Yedek deftere eklendi.', () {
      journal.replaceAll(before);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final cloud =
        ref.watch(backupControllerProvider).enabled &&
        ref.watch(currentUserProvider).value != null;

    Widget paragraph(String value) => Padding(
      padding: const EdgeInsets.only(top: Space.s),
      child: Text(value, style: text.bodyMedium),
    );

    return GurmePage(
      masthead: const Masthead(back: true),
      children: [
        PageTitle('Ayarlar', style: text.headlineLarge),
        const SectionTitle('Görünüm'),
        SegmentRow<ThemeMode>(
          options: [
            for (final MapEntry(key: mode, value: label)
                in appearanceLabels.entries)
              (mode, label),
          ],
          selected: ref.watch(appearanceProvider),
          onSelected: (mode) =>
              ref.read(appearanceProvider.notifier).select(mode),
        ),
        const SizedBox(height: Space.s),
        Text(
          'Cihaza uy: telefonun gündüz/gece ayarını izler.',
          style: text.bodySmall,
        ),
        const SectionTitle('Defterin'),
        paragraph(
          cloud
              ? 'Defterin ve fotoğrafların yalnızca senin erişebildiğin bulut '
                    'yedeğinde de durur.'
              : ref.watch(backupControllerProvider).enabled
              ? 'Defterin yalnızca bu cihazda; uygulama silinirse kaybolur. '
                    'Giriş yaparsan hesabına otomatik yedeklenir.'
              : 'Defterin yalnızca bu cihazda; uygulama silinirse kaybolur. '
                    'Yedek için aşağıdan dosya olarak dışa aktarabilirsin.',
        ),
        const SizedBox(height: Space.l),
        Builder(
          builder: (buttonContext) => ActionButton(
            'Dosya olarak dışa aktar',
            icon: GurmeGlyph.share,
            secondary: true,
            onPressed: () => _backup(buttonContext, ref),
          ),
        ),
        const SizedBox(height: Space.s),
        Text(
          'Dosya mekânları, deneyimleri, listeleri ve profili içerir; '
          'fotoğraflar dahil değildir.',
          style: text.bodySmall,
        ),
        const SizedBox(height: Space.l),
        ActionButton(
          'Dosyadan geri yükle',
          icon: GurmeGlyph.restore,
          secondary: true,
          onPressed: () => _restore(context, ref),
        ),
        const SizedBox(height: Space.s),
        Text(
          'Dışa aktardığın dosyayı defterinle birleştirir; mevcut kayıtların '
          'silinmez.',
          style: text.bodySmall,
        ),
        const SectionTitle('Konum'),
        paragraph('Konum izni istenmez. Aramalar profilindeki şehirle başlar.'),
        LinkLabel(
          'Şehrini düzenle',
          onTap: () => context.push('/profile/edit'),
        ),
        const SectionTitle('Veri kaynakları'),
        paragraph(
          'Defterdeki bilgileri sen girersin. Aramadaki puan, adres ve '
          'yorumlar Google Places\'tan gelir; özetleri yapay zekâ çıkarır. '
          'Helal, glutensiz ve çölyak bilgisi tahmindir, mekânla teyit et.',
        ),
        const SectionTitle('Gurme nasıl çalışır'),
        paragraph('Karne, lezzet izi, tabaklar ve kısayollar, kısaca.'),
        LinkLabel('Rehberi aç', onTap: () => context.push('/guide')),
      ],
    );
  }
}
