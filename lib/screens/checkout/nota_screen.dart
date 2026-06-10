import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../services/cart_manager.dart';
import '../main/main_screen.dart';

class NotaScreen extends StatefulWidget {
  final int pesananId;
  final String nama;
  final String whatsapp;
  final String email;
  final int hari;
  final String tglMulai;
  final String tglKembali;
  final String metodePembayaran;
  final String status;
  final double totalPembayaran;
  final List<CartItem> items;
  final File? buktiBayar;

  const NotaScreen({
    super.key,
    required this.pesananId,
    required this.nama,
    required this.whatsapp,
    required this.email,
    required this.hari,
    required this.tglMulai,
    required this.tglKembali,
    required this.metodePembayaran,
    required this.status,
    required this.totalPembayaran,
    required this.items,
    this.buktiBayar,
  });

  @override
  State<NotaScreen> createState() => _NotaScreenState();
}

class _NotaScreenState extends State<NotaScreen> {
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _downloadNota() async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        status = await Permission.photos.request();
      }

      if (status.isGranted) {
        RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        final result = await ImageGallerySaverPlus.saveImage(
            pngBytes,
            name: "Nota_DT_Adventure_${widget.pesananId}_${DateTime.now().millisecondsSinceEpoch}"
        );

        if (result != null && (result['isSuccess'] == true || result['isSuccess'] == "true")) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ Nota berhasil didownload ke galeri!"), backgroundColor: Colors.green),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("❌ Gagal menyimpan nota."), backgroundColor: Colors.redAccent),
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

  Future<void> _openMaps() async {
    const url = 'https://maps.app.goo.gl/GPCac51kjwxhDees9?g_st=iw';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp() async {
    const String nomorWA = "6288232778958";
    String pesan = "Halo Admin Adventure! Saya ingin konfirmasi pesanan saya dengan ID Pesanan #${widget.pesananId}.";
    final Uri waUrl = Uri.parse("https://wa.me/$nomorWA?text=${Uri.encodeComponent(pesan)}");
    try {
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal membuka WhatsApp. Pastikan aplikasi terinstal.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double subtotalPerHari = widget.totalPembayaran / widget.hari;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nota #${widget.pesananId}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF004466),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
              );
            },
          )
        ],
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
            // ==================== AREA NOTA YANG AKAN DIFOTO ====================
            RepaintBoundary(
              key: _globalKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Nota
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("DT Adventure", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004466))),
                              SizedBox(height: 4),
                              Text("Dusun Sepatan RT 09 RW 05 No. 8,\nRawang, Pekalongan\nTelp: 0812-3456-7890", style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Nota #${widget.pesananId}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 4),
                            const Text("Status:", style: TextStyle(fontSize: 12, color: Colors.black54)),
                            Text(widget.status, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Data Pemesan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Data Pemesan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                          const SizedBox(height: 8),
                          _buildTextRow("Nama", widget.nama),
                          _buildTextRow("WhatsApp", widget.whatsapp),
                          _buildTextRow("Email", widget.email.isEmpty ? "-" : widget.email),
                          _buildTextRow("Durasi", "${widget.hari} hari"),
                          _buildTextRow("Mulai", widget.tglMulai),
                          _buildTextRow("Kembali", widget.tglKembali),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Metode Pembayaran
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                          const SizedBox(height: 8),
                          Text(
                            widget.metodePembayaran == "Cash"
                                ? "💵 Cash — pembayaran dilakukan di tempat pengambilan barang."
                                : "📱 QRIS — pembayaran via scan QR.",
                            style: const TextStyle(color: Colors.black87, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Rincian Barang
                    const Text("Rincian Barang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: widget.items.map<Widget>((item) {
                          double hargaItem = item.produk.harga;
                          double subtotalPerHariItem = hargaItem * item.qty;
                          double totalItem = subtotalPerHariItem * widget.hari;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.produk.namaAlat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                                const SizedBox(height: 6),
                                _buildRowRincianSpesifik("Harga/hari", "Rp ${hargaItem.toInt()}"),
                                _buildRowRincianSpesifik("Jumlah", "${item.qty}x"),
                                _buildRowRincianSpesifik("Subtotal/hari", "Rp ${subtotalPerHariItem.toInt()}"),
                                _buildRowRincianSpesifik("Total (x ${widget.hari} hari)", "Rp ${totalItem.toInt()}", isTotal: true),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Total Pembayaran
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 250,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [const Text("Subtotal/hari", style: TextStyle(color: Colors.black54)), Text("Rp ${subtotalPerHari.toInt()}", style: const TextStyle(color: Colors.black87))],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [const Text("Durasi", style: TextStyle(color: Colors.black54)), Text("${widget.hari} hari", style: const TextStyle(color: Colors.black87))],
                            ),
                            const Divider(height: 20, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total Bayar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                Text("Rp ${widget.totalPembayaran.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF004466))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bukti Bayar (Hanya Muncul Jika QRIS)
                    if (widget.buktiBayar != null) ...[
                      const SizedBox(height: 20),
                      Container(height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 15),
                      const Text("Bukti Pembayaran:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 10),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(widget.buktiBayar!, height: 250, fit: BoxFit.cover),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            // ==================== BATAS AREA NOTA ====================

            const SizedBox(height: 24),

            // Tombol & Informasi Tambahan (Di luar RepaintBoundary)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFE8FFF0), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("📍 Alamat DT Adventure", style: TextStyle(color: Color(0xFF0A6B2A), fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _openMaps,
                      icon: const Icon(Icons.location_on),
                      label: const Text("Lihat di Google Maps", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EA8FE),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("⚠️ Harap simpan nota ini dan segera konfirmasi pesanan melalui WhatsApp agar pesanan segera diproses.",
                    style: TextStyle(color: Color(0xFF0A6B2A), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Download Nota
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF003B46),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _downloadNota,
                icon: const Icon(Icons.download),
                label: const Text("Download Nota", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol WhatsApp
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _openWhatsApp,
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text("Chat WhatsApp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Kembali
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF004466)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                        (route) => false,
                  );
                },
                child: const Text("Kembali ke Beranda", style: TextStyle(color: Color(0xFF004466), fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.black54))),
          const Text(": ", style: TextStyle(color: Colors.black54)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildRowRincianSpesifik(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: isTotal ? Colors.black87 : Colors.black54, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 13, color: isTotal ? const Color(0xFF004466) : Colors.black87, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}