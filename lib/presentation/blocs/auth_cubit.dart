import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/message.dart';
import '../../domain/entities/app_user.dart';
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
          message: AppMessage.loginSuccess,
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
          message: AppMessage.signUpSuccess,
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
          message: AppMessage.signOutSuccess,
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

  void updatePhoto(String photoBase64) {
    final user = state.user;
    if (user == null) return;
    emit(
      AuthState(
        status: state.status,
        user: AppUser(
          id: user.id,
          fullName: user.fullName,
          email: user.email,
          photoBase64: photoBase64,
        ),
        message: state.message,
      ),
    );
  }

  AppMessage _messageFor(AuthFailureType type) => switch (type) {
    AuthFailureType.invalidEmail => AppMessage.invalidEmail,
    AuthFailureType.emailInUse => AppMessage.emailInUse,
    AuthFailureType.weakPassword => AppMessage.weakPassword,
    AuthFailureType.invalidCredentials => AppMessage.invalidCredentials,
    AuthFailureType.tooManyRequests => AppMessage.blocked,
    AuthFailureType.network => AppMessage.networkError,
    AuthFailureType.serviceUnavailable => AppMessage.serviceUnavailable,
    AuthFailureType.accountSave => AppMessage.accountSaveError,
    AuthFailureType.generic => AppMessage.genericError,
  };
}
