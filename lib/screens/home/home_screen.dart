import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoe_store_app/providers/auth_provider.dart';
import 'package:shoe_store_app/providers/product_provider.dart';
import 'package:shoe_store_app/screens/auth/login_screen.dart';
import 'package:shoe_store_app/models/product.dart';
import 'package:shoe_store_app/screens/home/product_detail_screen.dart';
import 'package:shoe_store_app/screens/profile/order_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Untuk filter
  String? _selectedBrandFilter;
  double? _minPriceFilter;
  double? _maxPriceFilter;

  // List contoh merek (bisa diambil dari API nanti jika ada endpoint brands)
  final List<String> _availableBrands = ['Nike', 'Adidas', 'Puma', 'New Balance', 'Converse', 'Other'];

  @override
  void initState() {
    super.initState();
    _fetchProductsWithFilters(); // Panggil dengan filter awal (kosong)
  }

  // Fungsi untuk memuat produk dengan filter
  Future<void> _fetchProductsWithFilters() async {
    await Provider.of<ProductProvider>(context, listen: false).fetchProducts(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      brand: _selectedBrandFilter,
      minPrice: _minPriceFilter,
      maxPrice: _maxPriceFilter,
    );
  }

  // Fungsi untuk menampilkan filter bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar bisa full screen
      builder: (context) {
        // Gunakan StateBuilder atau StatefulBuilder untuk menjaga state di dalam bottom sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateBottomSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Products',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Filter Merek
                  Text('Brand', style: Theme.of(context).textTheme.titleMedium),
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select Brand'),
                    value: _selectedBrandFilter,
                    onChanged: (String? newValue) {
                      setStateBottomSheet(() {
                        _selectedBrandFilter = newValue;
                      });
                    },
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Brands')),
                      ..._availableBrands.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Filter Harga Minimum
                  Text('Min Price', style: Theme.of(context).textTheme.titleMedium),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 500000'),
                    onChanged: (value) {
                      _minPriceFilter = double.tryParse(value);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Filter Harga Maksimum
                  Text('Max Price', style: Theme.of(context).textTheme.titleMedium),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 2000000'),
                    onChanged: (value) {
                      _maxPriceFilter = double.tryParse(value);
                    },
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() { // Update state di HomeScreen
                              _selectedBrandFilter = null;
                              _minPriceFilter = null;
                              _maxPriceFilter = null;
                              _searchController.clear(); // Clear search juga
                            });
                            _fetchProductsWithFilters(); // Panggil ulang produk
                            Navigator.pop(context); // Tutup bottom sheet
                          },
                          child: const Text('Clear Filter'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() { // Update state di HomeScreen
                              // Nilai filter sudah diupdate oleh onChanged TextField dan DropdownButton
                            });
                            _fetchProductsWithFilters(); // Panggil ulang produk dengan filter
                            Navigator.pop(context); // Tutup bottom sheet
                          },
                          child: const Text('Apply Filter'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shoe Store'),
        actions: [
          // Search Bar di AppBar
          Expanded( // Expanded agar TextField bisa mengambil sisa ruang
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari sepatu...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white, // Sesuaikan dengan tema AppBar Anda
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (value) {
                  // Panggil fungsi pencarian saat user menekan Enter
                  _fetchProductsWithFilters();
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet, // Panggil filter bottom sheet
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productProvider.errorMessage != null
              ? Center(child: Text('Error: ${productProvider.errorMessage}'))
              : productProvider.products.isEmpty
                  ? const Center(child: Text('No products found.'))
                  : RefreshIndicator(
                      onRefresh: _fetchProductsWithFilters, // Refresh juga pakai filter
                      child: GridView.builder(
                        padding: const EdgeInsets.all(10.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: productProvider.products.length,
                        itemBuilder: (ctx, i) {
                          final product = productProvider.products[i];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(productId: product.id),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                          ? Image.network(
                                              product.imageUrl!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/paperbag.jpg',
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                );
                                              },
                                            )
                                          : Image.asset(
                                              'assets/paperbag.jpg',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          product.brand ?? 'Unknown Brand',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Rp ${product.price.toStringAsFixed(0)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                                        ),
                                        Text(
                                          'Stok: ${product.stock}',
                                          style: TextStyle(color: Colors.grey[700], fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // Already on Home Screen
    } else if (index == 1) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
    } else if (index == 2) {
      // TODO: Navigasi ke ProfileScreen (akan kita buat selanjutnya)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Screen will be here!')),
      );
    }
  }
}