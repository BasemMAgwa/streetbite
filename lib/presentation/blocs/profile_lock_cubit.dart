import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/security_settings_repository.dart';

// Holds the profile-lock preference; on by default.
class ProfileLockCubit extends Cubit<bool> {
  ProfileLockCubit(this._repository) : super(true);

  final SecuritySettingsRepository _repository;
  int _changeCount = 0;

  Future<void> load() async {
    final changeCount = _changeCount;
    final enabled = await _repository.loadProfileLock();
    if (!isClosed && changeCount == _changeCount) emit(enabled);
  }

  Future<void> toggle() async {
    final next = !state;
    final changeCount = ++_changeCount;
    emit(next);
    try {
      await _repository.saveProfileLock(next);
    } catch (_) {
      if (!isClosed && changeCount == _changeCount) emit(!next);
    }
  }
}
