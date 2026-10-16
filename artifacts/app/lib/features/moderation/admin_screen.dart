import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/clock.dart';
import '../../core/text/turkish.dart';
import '../../core/theme/gurme_colors.dart';
import '../../core/widgets/editorial.dart';
import '../account/data/auth_service.dart';
import 'admin_kit.dart';
import 'moderation_repository.dart';

/// Yönetim paneli. Yalnızca yönetici yetkisi olan hesapta açılır; sunucu da
/// her istekte yetkiyi denetler. Bölümler: genel bakış, kullanıcılar,
/// aramalar, listeler, bildirimler.
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key, this.section = AdminSection.overview});

  final AdminSection section;

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

enum AdminSection {
  overview('Genel bakış'),
  users('Kullanıcılar'),
  searches('Aramalar'),
  lists('Listeler'),
  reports('Bildirimler');

  const AdminSection(this.label);

  final String label;
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  late var _section = widget.section;

  void _refresh() {
    ref.invalidate(adminOverviewProvider);
    ref.invalidate(adminUsersProvider);
    ref.invalidate(adminSearchesProvider);
    ref.invalidate(adminListsProvider);
    ref.invalidate(reportedListsProvider);
    ref.invalidate(venueReportsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GurmePage(
      masthead: const Masthead(back: true),
      children: [
        SpacedRow(
          left: PageTitle('Yönetim', style: text.headlineLarge),
          right: LinkLabel('Yenile', onTap: _refresh),
        ),
        const SizedBox(height: Space.m),
        // Beş bölüm sarılarak dizilir: seçili olan kenarda soluk kalmaz.
        Wrap(
          spacing: Space.s,
          runSpacing: Space.s,
          children: [
            for (final s in AdminSection.values)
              ChoiceBox(
                label: s.label,
                selected: _section == s,
                onTap: () => setState(() => _section = s),
              ),
          ],
        ),
        const Rule(space: Space.l),
        ...switch (_section) {
          AdminSection.overview => [
            _Overview(onOpen: (s) => setState(() => _section = s)),
          ],
          AdminSection.users => const [_Users()],
          AdminSection.searches => const [_Searches()],
          AdminSection.lists => const [_Lists()],
          AdminSection.reports => const [_Reports()],
        },
      ],
    );
  }
}

/// Bir işlemi çalıştırır, sonucu bilgi çubuğunda söyler, verileri yeniler.
Future<void> runAdminAction(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function(ModerationRepository repo) action,
  String done,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action(ref.read(moderationRepositoryProvider));
    ref.invalidate(adminOverviewProvider);
    ref.invalidate(adminUsersProvider);
    ref.invalidate(adminUserProvider);
    ref.invalidate(adminListsProvider);
    ref.invalidate(reportedListsProvider);
    ref.invalidate(venueReportsProvider);
    showNotice(messenger, done);
  } on ModerationException catch (e) {
    showNotice(messenger, e.message);
  }
}

class _Overview extends ConsumerWidget {
  const _Overview({required this.onOpen});

