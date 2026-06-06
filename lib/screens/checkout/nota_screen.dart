import 'package:flutter/material.dart';
import '../../services/cart_manager.dart';
import '../main/main_screen.dart';

class NotaScreen extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    double subtotalPerHari = totalPembayaran / hari;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text("Nota #$pesananId", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF004466),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Text("Nota #$pesananId", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 4),
                      const Text("Status:", style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Text(status, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Data Pemesan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                    const SizedBox(height: 8),
                    _buildInfoText("Nama", nama),
                    _buildInfoText("WhatsApp", whatsapp),
                    _buildInfoText("Email", email.isEmpty ? "-" : email),
                    _buildInfoText("Durasi", "$hari hari"),
                    _buildInfoText("Mulai", tglMulai),
                    _buildInfoText("Kembali", tglKembali),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                      metodePembayaran == "Cash" ? "💵 Cash — pembayaran dilakukan di tempat pengambilan barang." : "📱 QRIS — pembayaran via scan QR.",
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text("Rincian Barang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 8),

              // ==================== REVISI RINCIAN BARANG ====================
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: items.map<Widget>((item) {
                    double hargaItem = item.produk.harga;
                    double subtotalPerHariItem = hargaItem * item.qty;
                    double totalItem = subtotalPerHariItem * hari;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Nama Barang
                          Text(
                              item.produk.namaAlat,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)
                          ),
                          const SizedBox(height: 6),

                          // 2. Baris Detail Spesifik
                          _buildRowRincianSpesifik("Harga/hari", "Rp ${hargaItem.toInt()}"),
                          _buildRowRincianSpesifik("Jumlah", "${item.qty}x"),
                          _buildRowRincianSpesifik("Subtotal/hari", "Rp ${subtotalPerHariItem.toInt()}"),
                          _buildRowRincianSpesifik("Total (x $hari hari)", "Rp ${totalItem.toInt()}", isTotal: true),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              // ==============================================================

              const SizedBox(height: 24),
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
                        children: [
                          const Text("Subtotal/hari", style: TextStyle(color: Colors.black54)),
                          Text("Rp ${subtotalPerHari.toInt()}", style: const TextStyle(color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Durasi", style: TextStyle(color: Colors.black54)),
                          Text("$hari hari", style: const TextStyle(color: Colors.black87)),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          Text("Rp ${totalPembayaran.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFE8FFF0), borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  "⚠️ Simpan nota ini & segera konfirmasi melalui WhatsApp",
                  style: TextStyle(color: Color(0xFF0A6B2A), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur buka WhatsApp akan segera tersedia.")));
                  },
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text("Chat WhatsApp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF004466)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const MainScreen()), (Route<dynamic> route) => false);
                  },
                  child: const Text("Kembali ke Beranda", style: TextStyle(color: Color(0xFF004466), fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
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

  // === WIDGET HELPER BARU UNTUK BARIS RINCIAN BARANG ===
  Widget _buildRowRincianSpesifik(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              label,
              style: TextStyle(
                  fontSize: 13,
                  color: isTotal ? Colors.black87 : Colors.black54,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal
              )
          ),
          Text(
              value,
              style: TextStyle(
                  fontSize: 13,
                  color: isTotal ? const Color(0xFF004466) : Colors.black87,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500
              )
          ),
        ],
      ),
    );
  }
}