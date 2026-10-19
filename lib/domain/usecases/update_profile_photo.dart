import 'dart:typed_data';

import '../repositories/profile_repository.dart';

class UpdateProfilePhoto {
  const UpdateProfilePhoto(this._repository);

  final ProfileRepository _repository;

  Future<void> call(String userId, Uint8List bytes) =>
      _repository.updatePhoto(userId, bytes);
}
