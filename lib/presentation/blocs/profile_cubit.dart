import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/message.dart';
import '../../core/errors/network_error.dart';
import '../../domain/usecases/get_device_details.dart';
import '../../domain/usecases/update_profile_photo.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._updatePhoto,
    this._deviceDetails,
    this._storedPhoto,
    this._userId, {
    this.onPhotoUploaded,
    this.photoPicker,
    this.fileSelectorPicker,
  }) : super(const ProfileState());

  final UpdateProfilePhoto _updatePhoto;
  final GetDeviceDetails _deviceDetails;
  final Future<String?> Function(String userId) _storedPhoto;
  final String _userId;
  final void Function(String photoBase64)? onPhotoUploaded;
  final Future<Uint8List?> Function()? photoPicker;
  final Future<Uint8List?> Function()? fileSelectorPicker;

  Future<void> load() async {
    try {
      final device = await _deviceDetails();
      emit(
        ProfileState(
          photoBytes: state.photoBytes,
          deviceModel: device.model,
          deviceOs: device.osVersion,
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('device_info_plus failed (${_safeErrorLabel(error)}).');
      }
      emit(ProfileState(photoBytes: state.photoBytes, deviceOs: ''));
    }
    final stored = await _storedPhoto(_userId);
    if (stored != null && !isClosed) {
      emit(
        ProfileState(
          photoBytes: base64Decode(stored),
          deviceModel: state.deviceModel,
          deviceOs: state.deviceOs,
        ),
      );
    }
  }

  // image_picker covers Android, iOS and macOS; Windows and Linux need the
  // file_selector dialog.
  bool get _needsFileSelector =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<Uint8List?> _pickWithFileSelector() async {
    const images = XTypeGroup(
      label: 'Images',
      extensions: <String>['jpg', 'jpeg', 'png', 'webp', 'heic'],
    );
    final file = await openFile(acceptedTypeGroups: [images]);
    return file?.readAsBytes();
  }

  Future<Uint8List?> _pickFromGallery() async {
    if (_needsFileSelector) {
      return (fileSelectorPicker ?? _pickWithFileSelector)();
    }
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 70,
    );
    return picked?.readAsBytes();
  }

  Future<Uint8List?> _pickPhotoBytes() async {
    try {
      return await (photoPicker ?? _pickFromGallery)();
    } catch (error) {
      if (!_isAndroid) rethrow;
      if (kDebugMode) {
        debugPrint(
          'image_picker failed (${_safeErrorLabel(error)}); '
          'retrying with the Android document picker.',
        );
      }
      return (fileSelectorPicker ?? _pickWithFileSelector)();
    }
  }

  Future<void> pickPhoto() async {
    if (state.isUploading) return;
    final previous = state.photoBytes;
    final previousDevice = state.deviceModel;
    final previousOs = state.deviceOs;
    Uint8List? bytes;
    try {
      bytes = await _pickPhotoBytes();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Photo selection failed (${_safeErrorLabel(error)}).');
      }
      emit(
        ProfileState(
          photoBytes: previous,
          deviceModel: previousDevice,
          deviceOs: previousOs,
          message: AppMessage.photoPickError,
        ),
      );
      return;
    }
    if (bytes == null) return;
    emit(
      ProfileState(
        photoBytes: bytes,
        deviceModel: previousDevice,
        deviceOs: previousOs,
        isUploading: true,
      ),
    );
    try {
      await _updatePhoto(_userId, bytes);
      onPhotoUploaded?.call(base64Encode(bytes));
      emit(
        ProfileState(
          photoBytes: bytes,
          deviceModel: previousDevice,
          deviceOs: previousOs,
          message: AppMessage.photoUploaded,
        ),
      );
    } catch (error) {
      emit(
        ProfileState(
          photoBytes: previous,
          deviceModel: previousDevice,
          deviceOs: previousOs,
          message: isNetworkError(error)
              ? AppMessage.networkError
              : AppMessage.photoUploadError,
        ),
      );
    }
  }

  String _safeErrorLabel(Object error) {
    if (error is PlatformException) {
      return 'PlatformException/${error.code}';
    }
    if (error is MissingPluginException) return 'MissingPluginException';
    return error.runtimeType.toString();
  }
}

typedef StoredPhotoReader = Future<String?> Function(String userId);
