import '../entities/biometric_result.dart';
import '../repositories/biometric_repository.dart';

class AuthenticateWithBiometrics {
  const AuthenticateWithBiometrics(this._repository);

  final BiometricRepository _repository;

  Future<BiometricResult> call(String localizedReason) =>
      _repository.authenticate(localizedReason);
}