  final ValueChanged<AdminSection> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: adminAsync(
        ref.watch(adminOverviewProvider),
        retry: () => ref.invalidate(adminOverviewProvider),
        data: (o) {
          final users = Map<String, dynamic>.from(o['users'] as Map? ?? {});
          final lists = Map<String, dynamic>.from(o['lists'] as Map? ?? {});
          final reports = Map<String, dynamic>.from(o['reports'] as Map? ?? {});
          final budgets = Map<String, dynamic>.from(o['budgets'] as Map? ?? {});
          final places = Map<String, dynamic>.from(
            budgets['places'] as Map? ?? {},
          );
          final photos = Map<String, dynamic>.from(
            budgets['photos'] as Map? ?? {},
          );
          final server = Map<String, dynamic>.from(o['server'] as Map? ?? {});
          final days = [
            for (final d in o['days'] as List? ?? const [])
              Map<String, dynamic>.from(d as Map),
          ];
          final today = days.isEmpty ? <String, dynamic>{} : days.last;
          final outcomes = Map<String, dynamic>.from(
            today['outcomes'] as Map? ?? {},
          );
          final openReports =
              adminInt(reports['lists']) + adminInt(reports['venues']);
          final top = [
            for (final t in places['topUsers'] as List? ?? const [])
              Map<String, dynamic>.from(t as Map),
          ];
          return [
            // Önce ilgilenilmesi gereken.
            if (openReports > 0) ...[
              HintBox(
                text:
                    '$openReports bildirim incelenmeyi bekliyor '
                    '(${adminInt(reports['lists'])} liste, '
                    '${adminInt(reports['venues'])} mekân).',
                action: 'İncele',
                onAction: () => onOpen(AdminSection.reports),
              ),
              const SizedBox(height: Space.l),
            ],
            Text(
              'Bugün ${adminInt(users['activeToday'])} kişi uygulamayı açtı; '
              '${adminInt(today['searches'])} arama Google\'a gitti, '
              '${adminInt(outcomes['cached'])} arama önbellekten döndü.',
              style: text.headlineSmall,
            ),
            const SizedBox(height: Space.xl),
            const Eyebrow('Google sayaçları (bugün)'),
            AdminMeter(
              label: 'Places istekleri',
              used: adminInt(places['used']),
              limit: adminInt(places['limit']),
              detail: places['userLimit'] == null
                  ? null
                  : 'Kişi başı en çok ${adminInt(places['userLimit'])} istek.',
            ),
            AdminMeter(
              label: 'Fotoğraf istekleri',
              used: adminInt(photos['used']),
              limit: adminInt(photos['limit']),
            ),
            if (top.isNotEmpty) ...[
              const SizedBox(height: Space.s),
              Text(
                'En çok harcayan: ${[for (final t in top.take(3)) '${t['userId']} (${adminInt(t['used'])})'].join(', ')}',
                style: text.bodySmall,
              ),
            ],
            const SizedBox(height: Space.xl),
            const Eyebrow('Son 7 gün: Google\'a giden arama'),
            const SizedBox(height: Space.s),
            AdminDays(days: days, value: (d) => adminInt(d['searches'])),
            const SizedBox(height: Space.l),
            const Eyebrow('Bugünkü aramalar'),
            for (final key in [
              'ok',
              'cached',
              'quota',
              'budget',
              'blocked',
              'error',
            ])
              if (adminInt(outcomes[key]) > 0)
                AdminRow(outcomeLabel(key), '${adminInt(outcomes[key])}'),
            AdminRow('Mekân analizi', '${adminInt(today['insights'])}'),
            AdminRow(
              'Tüm aramalar',
              '',
              onTap: () => onOpen(AdminSection.searches),
              detail: 'Ne arandığı ve en çok aranan kelimeler',
            ),
            const SizedBox(height: Space.xl),
            const Eyebrow('Kullanıcılar'),
            AdminRow('Toplam', '${adminInt(users['total'])}'),
            AdminRow('Bu hafta katılan', '${adminInt(users['newWeek'])}'),
            AdminRow('Bu hafta açan', '${adminInt(users['activeWeek'])}'),
            AdminRow(
              'Kısıtlanan',
              '${adminInt(users['publishingBlocked']) + adminInt(users['searchBlocked'])}',
              detail: 'Yayını ya da araması kapatılan hesaplar',
            ),
            AdminRow(
              'Kullanıcıları gör',
              '',
              onTap: () => onOpen(AdminSection.users),
            ),
            const SizedBox(height: Space.l),
            const Eyebrow('Son 7 gün: yeni kullanıcı'),
            const SizedBox(height: Space.s),
            AdminDays(days: days, value: (d) => adminInt(d['newUsers'])),
            const SizedBox(height: Space.xl),
            const Eyebrow('Listeler'),
            AdminRow('Herkese açık', '${adminInt(lists['public'])}'),
            AdminRow(
              'Bağlantıyla paylaşılan',
              '${adminInt(lists['unlisted'])}',
            ),
            AdminRow('Yayından kaldırılan', '${adminInt(lists['hidden'])}'),
            AdminRow('Bu hafta oluşturulan', '${adminInt(lists['newWeek'])}'),
            AdminRow(
              'Listeleri gör',
              '',
              onTap: () => onOpen(AdminSection.lists),
            ),
            const SizedBox(height: Space.xl),
            const Eyebrow('Sunucu'),
            AdminRow('Sürüm', '${server['revision'] ?? 'yerel'}'),
            AdminRow(
              'Giriş sistemi',
              server['authEnabled'] == true ? 'Açık' : 'Kapalı',
            ),
            AdminRow(
              'App Check',
              server['appCheckEnforced'] == true ? 'Zorunlu' : 'Zorunlu değil',
            ),
            AdminRow(
              'Google Places',
              server['placesConfigured'] == true ? 'Bağlı' : 'Anahtar yok',
            ),
            AdminRow(
              'Yapay zekâ',
              [for (final p in server['aiProviders'] as List? ?? const []) '$p']
                  .join(', ')
                  .ifEmpty('Yok'),
            ),
            AdminRow(
              'Çalışma süresi',
              _uptime(adminInt(server['uptimeSeconds'])),
              detail: 'Son yeniden başlamadan beri; sayaçlar bellekte tutulur',
            ),
          ];
        },
      ),
    );
  }

  static String _uptime(int seconds) {
    if (seconds < 3600) return '${seconds ~/ 60} dk';
    if (seconds < 86400) return '${seconds ~/ 3600} sa';
    return '${seconds ~/ 86400} gün';
  }
}

