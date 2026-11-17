import 'user_model.dart';

class LoginResponseModel {
  const LoginResponseModel({required this.accessToken, required this.user});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['accessToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String accessToken;
  final UserModel user;
}
