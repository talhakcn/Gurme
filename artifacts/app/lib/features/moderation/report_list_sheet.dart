import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/gurme_colors.dart';
import '../../core/widgets/editorial.dart';
import '../account/data/auth_service.dart';
import 'moderation_repository.dart';

/// Başkasının listesini bildirme sayfası. Bildirim hesapla yapılır; girişsiz
/// kullanıcıya önce giriş önerilir. Sonuç bilgi çubuğunda söylenir.
Future<void> showReportListSheet(BuildContext context, String listId) =>
    showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.paper,
      barrierColor: context.colors.scrim,
      shape: Border(top: BorderSide(color: context.colors.ink, width: 2)),
      builder: (_) => ReportListSheet(listId: listId),
    );

class ReportListSheet extends ConsumerStatefulWidget {
  const ReportListSheet({super.key, required this.listId});

  final String listId;

  @override
  ConsumerState<ReportListSheet> createState() => _ReportListSheetState();
}

class _ReportListSheetState extends ConsumerState<ReportListSheet> {
  final _note = TextEditingController();
  ListReportReason? _reason;
  var _busy = false;
  var _error = '';

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final reason = _reason;
    if (reason == null || _busy) return;
    setState(() {
      _busy = true;
      _error = '';
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(moderationRepositoryProvider)
          .report(widget.listId, reason, note: _note.text);
      if (!mounted) return;
      Navigator.of(context).pop();
      showNotice(
        messenger,
        'Bildirimin alındı. İnceleyip gerekirse listeyi kaldıracağız.',
      );
    } on ModerationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final signedIn = ref.watch(currentUserProvider).value != null;
    final authEnabled = ref.watch(authServiceProvider).enabled;
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
              Text('Listeyi bildir', style: text.headlineMedium),
              const SizedBox(height: Space.s),
              Text(
                'Bildirimin yalnızca Gurme ekibine gider; listeyi hazırlayan '
                'kimin bildirdiğini görmez.',
                style: text.bodySmall,
              ),
              const SizedBox(height: Space.l),
              if (authEnabled && !signedIn) ...[
                Text(
                  'Bildirmek için giriş yapman gerekiyor; böylece aynı liste '
                  'tekrar tekrar bildirilemez.',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: Space.l),
                ActionButton(
                  'Giriş yap',
                  onPressed: () {
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    router.push('/account');
                  },
                ),
              ] else ...[
                const Eyebrow('Neden?'),
                const SizedBox(height: Space.s),
                for (final r in ListReportReason.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.s),
                    child: ChoiceBox(
                      label: r.label,
                      center: false,
                      selected: _reason == r,
                      onTap: () => setState(() => _reason = r),
                    ),
                  ),
                const SizedBox(height: Space.m),
                Field(
                  label: 'Eklemek istediğin (isteğe bağlı)',
                  controller: _note,
                  placeholder: 'Ne gördün?',
                  multiline: true,
                ),
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.m),
                    child: Text(
                      _error,
                      style: text.bodySmall!.copyWith(
                        color: context.colors.error,
                      ),
                    ),
                  ),
                ActionButton(
                  _busy ? 'Gönderiliyor…' : 'Bildir',
                  onPressed: _reason == null || _busy ? null : _send,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
