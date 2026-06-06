import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../produk/produk_screen.dart';
import '../keranjang/keranjang_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _selectedKategoriId = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        _selectedKategoriId = 0; // Jika klik manual tab Produk, tampilkan Semua
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // List screens diletakkan di dalam build() agar dinamis menerima ID
    final List<Widget> screens = [
      HomeScreen(
        onCategoryTap: (categoryId) {
          setState(() {
            _selectedKategoriId = categoryId;
            _selectedIndex = 1; // Pindah ke tab Produk
          });
        },
      ),
      ProdukScreen(initialCategoryId: _selectedKategoriId),
      const KeranjangScreen(),
      const Center(child: Text('Halaman Akun', style: TextStyle(color: Colors.white))),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Image.asset(
          'assets/images/logo.png',
          height: 35,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Text("DT Adventure", style: TextStyle(fontWeight: FontWeight.bold));
          },
        ),
        elevation: 2,
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.backpack_outlined),
            activeIcon: Icon(Icons.backpack),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}