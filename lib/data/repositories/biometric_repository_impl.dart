import 'package:local_auth/local_auth.dart';

import '../../core/constants/app_strings.dart';
import '../../domain/entities/biometric_result.dart';
import '../../domain/repositories/biometric_repository.dart';

class BiometricRepositoryImpl implements BiometricRepository {
  const BiometricRepositoryImpl(this._auth);

  final LocalAuthentication _auth;

  @override
  Future<BiometricResult> authenticate() async {
    try {
      final enrolled = await _auth.getAvailableBiometrics();
      if (enrolled.isEmpty) return BiometricResult.unavailable;
      final ok = await _auth.authenticate(
        localizedReason: AppStrings.biometricReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      return ok ? BiometricResult.success : BiometricResult.cancelled;
    } catch (_) {
      return BiometricResult.failed;
    }
  }
}
