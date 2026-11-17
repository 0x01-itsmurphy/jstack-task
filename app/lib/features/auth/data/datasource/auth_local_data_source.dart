import 'dart:convert';

import '../../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._storage);

  final SecureStorage _storage;

  Future<void> saveSession({required String token, required UserModel user}) {
    return _storage.saveSession(
      token: token,
      userJson: jsonEncode(user.toJson()),
    );
  }

  Future<UserModel?> readSession() async {
    final token = await _storage.readToken();
    final userJson = await _storage.readUser();
    if (token == null || userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  Future<void> clearSession() => _storage.clear();
}
