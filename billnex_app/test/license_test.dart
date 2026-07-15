import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billnex/services/license_service.dart';

// Mirrors LicenseService's HMAC scheme + secret (see tool/mint_license.dart).
String _mint(String plan, int expMs) {
  const secret = 'billnex-lic-v1-2f9c7a1e5b';
  final payload = base64Url.encode(utf8.encode(jsonEncode({'p': plan, 'e': expMs})));
  final sig = base64Url.encode(Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(payload)).bytes);
  return '$payload.$sig';
}

int _inDays(int d) => DateTime.now().add(Duration(days: d)).millisecondsSinceEpoch;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fresh install starts a trial, billing unlocked', () async {
    SharedPreferences.setMockInitialValues({});
    final lic = LicenseService.instance;
    await lic.init();
    expect(lic.status, LicenseStatus.trialing);
    expect(lic.isBillingLocked, false);
    expect(lic.daysLeft, greaterThan(10)); // ~14-day trial
  });

  test('valid activation key makes the plan active', () async {
    SharedPreferences.setMockInitialValues({});
    final lic = LicenseService.instance;
    await lic.init();
    final ok = await lic.activate(_mint('yearly', _inDays(365)));
    expect(ok, true);
    expect(lic.status, LicenseStatus.active);
    expect(lic.isPaid, true);
    expect(lic.plan, 'yearly');
    expect(lic.isBillingLocked, false);
  });

  test('expired, garbage, and tampered keys are rejected', () async {
    SharedPreferences.setMockInitialValues({});
    final lic = LicenseService.instance;
    await lic.init();
    expect(await lic.activate(_mint('yearly', _inDays(-1))), false); // already expired
    expect(await lic.activate('not-a-key'), false);
    // Tamper: extend expiry in the payload without re-signing.
    final good = _mint('monthly', _inDays(30));
    final tampered = '${_mint('lifetime', _inDays(99999)).split('.').first}.${good.split('.').last}';
    expect(await lic.activate(tampered), false);
    expect(lic.isPaid, false); // still on trial, nothing accepted
  });
}
