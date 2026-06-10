import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/cart_manager.dart';
import '../main/main_screen.dart';
import 'dart:io';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nota Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF004466), Color(0xFF006688)]),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RepaintBoundary(
              key: _globalKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const Text("DT ADVENTURE", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF004466))),
                          const Text("Rental Peralatan Hiking & Camping", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 10),
                          Container(height: 1, color: Colors.grey.shade300),
                          const SizedBox(height: 15),
                          Text("ID PESANAN: #${widget.pesananId}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 5),
                          Text("Status: ${widget.status}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: widget.status.contains("Pengambilan") ? Colors.orange.shade800 : Colors.blue.shade800)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildTextRow("Nama Pemesan", widget.nama),
                    _buildTextRow("WhatsApp", widget.whatsapp),
                    _buildTextRow("Email", widget.email),
                    _buildTextRow("Metode Bayar", widget.metodePembayaran),
                    _buildTextRow("Durasi Sewa", "${widget.hari} Hari"),
                    _buildTextRow("Tgl Ambil", widget.tglMulai),
                    _buildTextRow("Tgl Kembali", widget.tglKembali),
                    const SizedBox(height: 15),
                    Container(height: 1, color: Colors.grey.shade300),
                    const SizedBox(height: 15),
                    const Text("Daftar Barang:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
                    const SizedBox(height: 8),
                    Column(
                      children: widget.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text("${item.qty}x ${item.produk.namaAlat}", style: const TextStyle(color: Colors.black87))),
                              Text("Rp ${(item.produk.harga * item.qty).toInt()}", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),
                    Container(height: 1, color: Colors.grey.shade300),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("TOTAL BAYAR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF004466))),
                        Text("Rp ${widget.totalPembayaran.toInt()}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF004466))),
                      ],
                    ),
                    if (widget.buktiBayar != null) ...[
                      const SizedBox(height: 20),
                      Container(height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 15),
                      const Text("Bukti Pembayaran:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 10),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            widget.buktiBayar!,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  const String nomorWA = "6288232778958";
                  String pesan = "Halo Admin Adventure! Saya ingin konfirmasi pesanan saya dengan ID Pesanan #${widget.pesananId}.";
                  final Uri waUrl = Uri.parse("https://wa.me/$nomorWA?text=${Uri.encodeComponent(pesan)}");
                  try {
                    if (await canLaunchUrl(waUrl)) {
                      await launchUrl(waUrl, mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Gagal membuka WhatsApp. Pastikan aplikasi terinstal.")),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Terjadi kesalahan: $e")),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text("Chat WhatsApp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
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
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.black54))),
          const Text(":", style: TextStyle(color: Colors.black54)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}