import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/tipe_alat.dart';
import '../services/cart_manager.dart';
import 'auth_manager.dart';

class ApiService {
  static const String baseUrl = 'https://dtadventure.web.id/api';

  Future<List<Map<String, dynamic>>> fetchRiwayatPesanan() async {
    try {
      final token = await AuthManager.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/pesanan'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('Status Code (Get Riwayat): ${response.statusCode}');
      print('Response Riwayat: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }

      throw Exception('Gagal memuat riwayat pesanan');
    } catch (e) {
      throw Exception('Kesalahan: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchPesananBerjalan() async {
    try {
      final data = await fetchRiwayatPesanan();

      final aktif = data.where((e) {
        final status = (e['status'] ?? '').toString().toLowerCase();

        return status != 'selesai' &&
            status != 'dibatalkan' &&
            status != 'batal';
      }).toList();

      if (aktif.isEmpty) return null;

      return aktif.first;
    } catch (e) {
      return null;
    }
  }

  Future<List<TipeAlat>> fetchProduk() async {
    try {
      final token = await AuthManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/tipe-alat'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('Status Code (Get Produk): ${response.statusCode}');
      print('Isi Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<TipeAlat> produkList = body
            .map((dynamic item) => TipeAlat.fromJson(item))
            .toList();
        return produkList;
      } else {
        throw Exception(
          'Gagal memuat data dari server. Kode: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Kesalahan: $e');
    }
  }

  // Kode gabungan: Fitur Token (dari temanmu) + Fitur QRIS (darimu)
  Future<int?> buatPesanan({
    required int userId,
    required String nama,
    required String whatsapp,
    required String email,
    required String metodePembayaran,
    required String tglMulai,
    required String tglSelesai,
    required double totalHarga,
    required List<CartItem> cartItems,
    File? buktiBayar,
  }) async {
    try {
      final token = await AuthManager.getToken(); // Mengambil token login

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/pesanan'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token', // Memasukkan token
      });

      request.fields['user_id'] = userId.toString();
      request.fields['nama'] = nama;
      request.fields['whatsapp'] = whatsapp;
      request.fields['email'] = email;
      request.fields['metode_pembayaran'] = metodePembayaran;
      request.fields['tgl_mulai'] = tglMulai;
      request.fields['tgl_selesai'] = tglSelesai;
      request.fields['total_harga'] = totalHarga.toInt().toString();

      for (int i = 0; i < cartItems.length; i++) {
        request.fields['items[$i][tipe_alat_id]'] = cartItems[i].produk.id.toString();
        request.fields['items[$i][qty]'] = cartItems[i].qty.toString();
      }

      // Mengirim file gambar jika ada
      if (buktiBayar != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'bukti_pembayaran',
            buktiBayar.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Status Code (Post Pesanan): ${response.statusCode}');
      print('Isi Response Pesanan: ${response.body}');

      // Mengembalikan ID pesanan agar nota_screen bisa terbuka
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['pesanan_id'];
      } else {
        return null;
      }
    } catch (e) {
      print("Error koneksi API Buat Pesanan: $e");
      return null;
    }
  }
}