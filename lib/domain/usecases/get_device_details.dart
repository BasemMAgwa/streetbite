import '../entities/device_details.dart';
import '../repositories/device_info_repository.dart';

class GetDeviceDetails {
  const GetDeviceDetails(this._repository);

  final DeviceInfoRepository _repository;

  Future<DeviceDetails> call() => _repository.load();
}
