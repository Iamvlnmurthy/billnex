import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billnex/services/license_service.dart';

// Same Ed25519 seed as tool/mint_license.dart, so test-minted keys verify
// against the public key embedded in LicenseService.
const _seedHex = '076580e9c5d2907e3159a5a7f35546b190725718bd31b0fd1f13af9e28aa1a3f';
List<int> _hex(String h) => [for (var i = 0; i < h.length; i += 2) int.parse(h.substring(i, i + 2), radix: 16)];

Future<String> _mint(String plan, int expMs) async {
  final algo = Ed25519();
  final keyPair = await algo.newKeyPairFromSeed(_hex(_seedHex));
  final payload = base64Url.encode(utf8.encode(jsonEncode({'p': plan, 'e': expMs})));
  final sig = await algo.sign(utf8.encode(payload), keyPair: keyPair);
  return '$payload.${base64Url.encode(sig.bytes)}';
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
    final ok = await lic.activate(await _mint('yearly', _inDays(365)));
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
    expect(await lic.activate(await _mint('yearly', _inDays(-1))), false); // already expired
    expect(await lic.activate('not-a-key'), false);
    // Tamper: extend expiry in the payload without re-signing.
    final good = await _mint('monthly', _inDays(30));
    final forged = await _mint('lifetime', _inDays(99999));
    final tampered = '${forged.split('.').first}.${good.split('.').last}';
    expect(await lic.activate(tampered), false);
    expect(lic.isPaid, false); // still on trial, nothing accepted
  });
}
