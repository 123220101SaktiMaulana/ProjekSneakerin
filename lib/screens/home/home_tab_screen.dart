import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoe_store_app/providers/product_provider.dart';
import 'package:shoe_store_app/models/product.dart';
import 'package:shoe_store_app/screens/home/product_detail_screen.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBrandFilter;
  double? _minPriceFilter;
  double? _maxPriceFilter;

  // List contoh merek (bisa diambil dari API nanti jika ada endpoint brands)
  final List<String> _availableBrands = ['Nike', 'Adidas', 'Puma', 'New Balance', 'Converse', 'Other'];

  @override
  void initState() {
    super.initState();
    // Panggil fetchProducts saat HomeTabScreen pertama kali dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProductsWithFilters();
    });
  }

  // Fungsi untuk memuat produk dengan filter
  Future<void> _fetchProductsWithFilters() async {
    // Pastikan context valid saat memanggil Provider
    if (!mounted) return; // Penting untuk menghindari error jika widget sudah di-dispose

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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateBottomSheet) {
            // Pastikan Anda memanggil _fetchProductsWithFilters() dari state di dalam HomeTabScreen
            // bukan dari state di dalam bottom sheet, untuk update list produk
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
                      setStateBottomSheet(() { // Update state di bottom sheet
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
                            setState(() { // Update state di HomeTabScreen (stateful widget utama)
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
                            setState(() { // Update state di HomeTabScreen
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
    final productProvider = Provider.of<ProductProvider>(context);

    // Ini adalah Scaffold body, jadi kita bisa menggunakan Column secara langsung
    // atau di wrap dengan Container/SizedBox jika perlu dimensi tertentu.
    return Column(
      children: [
        // Search Bar dan Filter di dalam Body
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
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
                    fillColor: Colors.grey[200], // Warna latar belakang search bar
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (value) {
                    _fetchProductsWithFilters();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterBottomSheet,
              ),
            ],
          ),
        ),
        // Sisa layar untuk daftar produk
        Expanded(
          child: productProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productProvider.errorMessage != null
                  ? Center(child: Text('Error: ${productProvider.errorMessage}'))
                  : productProvider.products.isEmpty
                      ? const Center(child: Text('No products found.'))
                      : RefreshIndicator(
                          onRefresh: _fetchProductsWithFilters,
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
        ),
      ],
    );
  }
}