extension on String {
  String ifEmpty(String other) => isEmpty ? other : this;
}

class _Users extends ConsumerStatefulWidget {
  const _Users();

  @override
  ConsumerState<_Users> createState() => _UsersState();
}

class _UsersState extends ConsumerState<_Users> {
  final _query = TextEditingController();
  var _submitted = '';
  var _filter = 'all';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final now = ref.watch(clockProvider)();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _query,
          textInputAction: TextInputAction.search,
          onSubmitted: (v) => setState(() => _submitted = v),
          decoration: InputDecoration(
            hintText: 'E-posta ya da kullanıcı kimliği',
            hintStyle: TextStyle(color: context.colors.muted),
          ),
        ),
        const SizedBox(height: Space.m),
        ChoiceStrip(
          children: [
            for (final (value, label) in const [
              ('all', 'Tümü'),
              ('active', 'Bugün açan'),
              ('blocked', 'Kısıtlanan'),
            ])
              ChoiceBox(
                label: label,
                selected: _filter == value,
                onTap: () => setState(() => _filter = value),
              ),
          ],
        ),
        const SizedBox(height: Space.m),
        ...adminAsync(
          ref.watch(adminUsersProvider((_submitted, _filter))),
          retry: () => ref.invalidate(adminUsersProvider),
          data: (users) => users.isEmpty
              ? [
                  const EmptyState(
                    icon: null,
                    secondary: true,
                    title: 'Kullanıcı bulunamadı.',
                    detail: 'Başka bir e-posta ya da süzgeç dene.',
                  ),
                ]
              : [
                  Eyebrow('${users.length} kullanıcı · son görülene göre'),
                  for (final u in users)
                    AdminRow(
                      (u['email'] as String?) ?? (u['id'] as String),
                      '${adminInt(u['searchesToday'])} arama',
                      detail: [
                        'Son görülme ${adminWhen(adminDate(u['lastSeenAt']), now)}',
                        '${adminInt(u['searchesTotal'])} arama toplam',
                        if (adminInt(u['lists']) > 0)
                          '${adminInt(u['lists'])} liste',
                        if (u['searchBlocked'] == true) 'arama kapalı',
                        if (u['publishingBlocked'] == true) 'yayın kapalı',
                      ].join(' · '),
                      onTap: () => context.push(
                        '/admin/user/${Uri.encodeComponent(u['id'] as String)}',
                      ),
                    ),
                ],
        ),
        if (_submitted.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Space.m),
            child: Text(
              'Giriş yapmış ve uygulamayı en az bir kez açmış hesaplar.',
              style: text.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _Searches extends ConsumerStatefulWidget {
  const _Searches();

  @override
  ConsumerState<_Searches> createState() => _SearchesState();
}

class _SearchesState extends ConsumerState<_Searches> {
  String? _outcome;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final now = ref.watch(clockProvider)();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: adminAsync(
        ref.watch(adminSearchesProvider(_outcome)),
        retry: () => ref.invalidate(adminSearchesProvider),
        data: (data) {
          List<Map<String, dynamic>> rows(String key) => [
            for (final r in data[key] as List? ?? const [])
              Map<String, dynamic>.from(r as Map),
          ];
          final recent = rows('recent');
          final queries = rows('topQueries');
          final cities = rows('topCities');
          return [
            if (_outcome == null && queries.isNotEmpty) ...[
              const Eyebrow('En çok aranan (7 gün)'),
              for (final q in queries)
                AdminRow('${q['value']}', '${adminInt(q['n'])}'),
              const SizedBox(height: Space.l),
            ],
            if (_outcome == null && cities.isNotEmpty) ...[
              const Eyebrow('En çok aranan yer (7 gün)'),
              for (final c in cities)
                AdminRow('${c['value']}', '${adminInt(c['n'])}'),
              const SizedBox(height: Space.l),
            ],
            const Eyebrow('Son aramalar'),
            const SizedBox(height: Space.s),
            ChoiceStrip(
              children: [
                ChoiceBox(
                  label: 'Tümü',
                  selected: _outcome == null,
                  onTap: () => setState(() => _outcome = null),
                ),
                for (final o in [
                  'ok',
                  'cached',
                  'quota',
                  'budget',
                  'blocked',
                  'error',
                ])
                  ChoiceBox(
                    label: outcomeLabel(o),
                    selected: _outcome == o,
                    onTap: () => setState(() => _outcome = o),
                  ),
              ],
            ),
            const SizedBox(height: Space.s),
            if (recent.isEmpty)
              Text('Bu süzgeçte arama yok.', style: text.bodyMedium)
            else
              for (final r in recent)
                AdminRow(
                  [
                    r['query'],
                    r['city'],
                  ].where((s) => '$s'.isNotEmpty).join(' · '),
                  outcomeLabel('${r['outcome']}'),
                  detail: [
                    adminWhen(adminDate(r['createdAt']), now),
                    if (r['outcome'] == 'ok' || r['outcome'] == 'cached')
                      '${adminInt(r['resultCount'])} sonuç',
                    (r['email'] as String?) ??
                        (r['userId'] as String?) ??
                        'girişsiz',
                  ].join(' · '),
                  onTap: r['userId'] == null
                      ? null
                      : () => context.push(
                          '/admin/user/${Uri.encodeComponent(r['userId'] as String)}',
                        ),
                ),
          ];
        },
      ),
    );
  }
}

