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
      id: json['id'] as int? ?? 0, // Default 0 jika null
      name: json['name'] as String? ?? 'Unknown Store',
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0, // Handle num? to double
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      phoneNumber: json['phone_number'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(), // Ini bisa null jika backend tidak mengembalikan
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