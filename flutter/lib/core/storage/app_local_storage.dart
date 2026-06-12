import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  Future<void> setBool(String key, bool value);
  bool? getBool(String key);
  Future<void> setString(String key, String value);
  String? getString(String key);

  Future<void> setSecureString(String key, String value);
  Future<String?> getSecureString(String key);

  Future<void> remove(String key);
  Future<void> removeSecure(String key);
}

class AppLocalStorage implements LocalStorage {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  AppLocalStorage({
    required SharedPreferences prefs,
    FlutterSecureStorage? secureStorage,
  }) : _prefs = prefs,
       _secureStorage = secureStorage ?? FlutterSecureStorage();

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setSecureString(String key, String value) =>
      _secureStorage.write(key: key, value: value);

  @override
  Future<String?> getSecureString(String key) => _secureStorage.read(key: key);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> removeSecure(String key) => _secureStorage.delete(key: key);
}

class SecureStorageOnly implements LocalStorage {
  final FlutterSecureStorage _secureStorage;

  SecureStorageOnly({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? FlutterSecureStorage();

  @override
  Future<void> setBool(String key, bool value) =>
      _secureStorage.write(key: key, value: value.toString());

  @override
  bool? getBool(String key) {
    throw UnsupportedError(
      'Use setString/getString for all storage with SecureStorageOnly',
    );
  }

  @override
  Future<void> setString(String key, String value) =>
      _secureStorage.write(key: key, value: value);

  @override
  String? getString(String key) => null;

  @override
  Future<void> setSecureString(String key, String value) =>
      _secureStorage.write(key: key, value: value);

  @override
  Future<String?> getSecureString(String key) => _secureStorage.read(key: key);

  @override
  Future<void> remove(String key) => _secureStorage.delete(key: key);

  @override
  Future<void> removeSecure(String key) => _secureStorage.delete(key: key);
}