class _Lists extends ConsumerStatefulWidget {
  const _Lists();

  @override
  ConsumerState<_Lists> createState() => _ListsState();
}

class _ListsState extends ConsumerState<_Lists> {
  var _filter = 'shared';

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(clockProvider)();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChoiceStrip(
          children: [
            for (final (value, label) in const [
              ('shared', 'Paylaşılan'),
              ('public', 'Herkese açık'),
              ('unlisted', 'Bağlantıyla'),
              ('hidden', 'Kaldırılan'),
            ])
              ChoiceBox(
                label: label,
                selected: _filter == value,
                onTap: () => setState(() => _filter = value),
              ),
          ],
        ),
        const SizedBox(height: Space.m),
        ...adminAsync(
          ref.watch(adminListsProvider((_filter, ''))),
          retry: () => ref.invalidate(adminListsProvider),
          data: (lists) => lists.isEmpty
              ? [
                  const EmptyState(
                    icon: null,
                    secondary: true,
                    title: 'Bu süzgeçte liste yok.',
                    detail: 'Paylaşılan listeler burada görünür.',
                  ),
                ]
              : [
                  for (final l in lists)
                    AdminRow(
                      '${l['title']}',
                      l['hidden'] == true
                          ? 'Kaldırıldı'
                          : l['visibility'] == 'public'
                          ? 'Herkese açık'
                          : 'Bağlantıyla',
                      detail: [
                        '${l['authorName']}',
                        (l['ownerEmail'] as String?) ?? 'girişsiz yayın',
                        '${adminInt(l['itemCount'])} mekân',
                        if (adminInt(l['reports']) > 0)
                          '${adminInt(l['reports'])} bildirim',
                        'güncellendi ${adminWhen(adminDate(l['updatedAt']), now)}',
                      ].join(' · '),
                      onTap: () => _actions(context, l),
                    ),
                ],
        ),
      ],
    );
  }

  Future<void> _actions(BuildContext context, Map<String, dynamic> l) async {
    final id = l['id'] as String;
    final hidden = l['hidden'] == true;
    final owner = l['ownerUserId'] as String?;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: context.colors.paper,
      shape: Border(top: BorderSide(color: context.colors.ink, width: 2)),
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${l['title']}',
                style: Theme.of(sheet).textTheme.headlineSmall,
              ),
              const SizedBox(height: Space.m),
              LinkLabel(
                'Listeyi aç',
                onTap: () {
                  Navigator.of(sheet).pop();
                  context.push('/shared/$id');
                },
              ),
              if (owner != null)
                LinkLabel(
                  'Sahibini gör',
                  onTap: () {
                    Navigator.of(sheet).pop();
                    context.push('/admin/user/${Uri.encodeComponent(owner)}');
                  },
                ),
              if (hidden)
                LinkLabel(
                  'Yayına geri al',
                  onTap: () {
                    Navigator.of(sheet).pop();
                    runAdminAction(
                      context,
                      ref,
                      (repo) => repo.moderate(id, ModerationAction.restore),
                      '"${l['title']}" yeniden yayında.',
                    );
                  },
                )
              else
                DangerLink(
                  'Yayından kaldır',
                  onPressed: () async {
                    Navigator.of(sheet).pop();
                    final ok = await confirmDialog(
                      context,
                      title: 'Liste yayından kaldırılsın mı?',
                      message:
                          'Keşfette ve paylaşım bağlantısında görünmez olur; '
                          'sahibinin cihazındaki liste silinmez.',
                      confirm: 'Kaldır',
                    );
                    if (!ok || !context.mounted) return;
                    await runAdminAction(
                      context,
                      ref,
                      (repo) => repo.moderate(id, ModerationAction.hide),
                      '"${l['title']}" yayından kaldırıldı.',
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Liste ve mekân bildirimleri.
class _Reports extends ConsumerStatefulWidget {
  const _Reports();

  @override
  ConsumerState<_Reports> createState() => _ReportsState();
}

class _ReportsState extends ConsumerState<_Reports> {
  var _openOnly = true;
  final _busy = <String>{};

  Future<void> _run(
    String key,
    Future<void> Function(ModerationRepository repo) action,
    String done,
  ) async {
    if (_busy.contains(key)) return;
    setState(() => _busy.add(key));
    await runAdminAction(context, ref, action, done);
    if (mounted) setState(() => _busy.remove(key));
  }

  Future<void> _hide(ReportedList list) async {
    final ok = await confirmDialog(
      context,
      title: 'Liste yayından kaldırılsın mı?',
      message:
          'Keşfette ve paylaşım bağlantısında görünmez olur; sahibinin '
          'cihazındaki liste silinmez. İstersen sonra geri açabilirsin.',
      confirm: 'Kaldır',
    );
    if (!ok || !mounted) return;
    await _run(
      list.id,
      (repo) => repo.moderate(list.id, ModerationAction.hide),
      '"${list.title}" yayından kaldırıldı.',
    );
  }

  Future<void> _block(ReportedList list, {required bool blocked}) async {
    final owner = list.ownerUserId!;
    if (blocked) {
      final ok = await confirmDialog(
        context,
        title: 'Hesabın yayını kapatılsın mı?',
        message:
            '${list.authorName} artık liste paylaşamaz; listelerini yalnızca '
            'kendisi görebilir. Yayındaki listeleri ayrıca kaldırman gerekir.',
        confirm: 'Yayını kapat',
      );
      if (!ok || !mounted) return;
    }
    await _run(
      list.id,
      (repo) => repo.setPublishing(owner, blocked: blocked),
      blocked
          ? '${list.authorName} artık liste paylaşamıyor.'
          : '${list.authorName} yeniden liste paylaşabiliyor.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final reviewer = ref.watch(currentUserProvider).value?.email ?? 'yönetici';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Listeler', style: text.headlineSmall),
        const SizedBox(height: Space.s),
        SegmentRow<bool>(
          options: const [(true, 'İncelenecek'), (false, 'Hepsi')],
          selected: _openOnly,
          onSelected: (v) => setState(() => _openOnly = v),
        ),
        ...adminAsync(
          ref.watch(reportedListsProvider(_openOnly)),
          retry: () => ref.invalidate(reportedListsProvider),
          data: (lists) => lists.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.l),
                    child: Text(
                      _openOnly
                          ? 'İncelenecek liste bildirimi yok.'
                          : 'Henüz bildirilen liste yok.',
                      style: text.bodyMedium,
                    ),
                  ),
                ]
              : [
                  for (final list in lists)
                    _ReportedListRow(
                      list: list,
                      busy: _busy.contains(list.id),
                      onOpen: () => context.push('/shared/${list.id}'),
                      onHide: () => _hide(list),
                      onRestore: () => _run(
                        list.id,
                        (repo) =>
                            repo.moderate(list.id, ModerationAction.restore),
                        '"${list.title}" yeniden yayında.',
                      ),
                      onDismiss: () => _run(
                        list.id,
                        (repo) =>
                            repo.moderate(list.id, ModerationAction.dismiss),
                        'Bildirimler kapatıldı; liste yayında kaldı.',
                      ),
                      onBlock: list.ownerUserId == null
                          ? null
                          : (blocked) => _block(list, blocked: blocked),
                    ),
                ],
        ),
        const SizedBox(height: Space.xl),
        Text('Mekânlar', style: text.headlineSmall),
        const SizedBox(height: Space.xs),
        Text(
          'Kullanıcıların "alkol servis ediyor", "kapanmış" gibi bildirimleri. '
          'Kabul edilen bildirim arama sonuçlarına yansır.',
          style: text.bodySmall,
        ),
        ...adminAsync(
          ref.watch(venueReportsProvider),
          retry: () => ref.invalidate(venueReportsProvider),
          data: (groups) => groups.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.l),
                    child: Text(
                      'İncelenecek mekân bildirimi yok.',
                      style: text.bodyMedium,
                    ),
                  ),
                ]
              : [
                  for (final g in groups)
                    _VenueReportRow(
                      group: g,
                      busy: _busy.contains(
                        '${g['placeId']}|${g['reportType']}',
                      ),
                      onDecide: (accept) => _run(
                        '${g['placeId']}|${g['reportType']}',
                        (repo) => repo.reviewVenueReports(
                          placeId: g['placeId'] as String,
                          reportType: g['reportType'] as String,
                          accept: accept,
                          reviewedBy: reviewer,
                        ),
                        accept
                            ? '"${g['venueName']}" bildirimi kabul edildi.'
                            : '"${g['venueName']}" bildirimi reddedildi.',
                      ),
                    ),
                ],
        ),
      ],
    );
  }
}

