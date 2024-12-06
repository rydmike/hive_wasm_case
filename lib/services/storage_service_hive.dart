import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

import '../app.dart';
import '../utils/app_data_dir/app_data_dir.dart';
import '../utils/same_types.dart';
import 'storage_service.dart';

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

  /// StorageServiceHive's init implementation. Must call be before accessing
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

  /// Loads a setting from the Storage service, using a key to access it from
  /// the Hive storage box.
  ///
  /// If type T is not an atomic Dart type, there must be a
  /// Hive type adapter that converts T into one.
  @override
  Future<T> load<T>(String key, T defaultValue) async {
    // A dynamic to hold the value we get from the Hive storage.
    dynamic storedValue;
    try {
      storedValue = await _hiveBox.get(key, defaultValue: defaultValue);

      debugPrint('Store LOAD ______________');
      debugPrint('  Store key     : $key');
      debugPrint('  Type expected : $T');
      debugPrint('  Stored value  : $storedValue');
      debugPrint('  Stored type   : ${storedValue.runtimeType}');
      debugPrint('  Default value : $defaultValue');
      debugPrint('  Default type  : ${defaultValue.runtimeType}');
      debugPrint('  Using WASM    : ${App.isRunningWithWasm}');

      // Must use the sameTypes() here to compare generic type to target type.
      final bool isNullableIntT = sameTypes<T, int?>();
      final bool isIntT = sameTypes<T, int>();

      // Add workaround for hive WASM returning double instead of int, when
      // values saved to IndexedDb were int.
      // In this reproduction sample we see this FAIL triggered when reloading
      // values from the DB.
      // We can reproduce this issue by running the sample as WASM build
      // hitting Increase button a few times, then hot restart the app or
      // reload the browser and hit Load Values. We then hit this issue.
      // Without this special if case handling, we would get an error thrown.
      // This path is never entered on native VM or JS builds.
      if (App.isRunningWithWasm &&
          storedValue != null &&
          (storedValue is double) &&
          (isNullableIntT || isIntT)) {
        final T loaded = storedValue.round() as T;
        debugPrint('  ** WASM Error : Expected int but got double, '
            'returning as int: $loaded');
        return loaded;
      } else {
        return storedValue as T;
      }
    } catch (e, stackTrace) {
      debugPrint('Store LOAD ERROR ********');
      debugPrint('  Error message ...... : $e');
      debugPrint('  Store key .......... : $key');
      debugPrint('  Store value ........ : $storedValue');
      debugPrint('  defaultValue ....... : $defaultValue');
      debugPrint('  Stacktrace ......... : $stackTrace');
      if (e is HiveError && e.message.contains('missing type adapter')) {
        // Skip the offending key
        debugPrint(' Missing type adapter : SKIP and return default');
      }
      // If something goes wrong we return the default value.
      return defaultValue;
    }
  }

  /// Save a setting to the Storage service with the Hive storage box,
  /// using key, as key for the value.
  ///
  /// If type T is not an atomic Dart type, there must be a
  /// Hive type adapter that converts T into one.
  @override
  Future<void> save<T>(String key, T value) async {
    try {
      await _hiveBox.put(key, value);
      debugPrint('Store SAVE ______________');
      debugPrint('  Store key     : $key');
      debugPrint('  Stored value  : $value');
      debugPrint('  Type to save  : $T');
      debugPrint('  Runtime type  : ${value.runtimeType}');
      debugPrint('  Using WASM    : ${App.isRunningWithWasm}');
    } catch (e, stackTrace) {
      debugPrint('Hive save (put) ERROR');
      debugPrint(' Error message ...... : $e');
      debugPrint(' Store key .......... : $key');
      debugPrint(' Save value ......... : $value');
      debugPrint(' Stacktrace ......... : $stackTrace');
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
