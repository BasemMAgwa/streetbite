import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../data/datasources/vendor_locations.dart';
import '../../l10n/app_localizations.dart';

class VendorMapScreen extends StatelessWidget {
  const VendorMapScreen({super.key});

  static final _markers = VendorLocations.all.map((vendor) {
    return Marker(
      markerId: MarkerId(vendor.id),
      position: LatLng(vendor.latitude, vendor.longitude),
      infoWindow: InfoWindow(
        title: '${vendor.name} · ${vendor.city}',
        snippet: '${vendor.cuisine} · ★ ${vendor.rating.toStringAsFixed(1)}',
      ),
    );
  }).toSet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(30.65, 31.1),
            zoom: 7.4,
          ),
          markers: _markers,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),
        PositionedDirectional(
          top: 16,
          start: 16,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 3,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                l10n.nearbyVendors,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: AppTheme.sectionFont,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
