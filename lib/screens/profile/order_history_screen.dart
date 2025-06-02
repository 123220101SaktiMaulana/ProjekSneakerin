import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoe_store_app/api/order_api.dart';
import 'package:shoe_store_app/api/utility_api.dart'; // Import UtilityApi
import 'package:shoe_store_app/models/order.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  // State untuk konversi waktu
  String _selectedDisplayTimezone = 'WIB'; // Default ke WIB
  final List<String> _availableTimezones = ['WIB', 'WITA', 'WIT', 'LONDON', 'NEW_YORK']; // Dari constants.js backend

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedOrders = await OrderApi().getOrders();
      setState(() {
        _orders = fetchedOrders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load order history: ${e.toString()}';
        _isLoading = false;
      });
      print('Error fetching order history: $e');
    }
  }

  // Fungsi untuk mengkonversi dan menampilkan waktu
  Future<String> _getConvertedOrderDate(DateTime originalDate) async {
    if (_selectedDisplayTimezone == 'WIB') {
      return originalDate.toLocal().toString().split(' ')[0] + ' ' + originalDate.toLocal().toString().split(' ')[1].substring(0, 5) + ' WIB'; // Format YYYY-MM-DD HH:MM WIB
    }

    try {
      // Asumsi waktu original order_date dari backend sudah UTC (ada 'Z' di akhir)
      // Kalau tidak, Anda perlu mengetahui timezone asli server Anda untuk 'from_tz'
      final result = await UtilityApi().convertTime(
        datetime: originalDate.toIso8601String(), // Pastikan format ISO 8601
        fromTimezone: 'WIB', // Asumsi waktu order disimpan di backend adalah WIB. Jika UTC, ganti 'WIB' menjadi 'UTC' atau zona waktu server
        toTimezone: _selectedDisplayTimezone,
      );
      // Format hasil yang readable
      return result['converted_datetime_readable'] ?? 'N/A';
    } catch (e) {
      print('Error converting time: $e');
      return 'Error Conv.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          // Dropdown untuk memilih zona waktu tampilan
          DropdownButton<String>(
            value: _selectedDisplayTimezone,
            items: _availableTimezones.map((String tz) {
              return DropdownMenuItem<String>(
                value: tz,
                child: Text(tz),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedDisplayTimezone = newValue;
                  // Tidak perlu fetch ulang, karena data waktu original sudah ada
                });
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _orders.isEmpty
                  ? const Center(child: Text('No orders found.'))
                  : RefreshIndicator(
                      onRefresh: _fetchOrderHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _orders.length,
                        itemBuilder: (ctx, i) {
                          final order = _orders[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order ID: ${order.id ?? 'N/A'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Produk: ${order.productDetails?.name ?? 'Unknown Product'}'),
                                  Text('Jumlah: ${order.quantity ?? 0}'),
                                  Text('Harga/Item: Rp ${order.priceAtPurchase?.toStringAsFixed(0) ?? 'N/A'}'),
                                  Text('Total Pembelian: Rp ${((order.quantity ?? 0) * (order.priceAtPurchase ?? 0.0)).toStringAsFixed(0)}'),
                                  // Tampilkan tanggal yang dikonversi
                                  FutureBuilder<String>(
                                    future: _getConvertedOrderDate(order.orderDate!), // orderDate tidak boleh null di sini
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Text('Tanggal: Loading...');
                                      } else if (snapshot.hasError) {
                                        return Text('Tanggal: Error (${snapshot.error})');
                                      } else {
                                        return Text('Tanggal: ${snapshot.data}');
                                      }
                                    },
                                  ),
                                  Text('Status: ${order.status?.toUpperCase() ?? 'N/A'}'),
                                  Text('Alamat Pengiriman: ${order.shippingAddress ?? 'N/A'}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}