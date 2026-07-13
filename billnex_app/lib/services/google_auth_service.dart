/// Google sign-in seam — EXPERIMENTAL, no real OAuth here.
///
/// This is a *seam* in exactly the same spirit as the experimental
/// [SyncService]: it defines the interface the app codes against, but the
/// default implementation ([StubGoogleAuthService]) does NOT perform a real
/// Google login. Real Google sign-in needs the `google_sign_in` package plus a
/// configured Firebase / OAuth client — an Android `google-services.json` and a
/// web/iOS OAuth client ID — none of which can be provisioned or tested in this
/// environment.
///
/// Because of that, the whole app treats a Google account as strictly optional:
/// every caller must handle [signIn] throwing [GoogleAuthUnavailable] (or
/// returning null) and continue without an account. When the app is ready to
/// ship real Google login, drop in a `GoogleSignInAuthService implements
/// GoogleAuthService` behind this same interface — no calling code changes.
library;

/// A signed-in Google user. Deliberately tiny — only what the UI shows.
class GoogleAccount {
  final String name;
  final String email;
  final String? photoUrl;
  const GoogleAccount({required this.name, required this.email, this.photoUrl});
}

/// Thrown by [GoogleAuthService.signIn] when Google login is not configured on
/// this build. Callers should catch it and continue without an account.
class GoogleAuthUnavailable implements Exception {
  final String message;
  const GoogleAuthUnavailable([this.message = 'Google sign-in is not configured on this build.']);
  @override
  String toString() => 'GoogleAuthUnavailable: $message';
}

/// The contract the app codes against. Swap the implementation to enable real
/// Google login without touching any UI.
abstract interface class GoogleAuthService {
  /// Attempts an interactive Google sign-in. Returns the [GoogleAccount] on
  /// success, `null` if the user cancels, or throws [GoogleAuthUnavailable]
  /// when Google login isn't wired up on this build.
  Future<GoogleAccount?> signIn();

  /// Signs the current Google user out. A no-op when nobody is signed in.
  Future<void> signOut();
}

/// The default, no-network stub. It never performs real OAuth: [signIn] throws
/// [GoogleAuthUnavailable] so callers uniformly treat Google as optional and
/// carry on. Kept dependency-free on purpose (no `google_sign_in`).
class StubGoogleAuthService implements GoogleAuthService {
  const StubGoogleAuthService();

  @override
  Future<GoogleAccount?> signIn() async {
    throw const GoogleAuthUnavailable();
  }

  @override
  Future<void> signOut() async {
    // Nothing to do — no session is ever established by the stub.
  }
}
