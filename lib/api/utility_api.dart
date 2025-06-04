// lib/api/utility_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shoe_store_app/services/local_storage_service.dart';

const String baseUrl = 'http://localhost:5000/api'; 
// const String baseUrl = 'http://192.168.71.144:5000/api'; 

class UtilityApi {
  final LocalStorageService _localStorageService = LocalStorageService();

  // Method untuk mendapatkan kurs mata uang
  Future<Map<String, dynamic>> getCurrencyRates() async {
    // Endpoint ini mungkin tidak dilindungi oleh token di backend,
    // tapi kita sertakan token untuk konsistensi jika sewaktu-waktu dilindungi
    String? token = await _localStorageService.getJwtToken();
    // Handle case if token is null, but for this specific endpoint, 
    // backend might allow without token if it's static data.
    // For now, let's assume it might require a token or handle if it doesn't.

    final response = await http.get(
      Uri.parse('$baseUrl/utils/currency/rates'), // Panggil endpoint rates
      headers: token != null ? {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      } : {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to load currency rates: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load currency rates: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
    }
  }


  // Method convertCurrency() yang sudah ada
  Future<Map<String, dynamic>> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    String? token = await _localStorageService.getJwtToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/utils/currency/convert?amount=$amount&from=$fromCurrency&to=$toCurrency'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to convert currency: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to convert currency: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
    }
  }

  Future<Map<String, dynamic>> convertTime({
    required String datetime, // Format ISO 8601 string, e.g., '2025-06-02T10:00:00Z'
    required String fromTimezone,
    required String toTimezone,
  }) async {
    String? token = await _localStorageService.getJwtToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/utils/time/convert?datetime=$datetime&from_tz=$fromTimezone&to_tz=$toTimezone'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to convert time: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to convert time: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
    }
  }


}
