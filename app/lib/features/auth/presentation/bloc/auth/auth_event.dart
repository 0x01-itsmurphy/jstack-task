import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthSessionRequested extends AuthEvent {
  const AuthSessionRequested();
}

final class AuthLoggedIn extends AuthEvent {
  const AuthLoggedIn(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}
