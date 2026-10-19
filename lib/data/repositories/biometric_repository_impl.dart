import 'package:local_auth/local_auth.dart';

import '../../domain/entities/biometric_result.dart';
import '../../domain/repositories/biometric_repository.dart';

class BiometricRepositoryImpl implements BiometricRepository {
  const BiometricRepositoryImpl(this._auth);

  final LocalAuthentication _auth;

  @override
  Future<BiometricResult> authenticate(String localizedReason) async {
    try {
      final enrolled = await _auth.getAvailableBiometrics();
      if (enrolled.isEmpty) return BiometricResult.unavailable;
      final ok = await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      return ok ? BiometricResult.success : BiometricResult.cancelled;
    } catch (_) {
      return BiometricResult.failed;
    }
  }
}
