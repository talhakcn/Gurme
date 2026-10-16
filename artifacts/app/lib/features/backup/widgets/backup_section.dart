import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../data/backup_controller.dart';

/// Yedeğin durumu tek cümlede; profilde ve hesap ekranında.
String backupLine(
  BackupStatus status, {
  required bool signedIn,
  required DateTime now,
}) {
  if (!status.enabled || !signedIn) return 'Defterin yalnızca bu cihazda.';
  if (status.syncing) return 'Yedekleniyor…';
  if (status.error case final error?) return error;
  final last = status.lastBackupAt;
  return last == null
      ? 'Henüz yedeklenmedi.'
      : 'Son yedek: ${relativeTimeTr(last, now)}.';
}

/// Hesap ekranında bulut yedeğinin durumu ve "Şimdi yedekle".
class BackupSection extends ConsumerWidget {
  const BackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(backupControllerProvider);
    final text = Theme.of(context).textTheme;
    if (!status.enabled) return const SizedBox.shrink();

    final line = backupLine(
      status,
      signedIn: true,
      now: ref.watch(clockProvider)(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Bulut yedeği'),
        const SizedBox(height: Space.s),
        Text(
          'Defterin ve fotoğrafların hesabına otomatik yedeklenir. Başka bir '
          'cihazda giriş yaptığında geri gelir.',
          style: text.bodyMedium,
        ),
        const SizedBox(height: Space.s),
        Text(
          line,
          style: text.bodySmall!.copyWith(
            color: status.error != null ? context.colors.error : null,
          ),
        ),
        const SizedBox(height: Space.l),
        ActionButton(
          'Şimdi yedekle',
          icon: GurmeGlyph.backup,
          secondary: true,
          onPressed: status.syncing
              ? null
              : () => ref.read(backupControllerProvider.notifier).syncNow(),
        ),
      ],
    );
  }
}
