import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoe_store_app/providers/auth_provider.dart';
import 'package:shoe_store_app/providers/product_provider.dart'; // Tetap import ini jika ProductProvider digunakan di HomeTab
import 'package:shoe_store_app/screens/auth/login_screen.dart';
import 'package:shoe_store_app/models/product.dart'; // Tetap import ini jika Product model digunakan di HomeTab

// Impor halaman-halaman untuk setiap tab
import 'package:shoe_store_app/screens/home/home_tab_screen.dart'; // <--- Akan kita buat ini
import 'package:shoe_store_app/screens/profile/order_history_screen.dart';
import 'package:shoe_store_app/screens/profile/profile_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // State untuk mengontrol tab yang aktif

  // List halaman yang akan ditampilkan di BottomNavigationBar
  // Pastikan Anda menginisialisasi provider di sini jika mereka punya initState
  final List<Widget> _widgetOptions = <Widget>[
    const HomeTabScreen(), // Halaman Home/Daftar Produk yang sebenarnya
    const OrderHistoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // Hanya untuk logout

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shoe Store'),
        actions: [
          // Anda bisa memindahkan search bar dan filter ke HomeTabScreen
          // Atau biarkan di sini jika ingin search/filter global untuk semua tab
          // Untuk kesederhanaan, biarkan search/filter di HomeTabScreen
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack( // Menggunakan IndexedStack untuk mempertahankan state tab
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex, // Mengikat ke state _selectedIndex
        selectedItemColor: Colors.deepPurple, // Warna ikon/teks yang dipilih
        unselectedItemColor: Colors.grey, // Warna ikon/teks yang tidak dipilih
        onTap: _onItemTapped, // Menangani tap item
      ),
    );
  }
}