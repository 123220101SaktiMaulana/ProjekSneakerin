// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoe_store_app/providers/auth_provider.dart';
import 'package:shoe_store_app/screens/locations/store_locator_screen.dart';
import 'package:shoe_store_app/screens/profile/user_profile_edit_screen.dart';
import 'package:shoe_store_app/screens/currency_converter_screen.dart';//dari folder utils

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
          : SingleChildScrollView( // Tambahkan SingleChildScrollView agar bisa di-scroll
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto Profil Statis (Contoh: foto Anda atau logo)
                  Center(
                    child: Column(
                      children: [
                        ClipOval( // Untuk membuat gambar bulat
                          child: Image.asset(
                            'assets/gweh.jpg', // <--- GANTI DENGAN NAMA FILE FOTO ANDA
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user.fullName ?? user.username, // Tampilkan nama lengkap atau username
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Informasi Profil User
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

                  // Tombol-tombol Navigasi
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const StoreLocatorScreen()),
                      );
                    },
                    child: const Text('Nearby Stores'),
                  ),
                  const SizedBox(height: 10), // Jarak antar tombol
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const CurrencyConverterScreen()),
                      );
                    },
                    child: const Text('Currency Converter'),
                  ),
                  const SizedBox(height: 10), // Jarak antar tombol
                  // Tombol View Order History (jika belum ada di bottom nav)
                  // Jika sudah ada di bottom nav, tombol ini bisa dihapus atau diganti
                  // ElevatedButton(
                  //   onPressed: () {
                  //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
                  //   },
                  //   child: const Text('View Order History'),
                  // ),
                  // const SizedBox(height: 20),

                  const Divider(height: 40, thickness: 1), // Garis pemisah

                  // Bagian Pesan dan Kesan Mata Kuliah
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Pesan dan Kesan Mata Kuliah',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Mata kuliah Teknologi dan Pemrograman Mobile ini sangat memberikan wawasan baru bagi saya. '
                          'Meskipun banyak tantangan dalam memahami konsep dan implementasi, '
                          'namun proses belajar Flutter dan integrasi backend sangat berharga. '
                          'Saya merasa kemampuan saya dalam pengembangan aplikasi mobile meningkat pesat. '
                          'Terima kasih banyak atas materi dan bimbingan yang telah diberikan!',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.justify, // Teks rata kiri kanan
                        ),
                        const SizedBox(height: 20),
                        // Anda bisa menambahkan foto kedua di sini jika ada
                        // Image.asset('assets/gambar_kesan.jpg', height: 150),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}