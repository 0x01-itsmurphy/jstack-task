import 'package:equatable/equatable.dart';

import '../../../../../core/failure/failure.dart';
import '../../../domain/entities/user_entity.dart';

enum LoginStatus { initial, submitting, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.user,
    this.failure,
  });

  final LoginStatus status;
  final UserEntity? user;
  final Failure? failure;

  bool get isSubmitting => status == LoginStatus.submitting;

  LoginState copyWith({
    LoginStatus? status,
    UserEntity? user,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      user: user ?? this.user,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, user, failure];
}
