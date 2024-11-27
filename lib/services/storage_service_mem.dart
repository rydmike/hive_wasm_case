import 'storage_service.dart';

/// A service that stores and retrieves Storage settings from memory only.
///
/// This class does not persist user settings, it only returns start default
/// values. The runtime in memory storage is actually handled by the Storage
/// controller.
///
/// Loading values from it just returns the default value for each settings
/// property.
class StorageServiceMem implements StorageService {
  /// StorageServiceMem implementations needs no init, it is just a no op.
  @override
  Future<void> init() async {}

  /// Loads a setting from the Storage service, using a key to access it.
  /// Just returning default value for the in memory service that does not
  /// persist values.
  @override
  Future<T> load<T>(String key, T defaultValue) async => defaultValue;

  /// Save a setting to the Storage service, using key, as key for the value.
  /// The in memory version does nothing  just a no op.
  @override
  Future<void> save<T>(String key, T value) async {}

  /// Get all stored key-value paris from the mem storage.
  @override
  Map<String, dynamic> getAll() {
    throw UnimplementedError();
  }

  /// Put all key-value pairs into the Mem storage.
  @override
  Future<void> putAll(
    Map<String, dynamic> values, {
    bool clearExisting = true,
  }) {
    throw UnimplementedError();
  }

  /// This implementation does not supports export and import of stored values.
  @override
  bool get supportsExportImport => false;

  /// Clear all stored values.
  @override
  Future<void> clearAll() async {
    throw UnimplementedError();
  }
}
