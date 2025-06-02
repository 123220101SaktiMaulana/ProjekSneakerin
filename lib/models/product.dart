class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? brand;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.brand,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    // UBAH BARIS INI:
    price: double.parse(json['price'].toString()), // Konversi string ke double
    stock: json['stock'],
    brand: json['brand'],
    imageUrl: json['image_url'],
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'brand': brand,
      'image_url': imageUrl,
    };
  }
}