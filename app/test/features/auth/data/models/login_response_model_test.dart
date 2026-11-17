import 'package:flutter_test/flutter_test.dart';
import 'package:jwallet_lite/features/auth/data/models/login_response_model.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  test('parses the login response data from the API', () {
    final json = {
      'accessToken': 'mock_access_token_123',
      'user': {
        'id': 'USR10001',
        'name': 'Demo User',
        'email': 'demo@jstack.co',
      },
    };

    final model = LoginResponseModel.fromJson(json);

    expect(model.accessToken, 'mock_access_token_123');
    expect(model.user.id, tUser.id);
    expect(model.user.name, tUser.name);
    expect(model.user.email, tUser.email);
  });
}
