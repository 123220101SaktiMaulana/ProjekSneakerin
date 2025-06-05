import 'package:flutter/material.dart';
import 'package:shoe_store_app/api/product_api.dart';
import 'package:shoe_store_app/models/product.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ProductApi _productApi = ProductApi();

  Future<void> fetchProducts({
    String? search, 
    String? brand, 
    double? minPrice, 
    double? maxPrice, 
    List<String>? brands
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use brands parameter if available, otherwise use single brand
      // This provides backward compatibility
      List<String>? finalBrands = brands ?? (brand != null ? [brand] : null);
      
      _products = await _productApi.getProducts(
        search: search, 
        brands: finalBrands, // Pass multiple brands to API
        minPrice: minPrice, 
        maxPrice: maxPrice
      );
    } catch (e) {
      _errorMessage = e.toString();
      print('Error fetching products: $e'); // Log error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method untuk fetch semua produk tanpa filter
  Future<void> fetchAllProducts() async {
    await fetchProducts();
  }

  // Method untuk clear products (useful for logout or refresh)
  void clearProducts() {
    _products = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // Method untuk reset error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Method untuk mendapatkan produk berdasarkan ID
  Product? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Method untuk mendapatkan semua brand yang tersedia
  List<String> getAvailableBrands() {
    Set<String> brands = {};
    for (Product product in _products) {
      if (product.brand != null && product.brand!.isNotEmpty) {
        brands.add(product.brand!);
      } else {
        brands.add('Other');
      }
    }
    return brands.toList()..sort();
  }

  // Method untuk mendapatkan range harga
  Map<String, double> getPriceRange() {
    if (_products.isEmpty) {
      return {'min': 0.0, 'max': 0.0};
    }
    
    double minPrice = _products.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    double maxPrice = _products.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    
    return {'min': minPrice, 'max': maxPrice};
  }
}