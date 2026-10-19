import '../entities/biometric_result.dart';
import '../repositories/biometric_repository.dart';

class AuthenticateWithBiometrics {
  const AuthenticateWithBiometrics(this._repository);

  final BiometricRepository _repository;

  Future<BiometricResult> call() => _repository.authenticate();
}
