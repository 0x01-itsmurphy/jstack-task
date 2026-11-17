import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repository/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._repository) : super(const LoginState()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  final AuthRepository _repository;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isSubmitting) return;

    emit(state.copyWith(status: LoginStatus.submitting, clearFailure: true));

    final result = await _repository.login(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(status: LoginStatus.failure, failure: failure)),
      (user) => emit(state.copyWith(status: LoginStatus.success, user: user)),
    );
  }
}
