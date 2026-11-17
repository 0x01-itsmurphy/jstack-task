import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth/auth_event.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_transactions_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardBloc>()..add(const DashboardRequested()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listenWhen: (previous, current) =>
            current.hasData &&
            current.failure != null &&
            previous.failure != current.failure,
        listener: (context, state) =>
            context.showSnackBar(state.failure!.message, isError: true),
        builder: (context, state) => _DashboardContent(state: state),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.state});

  final DashboardState state;

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<DashboardBloc>()..add(const DashboardRefreshed());
    await bloc.stream.firstWhere((state) => !state.isRefreshing);
  }

  Future<void> _openSendMoney(BuildContext context) async {
    await context.push(AppRoutes.transfer);
    if (context.mounted) {
      context.read<DashboardBloc>().add(const DashboardRefreshed());
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case DashboardStatus.initial:
      case DashboardStatus.loading:
        return const LoadingView();

      case DashboardStatus.failure:
        return ErrorView(
          message: state.failure?.message ?? 'Unable to load your wallet.',
          onRetry: () =>
              context.read<DashboardBloc>().add(const DashboardRequested()),
        );

      case DashboardStatus.loaded:
        return RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _UserHeader(user: state.user!),
              const SizedBox(height: 16),
              BalanceCard(wallet: state.wallet!),
              const SizedBox(height: 16),
              QuickActions(
                onSendMoney: () => _openSendMoney(context),
                onAddMoney: () =>
                    context.showSnackBar('Add Money is not available yet.'),
                onHistory: () => context.push(AppRoutes.transactions),
              ),
              const SizedBox(height: 16),
              RecentTransactionsSection(
                transactions: state.recentTransactions,
                onViewAll: () => context.push(AppRoutes.transactions),
                onTransactionTap: (transaction) =>
                    context.push(AppRoutes.transactionDetail(transaction.id)),
              ),
            ],
          ),
        );
    }
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Text(Formatters.initials(user.name))),
      title: const Text('Welcome back,'),
      subtitle: Text(user.name, style: context.textTheme.titleMedium),
    );
  }
}
