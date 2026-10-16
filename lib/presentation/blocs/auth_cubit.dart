import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository, this._signIn, this._signUp, this._signOut)
    : super(const AuthState());

  final AuthRepository _repository;
  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;

  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    if (isClosed || state.status != AuthStatus.initial) return;
    completeSplash();
  }

  void completeSplash() {
    if (state.status != AuthStatus.initial) return;
    final user = _repository.currentUser;
    emit(
      AuthState(
        status: user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  Future<void> logIn(String email, String password) async {
    if (state.isBusy) return;
    emit(const AuthState(status: AuthStatus.unauthenticated, isBusy: true));
    try {
      final user = await _signIn(email.trim(), password);
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: user,
          message: AppStrings.loginSuccess,
        ),
      );
    } on AuthFailure catch (failure) {
      emit(
        AuthState(
          status: AuthStatus.unauthenticated,
          message: _messageFor(failure.type),
        ),
      );
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    if (state.isBusy) return;
    emit(const AuthState(status: AuthStatus.unauthenticated, isBusy: true));
    try {
      final user = await _signUp(name.trim(), email.trim(), password);
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: user,
          message: AppStrings.signUpSuccess,
        ),
      );
    } on AuthFailure catch (failure) {
      emit(
        AuthState(
          status: AuthStatus.unauthenticated,
          message: _messageFor(failure.type),
        ),
      );
    }
  }

  Future<void> logOut() async {
    if (state.isBusy) return;
    final user = state.user;
    emit(AuthState(status: AuthStatus.authenticated, user: user, isBusy: true));
    try {
      await _signOut();
      emit(
        const AuthState(
          status: AuthStatus.unauthenticated,
          message: AppStrings.signOutSuccess,
        ),
      );
    } on AuthFailure catch (failure) {
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: user,
          message: _messageFor(failure.type),
        ),
      );
    }
  }

  String _messageFor(AuthFailureType type) => switch (type) {
    AuthFailureType.invalidEmail => AppStrings.invalidEmail,
    AuthFailureType.emailInUse => AppStrings.emailInUse,
    AuthFailureType.weakPassword => AppStrings.weakPassword,
    AuthFailureType.invalidCredentials => AppStrings.invalidCredentials,
    AuthFailureType.tooManyRequests => AppStrings.blocked,
    AuthFailureType.network => AppStrings.networkError,
    AuthFailureType.serviceUnavailable => AppStrings.serviceUnavailable,
    AuthFailureType.accountSave => AppStrings.accountSaveError,
    AuthFailureType.generic => AppStrings.genericError,
  };
}
