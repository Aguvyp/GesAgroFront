import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const String _keyAccessToken = 'access_token';
  static const String _keyUserRole = 'user_role';

  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyAccessToken, value: token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }

  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyAccessToken);
  }

  static Future<void> saveRole(String role) async {
    await _secureStorage.write(key: _keyUserRole, value: role);
  }

  static Future<String?> getRole() async {
    return await _secureStorage.read(key: _keyUserRole);
  }

  static Future<void> clearSecureData() async {
    await _secureStorage.deleteAll();
  }
}


