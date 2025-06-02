import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoe_store_app/models/product.dart';
import 'package:shoe_store_app/api/product_api.dart'; // Untuk memanggil API detail produk
import 'package:shoe_store_app/api/order_api.dart'; // Untuk memanggil API order
import 'package:shoe_store_app/providers/auth_provider.dart'; // Untuk mendapatkan user yang login
import 'package:shoe_store_app/screens/profile/order_history_screen.dart'; // Navigasi ke riwayat pembelian

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
  int _selectedQuantity = 1; // Default quantity for purchase

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final product = await ProductApi().getProductById(widget.productId);
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load product details: ${e.toString()}';
        _isLoading = false;
      });
      print('Error fetching product details: $e');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
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
      _isLoading = true; // Set loading for purchase action
    });

    try {
      // Panggil API order
      final success = await OrderApi().createOrder(
        productId: _product!.id,
        quantity: _selectedQuantity,
        shippingAddress: authProvider.user!.address!, // Gunakan alamat dari user yang login
      );

      if (success) {
        _showSnackBar('Purchase successful!');
        // Opsional: Refresh product details to show updated stock
        await _fetchProductDetails();
        // Navigasi ke halaman riwayat pembelian (opsional, bisa juga hanya pop)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
        );
      } else {
        _showSnackBar('Purchase failed. Please try again.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error during purchase: ${e.toString()}', isError: true);
      print('Error during purchase: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.name ?? 'Product Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _product == null
                  ? const Center(child: Text('Product not found.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gambar Produk
                          Center(
                            child: _product!.imageUrl != null && _product!.imageUrl!.isNotEmpty
                                ? Image.network(
                                    _product!.imageUrl!,
                                    height: 250,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/placeholder_shoe.png', // Placeholder jika gambar error
                                        height: 250,
                                        fit: BoxFit.contain,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/placeholder_shoe.png', // Placeholder jika tidak ada URL
                                    height: 250,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                          const SizedBox(height: 20),

                          // Nama Produk
                          Text(
                            _product!.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Brand
                          Text(
                            _product!.brand ?? 'Unknown Brand',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Harga
                          Text(
                            'Rp ${_product!.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Deskripsi
                          Text(
                            _product!.description ?? 'No description available for this product.',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 24),

                          // Stok
                          Row(
                            children: [
                              const Text(
                                'Stok Tersedia: ',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${_product!.stock}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _product!.stock > 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Pemilihan Kuantitas
                          if (_product!.stock > 0)
                            Row(
                              children: [
                                const Text(
                                  'Jumlah: ',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                DropdownButton<int>(
                                  value: _selectedQuantity,
                                  items: List.generate(_product!.stock > 10 ? 10 : _product!.stock, (index) => index + 1) // Batasi pilihan quantity sampai 10 atau stok tersedia
                                      .map((qty) => DropdownMenuItem<int>(
                                            value: qty,
                                            child: Text(qty.toString()),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedQuantity = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          const SizedBox(height: 24),

                          // Tombol Beli Sekarang
                          Center(
                            child: _isLoading // Loading indicator saat membeli
                                ? const CircularProgressIndicator()
                                : _product!.stock > 0
                                    ? ElevatedButton(
                                        onPressed: _buyNow,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple, // Warna tombol
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text(
                                          'Beli Sekarang',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      )
                                    : Text(
                                        'Stok Habis',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
    );
  }
}