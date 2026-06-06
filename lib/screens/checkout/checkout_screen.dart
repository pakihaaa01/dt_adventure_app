import 'package:flutter/material.dart';
import '../../services/cart_manager.dart';
import '../../services/api_service.dart';
import '../main/main_screen.dart';
import 'nota_screen.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> _downloadQRIS() async {
    try {
      // 1. Minta izin akses penyimpanan
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        status = await Permission.photos.request(); // Fallback untuk Android 13+
      }

      if (status.isGranted) {
        // 2. Load gambar dari assets
        ByteData byteData = await rootBundle.load('assets/images/qris.png');
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // 3. Simpan pakai package temuanmu (Perhatikan huruf kapitalnya: ImageGallerySaverPlus)
        final result = await ImageGallerySaverPlus.saveImage(
            pngBytes,
            name: "QRIS_DT_Adventure_${DateTime.now().millisecondsSinceEpoch}"
        );

        if (result != null && (result['isSuccess'] == true || result['isSuccess'] == "true")) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ QRIS berhasil didownload!"), backgroundColor: Colors.green),
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
        title: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF004466),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF004466), Color(0xFF006688)]),
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
              _buildRowText("Tanggal Ambil", "${widget.tglMulai.day}/${widget.tglMulai.month}/${widget.tglMulai.year}"),
              _buildRowText("Tanggal Kembali", "${widget.tglKembali.day}/${widget.tglKembali.month}/${widget.tglKembali.year}"),
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
                      Expanded(child: Text("${item.qty}x ${item.produk.namaAlat}", style: const TextStyle(color: Colors.white))),
                      Text("Rp ${item.produk.harga.toInt()}", style: const TextStyle(color: Color(0xFFFFD700))),
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
                  Text("Total Produk (${CartManager.items.length} item) x ${widget.hari} Hari", style: const TextStyle(color: Colors.white70)),
                  Text("Rp ${totalAkhir.toInt()}", style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle("Metode Pembayaran"),
            _buildCard([
              RadioListTile(
                title: const Text("Cash (Bayar di Tempat)", style: TextStyle(color: Colors.white)),
                activeColor: const Color(0xFFFFD700),
                value: "Cash",
                groupValue: metodePembayaran,
                onChanged: (val) => setState(() => metodePembayaran = val.toString()),
              ),
              RadioListTile(
                title: const Text("QRIS", style: TextStyle(color: Colors.white)),
                activeColor: const Color(0xFFFFD700),
                value: "QRIS",
                groupValue: metodePembayaran,
                onChanged: (val) => setState(() => metodePembayaran = val.toString()),
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
                        // Memanggil fungsi download yang sebenarnya
                        _downloadQRIS();
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text("Download", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Fitur upload bukti bayar akan segera tersedia."),
                            backgroundColor: Colors.blueAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text("Upload"),
                    ),
                  ],
                )
              ]
            ]),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF003B46),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _prosesPesanan(totalAkhir),
              child: const Text("Buat Pesanan Sekarang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildRowText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.white70))),
          const Text(":", style: TextStyle(color: Colors.white70)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Future<void> _prosesPesanan(double totalAkhir) async {
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))));

    String tglMulaiStr = "${widget.tglMulai.year}-${widget.tglMulai.month.toString().padLeft(2, '0')}-${widget.tglMulai.day.toString().padLeft(2, '0')}";
    String tglSelesaiStr = "${widget.tglKembali.year}-${widget.tglKembali.month.toString().padLeft(2, '0')}-${widget.tglKembali.day.toString().padLeft(2, '0')}";

    List<CartItem> itemDisimpan = List.from(CartManager.items);

    bool isSuccess = await ApiService().buatPesanan(
      userId: 1,
      nama: widget.nama,
      whatsapp: widget.whatsapp,
      email: widget.email,
      metodePembayaran: metodePembayaran,
      tglMulai: tglMulaiStr,
      tglSelesai: tglSelesaiStr,
      totalHarga: totalAkhir,
      cartItems: itemDisimpan,
    );

    Navigator.pop(context);

    if (isSuccess) {
      CartManager.bersihkanKeranjang();

      // FIX: Langsung buka NotaScreen dan bersihkan semua riwayat halaman ke belakang
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => NotaScreen(
              pesananId: DateTime.now().millisecondsSinceEpoch % 100000,
              nama: widget.nama,
              whatsapp: widget.whatsapp,
              email: widget.email,
              hari: widget.hari,
              tglMulai: tglMulaiStr,
              tglKembali: tglSelesaiStr,
              metodePembayaran: metodePembayaran,
              status: metodePembayaran == "Cash" ? "Menunggu Pengambilan" : "Menunggu Konfirmasi",
              totalPembayaran: totalAkhir,
              items: itemDisimpan,
            ),
          ),
              (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengirim pesanan."), backgroundColor: Colors.redAccent));
    }
  }
}