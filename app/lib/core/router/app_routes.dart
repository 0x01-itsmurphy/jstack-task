abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/';
  static const String transfer = '/transfer';
  static const String transferConfirm = '/transfer/confirm';
  static const String transferResult = '/transfer/result';
  static const String transactions = '/transactions';

  static String transactionDetail(String id) => '/transactions/$id';
}
