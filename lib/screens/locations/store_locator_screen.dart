// lib/screens/locations/store_locator_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shoe_store_app/api/location_api.dart';
import 'package:shoe_store_app/models/shoe_store.dart';
import 'package:url_launcher/url_launcher.dart'; // Ini sudah ada dan akan kita pakai!

class StoreLocatorScreen extends StatefulWidget {
  const StoreLocatorScreen({Key? key}) : super(key: key);

  @override
  State<StoreLocatorScreen> createState() => _StoreLocatorScreenState();
}

class _StoreLocatorScreenState extends State<StoreLocatorScreen> {
  List<ShoeStore> _nearbyStores = [];
  bool _isLoading = false;
  String? _errorMessage;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePositionAndFetchStores();
  }

  Future<void> _determinePositionAndFetchStores() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage = 'Layanan lokasi tidak aktif. Mohon aktifkan.';
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Izin lokasi ditolak.';
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage =
            'Izin lokasi ditolak secara permanen. Mohon aktifkan dari pengaturan.';
        _isLoading = false;
      });
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _fetchNearbyStores(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mendapatkan lokasi: ${e.toString()}';
        _isLoading = false;
      });
      print('Error getting location: $e');
    }
  }

  Future<void> _fetchNearbyStores(double lat, double lon) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final stores = await LocationApi().getNearbyStores(
        latitude: lat,
        longitude: lon,
      );
      setState(() {
        _nearbyStores = stores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat toko terdekat: ${e.toString()}';
        _isLoading = false;
      });
      print('Error fetching nearby stores: $e');
    }
  }

  // Fungsi untuk membuka Google Maps menggunakan URL scheme
  Future<void> _launchMaps(double latitude, double longitude, String storeName) async {
    // Gunakan URL scheme Google Maps untuk navigasi
    final Uri uri = Uri.parse('google.navigation:q=$latitude,$longitude&mode=d'); // mode=d untuk driving

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Jika scheme google.navigation tidak bisa dibuka (misal: Google Maps tidak terinstal),
      // coba fallback ke URL web Google Maps
      final Uri webUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving');
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri);
      } else {
        print('Could not launch $uri or $webUri');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka peta untuk $storeName. Pastikan Google Maps terinstal.')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toko Sepatu Terdekat')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _nearbyStores.isEmpty
          ? const Center(
              child: Text(
                'Tidak ada toko terdekat yang ditemukan atau izin lokasi tidak diberikan.',
              ),
            )
          : RefreshIndicator(
              onRefresh: _determinePositionAndFetchStores,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _nearbyStores.length,
                itemBuilder: (ctx, i) {
                  final store = _nearbyStores[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(Icons.store),
                      title: Text(
                        store.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(store.address ?? 'Tidak ada alamat'),
                          if (store.distanceKm != null)
                            Text(
                              '${store.distanceKm!.toStringAsFixed(2)} km jauhnya',
                            ),
                          if (store.phoneNumber != null)
                            Text('Telp: ${store.phoneNumber}'),
                        ],
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          _launchMaps(
                            store.latitude,
                            store.longitude,
                            store.name,
                          );
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text('Navigasi'),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
