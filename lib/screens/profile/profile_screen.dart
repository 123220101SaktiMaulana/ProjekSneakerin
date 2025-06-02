// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoe_store_app/providers/auth_provider.dart';
import 'package:shoe_store_app/screens/profile/user_profile_edit_screen.dart'; // Akan dibuat
import 'package:shoe_store_app/screens/currency_converter_screen.dart'; // Currency converter screen

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UserProfileEditScreen()),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Please login to view your profile.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Username: ${user.username}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Email: ${user.email}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Full Name: ${user.fullName ?? 'Not set'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Address: ${user.address ?? 'Not set'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Phone: ${user.phoneNumber ?? 'Not set'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  // Contoh tombol lain di profil
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigasi ke Order History jika belum ada tombol di bottom nav
                      // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
                    },
                    child: const Text('View Order History'),
                  ),
                  // TODO: Tombol untuk Saran/Kritik jika ingin di sini
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const CurrencyConverterScreen()),
                      );
                    },
                    child: const Text('Currency Converter'),
                  ),
                ],
              ),
            ),
    );
  }
}