// lib/models/shoe_store.dart
class ShoeStore {
  final int id;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final double? distanceKm; // Jarak dari user, dikembalikan oleh backend

  ShoeStore({
    required this.id,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.distanceKm,
  });

 factory ShoeStore.fromJson(Map<String, dynamic> json) {
  return ShoeStore(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? 'Unknown Store',
    address: json['address'] as String?,
    // UBAH BARIS INI:
    latitude: double.parse(json['latitude'].toString()), // Konversi string ke double
    longitude: double.parse(json['longitude'].toString()), // Konversi string ke double
    phoneNumber: json['phone_number'] as String?,
    // UBAH BARIS INI:
    distanceKm: json['distance_km'] != null ? double.parse(json['distance_km'].toString()) : null, // Handle null dan konversi
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'distance_km': distanceKm,
    };
  }
}