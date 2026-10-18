import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_strings.dart';
import '../../data/datasources/device_location_source.dart';

class CheckoutLocationMap extends StatefulWidget {
  const CheckoutLocationMap({
    super.key,
    this.locationSource = const DeviceLocationSource(),
  });

  final DeviceLocationSource locationSource;

  @override
  State<CheckoutLocationMap> createState() => _CheckoutLocationMapState();
}

class _CheckoutLocationMapState extends State<CheckoutLocationMap> {
  late Future<LatLng?> _position;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _position = widget.locationSource.currentPosition().then(
      (position) => position == null
          ? null
          : LatLng(position.latitude, position.longitude),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<LatLng?>(
    future: _position,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const SizedBox(
          height: 170,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text(AppStrings.findingLocation),
              ],
            ),
          ),
        );
      }
      final position = snapshot.data;
      if (position == null) {
        return SizedBox(
          height: 170,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off_outlined),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    AppStrings.locationUnavailable,
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(_load),
                  child: const Text(AppStrings.tryAgain),
                ),
              ],
            ),
          ),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 170,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: position, zoom: 15),
            markers: {
              Marker(
                markerId: const MarkerId('current-location'),
                position: position,
              ),
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),
        ),
      );
    },
  );
}
