import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/text/turkish.dart';
import '../../core/theme/gurme_colors.dart';
import '../../core/widgets/discard_guard.dart';
import '../../core/widgets/editorial.dart';
import '../../core/widgets/gurme_icons.dart';
import '../journal/data/dish_summary.dart';
import '../journal/data/journal_models.dart';
import '../account/data/auth_service.dart';
import '../backup/data/backup_controller.dart';
import '../backup/widgets/backup_section.dart';
import '../../core/clock.dart';
import '../journal/data/journal_notifier.dart';
import '../journal/widgets/taste_mark.dart';
import 'portrait.dart';
import '../moderation/moderation_repository.dart';

/// Profil sekmesi; sağ üstten ayarlara gidilir.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(journalDataProvider);
    final profile = data.profile;
    final text = Theme.of(context).textTheme;
    final account = ref.watch(currentUserProvider).value;
    final backup = ref.watch(backupControllerProvider);
    // Tabak kaydı olan türler, en çok tabağı olandan; "Diğer" sıralanmaz.
    final dishCounts = <DishKind, int>{};
    for (final d in summarizeDishes(data.visits)) {
      if (d.kind != DishKind.other) {
        dishCounts[d.kind] = (dishCounts[d.kind] ?? 0) + 1;
      }
    }
    dishCounts.removeWhere((_, n) => n < minRankedDishes);
    final rankedKinds = dishCounts.keys.toList()
      ..sort((a, b) => dishCounts[b]!.compareTo(dishCounts[a]!));
    final publicLists = data.lists
        .where((l) => l.isPublished && l.visibility == ListVisibility.public)
        .toList();

    return GurmePage(
      masthead: Masthead(
        rightIcon: GurmeGlyph.settings,
        rightTooltip: 'Ayarlar',
        onRight: () => context.push('/settings'),
      ),
      children: [
        PageTitle(
          profile.name.isEmpty ? 'Adını ekle' : profile.name,
          style: text.headlineLarge,
        ),
        if (profile.handle.isNotEmpty || profile.city.isNotEmpty)
          Eyebrow(
            [
              if (profile.handle.isNotEmpty) '@${profile.handle}',
              if (profile.city.isNotEmpty) profile.city,
            ].join(' · '),
          ),
        if (profile.bio.isNotEmpty) ...[
          const SizedBox(height: Space.m),
          Text(profile.bio, style: text.bodyLarge),
        ],
        if (profile.interests.isNotEmpty) ...[
          const SizedBox(height: Space.xs),
          Text('Sevdiklerin: ${profile.interests}', style: text.bodySmall),
        ],
        if (profile.areas.isNotEmpty)
          Text('Semtlerin: ${profile.areas}', style: text.bodySmall),
        LinkLabel(
          'Profili düzenle',
          onTap: () => context.push('/profile/edit'),
        ),
        const SizedBox(height: Space.s),
        Text(
          backupLine(
            backup,
            signedIn: account != null,
            now: ref.watch(clockProvider)(),
          ),
          style: text.bodySmall!.copyWith(
            color: backup.error != null && account != null
                ? context.colors.error
                : null,
          ),
        ),
        if (backup.enabled && account != null && backup.error != null)
          LinkLabel(
            'Tekrar dene',
            onTap: () => ref.read(backupControllerProvider.notifier).syncNow(),
          ),
        _Portrait(NotebookPortrait.of(data)),
        const SizedBox(height: Space.xl),
        // Giriş sistemi kapalı derlemede çıkmaz bir satır gösterilmez.
        if (ref.watch(authServiceProvider).enabled || account != null)
          _LinkRow(
            icon: GurmeGlyph.signIn,
            label: account == null
                ? 'Giriş yap · yapay zekâ araması için'
                : 'Hesap: ${account.label}',
            onTap: () => context.push('/account'),
          ),
        _LinkRow(
          icon: GurmeGlyph.calendar,
          label: 'Bu ayın özeti',
          onTap: () => context.push('/profile/month'),
        ),
        _LinkRow(
          icon: GurmeGlyph.year,
          label: 'Bu yılın özeti',
          onTap: () => context.push('/profile/year'),
        ),
        _LinkRow(
          icon: GurmeGlyph.activity,
          label: 'Etkinlik',
          onTap: () => context.push('/activity'),
        ),
        // Yalnızca yönetici yetkisi olan hesapta.
        if (ref.watch(isAdminProvider).value ?? false)
          _LinkRow(
            icon: GurmeGlyph.flag,
            label: 'Yönetim',
            onTap: () => context.push('/admin'),
          ),
        _LinkRow(
          icon: GurmeGlyph.info,
          label: 'Gurme nasıl çalışır',
          onTap: () => context.push('/guide'),
        ),
        if (rankedKinds.isNotEmpty) ...[
          const SectionTitle('Tabak sıralamaların'),
          for (final k in rankedKinds)
            _LinkRow(
              icon: GurmeGlyph.lists,
              label: '${k.label} sıralaman · ${dishCounts[k]} tabak',
              onTap: () => context.push('/dishes/${k.name}'),
            ),
        ],
        if (publicLists.isNotEmpty) ...[
          const SectionTitle('Herkese açık listelerin'),
          for (final l in publicLists)
            InkWell(
              onTap: () => context.push('/list/${l.id}'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: Space.l),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: context.colors.line),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.title, style: text.headlineSmall),
                    Text(
                      '${l.items.length} mekân · ${formatDateTr(l.updatedAt)}',
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Profildeki alt sayfalara giden satır.
/// Defter portresi: gittiklerinden çıkan birkaç gerçek, lezzet izleri ve
/// son deneyim. Sayım cümlesi Keşfet'te; burada kişinin kendisi anlatılır.
class _Portrait extends ConsumerWidget {
  const _Portrait(this.portrait);

  final NotebookPortrait portrait;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    if (portrait.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Defterinden'),
          Text(
            'Portren ilk deneyiminle başlar. Gittiğin bir mekânın '
            'sayfasından deneyim ekle; en sevdiğin tür, semtin ve lezzet '
            'izlerin burada birikir.',
            style: text.bodyMedium!.copyWith(color: context.colors.muted),
          ),
        ],
      );
    }

    String visitsText(int n) => '$n deneyim';
    final facts = [
      if (portrait.category case (final name, final n))
        _Fact('En sık gittiğin tür', name, visitsText(n)),
      if (portrait.district case (final name, final n))
        _Fact('En çok bulunduğun semt', name, visitsText(n)),
      if (portrait.favorite case final place?)
        _Fact(
          // "En çok önerdiğin" yanlış okunuyordu: öneri evet/hayır.
          'Önerdiklerinden en çok gittiğin',
          place.name,
          '${portrait.favoriteVisits} deneyim',
          onTap: () => context.push('/place/${place.id}'),
        ),
    ];
    final last = portrait.lastVisit!;
    final lastPlace = portrait.lastPlace!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Defterinden'),
        LayoutBuilder(
          builder: (context, constraints) {
            // Telefonda iki sütun; büyük yazıda tek sütun.
            final columns = largeText(context) ? 1 : 2;
            final width =
                (constraints.maxWidth - Space.l * (columns - 1)) / columns;
            return Wrap(
              spacing: Space.l,
              runSpacing: Space.l,
              children: [
                for (final f in facts) SizedBox(width: width, child: f),
              ],
            );
          },
        ),
        if (portrait.marks.isNotEmpty) ...[
          const SizedBox(height: Space.xl),
          const Eyebrow('Lezzet izlerin'),
          Text(
            'Her mekânın karne ortalaması; dokununca mekân açılır.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: Space.m),
          Wrap(
            spacing: Space.l,
            runSpacing: Space.l,
            children: [
              for (final (place, mark, average) in portrait.marks)
                _MarkTile(place: place, mark: mark, average: average),
            ],
          ),
        ],
        const SizedBox(height: Space.xl),
        const Eyebrow('Son deneyimin'),
        const SizedBox(height: Space.s),
        InkWell(
          onTap: () => context.push('/place/${lastPlace.id}'),
          child: MarginNote(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (last.title.isNotEmpty)
                  Text(
                    last.title,
                    style: text.headlineMedium!.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                Text(
                  '${lastPlace.name} · '
                  '${relativeIsoDateTr(last.date, ref.watch(clockProvider)())}',
                  style: text.labelSmall,
                ),
                if (last.note.isNotEmpty) ...[
                  const SizedBox(height: Space.xs),
                  // Satır sınırı yazı boyutuyla artar: 2x'te üç satır birkaç
                  // kelime ediyordu, kullanıcının notu yarım kalıyordu.
                  Text(
                    last.note,
                    maxLines: (3 * MediaQuery.textScalerOf(context).scale(1))
                        .round(),
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Portredeki tek gerçek: küçük başlık, serif değer, açıklama.
class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value, this.detail, {this.onTap});

  final String label;
  final String value;
  final String detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(label),
        const SizedBox(height: Space.xs),
        Text(value, style: text.headlineSmall),
        Text(detail, style: text.bodySmall),
      ],
    );
    return onTap == null
        ? MergeSemantics(child: body)
        : Semantics(
            button: true,
            child: InkWell(onTap: onTap, child: body),
          );
  }
}

/// Lezzet izi kolajındaki tek mekân.
class _MarkTile extends StatelessWidget {
  const _MarkTile({
    required this.place,
    required this.mark,
    required this.average,
  });

  final Place place;
  final TastingScores mark;
  final double? average;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    // Üç kutucuk 390 pt'ye sığar; uzun tek kelimelik ad kesilmez.
    final width = MediaQuery.textScalerOf(context).scale(108);
    return Semantics(
      button: true,
      label:
          '${place.name}'
          '${average == null ? '' : ', karne 5 üzerinden ${formatScore(average!)}'}',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => context.push('/place/${place.id}'),
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TasteMark(mark, cell: 8),
              const SizedBox(height: Space.s),
              Text(
                place.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall!.copyWith(color: context.colors.ink),
              ),
              if (average != null)
                Text('${formatScore(average!)} / 5', style: text.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final GurmeGlyph icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(vertical: Space.m),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.colors.line)),
        ),
        child: Row(
          children: [
            GurmeIcon(icon, size: 20),
            const SizedBox(width: Space.m),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            GurmeIcon(GurmeGlyph.next, size: 20, color: context.colors.muted),
          ],
        ),
      ),
    );
  }
}

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen>
    with DiscardGuard<ProfileEditScreen> {
  late final Profile _profile = ref.read(journalDataProvider).profile;
  late final _name = TextEditingController(text: _profile.name);
  late final _handle = TextEditingController(text: _profile.handle);
  late final _city = TextEditingController(text: _profile.city);
  late final _bio = TextEditingController(text: _profile.bio);
  late final _interests = TextEditingController(text: _profile.interests);
  late final _areas = TextEditingController(text: _profile.areas);

  @override
  List<Object?> get formValues => [
    for (final c in [_name, _handle, _city, _bio, _interests, _areas]) c.text,
  ];

  @override
  void initState() {
    super.initState();
    watchFields([_name, _handle, _city, _bio, _interests, _areas]);
    rememberInitialValues();
  }

  @override
  void dispose() {
    for (final c in [_name, _handle, _city, _bio, _interests, _areas]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    ref
        .read(journalProvider.notifier)
        .updateProfile(
          (p) => p.copyWith(
            name: _name.text.trim(),
            handle: _handle.text.trim().replaceFirst(RegExp('^@'), ''),
            city: _city.text.trim(),
            bio: _bio.text.trim(),
            interests: _interests.text.trim(),
            areas: _areas.text.trim(),
          ),
        );
    markSaved();
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    showNotice(messenger, 'Profil kaydedildi.');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return guarded(
      GurmePage(
        masthead: const Masthead(back: true),
        children: [
          PageTitle('Profili düzenle', style: text.headlineLarge),
          const SizedBox(height: Space.xl),
          Field(
            label: 'Adın',
            controller: _name,
            placeholder: 'Nasıl hitap edelim?',
          ),
          Text(
            'Liste yayınlarken yazar adı olarak bu ad görünür.',
            style: text.bodySmall,
          ),
          const SizedBox(height: Space.l),
          Field(
            label: 'Kullanıcı adı',
            controller: _handle,
            placeholder: 'Bir takma ad seç',
          ),
          Field(
            label: 'Şehrin',
            controller: _city,
            placeholder: 'Nereden keşfediyorsun?',
          ),
          Field(
            label: 'Kısa biyografi',
            controller: _bio,
            placeholder: 'Lezzetle ilişkin nasıl başladı?',
            multiline: true,
          ),
          Field(
            label: 'İlgi alanların',
            controller: _interests,
            placeholder: 'Kahve, fırınlar, esnaf mutfağı…',
          ),
          Field(
            label: 'Sevdiğin bölgeler',
            controller: _areas,
            placeholder: 'Kadıköy, Karaköy…',
          ),
          ActionButton('Profili kaydet', onPressed: _save),
        ],
      ),
    );
  }
}
