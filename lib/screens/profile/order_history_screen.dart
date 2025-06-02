import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoe_store_app/api/order_api.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
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
                                    'Order ID: ${order.id}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Produk: ${order.productDetails?.name ?? 'Unknown Product'}'),
                                  Text('Jumlah: ${order.quantity}'),
                                  Text('Harga/Item: Rp ${order.priceAtPurchase.toStringAsFixed(0)}'),
                                  Text('Total Pembelian: Rp ${(order.quantity * order.priceAtPurchase).toStringAsFixed(0)}'),
                                  Text('Tanggal: ${order.orderDate.toLocal().toString().split(' ')[0]}'),
                                  Text('Status: ${order.status.toUpperCase()}'),
                                  Text('Alamat Pengiriman: ${order.shippingAddress}'),
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