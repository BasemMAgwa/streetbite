import '../entities/device_details.dart';

abstract class DeviceInfoRepository {
  Future<DeviceDetails> load();
}
