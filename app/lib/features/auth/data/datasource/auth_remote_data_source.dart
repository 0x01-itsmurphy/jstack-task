import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/login_response_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
