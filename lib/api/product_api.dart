import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shoe_store_app/models/product.dart';
import 'package:shoe_store_app/services/local_storage_service.dart'; // Untuk mendapatkan token

// Pastikan baseUrl ini sama dengan yang di auth_api.dart
const String baseUrl = 'http://localhost:5000/api'; 
// const String baseUrl = 'http://192.168.71.144:5000/api'; 

class ProductApi {
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<List<Product>> getProducts({String? search, String? brand, double? minPrice, double? maxPrice}) async {
    String? token = await _localStorageService.getJwtToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    Map<String, String> queryParams = {};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (brand != null && brand.isNotEmpty) queryParams['brand'] = brand;
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();

    Uri uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> productJson = jsonDecode(response.body);
      return productJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode} ${response.body}');
    }
  }

  Future<Product> getProductById(int productId) async {
    String? token = await _localStorageService.getJwtToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product details: ${response.statusCode} ${response.body}');
    }
  }
}