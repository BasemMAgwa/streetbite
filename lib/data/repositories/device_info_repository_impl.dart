import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/device_details.dart';
import '../../domain/repositories/device_info_repository.dart';

class DeviceInfoRepositoryImpl implements DeviceInfoRepository {
  const DeviceInfoRepositoryImpl(this._plugin);

  final DeviceInfoPlugin _plugin;

  @override
  Future<DeviceDetails> load() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final info = await _plugin.androidInfo;
        final manufacturer = info.manufacturer.trim();
        final model = info.model.trim().isEmpty
            ? info.device.trim()
            : info.model.trim();
        final display =
            manufacturer.isEmpty ||
                model.isEmpty ||
                model.toLowerCase().startsWith(manufacturer.toLowerCase())
            ? model
            : '$manufacturer $model';
        return DeviceDetails(
          model: display.isEmpty ? 'Unknown device' : display,
          osVersion: 'Android ${info.version.release}',
        );
      case TargetPlatform.iOS:
        final info = await _plugin.iosInfo;
        return DeviceDetails(
          model: info.utsname.machine,
          osVersion: 'iOS ${info.systemVersion}',
        );
      case TargetPlatform.windows:
        final info = await _plugin.windowsInfo;
        return DeviceDetails(
          model: info.computerName,
          osVersion: 'Windows ${info.displayVersion}',
        );
      default:
        return const DeviceDetails(model: 'Unknown device', osVersion: '');
    }
  }
}
