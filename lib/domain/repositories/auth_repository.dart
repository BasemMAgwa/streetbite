import '../entities/app_user.dart';

abstract class AuthRepository {
  AppUser? get currentUser;

  Future<AppUser> signIn(String email, String password);

  Future<AppUser> signUp(String name, String email, String password);

  Future<void> signOut();
}
