import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoe_store_app/providers/auth_provider.dart';
import 'package:shoe_store_app/screens/auth/login_screen.dart';

// Impor halaman-halaman untuk setiap tab
// ... (imports) ...
import 'package:shoe_store_app/screens/home/home_tab_screen.dart';
import 'package:shoe_store_app/screens/profile/order_history_screen.dart';
import 'package:shoe_store_app/screens/profile/profile_screen.dart'; // Pastikan ini diimport

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const HomeTabScreen(),
    const OrderHistoryScreen(),
    const ProfileScreen(), // Pastikan ProfileScreen ada di sini
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // LOGIKA NAVIGASI SUDAH ADA DI IndexedStack DI BAWAH.
    // Cukup update _selectedIndex, IndexedStack akan menangani tampilan halaman.
    // Tidak perlu lagi Navigator.of(context).push di sini untuk BottomNav.
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Tombol logout bisa di sini atau di ProfileScreen
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                // Pastikan widget masih di-mount
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        // Ini yang menangani pergantian halaman
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped, // Panggil _onItemTapped saat item diklik
      ),
    );
  }
}
