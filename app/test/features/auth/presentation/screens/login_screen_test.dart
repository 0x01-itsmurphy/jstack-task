import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jwallet_lite/core/di/injection.dart';
import 'package:jwallet_lite/core/failure/failure.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/login/login_event.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/login/login_state.dart';
import 'package:jwallet_lite/features/auth/presentation/screens/login_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockLoginBloc loginBloc;
  late MockAuthBloc authBloc;

  final emailField = find.byKey(const Key('login_email_field'));
  final passwordField = find.byKey(const Key('login_password_field'));
  final submitButton = find.byKey(const Key('login_submit_button'));

  setUp(() {
    loginBloc = MockLoginBloc();
    authBloc = MockAuthBloc();
    when(() => loginBloc.state).thenReturn(const LoginState());
    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
    getIt.registerFactory<LoginBloc>(() => loginBloc);
  });

  tearDown(getIt.reset);

  Future<void> pumpLogin(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const LoginScreen(),
        ),
      ),
    );
  }

  testWidgets('shows required errors and does not submit an empty form', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    verifyNever(() => loginBloc.add(any()));
  });

  testWidgets('shows an error for an invalid email', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(emailField, 'demo@jstack');
    await tester.enterText(passwordField, 'Demo@123');
    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    verifyNever(() => loginBloc.add(any()));
  });

  testWidgets('submits trimmed credentials when the form is valid', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tester.enterText(emailField, '  demo@jstack.co ');
    await tester.enterText(passwordField, 'Demo@123');
    await tester.tap(submitButton);
    await tester.pump();

    verify(
      () => loginBloc.add(
        const LoginSubmitted(email: 'demo@jstack.co', password: 'Demo@123'),
      ),
    ).called(1);
  });

  testWidgets('toggles password visibility', (tester) async {
    await pumpLogin(tester);

    EditableText passwordText() => tester.widget<EditableText>(
      find.descendant(of: passwordField, matching: find.byType(EditableText)),
    );

    expect(passwordText().obscureText, isTrue);
    await tester.tap(find.byKey(const Key('login_password_toggle')));
    await tester.pump();
    expect(passwordText().obscureText, isFalse);
  });

  testWidgets('shows a loading indicator while submitting', (tester) async {
    when(() => loginBloc.state)
        .thenReturn(const LoginState(status: LoginStatus.submitting));
    await pumpLogin(tester);

    expect(
      find.descendant(
        of: submitButton,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows the error message for invalid credentials', (
    tester,
  ) async {
    when(() => loginBloc.state).thenReturn(
      const LoginState(
        status: LoginStatus.failure,
        failure: ApiFailure('Invalid email or password.', statusCode: 401),
      ),
    );
    await pumpLogin(tester);

    expect(find.text('Invalid email or password.'), findsOneWidget);
  });

  testWidgets('notifies AuthBloc when login succeeds', (tester) async {
    whenListen(
      loginBloc,
      Stream.value(const LoginState(status: LoginStatus.success, user: tUser)),
      initialState: const LoginState(),
    );
    await pumpLogin(tester);
    await tester.pump();

    verify(() => authBloc.add(const AuthLoggedIn(tUser))).called(1);
  });
}
