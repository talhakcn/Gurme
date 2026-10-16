import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../backup/data/backup_controller.dart';
import '../../backup/widgets/backup_section.dart';
import '../../lists/data/list_sync.dart';
import '../data/auth_service.dart';

/// Giriş, kayıt ve çıkış.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _register = false;
  var _busy = false;
  var _error = '';
  var _notice = '';

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(
    Future<void> Function() action, {
    bool signsIn = true,
  }) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = '';
      _notice = '';
    });
    try {
      await action();
      if (!signsIn || !mounted) return;
      // Bu cihazda yayınlanmış listeler hesaba bağlanır; cihazdaki defter
      // başka bir hesaba aitse onun listeleri devralınmaz.
      final uid = ref.read(authServiceProvider).currentUser?.uid;
      final mayClaim =
          uid != null &&
          await ref.read(backupControllerProvider.notifier).localBelongsTo(uid);
      if (!mounted) return;
      final claimed = mayClaim
          ? await ref.read(listSyncProvider).claimAll()
          : 0;
      if (!mounted) return;
      if (claimed > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$claimed yayınlanmış liste hesabına bağlandı.'),
          ),
        );
      }
      if (context.canPop()) context.pop();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider);
    final user = ref.watch(currentUserProvider).value;
    final text = Theme.of(context).textTheme;
    final isApple =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    if (!auth.enabled) {
      return GurmePage(
        masthead: const Masthead(back: true),
        children: [
          PageTitle('Giriş yakında', style: text.headlineLarge),
          const SizedBox(height: Space.m),
          Text(
            'Hesap sistemi bu sürümde yapılandırılmadı. Defterin ve listelerin '
            'bu cihazda çalışmaya devam eder.',
            style: text.bodyMedium,
          ),
        ],
      );
    }

    if (user != null) {
      return GurmePage(
        masthead: const Masthead(back: true),
        children: [
          // Başlık sabit; uzun bir e-posta başlık boyutunda bölünmesin.
          PageTitle('Hesabın', style: text.headlineLarge),
          const SizedBox(height: Space.s),
          if (user.displayName?.isNotEmpty == true)
            Text(user.displayName!, style: text.bodyLarge),
          if (user.email case final email?)
            Text(
              email,
              style: text.bodyMedium!.copyWith(color: context.colors.muted),
            ),
          const SizedBox(height: Space.l),
          Text(
            'Giriş yaptığın için yapay zekâ araması açık. Defterin ve '
            'yayınladığın listeler hesabına bağlı; çıkış yapınca defter '
            'buluta yüklenir ve bu cihazdan kaldırılır.',
            style: text.bodyMedium,
          ),
          const Rule(space: Space.xxl),
          const BackupSection(),
          const SizedBox(height: Space.xl),
          ActionButton(
            'Çıkış yap',
            secondary: true,
            // Defter önce buluta yüklenir, sonra bu cihazdan kaldırılır;
            // yüklenemezse çıkış yapılmaz.
            onPressed: () async {
              final ok = await confirmDialog(
                context,
                title: 'Çıkış yapılsın mı?',
                message:
                    'Defterin önce buluta yüklenir, sonra bu cihazdan '
                    'kaldırılır. Yeniden giriş yapınca geri gelir.',
                confirm: 'Çıkış yap',
                destructive: false,
              );
              if (!ok) return;
              await _run(
                () => ref.read(backupControllerProvider.notifier).signOut(),
                signsIn: false,
              );
            },
          ),
        ],
      );
    }

    return GurmePage(
      masthead: const Masthead(back: true),
      children: [
        PageTitle(
          _register ? 'Hesap oluştur' : 'Giriş yap',
          style: text.headlineLarge,
        ),
        const SizedBox(height: Space.s),
        Text(
          'Yapay zekâ araması için giriş gerekir: her gün 3 ücretsiz arama '
          'hakkın olur. Defterin hesap olmadan da çalışır.',
          style: text.bodyMedium!.copyWith(color: context.colors.muted),
        ),
        const SizedBox(height: Space.xl),
        if (isApple) ...[
          ActionButton(
            'Apple ile devam et',
            brandIcon: Icons.apple,
            onPressed: _busy ? null : () => _run(auth.signInWithApple),
          ),
          const SizedBox(height: Space.s),
        ],
        ActionButton(
          'Google ile devam et',
          brandIcon: Icons.account_circle_outlined,
          secondary: isApple,
          onPressed: _busy ? null : () => _run(auth.signInWithGoogle),
        ),
        const Rule(space: Space.xl),
        const Eyebrow('E-posta ile'),
        const SizedBox(height: Space.xs),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: 'E-posta',
            labelStyle: TextStyle(color: context.colors.muted),
          ),
        ),
        const SizedBox(height: Space.s),
        TextField(
          controller: _password,
          obscureText: true,
          autofillHints: [
            _register ? AutofillHints.newPassword : AutofillHints.password,
          ],
          decoration: InputDecoration(
            labelText: 'Şifre',
            labelStyle: TextStyle(color: context.colors.muted),
          ),
        ),
        const SizedBox(height: Space.l),
        ActionButton(
          _busy
              ? 'Bekle…'
              : _register
              ? 'Hesap oluştur'
              : 'Giriş yap',
          secondary: true,
          onPressed: _busy
              ? null
              : () => _run(
                  () => _register
                      ? auth.registerWithEmail(_email.text, _password.text)
                      : auth.signInWithEmail(_email.text, _password.text),
                ),
        ),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Space.m),
            child: Text(
              _error,
              style: text.bodySmall!.copyWith(color: context.colors.error),
            ),
          ),
        if (_notice.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Space.m),
            child: Text(_notice, style: text.bodySmall),
          ),
        LinkLabel(
          _register ? 'Hesabın var mı? Giriş yap' : 'Hesabın yok mu? Oluştur',
          onTap: () => setState(() {
            _register = !_register;
            _error = '';
          }),
        ),
        if (!_register)
          LinkLabel(
            'Şifremi unuttum',
            onTap: () => _run(() async {
              await auth.sendPasswordReset(_email.text);
              if (mounted) {
                setState(
                  () => _notice =
                      'Şifre sıfırlama bağlantısı e-postana gönderildi.',
                );
              }
            }, signsIn: false),
          ),
      ],
    );
  }
}
