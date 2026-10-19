abstract class SecuritySettingsRepository {
  Future<bool> loadProfileLock();
  Future<void> saveProfileLock(bool enabled);
}
