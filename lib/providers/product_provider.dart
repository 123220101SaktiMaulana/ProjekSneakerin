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

  Future<void> fetchProducts({String? search, String? brand, double? minPrice, double? maxPrice}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productApi.getProducts(search: search, brand: brand, minPrice: minPrice, maxPrice: maxPrice);
    } catch (e) {
      _errorMessage = e.toString();
      print('Error fetching products: $e'); // Log error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}