/// Abstract interface for the StorageService used to read and save key-value
/// properties.
abstract class StorageService {
  /// StorageService implementations may override this method to perform needed
  /// initialization and setup work.
  Future<void> init();

  /// Loads a setting from the storage service, stored with `key` string.
  Future<T> load<T>(String key, T defaultValue);

  /// Save a setting to the storage service, using `key` as its storage key.
  Future<void> save<T>(String key, T value);

  /// Get a map of all stored keys and values.
  Map<String, dynamic> getAll();

  /// Put all keys and values into storage.
  /// If [clearExisting] existing data will be deleted first
  Future<void> putAll(Map<String, dynamic> values, {bool clearExisting = true});

  /// If we can export the playground theme using this storage
  bool get supportsExportImport;

  /// Clear all stored values.
  Future<void> clearAll();
}
