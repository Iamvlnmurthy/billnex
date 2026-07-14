import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/print_settings.dart';
import '../services/bt_thermal_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../l10n/app_localizations.dart';

/// Lets the merchant pick a *separate* default printer for A4 invoices and for
/// thermal receipts, plus the thermal roll width. When a default is set, prints
/// go straight there; otherwise the system dialog opens on the correct paper.
class PrintSettingsScreen extends StatefulWidget {
  final AppState state;
  const PrintSettingsScreen({required this.state, super.key});
  @override
  State<PrintSettingsScreen> createState() => _PrintSettingsScreenState();
}

class _PrintSettingsScreenState extends State<PrintSettingsScreen> {
  double _width = 80;
  String? _a4Name;
  String? _thermalName;
  bool _loading = true;

  // Bluetooth
  bool _btOn = false;
  String? _btMac;
  String? _btName;
  bool _btEnabled = false;
  bool _btBusy = false;
  List<BtPrinter> _btDevices = const [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    // Fast, prefs-only load so the screen renders immediately. The native
    // Bluetooth-radio check can block on devices without an adapter (e.g. the
    // emulator), so it must NOT gate the initial render.
    final w = await PrintSettings.thermalWidthMm();
    final a4 = await PrintSettings.printerName(thermal: false);
    final th = await PrintSettings.printerName(thermal: true);
    final btEnabled = await PrintSettings.btEnabled();
    final btMac = await PrintSettings.btMac();
    final btName = await PrintSettings.btName();
    if (!mounted) return;
    setState(() {
      _width = w;
      _a4Name = a4;
      _thermalName = th;
      _btEnabled = btEnabled;
      _btMac = btMac;
      _btName = btName;
      _loading = false;
    });
    // Best-effort radio status, timed out so a blocking plugin can't wedge us.
    final on = await BtThermalService.isEnabled().timeout(const Duration(seconds: 3), onTimeout: () => false).catchError((_) => false);
    if (mounted) setState(() => _btOn = on);
  }

