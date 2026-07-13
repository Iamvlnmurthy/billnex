import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/app_localizations.dart';

/// Full-screen camera barcode scanner. Pops with the scanned code, or the
/// sentinel '__manual__' if the user chooses to type it instead, or null.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done || capture.barcodes.isEmpty) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;
    _done = true;
    if (!mounted) return;
    Navigator.of(context).pop(code);
  }

  Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L.of(context).notSupportedDevice)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l.scanBarcode),
        actions: [
          IconButton(tooltip: l.toggleFlash, onPressed: () => _safe(_controller.toggleTorch), icon: const Icon(Icons.flash_on)),
          IconButton(tooltip: l.switchCamera, onPressed: () => _safe(_controller.switchCamera), icon: const Icon(Icons.cameraswitch)),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.no_photography_outlined, color: Colors.white70, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      'Camera unavailable',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${error.errorCode}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: () => Navigator.of(context).pop('__manual__'), child: const Text('Type barcode instead')),
                  ],
                ),
              ),
            ),
          ),
          // Scan frame
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).pop('__manual__'),
                icon: const Icon(Icons.keyboard, color: Colors.white),
                label: const Text('Type instead', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
