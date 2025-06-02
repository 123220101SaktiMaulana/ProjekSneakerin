import 'package:shoe_store_app/models/product.dart'; // Untuk detail produk di order

class Order {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final double priceAtPurchase;
  final DateTime? orderDate; // <-- PASTIKAN INI NULLABLE
  final String? shippingAddress; // <-- PASTIKAN INI NULLABLE
  final String? status; // <-- PASTIKAN INI NULLABLE
  final Product? productDetails; // Detail produk yang dibeli

  Order({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.priceAtPurchase,
    required this.orderDate,
    required this.shippingAddress,
    required this.status,
    this.productDetails,
  });

    factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      priceAtPurchase: double.parse(json['price_at_purchase'].toString()), // Konversi string ke double
      orderDate: json['order_date'] != null ? DateTime.parse(json['order_date']) : null, // Handle null di sini
      shippingAddress: json['shipping_address'] as String?, // Casting ke nullable
      status: json['status'] as String?, // Casting ke nullable
      productDetails: json['Product'] != null ? Product.fromJson(json['Product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
      'order_date': orderDate?.toIso8601String(),
      'shipping_address': shippingAddress,
      'status': status,
      'product_details': productDetails?.toJson(),
    };
  }
}