  Future<void> _scanBt() async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _btBusy = true);
    try {
      final granted = await [Permission.bluetoothConnect, Permission.bluetoothScan].request();
      if (granted.values.any((s) => s.isPermanentlyDenied || s.isDenied)) {
        messenger.showSnackBar(SnackBar(content: Text(l.btPermissionNeeded)));
        return;
      }
      final on = await BtThermalService.isEnabled().timeout(const Duration(seconds: 3), onTimeout: () => false).catchError((_) => false);
      final devices = await BtThermalService.paired().timeout(const Duration(seconds: 5), onTimeout: () => const <BtPrinter>[]).catchError((_) => const <BtPrinter>[]);
      if (!mounted) return;
      setState(() {
        _btOn = on;
        _btDevices = devices;
      });
    } finally {
      if (mounted) setState(() => _btBusy = false);
    }
  }

  Future<void> _connectBt(BtPrinter d) async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _btBusy = true);
    try {
      final ok = await BtThermalService.connect(d.mac);
      if (!ok) {
        messenger.showSnackBar(SnackBar(content: Text(l.btConnectFail)));
        return;
      }
      await PrintSettings.setBt(enabled: true, mac: d.mac, name: d.name);
      await _reload();
      messenger.showSnackBar(SnackBar(content: Text(l.btConnectedTo(d.name))));
    } finally {
      if (mounted) setState(() => _btBusy = false);
    }
  }

  Future<void> _testBt() async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_btMac == null) return;
    setState(() => _btBusy = true);
    try {
      final ok = await BtThermalService.printTest(widget.state.shopName, mac: _btMac!, widthMm: _width.round());
      messenger.showSnackBar(SnackBar(content: Text(ok ? l.btTestSent : l.btConnectFail)));
    } finally {
      if (mounted) setState(() => _btBusy = false);
    }
  }

  Future<void> _pick({required bool thermal}) async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final printer = await Printing.pickPrinter(context: context);
    if (printer == null) return; // cancelled
    await PrintSettings.setPrinter(thermal: thermal, printer: printer);
    await _reload();
    messenger.showSnackBar(SnackBar(content: Text(l.printerSaved)));
  }

  Future<void> _clear({required bool thermal}) async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await PrintSettings.setPrinter(thermal: thermal);
    await _reload();
    messenger.showSnackBar(SnackBar(content: Text(l.printerCleared)));
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.printerSettings)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PageHeader(l.printerSettings, l.printerSettingsSub),
                        _printerCard(bx, l, thermal: false, label: l.invoicePrinterA4, icon: Icons.description_outlined, name: _a4Name),
                        const SizedBox(height: 14),
                        _printerCard(bx, l, thermal: true, label: l.receiptPrinterThermal, icon: Icons.receipt_outlined, name: _thermalName),
                        const SizedBox(height: 14),
                        // Thermal roll width
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.thermalRollWidth, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 12),
                                SegmentedButton<double>(
                                  segments: const [
                                    ButtonSegment(value: 58, label: Text('58 mm')),
                                    ButtonSegment(value: 80, label: Text('80 mm')),
                                  ],
                                  selected: {_width},
                                  onSelectionChanged: (s) async {
                                    setState(() => _width = s.first);
                                    await PrintSettings.setThermalWidthMm(s.first);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _btCard(bx, l),
                        const SizedBox(height: 16),
                        Text(l.printerSettingsNote, style: TextStyle(fontSize: 12.5, color: bx.faint, height: 1.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _btCard(BxColors bx, L l) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)),
                  child: Icon(Icons.bluetooth, color: bx.brand),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.btThermalTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(l.btThermalSub, style: TextStyle(fontSize: 12, color: bx.muted, height: 1.35)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _btEnabled,
              title: Text(l.btUseForReceipts, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: _btName != null ? Text('${l.btConnected}: $_btName', style: TextStyle(fontSize: 12, color: bx.pos)) : null,
              onChanged: (v) async {
                setState(() => _btEnabled = v);
                await PrintSettings.setBt(enabled: v);
                if (v && _btDevices.isEmpty) _scanBt();
              },
            ),
            if (_btEnabled) ...[
              if (!_btOn)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(l.btBluetoothOff, style: TextStyle(fontSize: 12.5, color: bx.warn)),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _btBusy ? null : _scanBt,
                      icon: _btBusy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.refresh, size: 18),
                      label: Text(l.btRefresh),
                    ),
                  ),
                  if (_btMac != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(onPressed: _btBusy ? null : _testBt, icon: const Icon(Icons.receipt_long, size: 18), label: Text(l.btTestPrint)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(l.btPairedDevices, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: bx.faint)),
              const SizedBox(height: 4),
              if (_btDevices.isEmpty)
                Text(l.btNoDevices, style: TextStyle(fontSize: 12.5, color: bx.muted, height: 1.4))
              else
                for (final d in _btDevices)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(Icons.print, color: _btMac == d.mac ? bx.pos : bx.muted),
                    title: Text(d.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                    subtitle: Text(d.mac, style: TextStyle(fontSize: 11, color: bx.faint)),
                    trailing: _btMac == d.mac ? Icon(Icons.check_circle, color: bx.pos, size: 20) : TextButton(onPressed: _btBusy ? null : () => _connectBt(d), child: Text(l.btConnected)),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _printerCard(BxColors bx, L l, {required bool thermal, required String label, required IconData icon, required String? name}) {
    final isSet = name != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)),
                  child: Icon(icon, color: bx.brand),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(isSet ? Icons.check_circle : Icons.help_outline, size: 14, color: isSet ? bx.pos : bx.faint),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              isSet ? name : l.printerAskEachTime,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12.5, color: bx.muted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _pick(thermal: thermal),
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: Text(l.choosePrinter),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                if (isSet) ...[
                  const SizedBox(width: 10),
                  OutlinedButton(onPressed: () => _clear(thermal: thermal), child: Text(l.useSystemDialog)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
