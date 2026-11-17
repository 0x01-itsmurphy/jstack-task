import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/transactions/presentation/screens/transaction_detail_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/transfer/presentation/bloc/transfer_bloc.dart';
import '../../features/transfer/presentation/screens/send_money_screen.dart';
import '../../features/transfer/presentation/screens/transfer_confirmation_screen.dart';
import '../../features/transfer/presentation/screens/transfer_result_screen.dart';
import '../di/injection.dart';
import 'app_routes.dart';
import 'router_refresh_stream.dart';

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: RouterRefreshStream(_authBloc.stream),
    redirect: _redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            BlocProvider(create: (_) => getIt<TransferBloc>(), child: child),
        routes: [
          GoRoute(
            path: AppRoutes.transfer,
            builder: (context, state) => const SendMoneyScreen(),
            routes: [
              GoRoute(
                path: 'confirm',
                builder: (context, state) => const TransferConfirmationScreen(),
              ),
              GoRoute(
                path: 'result',
                builder: (context, state) => const TransferResultScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.transactions,
        builder: (context, state) => const TransactionsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => TransactionDetailScreen(
              transactionId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final location = state.matchedLocation;
    final onSplash = location == AppRoutes.splash;
    final onLogin = location == AppRoutes.login;

    return switch (_authBloc.state.status) {
      AuthStatus.unknown => onSplash ? null : AppRoutes.splash,
      AuthStatus.authenticated =>
        onSplash || onLogin ? AppRoutes.dashboard : null,
      AuthStatus.unauthenticated => onLogin ? null : AppRoutes.login,
    };
  }
}
