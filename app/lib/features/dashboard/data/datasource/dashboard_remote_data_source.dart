import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/wallet_model.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.profile);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WalletModel> getWalletBalance() async {
    final response = await _apiClient.get(ApiEndpoints.walletBalance);
    return WalletModel.fromJson(response.data as Map<String, dynamic>);
  }
}
