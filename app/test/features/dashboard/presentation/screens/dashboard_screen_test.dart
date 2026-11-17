import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jwallet_lite/core/di/injection.dart';
import 'package:jwallet_lite/core/failure/failure.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:jwallet_lite/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:jwallet_lite/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:jwallet_lite/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:jwallet_lite/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockDashboardBloc dashboardBloc;
  late MockAuthBloc authBloc;

  setUp(() {
    dashboardBloc = MockDashboardBloc();
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthState.authenticated(tUser));
    getIt.registerFactory<DashboardBloc>(() => dashboardBloc);
  });

  tearDown(getIt.reset);

  Future<void> pumpDashboard(WidgetTester tester, DashboardState state) {
    when(() => dashboardBloc.state).thenReturn(state);
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const DashboardScreen(),
        ),
      ),
    );
  }

  testWidgets('requests dashboard data when opened', (tester) async {
    await pumpDashboard(tester, const DashboardState());

    verify(() => dashboardBloc.add(const DashboardRequested())).called(1);
  });

  testWidgets('shows a loader while loading', (tester) async {
    await pumpDashboard(
      tester,
      const DashboardState(status: DashboardStatus.loading),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an error with retry when loading fails', (tester) async {
    await pumpDashboard(
      tester,
      const DashboardState(
        status: DashboardStatus.failure,
        failure: NetworkFailure('No internet connection.'),
      ),
    );

    expect(find.text('No internet connection.'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    verify(() => dashboardBloc.add(const DashboardRequested())).called(2);
  });

  testWidgets('shows user, wallet, quick actions and recent transactions', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      DashboardState(
        status: DashboardStatus.loaded,
        user: tUser,
        wallet: tWallet,
        recentTransactions: tTransactionPage.items,
      ),
    );

    expect(find.text('Demo User'), findsOneWidget);
    expect(find.text('DU'), findsOneWidget);
    expect(find.text('₹25,450.75'), findsOneWidget);
    expect(find.text('Currency: INR'), findsOneWidget);
    expect(find.text('Account: XXXX XXXX 4589'), findsOneWidget);
    expect(find.text('Send Money'), findsOneWidget);
    expect(find.text('Add Money'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsOneWidget);
    expect(find.text('-₹1,500.00'), findsOneWidget);
    expect(find.text('+₹5,000.00'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);
  });
}
