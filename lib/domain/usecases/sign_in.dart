import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  const SignIn(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call(String email, String password) =>
      _repository.signIn(email, password);
}
