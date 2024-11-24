import 'package:flutter/foundation.dart';

/// App static functions and constants used in this application.
abstract final class App {
  // Check if this is a Web-WASM build, Web-JS build or native VM build.
  static const bool isRunningWithWasm =
      bool.fromEnvironment('dart.tool.dart2wasm');
  static const String buildType = isRunningWithWasm
      ? ' Web-WASM-GC'
      : kIsWeb
          ? ' Web-JS'
          : ' native VM';

  static const String keyInt = 'A: intNotNullable';
  static const int intDefault = 0;

  static const String keyIntNullable = 'B: intNullable';
  static const int? intDefaultNullable = null;

  static const String keyDouble = 'C: doubleNotNullable';
  static const double doubleDefault = 0.0;

  static const String keyDoubleNullable = 'D: doubleNullable';
  static const double? doubleDefaultNullable = null;

  static const String keyDoubleAlwaysNull = 'NULL: doubleAlwaysNull';
  static const double? doubleDefaultAlwaysNull = null;
}
