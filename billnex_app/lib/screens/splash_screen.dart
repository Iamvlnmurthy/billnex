import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// First-run splash — mirrors the Stitch `mobile_onboarding_business_type`
/// reference: centered brand mark, wordmark, "Get Started" CTA.
class SplashScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  const SplashScreen({required this.onGetStarted, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            children: [
              const Spacer(flex: 5),
              // Brand mark
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [bx.brand2, bx.brand], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [BoxShadow(color: bx.accent.withValues(alpha: 0.35), blurRadius: 28, offset: const Offset(0, 12))],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 46),
              ),
              const SizedBox(height: 22),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Bill',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34, letterSpacing: -1),
                    ),
                    TextSpan(
                      text: 'Nex',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34, letterSpacing: -1, color: bx.accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'BY NEXEN LABS',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 3, color: bx.faint),
              ),
              const Spacer(flex: 6),
              SizedBox(
                height: 54,
                width: double.infinity,
                child: FilledButton(
                  onPressed: onGetStarted,
                  style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(l.getStarted, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l.splashTagline,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: bx.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
