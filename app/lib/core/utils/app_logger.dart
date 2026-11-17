import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  static void info(String message) => _log(message, name: 'INFO');

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(message, name: 'ERROR', error: error, stackTrace: stackTrace);
  }

  static void _log(
    String message, {
    required String name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    developer.log(message, name: name, error: error, stackTrace: stackTrace);
  }
}
