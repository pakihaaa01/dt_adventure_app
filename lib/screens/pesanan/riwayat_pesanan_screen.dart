import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/tipe_alat.dart';
import '../../services/api_service.dart';
import '../../services/auth_manager.dart';
import 'package:intl/intl.dart';

import '../../services/cart_manager.dart';
import '../checkout/nota_screen.dart';

class RiwayatPesananScreen extends StatefulWidget {
  const RiwayatPesananScreen({super.key});

  @override
  State<RiwayatPesananScreen> createState() => _RiwayatPesananScreenState();
}

class _RiwayatPesananScreenState extends State<RiwayatPesananScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _pesananList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    try {
      final user = await AuthManager.getUser();
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Silakan login terlebih dahulu";
        });
        return;
      }

      final data = await _apiService.fetchRiwayatPesanan();
      setState(() {
        _pesananList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  String _formatCurrency(dynamic amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount ?? 0);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'lunas':
      case 'success':
      case 'selesai':
        return Colors.green;
      case 'batal':
      case 'cancel':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Future<void> _openNota(Map<String, dynamic> pesanan) async {
    final pembayaran = pesanan['pembayaran'] as Map<String, dynamic>?;

    final itemsJson = pesanan['items'] as List<dynamic>? ?? [];

    final List<CartItem> items = itemsJson.map((item) {
      return CartItem(
        produk: TipeAlat(
          id: item['product_id'] ?? 0,
          kategoriId: 0,
          namaAlat: item['nama_alat'] ?? '',
          gambar: null,
          stok: 0,
          harga: double.tryParse(item['harga'].toString()) ?? 0,
          deskripsi: null,
          subKategoriId: null,
        ),
        qty: item['jumlah'] ?? 1,
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotaScreen(
          pesananId: pesanan['id'],
          nama: pesanan['nama'] ?? '',
          whatsapp: pesanan['whatsapp'] ?? '',
          email: pesanan['email'] ?? '',
          hari: pesanan['hari'] ?? 1,
          tglMulai: pesanan['tanggal_mulai'] ?? '',
          tglKembali: pesanan['tanggal_kembali'] ?? '',
          metodePembayaran: pembayaran?['metode_pembayaran'] ?? '-',
          status: pesanan['status'] ?? '-',
          totalPembayaran:
              double.tryParse(pembayaran?['jumlah']?.toString() ?? '0') ?? 0,
          items: items,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Pesanan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadRiwayat();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF013a63),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_pesananList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat pesanan',
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pesananList.length,
      itemBuilder: (context, index) {
        final pesanan = _pesananList[index];
        final status = pesanan['status'] ?? 'Pending';
        final pembayaran = pesanan['pembayaran'] as Map<String, dynamic>?;
        final tgl = pesanan['created_at'] != null
            ? DateFormat(
                'dd MMM yyyy, HH:mm',
              ).format(DateTime.parse(pesanan['created_at']))
            : '-';

        return GestureDetector(
          onTap: () => _openNota(pesanan),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${pesanan['id']}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(status).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: _getStatusColor(status),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tgl,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const Divider(color: Colors.white12, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _formatCurrency(
                        double.tryParse(
                              pembayaran?['jumlah']?.toString() ?? '0',
                            ) ??
                            0,
                      ),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Metode: ${pembayaran?['metode_pembayaran'] ?? '-'}',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
