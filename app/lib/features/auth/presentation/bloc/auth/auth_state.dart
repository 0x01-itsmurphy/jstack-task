import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState._({
    required this.status,
    this.user,
    this.sessionExpired = false,
  });

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.authenticated(UserEntity user)
    : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated({bool sessionExpired = false})
    : this._(
        status: AuthStatus.unauthenticated,
        sessionExpired: sessionExpired,
      );

  final AuthStatus status;
  final UserEntity? user;
  final bool sessionExpired;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  @override
  List<Object?> get props => [status, user, sessionExpired];
}
