import 'dart:ui';

import 'package:dovia/core/crash_reporting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeReporter implements CrashReporter {
  final errors = <(Object, bool)>[];
  final flutterErrors = <FlutterErrorDetails>[];
  String? user = 'sin tocar';

  @override
  Future<void> recordError(Object error, StackTrace? stack,
      {bool fatal = false}) async {
    errors.add((error, fatal));
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    flutterErrors.add(details);
  }

  @override
  Future<void> setUser(String? uid) async => user = uid;
}

void main() {
  late FlutterExceptionHandler? previousFlutterHandler;
  late ErrorCallback? previousPlatformHandler;
  late CrashReporter previousReporter;
  late _FakeReporter reporter;

  setUp(() {
    previousFlutterHandler = FlutterError.onError;
    previousPlatformHandler = PlatformDispatcher.instance.onError;
    previousReporter = crashReporter;
    reporter = _FakeReporter();
    crashReporter = reporter;
    installErrorHandlers();
  });

  tearDown(() {
    FlutterError.onError = previousFlutterHandler;
    PlatformDispatcher.instance.onError = previousPlatformHandler;
    crashReporter = previousReporter;
  });

  test('un error del framework se registra (no fatal)', () {
    final details = FlutterErrorDetails(
      exception: StateError('build roto'),
      silent: true,
    );
    FlutterError.onError!(details);

    expect(reporter.flutterErrors, [details]);
    expect(reporter.errors, isEmpty);
  });

  test('un error de Dart sin capturar se registra como fatal', () {
    final error = StateError('future sin catch');
    final handled =
        PlatformDispatcher.instance.onError!(error, StackTrace.current);

    expect(handled, isTrue);
    expect(reporter.errors, [(error, true)]);
  });

  test('cambiar crashReporter después de instalar los handlers se respeta', () {
    final other = _FakeReporter();
    crashReporter = other;
    PlatformDispatcher.instance.onError!(Exception('x'), StackTrace.current);

    expect(reporter.errors, isEmpty);
    expect(other.errors, hasLength(1));
  });
}
