import 'package:bloc_test/bloc_test.dart';
import 'package:jwallet_lite/features/auth/domain/repository/auth_repository.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/login/login_event.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/login/login_state.dart';
import 'package:jwallet_lite/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:jwallet_lite/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:jwallet_lite/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:jwallet_lite/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:jwallet_lite/features/transactions/domain/repository/transaction_repository.dart';
import 'package:jwallet_lite/features/transfer/domain/repository/transfer_repository.dart';
import 'package:jwallet_lite/features/transfer/presentation/bloc/transfer_bloc.dart';
import 'package:jwallet_lite/features/transfer/presentation/bloc/transfer_event.dart';
import 'package:jwallet_lite/features/transfer/presentation/bloc/transfer_state.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/detail/transaction_detail_bloc.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/detail/transaction_detail_event.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/detail/transaction_detail_state.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/history/transactions_bloc.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/history/transactions_event.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/history/transactions_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

class MockDashboardRepository extends Mock implements DashboardRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockDashboardBloc extends MockBloc<DashboardEvent, DashboardState>
    implements DashboardBloc {}

class MockTransferRepository extends Mock implements TransferRepository {}

class MockTransferBloc extends MockBloc<TransferEvent, TransferState>
    implements TransferBloc {}

class MockTransactionsBloc
    extends MockBloc<TransactionsEvent, TransactionsState>
    implements TransactionsBloc {}

class MockTransactionDetailBloc
    extends MockBloc<TransactionDetailEvent, TransactionDetailState>
    implements TransactionDetailBloc {}
