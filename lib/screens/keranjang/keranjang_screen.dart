import 'package:flutter/material.dart';
import '../../services/cart_manager.dart';
import '../checkout/form_pesanan_screen.dart';

class KeranjangScreen extends StatefulWidget {
  const KeranjangScreen({super.key});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang Sewa", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF004466),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF004466), Color(0xFF006688)]),
        ),
        child: ValueListenableBuilder<List<CartItem>>(
          valueListenable: CartManager.tipeAlatCart,
          builder: (context, cartItems, child) {
            if (cartItems.isEmpty) {
              return const Center(child: Text("Keranjang masih kosong.", style: TextStyle(color: Colors.white70, fontSize: 16)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                String imageUrl = item.produk.gambar != null
                    ? (item.produk.gambar!.startsWith('gambar_alat/') ? 'https://dtadventure.web.id/storage/${item.produk.gambar}' : 'https://dtadventure.web.id/${item.produk.gambar}')
                    : 'https://dtadventure.web.id/gambargunung.png';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.white54)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.produk.namaAlat, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text("Rp ${item.produk.harga.toInt()} / hari", style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.white70), onPressed: () => CartManager.kurangiProduk(index)),
                          Text('${item.qty}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFFD700)), onPressed: () => CartManager.tambahQty(index)),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<List<CartItem>>(
        valueListenable: CartManager.tipeAlatCart,
        builder: (context, cartItems, child) {
          if (cartItems.isEmpty) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF003B46), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
            child: SafeArea(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF003B46),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FormPesananScreen()));
                },
                child: const Text("Isi Form Pesanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          );
        },
      ),
    );
  }
}