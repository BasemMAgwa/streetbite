import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  const SignUp(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call(String name, String email, String password) =>
      _repository.signUp(name, email, password);
}
