import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shoe_store_app/models/product.dart';
import 'package:shoe_store_app/services/local_storage_service.dart'; // Untuk mendapatkan token

// Pastikan baseUrl ini sama dengan yang di auth_api.dart
const String baseUrl = 'https://sepatu-be101-981623652580.us-central1.run.app/api'; 
// const String baseUrl = 'http://192.168.71.144:5000/api'; 

class ProductApi {
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<List<Product>> getProducts({
    String? search, 
    String? brand, 
    double? minPrice, 
    double? maxPrice, 
    List<String>? brands
  }) async {
    String? token = await _localStorageService.getJwtToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    Map<String, String> queryParams = {};
    
    // Search parameter
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    
    // Brand filtering - prioritize multiple brands over single brand
    if (brands != null && brands.isNotEmpty) {
      // Handle multiple brands
      // Option 1: Send as comma-separated string (most common)
      queryParams['brands'] = brands.join(',');
      
      // Option 2: If your backend expects multiple brand parameters, uncomment below:
      // for (int i = 0; i < brands.length; i++) {
      //   queryParams['brand[$i]'] = brands[i];
      // }
      
      print('Multiple brands filter: ${brands.join(', ')}'); // Debug log
    } else if (brand != null && brand.isNotEmpty) {
      // Fallback to single brand for backward compatibility
      queryParams['brand'] = brand;
      print('Single brand filter: $brand'); // Debug log
    }
    
    // Price filtering
    if (minPrice != null) {
      queryParams['min_price'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParams['max_price'] = maxPrice.toString();
    }

    Uri uri = Uri.parse('$baseUrl/products').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null
    );

    print('API Request URL: $uri'); // Debug log

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('API Response Status: ${response.statusCode}'); // Debug log

      if (response.statusCode == 200) {
        List<dynamic> productJson = jsonDecode(response.body);
        List<Product> products = productJson.map((json) => Product.fromJson(json)).toList();
        
        // Client-side filtering fallback (if backend doesn't support multiple brands)
        if (brands != null && brands.isNotEmpty) {
          products = products.where((product) {
            String productBrand = product.brand ?? 'Other';
            bool matchesBrand = brands.contains(productBrand);
            
            // Handle "Other" brand case
            if (brands.contains('Other') && (product.brand == null || product.brand!.isEmpty)) {
              matchesBrand = true;
            }
            
            return matchesBrand;
          }).toList();
        }
        
        print('Filtered products count: ${products.length}'); // Debug log
        return products;
      } else {
        throw Exception('Failed to load products: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('ProductApi Error: $e'); // Debug log
      throw Exception('Failed to load products: $e');
    }
  }

  Future<Product> getProductById(int productId) async {
    String? token = await _localStorageService.getJwtToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    try {
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
    } catch (e) {
      print('ProductApi getProductById Error: $e'); // Debug log
      throw Exception('Failed to load product details: $e');
    }
  }

  // Method untuk mendapatkan semua brands yang tersedia dari produk
  Future<List<String>> getAvailableBrands() async {
    try {
      // Fetch all products to extract brands
      List<Product> allProducts = await getProducts();
      
      Set<String> uniqueBrands = {};
      for (Product product in allProducts) {
        if (product.brand != null && product.brand!.isNotEmpty) {
          uniqueBrands.add(product.brand!);
        } else {
          uniqueBrands.add('Other');
        }
      }
      
      List<String> brandsList = uniqueBrands.toList()..sort();
      
      // Ensure 'Other' is at the end
      if (brandsList.contains('Other')) {
        brandsList.remove('Other');
        brandsList.add('Other');
      }
      
      return brandsList;
    } catch (e) {
      print('Error fetching available brands: $e');
      // Return default brands as fallback
      return ['Nike', 'Adidas', 'Puma', 'New Balance', 'Converse', 'Vans', 'Reebok', 'Other'];
    }
  }

  // Method untuk mendapatkan statistik produk
  Future<Map<String, dynamic>> getProductStats() async {
    try {
      List<Product> allProducts = await getProducts();
      
      if (allProducts.isEmpty) {
        return {
          'totalProducts': 0,
          'averagePrice': 0.0,
          'minPrice': 0.0,
          'maxPrice': 0.0,
          'brandCount': 0,
        };
      }
      
      double totalPrice = allProducts.fold(0.0, (sum, product) => sum + product.price);
      double averagePrice = totalPrice / allProducts.length;
      double minPrice = allProducts.map((p) => p.price).reduce((a, b) => a < b ? a : b);
      double maxPrice = allProducts.map((p) => p.price).reduce((a, b) => a > b ? a : b);
      
      Set<String> uniqueBrands = allProducts
          .map((p) => p.brand ?? 'Other')
          .toSet();
      
      return {
        'totalProducts': allProducts.length,
        'averagePrice': averagePrice,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'brandCount': uniqueBrands.length,
        'brands': uniqueBrands.toList()..sort(),
      };
    } catch (e) {
      print('Error fetching product stats: $e');
      throw Exception('Failed to fetch product statistics: $e');
    }
  }

  // Method untuk search suggestions
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.length < 2) return [];
    
    try {
      List<Product> products = await getProducts(search: query);
      
      Set<String> suggestions = {};
      for (Product product in products) {
        // Add product names that contain the query
        if (product.name.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(product.name);
        }
        
        // Add brands that contain the query
        if (product.brand != null && 
            product.brand!.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(product.brand!);
        }
      }
      
      return suggestions.take(10).toList(); // Limit to 10 suggestions
    } catch (e) {
      print('Error fetching search suggestions: $e');
      return [];
    }
  }
}