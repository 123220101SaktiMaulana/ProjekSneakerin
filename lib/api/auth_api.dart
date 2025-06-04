import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shoe_store_app/models/user.dart';

// Ganti ini dengan IP localhost Anda untuk emulator Android
// Jika di perangkat fisik, gunakan IP lokal komputer Anda (misal: http://192.168.1.5:5000)
// const String baseUrl = 'http://192.168.71.144:5000/api'; 
const String baseUrl = 'http://localhost:5000/api';


class AuthApi {
  Future<Map<String, dynamic>> register(String username, String email, String password, String fullName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'full_name': fullName,
      }),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'success': true, 'token': responseData['token'], 'user': User.fromJson(responseData['user'])};
    } else {
      return {'success': false, 'message': responseData['message'] ?? 'Registration failed'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'token': responseData['token'], 'user': User.fromJson(responseData['user'])};
    } else {
      return {'success': false, 'message': responseData['message'] ?? 'Login failed'};
    }
  }

  Future<User?> getLoggedInUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return User.fromJson(responseData);
    }
    return null;
  }
}