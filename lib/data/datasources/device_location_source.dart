import 'package:geolocator/geolocator.dart';

class DeviceLocationSource {
  const DeviceLocationSource();

  Future<bool> requestPermission() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  Future<Position?> currentPosition() async {
    try {
      if (!await requestPermission()) return null;
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        return await Geolocator.getLastKnownPosition();
      }
    } catch (_) {
      return null;
    }
  }
}
