import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoe_store_app/models/product.dart';
import 'package:shoe_store_app/api/product_api.dart';
import 'package:shoe_store_app/api/order_api.dart';
import 'package:shoe_store_app/api/utility_api.dart';
import 'package:shoe_store_app/providers/auth_provider.dart';
import 'package:shoe_store_app/screens/profile/order_history_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedQuantity = 1;
  bool _isFavorite = false;

  // State untuk Konversi Mata Uang
  String _selectedCurrency = 'IDR';
  double _convertedPrice = 0.0;
  double _convertedTotalPrice = 0.0;
  Map<String, double> _currencyRates = {};

  // List mata uang yang didukung
  final List<String> _supportedCurrencies = ['IDR', 'USD', 'SGD', 'MYR'];

  @override
  void initState() {
    super.initState();
    _fetchProductDetailsAndRates();
  }

  Future<void> _fetchProductDetailsAndRates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final product = await ProductApi().getProductById(widget.productId);
      final ratesData = await UtilityApi().getCurrencyRates();

      setState(() {
        _product = product;
        _currencyRates = {};
        (ratesData['rates'] as Map<String, dynamic>).forEach((key, value) {
          _currencyRates[key] = (value is num) ? value.toDouble() : double.tryParse(value.toString()) ?? 1.0;
        });
        _isLoading = false;
        _updateConvertedPrices();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load details or rates: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _updateConvertedPrices() {
    if (_product == null || _currencyRates.isEmpty) {
      return;
    }

    double basePriceInIdr = _product!.price;
    _convertedPrice = basePriceInIdr * (_currencyRates[_selectedCurrency] ?? 1.0);
    _convertedTotalPrice = _convertedPrice * _selectedQuantity;
    setState(() {});
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.blue.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _buyNow() async {
    if (_product == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.user?.address == null) {
      _showSnackBar('Please login and set your address in profile before purchasing.', isError: true);
      return;
    }
    if (_product!.stock < _selectedQuantity) {
      _showSnackBar('Not enough stock. Available stock: ${_product!.stock}', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await OrderApi().createOrder(
        productId: _product!.id,
        quantity: _selectedQuantity,
        shippingAddress: authProvider.user!.address!,
      );

      if (success) {
        _showSnackBar('Purchase successful!');
        await _fetchProductDetailsAndRates();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
        );
      } else {
        _showSnackBar('Purchase failed. Please try again.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error during purchase: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _product == null
                  ? const Center(child: Text('Product not found.'))
                  : Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header dengan gambar produk
                              Container(
                                height: 400,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.blue.shade50,
                                      Colors.white,
                                    ],
                                  ),
                                ),
                                child: Stack(
                                  
                                  children: [
                                    // Gambar produk
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 80, bottom: 20),
                                        child: _product!.imageUrl != null && _product!.imageUrl!.isNotEmpty
                                            ? Image.network(
                                                _product!.imageUrl!,
                                                height: 280,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Image.asset(
                                                    'assets/paperbag.jpg',
                                                    height: 280,
                                                    fit: BoxFit.contain,
                                                  );
                                                },
                                              )
                                            : Image.asset(
                                                'assets/paperbag.jpg',
                                                height: 280,
                                                fit: BoxFit.contain,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Content area
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Nama produk dan brand
                                      Text(
                                        _product!.name,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _product!.brand ?? 'Unknown Brand',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Pemilihan mata uang
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade200),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.currency_exchange, color: Colors.blue.shade700, size: 20),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Currency: ',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                                            ),
                                            DropdownButton<String>(
                                              value: _selectedCurrency,
                                              underline: const SizedBox(),
                                              items: _supportedCurrencies.map((String currency) {
                                                return DropdownMenuItem<String>(
                                                  value: currency,
                                                  child: Text(
                                                    currency,
                                                    style: TextStyle(
                                                      color: Colors.blue.shade700,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    _selectedCurrency = newValue;
                                                    _updateConvertedPrices();
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Harga
                                      Text(
                                        '${_selectedCurrency} ${_convertedPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Descriptions
                                      const Text(
                                        'Description',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Deskripsi produk
                                      Text(
                                        _product!.description ?? 'No description available for this product.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Stok info
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _product!.stock > 0 ? Colors.green.shade300 : Colors.red.shade300,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _product!.stock > 0 ? Icons.check_circle_outline : Icons.error_outline,
                                              color: _product!.stock > 0 ? Colors.green.shade600 : Colors.red.shade600,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Stock Available: ${_product!.stock}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: _product!.stock > 0 ? Colors.green.shade700 : Colors.red.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Quantity selector
                                      if (_product!.stock > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade200),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              const Text(
                                                'Quantity: ',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.blue.shade200),
                                                ),
                                                child: DropdownButton<int>(
                                                  value: _selectedQuantity,
                                                  underline: const SizedBox(),
                                                  items: List.generate(
                                                    _product!.stock > 10 ? 10 : _product!.stock,
                                                    (index) => index + 1,
                                                  ).map((qty) => DropdownMenuItem<int>(
                                                    value: qty,
                                                    child: Text(
                                                      qty.toString(),
                                                      style: TextStyle(
                                                        color: Colors.blue.shade700,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  )).toList(),
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      setState(() {
                                                        _selectedQuantity = value;
                                                        _updateConvertedPrices();
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(height: 24),

                                      // Total price
                                      if (_product!.stock > 0)
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade700,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.shade300.withOpacity(0.3),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              const Text(
                                                'Total Price',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${_selectedCurrency} ${_convertedTotalPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(height: 100), // Space for floating buttons
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Floating App Bar
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top + 16,
                              left: 24,
                              right: 24,
                              bottom: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back, size: 20),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Floating bottom buttons
                        if (_product!.stock > 0)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, -5),
                                  ),
                                ],
                              ),
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(color: Colors.blue),
                                    )
                                  : ElevatedButton(
                                      onPressed: _buyNow,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: const Text(
                                        'Buy Now',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                      ],
                    ),
    );
  }
}