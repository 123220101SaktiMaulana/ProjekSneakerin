// lib/screens/locations/store_locator_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Untuk mendapatkan lokasi
import 'package:shoe_store_app/api/location_api.dart';
import 'package:shoe_store_app/models/shoe_store.dart';
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka peta

class StoreLocatorScreen extends StatefulWidget {
  const StoreLocatorScreen({super.key});

  @override
  State<StoreLocatorScreen> createState() => _StoreLocatorScreenState();
}

class _StoreLocatorScreenState extends State<StoreLocatorScreen> {
  List<ShoeStore> _nearbyStores = [];
  bool _isLoading = false;
  String? _errorMessage;
  Position? _currentPosition; // Untuk menyimpan lokasi user

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

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage = 'Location services are disabled. Please enable them.';
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permissions are denied.';
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = 'Location permissions are permanently denied. Please enable from settings.';
        _isLoading = false;
      });
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _fetchNearbyStores(_currentPosition!.latitude, _currentPosition!.longitude);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: ${e.toString()}';
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
      final stores = await LocationApi().getNearbyStores(latitude: lat, longitude: lon);
      setState(() {
        _nearbyStores = stores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load nearby stores: ${e.toString()}';
        _isLoading = false;
      });
      print('Error fetching nearby stores: $e');
    }
  }

  // Fungsi untuk membuka Google Maps
  Future<void> _launchMaps(double lat, double lon) async {
    final uri = Uri.parse('google.navigation:q=$lat,$lon&mode=d'); // d for driving
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Shoe Stores'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _nearbyStores.isEmpty
                  ? const Center(child: Text('No nearby stores found or permissions not granted.'))
                  : RefreshIndicator(
                      onRefresh: _determinePositionAndFetchStores, // Refresh akan coba dapat lokasi ulang
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
                                  Text(store.address ?? 'No address'),
                                  if (store.distanceKm != null)
                                    Text('${store.distanceKm!.toStringAsFixed(2)} km away'),
                                  if (store.phoneNumber != null)
                                    Text('Telp: ${store.phoneNumber}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.navigation, color: Colors.blue),
                                onPressed: () {
                                  _launchMaps(store.latitude, store.longitude);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}