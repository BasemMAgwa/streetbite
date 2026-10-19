import 'dart:typed_data';

abstract class ProfileRepository {
  Future<void> updatePhoto(String userId, Uint8List bytes);
}
