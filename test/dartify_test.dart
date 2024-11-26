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

  // In this test we just test the value equality.
  group('A) dartify no casts', () {
    // Int value tests
    test('1: dartify JSAny? value 1 and test if int', () {
      const int inputValue = 1;
      final JSAny? jsValue = inputValue.toJS;
      final Object? dartValue = jsValue.dartify();
      print('inputValue=$inputValue  jsValue=$jsValue  dartValue=$dartValue');
      expect(dartValue, equals(inputValue));
    });
    test('2: dartify JSAny? value 1 and test if int?', () {
      const int? inputValue = 1;
      final JSAny? jsValue = inputValue.toJS;
      final Object? dartValue = jsValue.dartify();
      print('inputValue=$inputValue  jsValue=$jsValue  dartValue=$dartValue');
      expect(dartValue, equals(inputValue));
    });
    test('3: dartify JSAny? value null and test if int? null', () {
      const int? inputValue = null;
      final JSAny? jsValue = inputValue as JSAny?;
      final Object? dartValue = jsValue.dartify();
      print('inputValue=$inputValue  jsValue=$jsValue  dartValue=$dartValue');
      expect(dartValue, equals(inputValue));
    });

    // Double value tests
    test('4: dartify JSAny? value 0.1 and test if double', () {
      const double inputValue = 0.1;
      final JSAny? jsValue = inputValue.toJS;
      final Object? dartValue = jsValue.dartify();
      print('inputValue=$inputValue  jsValue=$jsValue  dartValue=$dartValue');
      expect(dartValue, equals(inputValue));
    });
    test('5: dartify JSAny? value 0.1 and test if double?', () {
      const double? inputValue = 0.1;
      final JSAny? jsValue = inputValue.toJS;
      final Object? dartValue = jsValue.dartify();
      print('inputValue=$inputValue  jsValue=$jsValue  dartValue=$dartValue');
      expect(dartValue, equals(inputValue));
    });
    test('6: dartify JSAny? value null and test if double? null', () {
      const double? inputValue = null;
      final JSAny? jsValue = inputValue as JSAny?;
      final Object? dartValue = jsValue.dartify();
      print('inputValue=$inputValue  jsValue=$jsValue  dartValue=$dartValue');
      expect(dartValue, equals(inputValue));
    });
  });

  // In this test we just test the value equality and that we get the
  // correct expected type that we put in to it. We use casts to see if
  // the type conversion fails.
  // This is what would happen in issue 2) if the added hacky workaround
  // was not in place.
  group('B) dartify with casts', () {
    // Int value tests
    test('7: dartify JSAny? value 1 and test if int', () {
      const int inputValue = 1;
      final JSAny? jsValue = inputValue.toJS;
      final Object? dartValue = jsValue.dartify();
      print('inputValue=$inputValue  jsValue=$jsValue  dartValue=$dartValue');
      expect(dartValue as int, equals(inputValue));
    });
    test('8: dartify JSAny? value 1 and test if int?', () {
      const int? inputValue = 1;
      final JSAny? jsValue = inputValue.toJS;
      final Object? dartValue = jsValue.dartify();
      print('inputValue=$inputValue  jsValue=$jsValue  dartValue=$dartValue');
      expect(dartValue as int?, equals(inputValue));
    });
    test('9: dartify JSAny? value null and test if int? null', () {
      const int? inputValue = null;
      final JSAny? jsValue = inputValue as JSAny?;
      final Object? dartValue = jsValue.dartify();
      print('inputValue=$inputValue  jsValue=$jsValue  dartValue=$dartValue');
      expect(dartValue as int?, equals(inputValue));
    });

    // Double value tests
    test('10: dartify JSAny? value 0.1 and test if double', () {
      const double inputValue = 0.1;
      final JSAny? jsValue = inputValue.toJS;
      final Object? dartValue = jsValue.dartify();
      print('inputValue=$inputValue  jsValue=$jsValue  dartValue=$dartValue');
      expect(dartValue as double, equals(inputValue));
    });
    test('11: dartify JSAny? value 0.1 and test if double?', () {
      const double? inputValue = 0.1;
      final JSAny? jsValue = inputValue.toJS;
      final Object? dartValue = jsValue.dartify();
      print('inputValue=$inputValue  jsValue=$jsValue  dartValue=$dartValue');
      expect(dartValue as double?, equals(inputValue));
    });
    test('12: dartify JSAny? value null and test if double? null', () {
      const double? inputValue = null;
      final JSAny? jsValue = inputValue as JSAny?;
      final Object? dartValue = jsValue.dartify();
      print('inputValue=$inputValue  jsValue=$jsValue  dartValue=$dartValue');
      expect(dartValue as double?, equals(inputValue));
    });
  });
}
