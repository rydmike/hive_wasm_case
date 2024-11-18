/// App static functions and constants used in this application.
sealed class App {
  // Check if this is a Web-WASM build, Web-JS build or native VM build.
  static const bool isRunningWithWasm = bool.fromEnvironment(
    'dart.tool.dart2wasm',
  );

  static const String keyIntNullable = 'intNullable';
  static const int? intDefaultNullable = null;

  static const String keyDoubleNullable = 'doubleNullable';
  static const double? doubleDefaultNullable = null;

  static const String keyInt = 'intNotNullable';
  static const int intDefault = 0;

  static const String keyDouble = 'doubleNotNullable';
  static const double doubleDefault = 0.0;

  static const String keyNotUsedInt = 'notUsedInt';
  static const int notUsedIntDefault = 2;

  static const String keyNotUsedDouble = 'notUsedDouble';
  static const double notUsedDoubleDefault = 2.0;
}
