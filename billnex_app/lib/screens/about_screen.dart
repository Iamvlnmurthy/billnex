import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// About BillNex — app identity, version/build, and support links. Also the
/// natural home for subscription/licence status once SaaS billing lands.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((i) {
      if (mounted) setState(() => _info = i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    final version = _info == null ? '—' : '${_info!.version} (${l.aboutBuild} ${_info!.buildNumber})';
    return Scaffold(
      appBar: AppBar(title: Text(l.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                      child: Icon(Icons.receipt_long, size: 40, color: bx.brand),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Center(child: Text('BillNex', style: BxText.pageTitle)),
                  const SizedBox(height: 4),
                  Center(child: Text(l.aboutTagline, textAlign: TextAlign.center, style: TextStyle(color: bx.muted))),
                  const SizedBox(height: 24),
                  Card(
                    child: Column(
                      children: [
                        _row(bx, Icons.info_outline, l.aboutVersion, version, first: true),
                        _row(bx, Icons.business_outlined, l.aboutPublisher, 'NexenLabs'),
                        _row(bx, Icons.verified_user_outlined, l.aboutLicence, l.aboutLicenceFree),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(child: Text(l.aboutCopyright, style: TextStyle(fontSize: 12, color: bx.faint))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BxColors bx, IconData icon, String label, String value, {bool first = false}) {
    return Container(
      decoration: BoxDecoration(border: first ? null : Border(top: BorderSide(color: bx.border))),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: bx.muted),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(value, style: TextStyle(color: bx.muted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
