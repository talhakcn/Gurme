import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountUser {
  const AccountUser({required this.uid, this.email, this.displayName});

  final String uid;
  final String? email;
  final String? displayName;

  /// Ekranda gösterilecek ad: görünen ad, yoksa e-posta.
  String get label =>
      displayName?.isNotEmpty == true ? displayName! : (email ?? 'Hesabın');
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Firebase Auth'u sarmalar; Firebase yapılandırılmamışsa ya da testlerde
/// [DisabledAuthService] kullanılır.
abstract interface class AuthService {
  /// Hesap sistemi bu kurulumda çalışıyor mu.
  bool get enabled;
  AccountUser? get currentUser;
  Stream<AccountUser?> userChanges();
  Future<void> signInWithApple();
  Future<void> signInWithGoogle();
  Future<void> signInWithEmail(String email, String password);
  Future<void> registerWithEmail(String email, String password);
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();

  /// API isteklerine eklenecek Firebase ID token'ı; giriş yoksa `null`.
  Future<String?> idToken();

  /// API isteklerine eklenecek App Check token'ı; yoksa `null`.
  Future<String?> appCheckToken();
}

final authServiceProvider = Provider<AuthService>(
  (ref) => const DisabledAuthService(),
);

final currentUserProvider = StreamProvider<AccountUser?>(
  (ref) => ref.watch(authServiceProvider).userChanges(),
);

class DisabledAuthService implements AuthService {
  const DisabledAuthService();

  static const _message = 'Hesap sistemi bu sürümde yapılandırılmadı.';

  @override
  bool get enabled => false;

  @override
  AccountUser? get currentUser => null;

  @override
  Stream<AccountUser?> userChanges() => Stream.value(null);

  @override
  Future<void> signInWithApple() async => throw const AuthException(_message);

  @override
  Future<void> signInWithGoogle() async => throw const AuthException(_message);

  @override
  Future<void> signInWithEmail(String email, String password) async =>
      throw const AuthException(_message);

  @override
  Future<void> registerWithEmail(String email, String password) async =>
      throw const AuthException(_message);

  @override
  Future<void> sendPasswordReset(String email) async =>
      throw const AuthException(_message);

  @override
  Future<void> signOut() async {}

  @override
  Future<String?> idToken() async => null;

  @override
  Future<String?> appCheckToken() async => null;
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth, FirebaseAppCheck? appCheck})
    : _auth = auth ?? FirebaseAuth.instance,
      _appCheck = appCheck ?? FirebaseAppCheck.instance;

  final FirebaseAuth _auth;
  final FirebaseAppCheck _appCheck;

  static AccountUser? _map(User? u) => u == null
      ? null
      : AccountUser(uid: u.uid, email: u.email, displayName: u.displayName);

  @override
  bool get enabled => true;

  @override
  AccountUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AccountUser?> userChanges() => _auth.userChanges().map(_map);

  Future<void> _guard(Future<Object?> Function() call) async {
    try {
      await call();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e.code));
    }
  }

  /// iOS'ta yerel "Apple ile giriş" penceresi; Xcode'da "Sign in with Apple"
  /// yeteneği açık olmalı.
  @override
  Future<void> signInWithApple() => _guard(
    () => _auth.signInWithProvider(
      AppleAuthProvider()
        ..addScope('email')
        ..addScope('name'),
    ),
  );

  /// Google girişi Firebase'in tarayıcı akışıyla yapılır; ek paket gerekmez.
  @override
  Future<void> signInWithGoogle() =>
      _guard(() => _auth.signInWithProvider(GoogleAuthProvider()));

  @override
  Future<void> signInWithEmail(String email, String password) => _guard(
    () => _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  @override
  Future<void> registerWithEmail(String email, String password) => _guard(
    () => _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<String?> idToken() async => _auth.currentUser?.getIdToken();

  @override
  Future<String?> appCheckToken() async {
    try {
      return await _appCheck.getToken();
    } catch (_) {
      // App Check alınamazsa istek yine gider; sunucu zorunlu tutuyorsa reddeder.
      return null;
    }
  }

  static String _message(String code) => switch (code) {
    'invalid-email' => 'E-posta adresi geçersiz.',
    'user-disabled' => 'Bu hesap devre dışı bırakılmış.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'E-posta ya da şifre hatalı.',
    'email-already-in-use' => 'Bu e-postayla zaten bir hesap var.',
    'weak-password' => 'Şifre en az 6 karakter olmalı.',
    'too-many-requests' => 'Çok fazla deneme yapıldı. Biraz sonra tekrar dene.',
    'network-request-failed' => 'Bağlantı kurulamadı. İnternetini kontrol et.',
    'web-context-canceled' ||
    'canceled' ||
    'popup-closed-by-user' => 'Giriş iptal edildi.',
    'account-exists-with-different-credential' =>
      'Bu e-posta başka bir giriş yöntemiyle kayıtlı.',
    // Eşlenmeyen kod kullanıcıya gösterilmez; ne yapılacağı söylenir.
    _ => 'Giriş yapılamadı. Biraz sonra tekrar dene.',
  };
}
