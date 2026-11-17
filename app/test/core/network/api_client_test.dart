import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jwallet_lite/core/network/api_client.dart';
import 'package:jwallet_lite/core/network/app_exceptions.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusCode, this.body);

  final int statusCode;
  final Object body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiClient _client(int statusCode, Object body) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeAdapter(statusCode, body);
  return ApiClient(dio);
}

void main() {
  test('returns the unwrapped data for a successful envelope', () async {
    final response = await _client(200, {
      'success': true,
      'data': {'walletId': 'WALLET10001'},
    }).get('/wallet/balance');

    expect(response.success, isTrue);
    expect(response.data, {'walletId': 'WALLET10001'});
  });

  test('exposes meta for paginated responses', () async {
    final response = await _client(200, {
      'success': true,
      'data': <Object>[],
      'meta': {'page': 1, 'hasMore': false},
    }).get('/transactions');

    expect(response.meta, {'page': 1, 'hasMore': false});
  });

  test('throws when the success flag is missing', () async {
    final call = _client(200, {
      'data': {'id': 'USR10001'},
    }).get('/users/profile');

    await expectLater(call, throwsA(isA<ServerException>()));
  });

  test('throws when the body is not a JSON object', () async {
    final call = _client(200, ['unexpected']).get('/users/profile');

    await expectLater(call, throwsA(isA<UnknownException>()));
  });

  test('throws when a 200 response has success false', () async {
    final call = _client(200, {
      'success': false,
      'error': {'code': 'FAILED', 'message': 'Not processed.'},
    }).get('/wallet/balance');

    await expectLater(
      call,
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'Not processed.',
        ),
      ),
    );
  });

  test('maps a 401 error envelope to UnauthorizedException', () async {
    final call = _client(401, {
      'success': false,
      'error': {
        'code': 'INVALID_CREDENTIALS',
        'message': 'Invalid email or password.',
      },
    }).post('/auth/login');

    await expectLater(
      call,
      throwsA(
        isA<UnauthorizedException>()
            .having((e) => e.code, 'code', 'INVALID_CREDENTIALS')
            .having((e) => e.message, 'message', 'Invalid email or password.'),
      ),
    );
  });

  test('maps a 409 error envelope to ConflictException', () async {
    final call = _client(409, {
      'success': false,
      'error': {
        'code': 'INSUFFICIENT_BALANCE',
        'message': 'Insufficient wallet balance for this transfer.',
      },
    }).post('/transactions/transfer');

    await expectLater(
      call,
      throwsA(
        isA<ConflictException>().having(
          (e) => e.code,
          'code',
          'INSUFFICIENT_BALANCE',
        ),
      ),
    );
  });

  test('maps 400 field errors to BadRequestException', () async {
    final call = _client(400, {
      'success': false,
      'error': {
        'code': 'VALIDATION_ERROR',
        'message': 'One or more fields are invalid.',
        'details': {
          'fieldErrors': {'amount': 'Amount must be greater than zero.'},
        },
      },
    }).post('/transactions/transfer');

    await expectLater(
      call,
      throwsA(
        isA<BadRequestException>().having(
          (e) => e.fieldErrors['amount'],
          'amount error',
          'Amount must be greater than zero.',
        ),
      ),
    );
  });
}
