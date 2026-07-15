import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Subscription state for the SaaS licence gate.
enum LicenseStatus { trialing, active, grace, expired }

/// Client-side licensing (Phase 1 — offline activation keys, gateway-agnostic).
///
/// A free trial auto-starts on first run. A paid activation key extends the
/// expiry. When the paid/trial period ends there is a short grace window, then
/// billing actions are locked (data stays fully viewable + exportable).
///
/// Activation keys are Ed25519-signed: `base64url(payload).base64url(sig)` where
/// payload = {"p":plan,"e":expiryEpochMs}. The app embeds ONLY the public key
/// ([kPublicKeyB64]), so keys cannot be forged without the private seed — which
/// lives only in tool/mint_license.dart (a dev tool, never shipped). Mint keys
/// with `dart run tool/mint_license.dart <plan> <months>`.
class LicenseService extends ChangeNotifier {
  LicenseService._();
  static final LicenseService instance = LicenseService._();

  // ── tunables ──
  static const int trialDays = 14;
  static const int graceDays = 3;
  static const int warnWithinDays = 15; // show the renewal banner inside this window
  // Ed25519 PUBLIC verification key (base64url). Private seed is in the mint tool.
  static const String kPublicKeyB64 = 'ze6_QxIKOjU91z4_hhWlGPD9E34IZhrMBSka0Y-YisY=';
  static final _ed = Ed25519();

  static const _kFirstRun = 'lic.firstRunMs';
  static const _kPlan = 'lic.plan';
  static const _kExp = 'lic.expMs';
  static const _kKey = 'lic.key';

  int _firstRunMs = 0;
  String? _plan; // null while on trial
  int _expMs = 0; // 0 while on trial (uses trial end)
  String? _activationKey;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  String? get plan => _plan;
  String? get activationKey => _activationKey;

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    _firstRunMs = p.getInt(_kFirstRun) ?? 0;
    if (_firstRunMs == 0) {
      _firstRunMs = DateTime.now().millisecondsSinceEpoch; // trial starts now
      await p.setInt(_kFirstRun, _firstRunMs);
    }
    _plan = p.getString(_kPlan);
    _expMs = p.getInt(_kExp) ?? 0;
    _activationKey = p.getString(_kKey);
    _loaded = true;
    notifyListeners();
  }

  int get _trialEndMs => _firstRunMs + trialDays * 86400000;

  /// The active expiry: the paid expiry once activated, else the trial end.
  int get expiryMs => _plan != null && _expMs > 0 ? _expMs : _trialEndMs;

  DateTime get expiryDate => DateTime.fromMillisecondsSinceEpoch(expiryMs);

  int get _now => DateTime.now().millisecondsSinceEpoch;

  /// Whole days until expiry (negative once past). Ceil so "in 6 hours" reads 1.
  int get daysLeft => (expiryMs - _now) / 86400000 > 0 ? ((expiryMs - _now) / 86400000).ceil() : ((expiryMs - _now) / 86400000).floor();

  LicenseStatus get status {
    final now = _now;
    if (now <= expiryMs) return _plan != null ? LicenseStatus.active : LicenseStatus.trialing;
    if (now <= expiryMs + graceDays * 86400000) return LicenseStatus.grace;
    return LicenseStatus.expired;
  }

  bool get isPaid => _plan != null;

  /// True once billing must be blocked (past the grace window). Viewing and
  /// exporting stay allowed — we never hold the merchant's data hostage.
  bool get isBillingLocked => status == LicenseStatus.expired;

  /// Show the renewal banner during the last [warnWithinDays] days and after.
  bool get showRenewalBanner => status == LicenseStatus.expired || status == LicenseStatus.grace || daysLeft <= warnWithinDays;

  /// Activate with a signed key. Returns true on success (valid signature and a
  /// future expiry). Persists plan + expiry.
  Future<bool> activate(String rawKey) async {
    final parsed = await _verify(rawKey.trim());
    if (parsed == null) return false;
    final (plan, exp) = parsed;
    if (exp <= _now) return false; // already-expired key
    final p = await SharedPreferences.getInstance();
    _plan = plan;
    _expMs = exp;
    _activationKey = rawKey.trim();
    await p.setString(_kPlan, plan);
    await p.setInt(_kExp, exp);
    await p.setString(_kKey, rawKey.trim());
    notifyListeners();
    return true;
  }

  /// Verify an activation key's Ed25519 signature and return (plan, expiryMs),
  /// or null if the signature is invalid or the key is malformed.
  Future<(String, int)?> _verify(String key) async {
    try {
      final dot = key.lastIndexOf('.');
      if (dot <= 0) return null;
      final payloadB64 = key.substring(0, dot);
      final sigBytes = base64Url.decode(key.substring(dot + 1));
      final publicKey = SimplePublicKey(base64Url.decode(kPublicKeyB64), type: KeyPairType.ed25519);
      final ok = await _ed.verify(
        utf8.encode(payloadB64),
        signature: Signature(sigBytes, publicKey: publicKey),
      );
      if (!ok) return null;
      final json = jsonDecode(utf8.decode(base64Url.decode(payloadB64))) as Map<String, dynamic>;
      return (json['p'] as String, (json['e'] as num).toInt());
    } catch (_) {
      return null;
    }
  }
}
