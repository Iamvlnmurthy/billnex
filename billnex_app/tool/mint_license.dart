// Mint a BillNex activation key (Ed25519-signed, offline).
//
// Usage:
//   dart run tool/mint_license.dart <plan> <months>
//   dart run tool/mint_license.dart yearly 12
//   dart run tool/mint_license.dart pubkey            # print the app's public key
//
// SECURITY MODEL: the 32-byte SEED below is the PRIVATE key and must stay in
// this dev tool only — it is NOT shipped in the app. The app embeds only the
// PUBLIC key (LicenseService.kPublicKeyB64), so activation keys cannot be forged
// without this seed. Keep tool/ out of the released APK (it already is — only
// lib/ is bundled).
//
// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:cryptography/cryptography.dart';

// PRIVATE seed — keep secret. Rotate by generating a new one (openssl rand -hex
// 32), then run `dart run tool/mint_license.dart pubkey` and paste the printed
// value into LicenseService.kPublicKeyB64.
const String seedHex = '076580e9c5d2907e3159a5a7f35546b190725718bd31b0fd1f13af9e28aa1a3f';

List<int> _hex(String h) => [for (var i = 0; i < h.length; i += 2) int.parse(h.substring(i, i + 2), radix: 16)];

Future<void> main(List<String> args) async {
  final algo = Ed25519();
  final keyPair = await algo.newKeyPairFromSeed(_hex(seedHex));
  final pub = await keyPair.extractPublicKey();

  if (args.isNotEmpty && args[0] == 'pubkey') {
    print('Public key (paste into LicenseService.kPublicKeyB64):');
    print(base64Url.encode(pub.bytes));
    return;
  }
  if (args.length < 2) {
    print('Usage: dart run tool/mint_license.dart <plan> <months>   |   pubkey');
    return;
  }

  final plan = args[0];
  final months = int.parse(args[1]);
  final expMs = DateTime.now().add(Duration(days: months * 30)).millisecondsSinceEpoch;
  final payload = base64Url.encode(utf8.encode(jsonEncode({'p': plan, 'e': expMs})));
  final sig = await algo.sign(utf8.encode(payload), keyPair: keyPair);
  final key = '$payload.${base64Url.encode(sig.bytes)}';

  print('Plan   : $plan');
  print('Expires: ${DateTime.fromMillisecondsSinceEpoch(expMs)}');
  print('KEY    : $key');
}
