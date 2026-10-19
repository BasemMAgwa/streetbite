import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/security_settings_repository.dart';

// Holds the profile-lock preference; on by default.
class ProfileLockCubit extends Cubit<bool> {
  ProfileLockCubit(this._repository) : super(true);

  final SecuritySettingsRepository _repository;

  Future<void> load() async {
    if (isClosed) return;
    emit(await _repository.loadProfileLock());
  }

  Future<void> toggle() async {
    final next = !state;
    emit(next);
    try {
      await _repository.saveProfileLock(next);
    } catch (_) {
      if (!isClosed) emit(!next);
    }
  }
}
