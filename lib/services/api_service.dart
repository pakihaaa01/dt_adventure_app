import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tipe_alat.dart';
import '../services/cart_manager.dart';

class ApiService {
  static const String baseUrl = 'https://dtadventure.web.id/api';

  Future<List<TipeAlat>> fetchProduk() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tipe-alat'));

      print('Status Code (Get Produk): ${response.statusCode}');
      print('Isi Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<TipeAlat> produkList = body
            .map((dynamic item) => TipeAlat.fromJson(item))
            .toList();
        return produkList;
      } else {
        throw Exception('Gagal memuat data dari server. Kode: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan: $e');
    }
  }

  Future<bool> buatPesanan({
    required int userId,
    required String nama,
    required String whatsapp,
    required String email,
    required String metodePembayaran,
    required String tglMulai,
    required String tglSelesai,
    required double totalHarga,
    required List<CartItem> cartItems,
  }) async {
    try {
      List<Map<String, dynamic>> itemsJson = cartItems.map((item) {
        return {
          'tipe_alat_id': item.produk.id,
          'qty': item.qty,
        };
      }).toList();

      final response = await http.post(
        Uri.parse('$baseUrl/pesanan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'nama': nama,
          'whatsapp': whatsapp,
          'email': email,
          'metode_pembayaran': metodePembayaran,
          'tgl_mulai': tglMulai,
          'tgl_selesai': tglSelesai,
          'total_harga': totalHarga,
          'items': itemsJson,
        }),
      );

      print('Status Code (Post Pesanan): ${response.statusCode}');
      print('Isi Response Pesanan: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error koneksi API Buat Pesanan: $e");
      return false;
    }
  }
}