import '../../domain/entities/vendor.dart';

class VendorLocations {
  const VendorLocations._();

  static const all = <Vendor>[
    Vendor(
      id: 'cairo-nile-kitchen',
      name: 'Nile Kitchen',
      city: 'Cairo',
      cuisine: 'Egyptian',
      rating: 4.8,
      latitude: 30.0444,
      longitude: 31.2357,
    ),
    Vendor(
      id: 'ismailia-canal-grill',
      name: 'Canal Grill',
      city: 'Ismailia',
      cuisine: 'Grill',
      rating: 4.6,
      latitude: 30.5965,
      longitude: 32.2715,
    ),
    Vendor(
      id: 'alexandria-sea-table',
      name: 'Sea Table',
      city: 'Alexandria',
      cuisine: 'Seafood',
      rating: 4.7,
      latitude: 31.2001,
      longitude: 29.9187,
    ),
    Vendor(
      id: 'mansoura-spice-corner',
      name: 'Spice Corner',
      city: 'Mansoura',
      cuisine: 'Middle Eastern',
      rating: 4.5,
      latitude: 31.0364,
      longitude: 31.3807,
    ),
    Vendor(
      id: 'tanta-oven',
      name: 'Tanta Oven',
      city: 'Tanta',
      cuisine: 'Bakery',
      rating: 4.7,
      latitude: 30.7865,
      longitude: 31.0004,
    ),
    Vendor(
      id: 'port-said-harbor-bites',
      name: 'Harbor Bites',
      city: 'Port Said',
      cuisine: 'Seafood',
      rating: 4.6,
      latitude: 31.2653,
      longitude: 32.3019,
    ),
  ];
}
