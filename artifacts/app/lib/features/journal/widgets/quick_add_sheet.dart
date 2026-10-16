import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../data/journal_models.dart';
import '../data/journal_notifier.dart';
import '../screens/place_edit_screen.dart';

const quickAddSources = ['Arkadaş önerisi', 'Sosyal medya', 'Yoldan geçerken'];

/// Yalnızca adla, birkaç saniyede mekân ekleyen alt sayfa. Ayrıntılar için
/// tam forma geçilebilir.
Future<void> showQuickAddSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      // Kök gezginde: perde sekme çubuğunu da örter.
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.paper,
      barrierColor: context.colors.scrim,
      shape: Border(top: BorderSide(color: context.colors.ink, width: 2)),
      builder: (_) => const QuickAddSheet(),
    );

class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _name = TextEditingController();
  var _status = PlaceStatus.want;
  var _source = '';
  var _error = '';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Mekân adı gerekli.');
      return;
    }
    final data = ref.read(journalDataProvider);
    final city = data.profile.city.trim();
    final existing = data.places
        .where((p) => equalsTr(p.name, name) && equalsTr(p.city, city))
        .firstOrNull;
    if (existing != null) {
      setState(() => _error = 'Bu mekân defterinde zaten var.');
      return;
    }
    final id = ref
        .read(journalProvider.notifier)
        .addPlace(
          (id, now) => Place(
            id: id,
            name: name,
            city: city,
            status: _status,
            source: _source,
            createdAt: now,
          ),
        );
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('$name deftere eklendi.'),
        action: SnackBarAction(
          label: 'Aç',
          onPressed: () => router.push('/place/$id'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final city = ref.watch(journalDataProvider).profile.city.trim();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Space.l,
            Space.m,
            Space.l,
            Space.l,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tutma çubuğunu tema çiziyor (showDragHandle).
              Text('Mekân ekle', style: text.headlineMedium),
              const SizedBox(height: Space.l),
              const Eyebrow('Mekân adı'),
              TextField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                onChanged: (_) {
                  if (_error.isNotEmpty) setState(() => _error = '');
                },
                decoration: InputDecoration(
                  hintText: 'Örn. Mahalle Lahmacuncusu',
                  hintStyle: TextStyle(color: context.colors.muted),
                ),
                style: text.bodyLarge,
              ),
              const SizedBox(height: Space.s),
              Text(
                _error.isNotEmpty
                    ? _error
                    : city.isEmpty
                    ? 'Şehir ve semti sonra ekleyebilirsin.'
                    : 'Şehir otomatik: profildeki şehir · $city',
                style: text.bodySmall!.copyWith(
                  color: _error.isNotEmpty ? context.colors.error : null,
                ),
              ),
              const SizedBox(height: Space.l),
              SegmentRow<PlaceStatus>(
                options: const [
                  (PlaceStatus.want, 'Gideceğim'),
                  (PlaceStatus.went, 'Gittim'),
                ],
                selected: _status,
                onSelected: (s) => setState(() => _status = s),
              ),
              const SizedBox(height: Space.l),
              const Eyebrow('Kaynak'),
              const SizedBox(height: Space.s),
              Wrap(
                spacing: Space.s,
                runSpacing: Space.s,
                children: [
                  for (final s in quickAddSources)
                    ChoiceBox(
                      label: s,
                      selected: _source == s,
                      onTap: () =>
                          setState(() => _source = _source == s ? '' : s),
                    ),
                ],
              ),
              const SizedBox(height: Space.l),
              ActionButton('Deftere ekle', onPressed: _save),
              // Yazılan ad, durum ve kaynak ayrıntılı forma taşınır.
              LinkLabel(
                'Adres, fotoğraf ve not için ayrıntılı forma geç',
                onTap: () {
                  final router = GoRouter.of(context);
                  final PlaceDraft draft = (
                    name: _name.text.trim(),
                    status: _status,
                    source: _source,
                  );
                  Navigator.of(context).pop();
                  router.push('/place/new', extra: draft);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
