import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/session/session_events.dart';
import '../../../domain/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._repository,
    SessionEvents sessionEvents, {
    this.minimumSplashDuration = const Duration(milliseconds: 800),
  }) : super(const AuthState.unknown()) {
    on<AuthSessionRequested>(_onSessionRequested);
    on<AuthLoggedIn>(_onLoggedIn);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionExpired>(_onSessionExpired);

    _sessionSubscription = sessionEvents.onExpired.listen(
      (_) => add(const AuthSessionExpired()),
    );
  }

  final AuthRepository _repository;
  final Duration minimumSplashDuration;
  late final StreamSubscription<void> _sessionSubscription;

  Future<void> _onSessionRequested(
    AuthSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    final (result, _) = await (
      _repository.restoreSession(),
      Future<void>.delayed(minimumSplashDuration),
    ).wait;

    result.fold(
      (_) => emit(const AuthState.unauthenticated()),
      (user) => emit(
        user == null
            ? const AuthState.unauthenticated()
            : AuthState.authenticated(user),
      ),
    );
  }

  void _onLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    emit(AuthState.authenticated(event.user));
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    if (!state.isAuthenticated) return;
    await _repository.logout();
    emit(const AuthState.unauthenticated(sessionExpired: true));
  }

  @override
  Future<void> close() async {
    await _sessionSubscription.cancel();
    return super.close();
  }
}
