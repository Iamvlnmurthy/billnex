import 'package:flutter/foundation.dart';

/// Crash/error-reporting seam (PRD §18 reliability telemetry).
///
/// A console reporter ships by default; swap in a Crashlytics/Sentry adapter
/// (both need an account) by implementing [ErrorReporter] and passing it to
/// [installErrorHandling]. Telemetry must exclude invoice/customer content —
/// send identifiers and stack traces only.
abstract interface class ErrorReporter {
  void report(Object error, StackTrace? stack, {String? context});
}

class ConsoleErrorReporter implements ErrorReporter {
  const ConsoleErrorReporter();
  @override
  void report(Object error, StackTrace? stack, {String? context}) {
    debugPrint('[BillNex error]${context != null ? ' ($context)' : ''}: $error');
    if (stack != null) debugPrintStack(stackTrace: stack);
  }
}

/// Routes framework + zone errors to [reporter]. Call inside the same zone that
/// runs the app (see main.dart's runZonedGuarded).
void installErrorHandling(ErrorReporter reporter) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    reporter.report(details.exception, details.stack, context: details.context?.toString());
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    reporter.report(error, stack, context: 'platform');
    return true;
  };
}
