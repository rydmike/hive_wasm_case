import 'dart:js_interop';

import 'package:test/test.dart';

void main() {
  group('dartify tests with no casts', () {
    // Int value tests
    test('dartify JSAny? value 1 and test if int?', () {
      JSAny? jsValue = 1 as JSAny?;
      Object? dartValue = jsValue.dartify();
      int? typedValue = 1;
      print('dartValue: $dartValue');
      expect(dartValue, equals(typedValue));
    });
    test('dartify JSAny? value 1 and test if int', () {
      JSAny? jsValue = 1 as JSAny?;
      Object? dartValue = jsValue.dartify();
      int typedValue = 1;
      print('dartValue: $dartValue');
      expect(dartValue, equals(typedValue));
    });
    test('dartify JSAny? value null and test if int? null', () {
      JSAny? jsValue = null as JSAny?;
      Object? dartValue = jsValue.dartify();
      int? typedValue = null;
      print('dartValue: $dartValue');
      expect(dartValue, equals(typedValue));
    });

    // Double value tests
    test('dartify JSAny? value 1.0 and test if double?', () {
      JSAny? jsValue = 1.0 as JSAny?;
      Object? dartValue = jsValue.dartify();
      double? typedValue = 1;
      print('dartValue: $dartValue');
      expect(dartValue, equals(typedValue));
    });
    test('dartify JSAny? value 1.0 and test if double', () {
      JSAny? jsValue = 1.0 as JSAny?;
      Object? dartValue = jsValue.dartify();
      double typedValue = 1.0;
      print('dartValue: $dartValue');
      expect(dartValue, equals(typedValue));
    });
    test('dartify JSAny? value null and test if double? null', () {
      JSAny? jsValue = null as JSAny?;
      Object? dartValue = jsValue.dartify();
      double? typedValue = null;
      print('dartValue: $dartValue');
      expect(dartValue, equals(typedValue));
    });
  });

  group('dartify tests with casts', () {
    // Int value tests
    test('dartify JSAny? value 1 and test if int?', () {
      JSAny? jsValue = 1 as JSAny?;
      Object? dartValue = jsValue.dartify();
      int? typedValue = 1;
      print('dartValue: $dartValue');
      expect(dartValue as int?, equals(typedValue));
    });
    test('dartify JSAny? value 1 and test if int', () {
      JSAny? jsValue = 1 as JSAny?;
      Object? dartValue = jsValue.dartify();
      int typedValue = 1;
      print('dartValue: $dartValue');
      expect(dartValue as int, equals(typedValue));
    });
    test('dartify JSAny? value null and test if int? null', () {
      JSAny? jsValue = null as JSAny?;
      Object? dartValue = jsValue.dartify();
      int? typedValue = null;
      print('dartValue: $dartValue');
      expect(dartValue as int?, equals(typedValue));
    });

    // Double value tests
    test('dartify JSAny? value 1.0 and test if double?', () {
      JSAny? jsValue = 1.0 as JSAny?;
      Object? dartValue = jsValue.dartify();
      double? typedValue = 1;
      print('dartValue: $dartValue');
      expect(dartValue as double?, equals(typedValue));
    });
    test('dartify JSAny? value 1.0 and test if double', () {
      JSAny? jsValue = 1 as JSAny?;
      Object? dartValue = jsValue.dartify();
      double typedValue = 1.0;
      print('dartValue: $dartValue');
      expect(dartValue as double, equals(typedValue));
    });
    test('dartify JSAny? value null and test if double? null', () {
      JSAny? jsValue = null as JSAny?;
      Object? dartValue = jsValue.dartify();
      double? typedValue = null;
      print('dartValue: $dartValue');
      expect(dartValue as double?, equals(typedValue));
    });
  });
}
