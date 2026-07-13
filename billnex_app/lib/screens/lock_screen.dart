import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Full-screen PIN gate shown at launch when an app-lock PIN is set.
class LockScreen extends StatefulWidget {
  final AuthService auth;
  final VoidCallback onUnlocked;
  const LockScreen({required this.auth, required this.onUnlocked, super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _entry = '';
  String? _error;
  int _lockout = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _press(String d) async {
    if (_lockout > 0 || _entry.length >= 4) return;
    setState(() {
      _entry += d;
      _error = null;
    });
    if (_entry.length == 4) await _submit();
  }

  void _back() => setState(() => _entry = _entry.isEmpty ? '' : _entry.substring(0, _entry.length - 1));

  Future<void> _submit() async {
    final ok = await widget.auth.verify(_entry);
    if (ok) {
      widget.onUnlocked();
      return;
    }
    final wait = await widget.auth.lockoutSeconds();
    if (!mounted) return;
    setState(() {
      _entry = '';
      _error = wait > 0 ? 'Too many attempts' : 'Wrong PIN';
      _lockout = wait;
    });
    if (wait > 0) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() => _lockout--);
        if (_lockout <= 0) t.cancel();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [bx.brand2, bx.brand]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.lock_outline, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 18),
                const Text('Enter PIN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(_lockout > 0 ? 'Locked · try in ${_lockout}s' : (_error ?? 'BillNex is locked'), style: TextStyle(fontSize: 13, color: _error != null ? bx.danger : bx.muted)),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < 4; i++)
                      Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _entry.length ? bx.brand : Colors.transparent,
                          border: Border.all(color: i < _entry.length ? bx.brand : bx.border, width: 2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 26),
                _keypad(bx),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _keypad(BxColors bx) {
    Widget key(String label, {Widget? child, VoidCallback? onTap}) => Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: 68,
        height: 68,
        child: label.isEmpty && child == null
            ? const SizedBox()
            : Material(
                color: bx.surface2,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _lockout > 0 ? null : (onTap ?? () => _press(label)),
                  child: Center(
                    child: child ?? Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
      ),
    );
    return Column(
      children: [
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (final d in row) key(d)]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            key(''),
            key('0'),
            key(
              'x',
              child: Icon(Icons.backspace_outlined, color: bx.muted),
              onTap: _back,
            ),
          ],
        ),
      ],
    );
  }
}
