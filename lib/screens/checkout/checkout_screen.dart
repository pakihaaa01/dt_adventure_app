import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

import '../../services/cart_manager.dart';
import '../../services/api_service.dart';
import '../main/main_screen.dart';
import 'nota_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String nama;
  final String whatsapp;
  final String email;
  final int hari;
  final DateTime tglMulai;
  final DateTime tglKembali;

  const CheckoutScreen({
    super.key,
    required this.nama,
    required this.whatsapp,
    required this.email,
    required this.hari,
    required this.tglMulai,
    required this.tglKembali,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String metodePembayaran = 'Cash';
  File? _buktiBayar;

  Future<void> _pilihBuktiBayar() async {
    final picker = ImagePicker();
    // Menggunakan kompresi agar aman untuk kamera beresolusi tinggi
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      setState(() {
        _buktiBayar = File(pickedFile.path);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Bukti bayar berhasil dipilih!"), backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<void> _downloadQRIS() async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        status = await Permission.photos.request();
      }

      if (status.isGranted) {
        ByteData byteData = await rootBundle.load('assets/images/qris.png');
        Uint8List pngBytes = byteData.buffer.asUint8List();

        final result = await ImageGallerySaverPlus.saveImage(
            pngBytes,
            name: "QRIS_DT_Adventure_${DateTime.now().millisecondsSinceEpoch}"
        );

        if (result != null && (result['isSuccess'] == true || result['isSuccess'] == "true")) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ QRIS berhasil disimpan ke galeri!"), backgroundColor: Colors.green),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("❌ Gagal menyimpan QRIS."), backgroundColor: Colors.redAccent),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("⚠️ Izin penyimpanan ditolak!"), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalHargaProduk = CartManager.hitungTotal(1);
    double totalAkhir = totalHargaProduk * widget.hari;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF004466),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF004466), Color(0xFF006688)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle("Detail Pemesan"),
            _buildCard([
              _buildRowText("Nama", widget.nama),
              _buildRowText("WhatsApp", widget.whatsapp),
              _buildRowText("Email", widget.email),
              _buildRowText("Durasi Sewa", "${widget.hari} Hari"),
              _buildRowText(
                "Tanggal Ambil",
                "${widget.tglMulai.day}/${widget.tglMulai.month}/${widget.tglMulai.year}",
              ),
              _buildRowText(
                "Tanggal Kembali",
                "${widget.tglKembali.day}/${widget.tglKembali.month}/${widget.tglKembali.year}",
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle("Barang Pinjaman"),
            _buildCard(
              CartManager.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${item.qty}x ${item.produk.namaAlat}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Text(
                        "Rp ${item.produk.harga.toInt()}",
                        style: const TextStyle(color: Color(0xFFFFD700)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Ringkasan Biaya"),
            _buildCard([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Produk (${CartManager.items.length} item) x ${widget.hari} Hari",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "Rp ${totalAkhir.toInt()}",
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle("Metode Pembayaran"),
            _buildCard([
              RadioListTile(
                title: const Text(
                  "Cash (Bayar di Tempat)",
                  style: TextStyle(color: Colors.white),
                ),
                activeColor: const Color(0xFFFFD700),
                value: "Cash",
                groupValue: metodePembayaran,
                onChanged: (val) =>
                    setState(() => metodePembayaran = val.toString()),
              ),
              RadioListTile(
                title: const Text(
                  "QRIS",
                  style: TextStyle(color: Colors.white),
                ),
                activeColor: const Color(0xFFFFD700),
                value: "QRIS",
                groupValue: metodePembayaran,
                onChanged: (val) =>
                    setState(() => metodePembayaran = val.toString()),
              ),
              if (metodePembayaran == "QRIS") ...[
                const SizedBox(height: 16),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/qris.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF003B46),
                      ),
                      onPressed: () {
                        _downloadQRIS();
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text(
                        "Download",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _buktiBayar != null ? Colors.green : Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _pilihBuktiBayar,
                      icon: Icon(_buktiBayar != null ? Icons.check_circle : Icons.upload_file, size: 18),
                      label: Text(_buktiBayar != null ? "Ubah Foto" : "Upload"),
                    ),
                  ],
                ),

                // --- KODE GABUNGAN: Menampilkan preview foto buatan temanmu ---
                if (_buktiBayar != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _buktiBayar!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      "✅ Bukti pembayaran berhasil dipilih",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                // ----------------------------------------------------------------
              ]
            ]),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF003B46),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _prosesPesanan(totalAkhir),
              child: const Text(
                "Buat Pesanan Sekarang",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildRowText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          const Text(":", style: TextStyle(color: Colors.white70)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _prosesPesanan(double totalAkhir) async {
    if (metodePembayaran == "QRIS" && _buktiBayar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan upload bukti pembayaran terlebih dahulu"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      ),
    );

    String tglMulaiStr = "${widget.tglMulai.year}-${widget.tglMulai.month.toString().padLeft(2, '0')}-${widget.tglMulai.day.toString().padLeft(2, '0')}";
    String tglSelesaiStr = "${widget.tglKembali.year}-${widget.tglKembali.month.toString().padLeft(2, '0')}-${widget.tglKembali.day.toString().padLeft(2, '0')}";

    List<CartItem> itemDisimpan = List.from(CartManager.items);

    int? idPesananAsli = await ApiService().buatPesanan(
      userId: 1,
      nama: widget.nama,
      whatsapp: widget.whatsapp,
      email: widget.email,
      metodePembayaran: metodePembayaran,
      tglMulai: tglMulaiStr,
      tglSelesai: tglSelesaiStr,
      totalHarga: totalAkhir,
      cartItems: itemDisimpan,
      buktiBayar: _buktiBayar,
    );

    if (mounted) {
      Navigator.pop(context);
    }

    if (idPesananAsli != null) {
      CartManager.bersihkanKeranjang();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => NotaScreen(
              pesananId: idPesananAsli,
              nama: widget.nama,
              whatsapp: widget.whatsapp,
              email: widget.email,
              hari: widget.hari,
              tglMulai: tglMulaiStr,
              tglKembali: tglSelesaiStr,
              metodePembayaran: metodePembayaran,
              status: metodePembayaran == "Cash" ? "Menunggu Pengambilan" : "Menunggu Verifikasi",
              totalPembayaran: totalAkhir,
              items: itemDisimpan,
              buktiBayar: _buktiBayar,
            ),
          ),
              (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mengirim pesanan. Silakan coba lagi."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}