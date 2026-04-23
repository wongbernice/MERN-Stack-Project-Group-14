import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userId = 'user_id';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<void> saveID(String id) async {
    await _storage.write(key: _userId, value: id);
  }

  static Future<String?> getID() async {
    return await _storage.read(key: _userId);
  }

  static Future<void> deleteID() async {
    await _storage.delete(key: _userId);
  }
}