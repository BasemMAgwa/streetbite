import 'dart:convert';
import 'dart:typed_data';

import '../../domain/repositories/profile_repository.dart';
import '../datasources/firestore_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._service);

  final FirestoreService _service;

  @override
  Future<void> updatePhoto(String userId, Uint8List bytes) => _service
      .mergeUser(userId, {'id': userId, 'photoBase64': base64Encode(bytes)});
}
