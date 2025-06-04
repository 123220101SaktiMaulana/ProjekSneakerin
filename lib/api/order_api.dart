import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shoe_store_app/services/local_storage_service.dart';
import 'package:shoe_store_app/models/order.dart'; // Akan kita buat setelah ini
import 'package:shoe_store_app/models/product.dart'; // Untuk include product details in order

// Pastikan baseUrl ini sama dengan yang di auth_api.dart dan product_api.dart
const String baseUrl = 'http://localhost:5000/api'; 
// const String baseUrl = 'http://192.168.71.144:5000/api'; 

class OrderApi {
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<bool> createOrder({
    required int productId,
    required int quantity,
    required String shippingAddress,
  }) async {
    String? token = await _localStorageService.getJwtToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/orders/checkout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'product_id': productId,
        'quantity': quantity,
        'shipping_address': shippingAddress,
        // Anda bisa menambahkan payment_method jika ada
      }),
    );

    if (response.statusCode == 201) {
      return true; // Pesanan berhasil dibuat
    } else {
      print('Failed to create order: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to create order: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
    }
  }

  Future<List<Order>> getOrders() async {
    String? token = await _localStorageService.getJwtToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> orderJson = jsonDecode(response.body);
      return orderJson.map((json) => Order.fromJson(json)).toList();
    } else {
      print('Failed to load orders: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load orders: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
    }
  }
}