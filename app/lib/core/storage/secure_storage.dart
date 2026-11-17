import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/app_exceptions.dart';

class SecureStorage {
  SecureStorage(this._storage);

  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user';

  final FlutterSecureStorage _storage;
  String? _cachedToken;

  Future<String?> readToken() async {
    return _cachedToken ??= await _read(_tokenKey);
  }

  Future<String?> readUser() => _read(_userKey);

  Future<void> saveSession({
    required String token,
    required String userJson,
  }) async {
    await _write(_tokenKey, token);
    await _write(_userKey, userJson);
    _cachedToken = token;
  }

  Future<void> clear() async {
    _cachedToken = null;
    try {
      await _storage.deleteAll();
    } on PlatformException {
      throw const CacheException();
    }
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException {
      throw const CacheException();
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException {
      throw const CacheException();
    }
  }
}
