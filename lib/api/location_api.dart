// lib/api/location_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shoe_store_app/services/local_storage_service.dart';
import 'package:shoe_store_app/models/shoe_store.dart'; // Akan dibuat setelah ini

const String baseUrl = 'http://localhost:5000/api'; 
// const String baseUrl = 'http://192.168.71.144:5000/api'; 


class LocationApi {
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<List<ShoeStore>> getNearbyStores({
    required double latitude,
    required double longitude,
    double radiusKm = 50, // Default radius 50 km
  }) async {
    String? token = await _localStorageService.getJwtToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/locations/stores?latitude=$latitude&longitude=$longitude&radius_km=$radiusKm'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> storeJson = jsonDecode(response.body);
      return storeJson.map((json) => ShoeStore.fromJson(json)).toList();
    } else {
      print('Failed to load nearby stores: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load nearby stores: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
    }
  }
}