String venueReportLabel(String type) => switch (type) {
  'serves_alcohol' => 'Alkol servis ediyor',
  'closed' => 'Kapanmış',
  'wrong_info' => 'Yanlış bilgi',
  'irrelevant' => 'Aramayla ilgisiz',
  _ => type,
};

class _VenueReportRow extends ConsumerWidget {
  const _VenueReportRow({
    required this.group,
    required this.busy,
    required this.onDecide,
  });

  final Map<String, dynamic> group;
  final bool busy;
  final ValueChanged<bool> onDecide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final now = ref.watch(clockProvider)();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Space.l),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(
            '${adminInt(group['reportCount'])} bildirim · '
            '${adminWhen(adminDate(group['lastReportedAt']), now)}',
          ),
          const SizedBox(height: Space.xs),
          Text('${group['venueName']}', style: text.headlineSmall),
          Text(
            venueReportLabel('${group['reportType']}'),
            style: text.bodyMedium,
          ),
          const SizedBox(height: Space.s),
          LinkLabel('Kabul et', onTap: busy ? () {} : () => onDecide(true)),
          DangerLink('Reddet', onPressed: busy ? null : () => onDecide(false)),
        ],
      ),
    );
  }
}

class _ReportedListRow extends StatelessWidget {
  const _ReportedListRow({
    required this.list,
    required this.busy,
    required this.onOpen,
    required this.onHide,
    required this.onRestore,
    required this.onDismiss,
    required this.onBlock,
  });

