// Ignored rules for this test
// ignore_for_file: avoid_print, avoid_init_to_null, unnecessary_nullable_for_final_variable_declarations, lines_longer_than_80_chars, prefer_const_declarations

import 'dart:js_interop';

import 'package:test/test.dart';

void main() {
  const int i = 1;
  print(i.toJS.dartify()); // WASM 1.0, JS 1
  print(i.toJS.dartify().runtimeType); // WASM double, JS int
  print(i.toJS.dartify() is int); // WASM false, JS true
  print(i.toJS.dartify() is double); // WASM true, JS true

  group('dartify tests with no casts', () {
    // Int value tests
    test('dartify JSAny? value 1 and test if int?', () {
      final JSAny? jsValue = 1.toJS;
      final Object? dartValue = jsValue.dartify();
      const int? typedValue = 1;
      print('dartValue: $dartValue');
      expect(dartValue, equals(typedValue));
    });
    test('dartify JSAny? value 1 and test if int', () {
      final JSAny? jsValue = 1.toJS;
      final Object? dartValue = jsValue.dartify();
      const int typedValue = 1;
      print('dartValue: $dartValue');
      expect(dartValue, equals(typedValue));
    });
    test('dartify JSAny? value null and test if int? null', () {
      final JSAny? jsValue = null as JSAny?;
      final Object? dartValue = jsValue.dartify();
      const int? typedValue = null;
      print('dartValue: $dartValue');
      expect(dartValue, equals(typedValue));
    });

    // Double value tests
    test('dartify JSAny? value 1.0 and test if double?', () {
      final JSAny? jsValue = 1.0.toJS;
      final Object? dartValue = jsValue.dartify();
      const double? typedValue = 1;
      print('dartValue: $dartValue');
      expect(dartValue, equals(typedValue));
    });
    test('dartify JSAny? value 1.0 and test if double', () {
      final JSAny? jsValue = 1.0.toJS;
      final Object? dartValue = jsValue.dartify();
      const double typedValue = 1.0;
      print('dartValue: $dartValue');
      expect(dartValue, equals(typedValue));
    });
    test('dartify JSAny? value null and test if double? null', () {
      final JSAny? jsValue = null as JSAny?;
      final Object? dartValue = jsValue.dartify();
      const double? typedValue = null;
      print('dartValue: $dartValue');
      expect(dartValue, equals(typedValue));
    });
  });

  group('dartify tests with casts', () {
    // Int value tests
    test('dartify JSAny? value 1 and test if int?', () {
      final JSAny? jsValue = 1.toJS;
      final Object? dartValue = jsValue.dartify();
      const int? typedValue = 1;
      print('dartValue: $dartValue');
      expect(dartValue as int?, equals(typedValue));
    });
    test('dartify JSAny? value 1 and test if int', () {
      final JSAny? jsValue = 1.toJS;
      final Object? dartValue = jsValue.dartify();
      const int typedValue = 1;
      print('dartValue: $dartValue');
      expect(dartValue as int?, equals(typedValue));
    });
    test('dartify JSAny? value null and test if int? null', () {
      final JSAny? jsValue = null as JSAny?;
      final Object? dartValue = jsValue.dartify();
      const int? typedValue = null;
      print('dartValue: $dartValue');
      expect(dartValue as int?, equals(typedValue));
    });

    // Double value tests
    test('dartify JSAny? value 1.0 and test if double?', () {
      final JSAny? jsValue = 1.0.toJS;
      final Object? dartValue = jsValue.dartify();
      const double? typedValue = 1;
      print('dartValue: $dartValue');
      expect(dartValue as double?, equals(typedValue));
    });
    test('dartify JSAny? value 1.0 and test if double', () {
      final JSAny? jsValue = 1.toJS;
      final Object? dartValue = jsValue.dartify();
      const double typedValue = 1.0;
      print('dartValue: $dartValue');
      expect(dartValue as double?, equals(typedValue));
    });
    test('dartify JSAny? value null and test if double? null', () {
      final JSAny? jsValue = null as JSAny?;
      final Object? dartValue = jsValue.dartify();
      const double? typedValue = null;
      print('dartValue: $dartValue');
      expect(dartValue as double?, equals(typedValue));
    });
  });
}
