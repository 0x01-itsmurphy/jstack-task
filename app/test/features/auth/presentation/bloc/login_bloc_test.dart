import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jwallet_lite/core/failure/failure.dart';
import 'package:jwallet_lite/features/auth/domain/entities/user_entity.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/login/login_event.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/login/login_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;

  const submitted = LoginSubmitted(
    email: 'demo@jstack.co',
    password: 'Demo@123',
  );
  const invalidCredentials = ApiFailure(
    'Invalid email or password.',
    statusCode: 401,
    code: 'INVALID_CREDENTIALS',
  );

  void stubLogin(Future<Either<Failure, UserEntity>> Function() answer) {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => answer());
  }

  setUp(() => repository = MockAuthRepository());

  blocTest<LoginBloc, LoginState>(
    'emits submitting then success with the user',
    setUp: () => stubLogin(() async => const Right(tUser)),
    build: () => LoginBloc(repository),
    act: (bloc) => bloc.add(submitted),
    expect: () => const [
      LoginState(status: LoginStatus.submitting),
      LoginState(status: LoginStatus.success, user: tUser),
    ],
    verify: (_) => verify(
      () => repository.login(email: 'demo@jstack.co', password: 'Demo@123'),
    ).called(1),
  );

  blocTest<LoginBloc, LoginState>(
    'emits failure for invalid credentials',
    setUp: () => stubLogin(() async => const Left(invalidCredentials)),
    build: () => LoginBloc(repository),
    act: (bloc) => bloc.add(submitted),
    expect: () => const [
      LoginState(status: LoginStatus.submitting),
      LoginState(status: LoginStatus.failure, failure: invalidCredentials),
    ],
  );

  blocTest<LoginBloc, LoginState>(
    'clears the previous failure when resubmitting',
    setUp: () => stubLogin(() async => const Right(tUser)),
    build: () => LoginBloc(repository),
    seed: () => const LoginState(
      status: LoginStatus.failure,
      failure: invalidCredentials,
    ),
    act: (bloc) => bloc.add(submitted),
    expect: () => const [
      LoginState(status: LoginStatus.submitting),
      LoginState(status: LoginStatus.success, user: tUser),
    ],
  );

  blocTest<LoginBloc, LoginState>(
    'ignores repeated submits while a login is in progress',
    setUp: () => stubLogin(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return const Right(tUser);
    }),
    build: () => LoginBloc(repository),
    act: (bloc) => bloc
      ..add(submitted)
      ..add(submitted),
    wait: const Duration(milliseconds: 50),
    expect: () => const [
      LoginState(status: LoginStatus.submitting),
      LoginState(status: LoginStatus.success, user: tUser),
    ],
    verify: (_) => verify(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).called(1),
  );
}
