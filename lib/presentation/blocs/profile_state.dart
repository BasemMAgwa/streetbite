import '../../core/constants/message.dart';

import 'dart:typed_data';

class ProfileState {
  const ProfileState({
    this.photoBytes,
    this.deviceModel,
    this.deviceOs,
    this.isUploading = false,
    this.message,
  });

  final Uint8List? photoBytes;
  final String? deviceModel;
  final String? deviceOs;
  final bool isUploading;
  final AppMessage? message;
}