  final ReportedList list;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onHide;
  final VoidCallback onRestore;
  final VoidCallback onDismiss;

  /// Hesapla yayınlanmamış listede `null`.
  final ValueChanged<bool>? onBlock;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final reasons = [
      for (final MapEntry(key: reason, value: n) in list.reasons.entries)
        '${reason.label} ($n)',
    ].join(' · ');
    final state = [
      list.hidden ? 'Yayından kaldırıldı' : 'Yayında',
      if (list.ownerBlocked) 'sahibinin yayını kapalı',
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Space.l),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(
            '${list.openReports > 0 ? '${list.openReports} açık bildirim' : '${list.totalReports} bildirim, incelendi'} · '
            '${formatDateTr(list.lastReportedAt)}',
          ),
          const SizedBox(height: Space.xs),
          Text(list.title, style: text.headlineSmall),
          Text(
            '${list.authorName} · ${list.itemCount} mekân · $state',
            style: text.bodySmall,
          ),
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: Space.s),
            Text(reasons, style: text.bodyMedium),
          ],
          for (final note in list.notes)
            NoteQuote(title: 'Bildirenin notu', text: note),
          const SizedBox(height: Space.s),
          LinkLabel('Listeyi aç', onTap: onOpen),
          if (list.hidden)
            LinkLabel('Yayına geri al', onTap: busy ? () {} : onRestore)
          else ...[
            if (list.openReports > 0)
              LinkLabel(
                'Bildirimleri kapat, yayında kalsın',
                onTap: busy ? () {} : onDismiss,
              ),
            DangerLink('Yayından kaldır', onPressed: busy ? null : onHide),
          ],
          if (onBlock case final block?)
            list.ownerBlocked
                ? LinkLabel(
                    'Sahibinin yayınını yeniden aç',
                    onTap: busy ? () {} : () => block(false),
                  )
                : DangerLink(
                    'Sahibinin yayınını kapat',
                    onPressed: busy ? null : () => block(true),
                  ),
        ],
      ),
    );
  }
}
