import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/clock.dart';
import '../../core/text/turkish.dart';
import '../../core/widgets/editorial.dart';
import 'admin_kit.dart';
import 'admin_screen.dart';
import 'moderation_repository.dart';

/// Bir kullanıcının yönetim sayfası: kullanım, son aramalar, listeler ve
/// kısıtlamalar.
class AdminUserScreen extends ConsumerWidget {
  const AdminUserScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final now = ref.watch(clockProvider)();
    return GurmePage(
      masthead: const Masthead(back: true),
      children: adminAsync(
        ref.watch(adminUserProvider(userId)),
        retry: () => ref.invalidate(adminUserProvider(userId)),
        data: (u) {
          final today = Map<String, dynamic>.from(u['today'] as Map? ?? {});
          List<Map<String, dynamic>> rows(String key) => [
            for (final r in u[key] as List? ?? const [])
              Map<String, dynamic>.from(r as Map),
          ];
          final searchBlocked = u['searchBlocked'] == true;
          final publishingBlocked = u['publishingBlocked'] == true;
          final email = (u['email'] as String?) ?? userId;
          return [
            PageTitle(email, style: text.headlineMedium),
            const SizedBox(height: Space.xs),
            Text(
              'Katıldı ${formatDateTr(adminDate(u['createdAt']))} · son görülme '
              '${adminWhen(adminDate(u['lastSeenAt']), now)}',
              style: text.bodySmall,
            ),
            Text('Kimlik: $userId', style: text.bodySmall),
            if (searchBlocked || publishingBlocked) ...[
              const SizedBox(height: Space.m),
              HintBox(
                text: [
                  if (searchBlocked) 'Bu hesabın araması kapalı.',
                  if (publishingBlocked) 'Bu hesap liste paylaşamıyor.',
                ].join(' '),
              ),
            ],
            const SizedBox(height: Space.xl),
            const Eyebrow('Bugün'),
            AdminMeter(
              label: 'Arama hakkı',
              used: adminInt(today['searches']),
              limit: adminInt(today['searchesLimit']),
            ),
            AdminRow('Mekân analizi', '${adminInt(today['insights'])}'),
            AdminRow(
              'Google Places isteği',
              '${adminInt(today['placesUsed'])}',
            ),
            const SizedBox(height: Space.m),
            Wrap(
              spacing: Space.s,
              runSpacing: Space.s,
              children: [
                for (final n in [1, 3, 5])
                  ActionButton(
                    '+$n arama',
                    secondary: true,
                    onPressed: () => runAdminAction(
                      context,
                      ref,
                      (repo) => repo.grantBonus(userId, n),
                      '$email bugün $n arama daha yapabilir.',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Space.xl),
            const Eyebrow('Kısıtlamalar'),
            if (searchBlocked)
              LinkLabel(
                'Aramayı yeniden aç',
                onTap: () => runAdminAction(
                  context,
                  ref,
                  (repo) => repo.setSearch(userId, blocked: false),
                  '$email yeniden arama yapabilir.',
                ),
              )
            else
              DangerLink(
                'Aramayı kapat',
                onPressed: () async {
                  final ok = await confirmDialog(
                    context,
                    title: 'Bu hesabın araması kapatılsın mı?',
                    message:
                        'Yapay zekâ araması ve mekân ayrıntısı çalışmaz; '
                        'defteri ve listeleri etkilenmez.',
                    confirm: 'Aramayı kapat',
                  );
                  if (!ok || !context.mounted) return;
                  await runAdminAction(
                    context,
                    ref,
                    (repo) => repo.setSearch(userId, blocked: true),
                    '$email artık arama yapamıyor.',
                  );
                },
              ),
            if (publishingBlocked)
              LinkLabel(
                'Liste paylaşımını yeniden aç',
                onTap: () => runAdminAction(
                  context,
                  ref,
                  (repo) => repo.setPublishing(userId, blocked: false),
                  '$email yeniden liste paylaşabilir.',
                ),
              )
            else
              DangerLink(
                'Liste paylaşımını kapat',
                onPressed: () async {
                  final ok = await confirmDialog(
                    context,
                    title: 'Hesabın yayını kapatılsın mı?',
                    message:
                        'Bu hesap artık liste paylaşamaz; yayındaki '
                        'listelerini ayrıca kaldırman gerekir.',
                    confirm: 'Yayını kapat',
                  );
                  if (!ok || !context.mounted) return;
                  await runAdminAction(
                    context,
                    ref,
                    (repo) => repo.setPublishing(userId, blocked: true),
                    '$email artık liste paylaşamıyor.',
                  );
                },
              ),
            const SizedBox(height: Space.xl),
            Eyebrow('Listeleri (${rows('lists').length})'),
            if (rows('lists').isEmpty)
              Text('Sunucuda listesi yok.', style: text.bodyMedium)
            else
              for (final l in rows('lists'))
                AdminRow(
                  '${l['title']}',
                  l['hidden'] == true
                      ? 'Kaldırıldı'
                      : switch (l['visibility']) {
                          'public' => 'Herkese açık',
                          'unlisted' => 'Bağlantıyla',
                          _ => 'Özel',
                        },
                  detail: '${adminInt(l['itemCount'])} mekân',
                  onTap: l['visibility'] == 'private'
                      ? null
                      : () => context.push('/shared/${l['id']}'),
                ),
            const SizedBox(height: Space.xl),
            const Eyebrow('Son 14 gün'),
            if (rows('usage').isEmpty)
              Text('Kullanım kaydı yok.', style: text.bodyMedium)
            else
              for (final d in rows('usage'))
                AdminRow(
                  formatIsoDateTr('${d['day']}'),
                  '${adminInt(d['searches'])} arama',
                  detail: [
                    '${adminInt(d['insights'])} analiz',
                    if (adminInt(d['bonus']) > 0)
                      '+${adminInt(d['bonus'])} ek hak',
                  ].join(' · '),
                ),
            const SizedBox(height: Space.xl),
            const Eyebrow('Son aramaları'),
            if (rows('searches').isEmpty)
              Text('Arama kaydı yok.', style: text.bodyMedium)
            else
              for (final s in rows('searches'))
                AdminRow(
                  [
                    s['query'],
                    s['city'],
                  ].where((v) => '$v'.isNotEmpty).join(' · '),
                  outcomeLabel('${s['outcome']}'),
                  detail: adminWhen(adminDate(s['createdAt']), now),
                ),
            if (adminInt(u['reportsMade']) > 0) ...[
              const SizedBox(height: Space.l),
              Text(
                'Bu hesap ${adminInt(u['reportsMade'])} liste bildirdi.',
                style: text.bodySmall,
              ),
            ],
          ];
        },
      ),
    );
  }
}
