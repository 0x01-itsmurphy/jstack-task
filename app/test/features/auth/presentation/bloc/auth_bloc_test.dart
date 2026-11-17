import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jwallet_lite/core/failure/failure.dart';
import 'package:jwallet_lite/core/session/session_events.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late SessionEvents sessionEvents;

  AuthBloc buildBloc() =>
      AuthBloc(repository, sessionEvents, minimumSplashDuration: Duration.zero);

  setUp(() {
    repository = MockAuthRepository();
    sessionEvents = SessionEvents();
    when(() => repository.logout()).thenAnswer((_) async => const Right(unit));
  });

  tearDown(() => sessionEvents.dispose());

  test('initial state is unknown', () {
    expect(buildBloc().state, const AuthState.unknown());
  });

  group('AuthSessionRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated when a stored session exists',
      setUp: () =>
          when(() => repository.restoreSession())
              .thenAnswer((_) async => const Right(tUser)),
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthSessionRequested()),
      expect: () => [const AuthState.authenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated when no session is stored',
      setUp: () =>
          when(() => repository.restoreSession())
              .thenAnswer((_) async => const Right(null)),
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthSessionRequested()),
      expect: () => [const AuthState.unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated when secure storage fails',
      setUp: () => when(() => repository.restoreSession()).thenAnswer(
        (_) async => const Left(CacheFailure('Unable to access storage.')),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthSessionRequested()),
      expect: () => [const AuthState.unauthenticated()],
    );
  });

  blocTest<AuthBloc, AuthState>(
    'AuthLoggedIn emits authenticated',
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthLoggedIn(tUser)),
    expect: () => [const AuthState.authenticated(tUser)],
  );

  blocTest<AuthBloc, AuthState>(
    'AuthLogoutRequested clears the session and emits unauthenticated',
    build: buildBloc,
    seed: () => const AuthState.authenticated(tUser),
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => [const AuthState.unauthenticated()],
    verify: (_) => verify(() => repository.logout()).called(1),
  );

  group('session expiry', () {
    blocTest<AuthBloc, AuthState>(
      'logs out with sessionExpired when the API reports a 401',
      build: buildBloc,
      seed: () => const AuthState.authenticated(tUser),
      act: (_) => sessionEvents.notifyExpired(),
      expect: () => [const AuthState.unauthenticated(sessionExpired: true)],
      verify: (_) => verify(() => repository.logout()).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'is ignored when the user is not authenticated',
      build: buildBloc,
      seed: () => const AuthState.unauthenticated(),
      act: (_) => sessionEvents.notifyExpired(),
      expect: () => <AuthState>[],
      verify: (_) => verifyNever(() => repository.logout()),
    );
  });
}
