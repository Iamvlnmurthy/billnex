import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// App-lock via a salted PIN hash held in the platform secure store
/// (Keychain / Keystore) — PRD BNX-0348 (password/PIN protection, rate-limit).
///
/// The PIN itself is never stored; only `sha256(salt + pin)` is kept, and the
/// salt lives in secure storage too. Attempts are rate-limited after 5 fails.
class AuthService {
  AuthService({FlutterSecureStorage? storage}) : _s = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;

  static const _kHash = 'bx_pin_hash';
  static const _kSalt = 'bx_pin_salt';
  static const _kFails = 'bx_pin_fails';

  Future<bool> hasPin() async => (await _s.read(key: _kHash)) != null;

  String _hash(String pin, String salt) => sha256.convert(utf8.encode('$salt|$pin')).toString();

  Future<void> setPin(String pin) async {
    final salt = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    await _s.write(key: _kSalt, value: salt);
    await _s.write(key: _kHash, value: _hash(pin, salt));
    await _s.delete(key: _kFails);
  }

  Future<void> clearPin() async {
    await _s.delete(key: _kHash);
    await _s.delete(key: _kSalt);
    await _s.delete(key: _kFails);
  }

  Future<int> failedAttempts() async => int.tryParse(await _s.read(key: _kFails) ?? '0') ?? 0;

  /// Returns true on success. On failure increments the attempt counter.
  Future<bool> verify(String pin) async {
    final hash = await _s.read(key: _kHash);
    final salt = await _s.read(key: _kSalt);
    if (hash == null || salt == null) return true; // no PIN set → open
    if (_hash(pin, salt) == hash) {
      await _s.delete(key: _kFails);
      return true;
    }
    final fails = await failedAttempts() + 1;
    await _s.write(key: _kFails, value: '$fails');
    return false;
  }

  /// Seconds the user must wait before the next attempt (0 = none).
  Future<int> lockoutSeconds() async {
    final fails = await failedAttempts();
    if (fails < 5) return 0;
    return 30 * (fails - 4); // escalating backoff
  }
}
