import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shoe_store_app/providers/product_provider.dart';
import 'package:shoe_store_app/models/product.dart';
import 'package:shoe_store_app/screens/home/product_detail_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

  // Untuk kategori
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Running', 'Sneakers', 'Formal', 'Boots'];

  // List contoh merek (bisa diambil dari API nanti jika ada endpoint brands)
  final List<String> _availableBrands = ['Nike', 'Adidas', 'Puma', 'New Balance', 'Converse', 'Other'];

  // Variabel untuk deteksi goyangan
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _shakeThreshold = 15.0;
  int _shakeCount = 0;
  DateTime _lastShakeTime = DateTime.now();

  // List gambar iklan (ganti dengan gambar Anda)
  final List<String> _adImages = [
    'assets/iklan1.jpg',
    'assets/ads2.jpg',
    'assets/ads3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProductsWithFilters();
    _initShakeDetection();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _initShakeDetection() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (magnitude > _shakeThreshold && DateTime.now().difference(_lastShakeTime).inMilliseconds > 500) {
        _lastShakeTime = DateTime.now();
        _shakeCount++;

        if (_shakeCount >= 2) {
          _shakeCount = 0;
          _resetSearchAndFilters();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filter dan Pencarian direset!')),
            );
          }
        }
      } else if (DateTime.now().difference(_lastShakeTime).inSeconds > 2) {
        _shakeCount = 0;
      }
    });
  }

  // Fungsi untuk memuat produk dengan filter dan kategori
  Future<void> _fetchProductsWithFilters() async {
    if (!mounted) return;

    // Menambahkan pengecekan kategori yang tidak digunakan
    // String? categoryFilter = _selectedCategory == 'All' ? null : _selectedCategory;

    await Provider.of<ProductProvider>(context, listen: false).fetchProducts(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      brand: _selectedBrandFilter,
      minPrice: _minPriceFilter,
      maxPrice: _maxPriceFilter,
      // category: categoryFilter, // Uncomment jika API mendukung filter kategori
    );
  }

  void _resetSearchAndFilters() {
    setState(() {
      _searchController.clear();
      _selectedBrandFilter = null;
      _minPriceFilter = null;
      _maxPriceFilter = null;
      _selectedCategory = 'All';
    });
    _fetchProductsWithFilters();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
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
                  Text('Brand', style: Theme.of(context).textTheme.titleMedium),
                  Wrap(
                    spacing: 8.0,
                    children: _availableBrands.map((brand) => ChoiceChip(
                      label: Text(brand),
                      selected: _selectedBrandFilter == brand,
                      onSelected: (bool selected) {
                        setStateBottomSheet(() {
                          _selectedBrandFilter = selected ? brand : null;
                        });
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 10),
                  Text('Min Price', style: Theme.of(context).textTheme.titleMedium),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 500000'),
                    onChanged: (value) {
                      _minPriceFilter = double.tryParse(value);
                    },
                  ),
                  const SizedBox(height: 10),
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
                            setState(() {
                              _selectedBrandFilter = null;
                              _minPriceFilter = null;
                              _maxPriceFilter = null;
                              _searchController.clear();
                              _selectedCategory = 'All';
                            });
                            _fetchProductsWithFilters();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear Filter'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                            _fetchProductsWithFilters();
                            Navigator.pop(context);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Bar Kustom
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hapus IconButton menu di kiri atas

              const Text(
                'Sneakerin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  // Hapus token, session, dsb jika perlu di sini

                  // Pindah ke halaman login dan hapus semua halaman sebelumnya
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Carousel Slider untuk Iklan
        CarouselSlider(
          options: CarouselOptions(
            height: 200.0,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.8,
          ),
          items: _adImages.map((image) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.error, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Filter Merek (Horizontal)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Filter by Brand', style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _availableBrands.length,
            itemBuilder: (context, index) {
              String brand = _availableBrands[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(brand),
                  selected: _selectedBrandFilter == brand,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedBrandFilter = selected ? brand : null;
                    });
                    _fetchProductsWithFilters();
                  },
                  selectedColor: Colors.black,
                  labelStyle: TextStyle(
                    color: _selectedBrandFilter == brand ? Colors.white : Colors.black87,
                    fontWeight: _selectedBrandFilter == brand ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.grey[200],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari sepatu...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                  onSubmitted: (value) {
                    _fetchProductsWithFilters();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.grey),
                onPressed: _showFilterBottomSheet,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Grid Produk
        Expanded(
          child: productProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productProvider.errorMessage != null
                  ? Center(child: Text('Error: ${productProvider.errorMessage}'))
                  : productProvider.products.isEmpty
                      ? const Center(child: Text('Tidak ada produk ditemukan.'))
                      : RefreshIndicator(
                          onRefresh: _fetchProductsWithFilters,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(10.0),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: productProvider.products.length,
                            itemBuilder: (ctx, i) {
                              final product = productProvider.products[i];
                              return Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                clipBehavior: Clip.antiAlias,
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
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                                  ? Image.network(
                                                      product.imageUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Image.asset(
                                                          'assets/paperbag.jpg',
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    )
                                                  : Image.asset(
                                                      'assets/paperbag.jpg',
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                            Positioned(
                                              bottom: 8,
                                              right: 8,
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
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
                                            const SizedBox(height: 5),
                                            Text(
                                              'Rp ${product.price.toStringAsFixed(0)}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
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