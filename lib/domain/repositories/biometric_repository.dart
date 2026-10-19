import '../entities/biometric_result.dart';

abstract class BiometricRepository {
  Future<BiometricResult> authenticate(String localizedReason);
}
