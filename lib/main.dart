import 'package:flutter/material.dart';
import 'screens/main/main_screen.dart';
// Jika kamu ingin pakai font Poppins dengan mudah,
// tambahkan package google_fonts di pubspec.yaml lalu import:
// import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DT Adventure',
      theme: ThemeData(
        // Latar belakang default
        scaffoldBackgroundColor: const Color(0xFF005577),

        // Warna Font Utama (Opsional jika pakai google_fonts)
        // textTheme: GoogleFonts.poppinsTextTheme().apply(
        //   bodyColor: Colors.white,
        //   displayColor: Colors.white,
        // ),

        // Gaya AppBar menyesuaikan Header web
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF013a63),
          foregroundColor: Colors.white, // Teks title warna putih
          elevation: 0,
        ),

        // Gaya Navigasi Bawah
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF013a63),
          selectedItemColor: Color(0xFFFFD700), // Kuning Emas khas web
          unselectedItemColor: Colors.white54,
        ),

        // Gaya Teks default agar warna putih
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: const MainScreen(),
    );
  }
}