class User {
  final int id;
  final String username;
  final String email;
  final String? fullName; // Opsional, bisa null
  final String? address; // Opsional, bisa null
  final String? phoneNumber; // Opsional, bisa null

  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.address,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'address': address,
      'phone_number': phoneNumber,
    };
  }
}