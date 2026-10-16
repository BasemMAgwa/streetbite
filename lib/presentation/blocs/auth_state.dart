import '../../domain/entities/app_user.dart';

enum AuthStatus { initial, unauthenticated, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.isBusy = false,
    this.message,
  });

  final AuthStatus status;
  final AppUser? user;
  final bool isBusy;
  final String? message;
}
