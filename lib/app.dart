/// App static functions and constants used in this application.
sealed class App {
  // Check if this is a Web-WASM build, Web-JS build or native VM build.
  static const bool isRunningWithWasm = bool.fromEnvironment(
    'dart.tool.dart2wasm',
  );

  static const String keyDouble = 'counterOne';
  static const double doubleDefault = 0.0;

  static const String keyInt = 'counterTwo';
  static const int intDefault = 0;

  static const String keyNotUsed1 = 'notUsed1';
  static const int notUsed1Default = 0;

  static const String keyNotUsed2 = 'notUsed2';
  static const double notUsed2Default = 0.0;
}
