abstract final class AppConfig {
  static const String appName = 'jWallet Lite';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
