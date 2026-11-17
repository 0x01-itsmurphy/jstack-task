import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../bloc/history/transactions_bloc.dart';
import '../bloc/history/transactions_event.dart';
import '../bloc/history/transactions_state.dart';
import '../widgets/transaction_filter_bar.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<TransactionsBloc>()..add(const TransactionsRequested()),
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: SafeArea(
        child: BlocConsumer<TransactionsBloc, TransactionsState>(
          listenWhen: (previous, current) =>
              current.items.isNotEmpty &&
              current.failure != null &&
              previous.failure != current.failure,
          listener: (context, state) =>
              context.showSnackBar(state.failure!.message, isError: true),
          builder: (context, state) => Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _SearchField(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TransactionFilterBar(
                    selected: state.type,
                    onChanged: (type) => context.read<TransactionsBloc>().add(
                      TransactionsTypeChanged(type),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _TransactionsContent(state: state)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField();

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  static const Duration _debounce = Duration(milliseconds: 400);

  final _controller = TextEditingController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(_debounce, () => _search(value));
  }

  void _search(String value) {
    context.read<TransactionsBloc>().add(TransactionsSearchChanged(value));
  }

  void _clear() {
    _timer?.cancel();
    _controller.clear();
    _search('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('transactions_search_field'),
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      onSubmitted: _search,
      decoration: InputDecoration(
        hintText: 'Search by reference or name',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.clear),
                  onPressed: _clear,
                ),
        ),
      ),
    );
  }
}

class _TransactionsContent extends StatelessWidget {
  const _TransactionsContent({required this.state});

  final TransactionsState state;

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<TransactionsBloc>()
      ..add(const TransactionsRefreshed());
    await bloc.stream.firstWhere((state) => !state.isRefreshing);
  }

  bool _onScroll(BuildContext context, ScrollNotification notification) {
    if (notification.metrics.extentAfter < 200) {
      context.read<TransactionsBloc>().add(
        const TransactionsNextPageRequested(),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case TransactionsStatus.initial:
      case TransactionsStatus.loading:
        return const LoadingView();

      case TransactionsStatus.failure:
        return ErrorView(
          message: state.failure?.message ?? 'Unable to load transactions.',
          onRetry: () => context.read<TransactionsBloc>().add(
            const TransactionsRequested(),
          ),
        );

      case TransactionsStatus.empty:
        return EmptyView(
          title: state.hasFilters
              ? 'No matching transactions'
              : 'No transactions yet',
          message: state.hasFilters
              ? 'Try a different search or filter.'
              : 'Your transactions will appear here.',
          icon: Icons.receipt_long_outlined,
        );

      case TransactionsStatus.loaded:
        return RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) => _onScroll(context, notification),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.items.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final transaction = state.items[index];
                return TransactionTile(
                  transaction: transaction,
                  onTap: () =>
                      context.push(AppRoutes.transactionDetail(transaction.id)),
                );
              },
            ),
          ),
        );
    }
  }
}
