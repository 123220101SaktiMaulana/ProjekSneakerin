// lib/api/user_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shoe_store_app/models/user.dart';
import 'package:shoe_store_app/services/local_storage_service.dart';

const String baseUrl = 'http://localhost:5000/api'; 
// const String baseUrl = 'http://192.168.71.144:5000/api'; 

class UserApi {
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<User> updateProfile(Map<String, dynamic> userData) async {
    String? token = await _localStorageService.getJwtToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return User.fromJson(responseData['user']); // Backend mengirim 'user' di dalam respons
    } else {
      print('Failed to update profile: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to update profile: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
    }
  }
}