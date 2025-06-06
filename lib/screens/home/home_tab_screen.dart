import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shoe_store_app/providers/product_provider.dart';
import 'package:shoe_store_app/models/product.dart';
import 'package:shoe_store_app/screens/home/product_detail_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

// Widget terpisah untuk Carousel agar tidak ter-refresh
class AdCarouselWidget extends StatefulWidget {
  final List<String> adImages;

  const AdCarouselWidget({super.key, required this.adImages});

  @override
  State<AdCarouselWidget> createState() => _AdCarouselWidgetState();
}

class _AdCarouselWidgetState extends State<AdCarouselWidget> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
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
      items: widget.adImages.map((image) {
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
    );
  }
}

// Widget terpisah untuk ProductGrid agar bisa di-rebuild secara independen
class ProductGridWidget extends StatelessWidget {
  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;

  const ProductGridWidget({
    super.key,
    required this.products,
    required this.isLoading,
    this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return SliverFillRemaining(
        child: Center(child: Text('Error: $errorMessage')),
      );
    }

    if (products.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('Tidak ada produk ditemukan.')),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      delegate: SliverChildBuilderDelegate((ctx, i) {
        final product = products[i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailScreen(productId: product.id),
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
                          child:
                              product.imageUrl != null &&
                                  product.imageUrl!.isNotEmpty
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
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
                            ),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          product.brand ?? 'Unknown',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Rp ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }, childCount: products.length),
    );
  }
}

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Filter variables - support multiple selection
  Set<String> _selectedBrandFilters = <String>{};
  double? _minPriceFilter;
  double? _maxPriceFilter;

  // Untuk kategori
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Running',
    'Sneakers',
    'Formal',
    'Boots',
  ];

  // List contoh merek tanpa 'Other'
  final List<String> _availableBrands = [
    'Nike',
    'Adidas',
    'Puma',
    'New Balance',
    'Converse',
    'Vans',
    'Reebok',
  ];

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

  // Key untuk mempertahankan state carousel
  final GlobalKey<_AdCarouselWidgetState> _carouselKey = GlobalKey();

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
    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
      double magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude > _shakeThreshold &&
          DateTime.now().difference(_lastShakeTime).inMilliseconds > 500) {
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

    // Convert Set to List for API call, or pass as comma-separated string
    List<String>? brandFilters = _selectedBrandFilters.isNotEmpty
        ? _selectedBrandFilters.toList()
        : null;

    await Provider.of<ProductProvider>(context, listen: false).fetchProducts(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      brands: brandFilters, // Changed from single brand to multiple brands
      minPrice: _minPriceFilter,
      maxPrice: _maxPriceFilter,
      // category: categoryFilter, // Uncomment jika API mendukung filter kategori
    );
  }

  void _resetSearchAndFilters() {
    setState(() {
      _searchController.clear();
      _selectedBrandFilters.clear();
      _minPriceFilter = null;
      _maxPriceFilter = null;
      _selectedCategory = 'All';
    });
    _fetchProductsWithFilters();
  }

  void _showFilterBottomSheet() {
    // Create temporary variables for the bottom sheet
    Set<String> tempSelectedBrands = Set.from(_selectedBrandFilters);
    double? tempMinPrice = _minPriceFilter;
    double? tempMaxPrice = _maxPriceFilter;

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

                  // Brand Filter Section
                  Text(
                    'Brand (Multiple Selection)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _availableBrands
                        .map(
                          (brand) => FilterChip(
                            label: Text(brand),
                            selected: tempSelectedBrands.contains(brand),
                            onSelected: (bool selected) {
                              setStateBottomSheet(() {
                                if (selected) {
                                  tempSelectedBrands.add(brand);
                                } else {
                                  tempSelectedBrands.remove(brand);
                                }
                              });
                            },
                            selectedColor: Colors.black.withOpacity(0.8),
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: tempSelectedBrands.contains(brand)
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: tempSelectedBrands.contains(brand)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            backgroundColor: Colors.grey[200],
                          ),
                        )
                        .toList(),
                  ),

                  if (tempSelectedBrands.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Selected: ${tempSelectedBrands.join(', ')}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Price Filter Section
                  Text(
                    'Price Range',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Min Price',
                            hintText: 'e.g. 500000',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            tempMinPrice = double.tryParse(value);
                          },
                          controller: TextEditingController(
                            text: tempMinPrice?.toString() ?? '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Max Price',
                            hintText: 'e.g. 2000000',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            tempMaxPrice = double.tryParse(value);
                          },
                          controller: TextEditingController(
                            text: tempMaxPrice?.toString() ?? '',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedBrandFilters.clear();
                              _minPriceFilter = null;
                              _maxPriceFilter = null;
                              _searchController.clear();
                              _selectedCategory = 'All';
                            });
                            _fetchProductsWithFilters();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear All'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedBrandFilters = tempSelectedBrands;
                              _minPriceFilter = tempMinPrice;
                              _maxPriceFilter = tempMaxPrice;
                            });
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Bar Kustom - Fixed di atas
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text dengan font styling menarik - Tanpa Logo
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade900],
                    ).createShader(bounds),
                    child: const Text(
                      'Sneakerin',
                      style: TextStyle(
                        fontSize: 32, // Lebih besar karena jadi fokus utama
                        fontWeight: FontWeight.w800,
                        color: Colors.white, // Diperlukan untuk ShaderMask
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                  ),
                  Container(
                    height: 3,
                    width: 60, // Lebih panjang untuk proporsi yang bagus
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.transparent],
                      ),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ],
              ),

              // Logout button dengan desain modern
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade50, Colors.grey.shade100],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: Colors.orange.shade600,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Konfirmasi Logout',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            content: const Text(
                              'Apakah Anda yakin ingin keluar dari aplikasi?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Batal',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login',
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.logout_rounded,
                        color: Colors.grey.shade700,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search Bar - Fixed di atas
        Padding(
          padding: const EdgeInsets.all(16.0),
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
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                  ),
                  onSubmitted: (value) {
                    _fetchProductsWithFilters();
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color:
                      (_selectedBrandFilters.isNotEmpty ||
                          _minPriceFilter != null ||
                          _maxPriceFilter != null)
                      ? Colors.blue
                      : Colors.grey,
                ),
                onPressed: _showFilterBottomSheet,
              ),
            ],
          ),
        ),

        // Expanded ScrollView dengan Carousel yang tidak ter-refresh
        Expanded(
          child: CustomScrollView(
            slivers: [
              // Carousel Slider untuk Iklan - Menggunakan key untuk mempertahankan state
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    AdCarouselWidget(key: _carouselKey, adImages: _adImages),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Filter Merek (Horizontal Scrollable)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter by Brand',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (_selectedBrandFilters.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedBrandFilters.clear();
                                });
                                _fetchProductsWithFilters();
                              },
                              child: Text(
                                'Clear (${_selectedBrandFilters.length})',
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Horizontal Scrollable Brand Filter
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _availableBrands.length,
                        itemBuilder: (context, index) {
                          String brand = _availableBrands[index];
                          bool isSelected = _selectedBrandFilters.contains(
                            brand,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(brand),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedBrandFilters.add(brand);
                                  } else {
                                    _selectedBrandFilters.remove(brand);
                                  }
                                });
                                _fetchProductsWithFilters();
                              },
                              selectedColor: Colors.black,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              backgroundColor: Colors.grey[200],
                              showCheckmark: true,
                            ),
                          );
                        },
                      ),
                    ),

                    // Show selected filters indicator
                    if (_selectedBrandFilters.isNotEmpty ||
                        _minPriceFilter != null ||
                        _maxPriceFilter != null)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Active Filters:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_selectedBrandFilters.isNotEmpty)
                              Text(
                                'Brands: ${_selectedBrandFilters.join(', ')}',
                              ),
                            if (_minPriceFilter != null ||
                                _maxPriceFilter != null)
                              Text(
                                'Price: ${_minPriceFilter != null ? 'Rp ${_minPriceFilter!.toStringAsFixed(0)}' : 'Min'} - ${_maxPriceFilter != null ? 'Rp ${_maxPriceFilter!.toStringAsFixed(0)}' : 'Max'}',
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // Consumer untuk hanya mendengarkan perubahan ProductProvider
              Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  return ProductGridWidget(
                    products: productProvider.products,
                    isLoading: productProvider.isLoading,
                    errorMessage: productProvider.errorMessage,
                    onRefresh: _fetchProductsWithFilters,
                  );
                },
              ),

              // Bottom padding untuk grid
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ],
    );
  }
}
