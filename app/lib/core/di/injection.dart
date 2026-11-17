import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasource/auth_local_data_source.dart';
import '../../features/auth/data/datasource/auth_remote_data_source.dart';
import '../../features/auth/data/repository/auth_repository_impl.dart';
import '../../features/auth/domain/repository/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../../features/auth/presentation/bloc/login/login_bloc.dart';
import '../../features/dashboard/data/datasource/dashboard_remote_data_source.dart';
import '../../features/dashboard/data/repository/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repository/dashboard_repository.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/transactions/data/datasource/transaction_remote_data_source.dart';
import '../../features/transactions/data/repository/transaction_repository_impl.dart';
import '../../features/transactions/domain/repository/transaction_repository.dart';
import '../../features/transactions/presentation/bloc/detail/transaction_detail_bloc.dart';
import '../../features/transactions/presentation/bloc/history/transactions_bloc.dart';
import '../../features/transfer/data/datasource/transfer_remote_data_source.dart';
import '../../features/transfer/data/repository/transfer_repository_impl.dart';
import '../../features/transfer/domain/repository/transfer_repository.dart';
import '../../features/transfer/presentation/bloc/transfer_bloc.dart';
import '../network/api_client.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../router/app_router.dart';
import '../session/session_events.dart';
import '../storage/secure_storage.dart';

final GetIt getIt = GetIt.instance;

void setupDependencies() {
  _registerCore();
  _registerDataSources();
  _registerRepositories();
  _registerBlocs();
}

void _registerCore() {
  getIt
    ..registerLazySingleton<SessionEvents>(SessionEvents.new)
    ..registerLazySingleton<FlutterSecureStorage>(FlutterSecureStorage.new)
    ..registerLazySingleton<SecureStorage>(
      () => SecureStorage(getIt<FlutterSecureStorage>()),
    )
    ..registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(getIt<SecureStorage>(), getIt<SessionEvents>()),
    )
    ..registerLazySingleton<Dio>(() => DioClient(getIt<AuthInterceptor>()).dio)
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()))
    ..registerLazySingleton<AppRouter>(() => AppRouter(getIt<AuthBloc>()));
}

void _registerDataSources() {
  getIt
    ..registerLazySingleton(() => AuthRemoteDataSource(getIt<ApiClient>()))
    ..registerLazySingleton(() => AuthLocalDataSource(getIt<SecureStorage>()))
    ..registerLazySingleton(() => DashboardRemoteDataSource(getIt<ApiClient>()))
    ..registerLazySingleton(
      () => TransactionRemoteDataSource(getIt<ApiClient>()),
    )
    ..registerLazySingleton(() => TransferRemoteDataSource(getIt<ApiClient>()));
}

void _registerRepositories() {
  getIt
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(),
        getIt<AuthLocalDataSource>(),
      ),
    )
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(getIt<DashboardRemoteDataSource>()),
    )
    ..registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(getIt<TransactionRemoteDataSource>()),
    )
    ..registerLazySingleton<TransferRepository>(
      () => TransferRepositoryImpl(getIt<TransferRemoteDataSource>()),
    );
}

void _registerBlocs() {
  getIt
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(getIt<AuthRepository>(), getIt<SessionEvents>()),
    )
    ..registerFactory<LoginBloc>(() => LoginBloc(getIt<AuthRepository>()))
    ..registerFactory<DashboardBloc>(
      () => DashboardBloc(
        getIt<DashboardRepository>(),
        getIt<TransactionRepository>(),
      ),
    )
    ..registerFactory<TransferBloc>(
      () => TransferBloc(getIt<TransferRepository>()),
    )
    ..registerFactory<TransactionsBloc>(
      () => TransactionsBloc(getIt<TransactionRepository>()),
    )
    ..registerFactory<TransactionDetailBloc>(
      () => TransactionDetailBloc(getIt<TransactionRepository>()),
    );
}
