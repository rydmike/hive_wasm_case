import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

import '../app.dart';
import '../utils/app_data_dir/app_data_dir.dart';
import '../utils/same_types.dart';
import 'theme_service.dart';

/// A [StorageService] implementation that stores and retrieves settings
/// locally using the package Hive: https://pub.dev/packages/hive
class StorageServiceHive implements StorageService {
  StorageServiceHive(this.boxName);

  /// The name of the Hive storage box.
  ///
  /// This is the filename without any extension or path, to use for
  /// the Hive storage box, for example: 'my_app_settings'
  final String boxName;

  // Holds an instance to Hive box, must be initialized
  // by the init call before accessing the storage box.
  late final Box<dynamic> _hiveBox;

  /// ThemeServiceHive's init implementation. Must call be before accessing
  /// the storage box.
  ///
  /// - Registers Hive data type adapters for our enum values
  /// - Gets a usable platform appropriate folder where data can be stored.
  /// - Open the box in the folder with name given via class constructor.
  /// - Assign box to local Hive box instance.
  @override
  Future<void> init() async {
    // Get platform compatible storage folder for the Hive box,
    // this setup should work on all Flutter platforms. Hive does not do this
    // right, or it did not in some older versions, never bothered to check
    // if it has corrected it, the folder we got with it did not work on
    // Windows. This implementation works and it uses the same folder that
    // SharedPreferences does.
    final String appDataDir = await getAppDataDir();
    // To make it easier to find the files on your device, this should help.
    // Usually you find the "shared_preferences.json" file in the same folder
    // that the ThemeServicePref creates with SharedPreferences. You cannot
    // set the name on that file so all examples would have shared the same
    // settings on local builds if SharedPreferences would have been used for
    // all examples. Wanted to avoid that, which we can do with Hive. Sure we
    // could have used only Hive too, but SharedPreferences is a very popular
    // choice for this type of feature. I wanted to show how it can be
    // used as well. We always show this path info in none release builds.
    debugPrint(
      'Hive using storage path: $appDataDir and file name: $boxName',
    );
    // Init the Hive box box giving it the platform usable folder.
    Hive.init(appDataDir);
    // Open the Hive box with passed in name, we just keep it open all the
    // time in this demo app.
    await Hive.openBox<dynamic>(boxName);
    // Assign the box to our instance.
    _hiveBox = Hive.box<dynamic>(boxName);
  }

  // ----------

  /// Loads a setting from the Theme service, using a key to access it from
  /// the Hive storage box.
  ///
  /// If type <T> is not an atomic Dart type, there must be a
  /// Hive type adapter that converts <T> into one.
  @override
  Future<T> load<T>(String key, T defaultValue) async {
    // This one is typically inside the try-catch block, but we want to
    // debug print the storedValue also in the catch block, and for the issue
    // being debugged, we have no crash on getting values from the the WEB
    // indexedDB storage, the issues are on the type conversions.
    final dynamic storedValue = _hiveBox.get(key, defaultValue: defaultValue);
    try {
      final bool isNullableDoubleT = sameTypes<T, double?>();
      debugPrint('Hive LOAD _______________');
      debugPrint('  Stored value  : $storedValue');
      debugPrint('  Type expected : $key as ${defaultValue.runtimeType}');
      debugPrint('  Type loaded   : $key as ${storedValue.runtimeType}');
      debugPrint('  Type value    : $T');
      debugPrint('  Default value : $defaultValue');
      debugPrint('  T is double?  : $isNullableDoubleT');
      debugPrint('  Using WASM    : ${App.isRunningWithWasm}');
      // Add workaround for hive WASM returning double instead of int, when
      // values saved to IndexedDb were int.
      // See issue: https://github.com/IO-Design-Team/hive_ce/issues/46
      // In this reproduction sample we seen this FAIL triggered ONLY when
      // loading the values from the DB without having written anything to it
      // first. We can reproduce this issue by running the sample as WASM build
      // hitting plus a few times, then hot restart the app and hit Load Values.
      // We now hit this issue:
      if (App.isRunningWithWasm &&
          storedValue != null &&
          (storedValue is double) &&
          (defaultValue is int || defaultValue is int?)) {
        final T loaded = storedValue.round() as T;
        debugPrint(
          '  ** WASM Error : Expected int got double, '
          'returning as int: $loaded',
        );
        return loaded;
        // We should catch the 2nd issue here, but we do not see it in this
        // branch, we should see the debugPrint, but we do not see it.
        // We get a caught error in the catch block instead.
      } else if (App.isRunningWithWasm &&
          storedValue != null &&
          isNullableDoubleT &&
          defaultValue == null) {
        debugPrint(
          '   WASM Error : Expected double? but thinks T is int, '
          'returning as double: $storedValue',
        );
        final double loaded = storedValue as double;
        return loaded as T;
      } else {
        final T loaded = storedValue as T;
        return loaded;
      }
      // In this reproduction sample we see this CATCH triggered when loading
      // the nullable double value, that it thinks is an INT for some odd reason
      // and then type conversion throws.
      // This issue likely also happen in the release build of WASM-GC Themes
      // Playground build, as we can get a crash there too. We do not see
      // this in debug builds of the Playground WASM-GC, only in the release
      // build.
    } catch (e) {
      debugPrint('Hive LOAD ERROR ********');
      debugPrint('  Error message ...... : $e');
      debugPrint('  Store key .......... : $key');
      debugPrint('  Store value ........ : $storedValue');
      debugPrint('  defaultValue ....... : $defaultValue');
      if (e is HiveError && e.message.contains('missing type adapter')) {
        // Skip the offending key
        debugPrint(' Missing type adapter : SKIP and return default');
      }
      // If something goes wrong we return the default value.
      return defaultValue;
    }
  }

  /// Save a setting to the Theme service with the Hive storage box,
  /// using key, as key for the value.
  ///
  /// If type <T> is not an atomic Dart type, there must be a
  /// Hive type adapter that converts <T> into one.
  @override
  Future<void> save<T>(String key, T value) async {
    try {
      await _hiveBox.put(key, value);
      debugPrint('Hive SAVE _______________');
      debugPrint(' Type  : $key as ${value.runtimeType}');
      debugPrint(' Value : $key as $value');
    } catch (e) {
      debugPrint('Hive save (put) ERROR');
      debugPrint(' Error message ...... : $e');
      debugPrint(' Store key .......... : $key');
      debugPrint(' Save value ......... : $value');
    }
  }

  /// Get all stored key-value paris from the SharedPreferences storage.
  @override
  Map<String, dynamic> getAll() {
    // Filter out entries where the value is null.
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final MapEntry<dynamic, dynamic> entry in _hiveBox.toMap().entries) {
      if (entry.value != null) {
        result[entry.key.toString()] = entry.value;
      }
    }
    return result;
  }

  /// Put all key-value pairs into the Hive storage.
  @override
  Future<void> putAll(
    Map<String, dynamic> values, {
    bool clearExisting = true,
  }) async {
    if (clearExisting) {
      await _hiveBox.clear();
    }

    return _hiveBox.putAll(values);
  }

  /// This implementation supports export and import of stored values.
  @override
  bool get supportsExportImport => true;

  /// Clear all stored values.
  @override
  Future<void> clearAll() async {
    await _hiveBox.clear();
  }
}
