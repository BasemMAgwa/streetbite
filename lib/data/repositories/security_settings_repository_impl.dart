import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/security_settings_repository.dart';

class SecuritySettingsRepositoryImpl implements SecuritySettingsRepository {
  const SecuritySettingsRepositoryImpl(this._preferences);

  final SharedPreferencesAsync _preferences;

  static const _profileLockKey = 'profileLockEnabled';

  @override
  Future<bool> loadProfileLock() =>
      _preferences.getBool(_profileLockKey).then((enabled) => enabled ?? true);

  @override
  Future<void> saveProfileLock(bool enabled) =>
      _preferences.setBool(_profileLockKey, enabled);
}
