// Mint a BillNex activation key (Phase-1 offline licensing).
//
// Usage:
//   dart run tool/mint_license.dart <plan> <months>
//   dart run tool/mint_license.dart yearly 12
//   dart run tool/mint_license.dart lifetime 1200   # ~100 years
//
// The printed key is what a customer pastes into Subscription → Activate.
// The secret MUST match LicenseService._secret. For production, replace this
// HMAC scheme with a server that signs Ed25519/RSA tokens (app holds only the
// public key), so keys can't be minted by anyone who decompiles the app.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:crypto/crypto.dart';

const String secret = 'billnex-lic-v1-2f9c7a1e5b'; // == LicenseService._secret

void main(List<String> args) {
  if (args.length < 2) {
    print('Usage: dart run tool/mint_license.dart <plan> <months>');
    return;
  }
  final plan = args[0];
  final months = int.parse(args[1]);
  // Note: pass a fixed "now" so runs are reproducible if needed; here we use the
  // current time. (This is a dev tool, not app code, so DateTime.now() is fine.)
  final expMs = DateTime.now().add(Duration(days: months * 30)).millisecondsSinceEpoch;
  final payload = base64Url.encode(utf8.encode(jsonEncode({'p': plan, 'e': expMs})));
  final sig = base64Url.encode(Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(payload)).bytes);
  final key = '$payload.$sig';
  print('Plan   : $plan');
  print('Expires: ${DateTime.fromMillisecondsSinceEpoch(expMs)}');
  print('KEY    : $key');
}
