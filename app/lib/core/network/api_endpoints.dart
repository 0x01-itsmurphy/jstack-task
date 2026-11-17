abstract final class ApiEndpoints {
  static const String login = '/auth/login';
  static const String profile = '/users/profile';
  static const String walletBalance = '/wallet/balance';
  static const String transactions = '/transactions';
  static const String transfer = '/transactions/transfer';

  static String transaction(String id) => '/transactions/$id';
}
