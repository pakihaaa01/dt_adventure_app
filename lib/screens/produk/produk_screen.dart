import 'package:flutter/material.dart';
import '../../models/tipe_alat.dart';
import '../../services/api_service.dart';
import '../../services/cart_manager.dart';

class ProdukScreen extends StatefulWidget {
  final int initialCategoryId; // INI YANG BIKIN ERROR KALAU TIDAK ADA

  const ProdukScreen({super.key, this.initialCategoryId = 0}); // INI JUGA WAJIB ADA

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<TipeAlat>> _futureProduk;

  late int selectedCategoryId;
  String selectedSubCategory = "Semua";
  String searchQuery = "";

  final List<Map<String, dynamic>> categories = [
    {'id': 0, 'name': 'Semua'},
    {'id': 1, 'name': 'Tenda & Alat Tidur'},
    {'id': 2, 'name': 'Kebutuhan Tracking'},
    {'id': 3, 'name': 'Peralatan Masak'},
    {'id': 4, 'name': 'Outfit Outdoor'},
    {'id': 5, 'name': 'Perlengkapan Tambahan'},
  ];

  final List<String> trackingSubCategories = [
    'Semua', 'Carrier', 'Daypack', 'Hydropack', 'Tracking Pole',
    'Headlamp', 'Powerbank', 'Kacamata Gunung', 'Timbangan Portable'
  ];

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.initialCategoryId; // Menangkap ID dari Home
    _futureProduk = _apiService.fetchProduk();
  }

  @override
  void didUpdateWidget(ProdukScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategoryId != widget.initialCategoryId) {
      setState(() {
        selectedCategoryId = widget.initialCategoryId;
        selectedSubCategory = "Semua";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF004466), Color(0xFF006688)]),
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          _buildMainCategoryList(),
          if (selectedCategoryId == 2) _buildSubCategoryList(),
          _buildProductGrid(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Cari alat pendakian...",
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: Colors.black.withOpacity(0.4),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildMainCategoryList() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          bool isSelected = selectedCategoryId == categories[i]['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(categories[i]['name'], style: TextStyle(color: isSelected ? const Color(0xFF003B46) : Colors.white)),
              selected: isSelected,
              onSelected: (s) => setState(() { selectedCategoryId = categories[i]['id']; selectedSubCategory = "Semua"; }),
              selectedColor: const Color(0xFFFFD700),
              backgroundColor: Colors.black.withOpacity(0.4),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubCategoryList() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: trackingSubCategories.length,
        itemBuilder: (ctx, i) {
          bool isSelected = selectedSubCategory == trackingSubCategories[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(trackingSubCategories[i], style: TextStyle(fontSize: 12, color: isSelected ? const Color(0xFF003B46) : Colors.white)),
              selected: isSelected,
              onSelected: (s) => setState(() => selectedSubCategory = trackingSubCategories[i]),
              selectedColor: const Color(0xFFFFD700),
              backgroundColor: Colors.black.withOpacity(0.3),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return Expanded(
      child: FutureBuilder<List<TipeAlat>>(
        future: _futureProduk,
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));

          final filtered = snapshot.data!.where((p) {
            // p.kategoriId berisi angka 1 sampai 16 (Sesuai database asli kamu)

            // 1. FILTER KATEGORI UTAMA (Mapping 16 ID Database ke 5 Tab Mobile)
            bool catMatch = false;
            if (selectedCategoryId == 0) {
              catMatch = true; // Tab "Semua"
            } else if (selectedCategoryId == 1 && p.kategoriId == 1) {
              catMatch = true; // Tenda & Alat Tidur
            } else if (selectedCategoryId == 2 && p.kategoriId >= 2 && p.kategoriId <= 9) {
              catMatch = true; // Kebutuhan Tracking (ID 2 sampai 9)
            } else if (selectedCategoryId == 3 && p.kategoriId == 10) {
              catMatch = true; // Peralatan Masak
            } else if (selectedCategoryId == 4 && p.kategoriId >= 11 && p.kategoriId <= 15) {
              catMatch = true; // Outfit Outdoor (ID 11 sampai 15)
            } else if (selectedCategoryId == 5 && p.kategoriId == 16) {
              catMatch = true; // Perlengkapan Tambahan
            }

            // 2. FILTER SUB-KATEGORI (Khusus saat Tab Tracking dipilih)
            bool subMatch = true;
            if (selectedCategoryId == 2 && selectedSubCategory != "Semua") {
              subMatch = false; // Matikan dulu, lalu kita cocokkan persis dengan ID database
              if (selectedSubCategory == "Carrier" && p.kategoriId == 2) subMatch = true;
              else if (selectedSubCategory == "Daypack" && p.kategoriId == 3) subMatch = true;
              else if (selectedSubCategory == "Hydropack" && p.kategoriId == 4) subMatch = true;
              else if (selectedSubCategory == "Tracking Pole" && p.kategoriId == 5) subMatch = true;
              else if (selectedSubCategory == "Headlamp" && p.kategoriId == 6) subMatch = true;
              else if (selectedSubCategory == "Powerbank" && p.kategoriId == 7) subMatch = true;
              else if (selectedSubCategory == "Kacamata Gunung" && p.kategoriId == 8) subMatch = true;
              else if (selectedSubCategory == "Timbangan Portable" && p.kategoriId == 9) subMatch = true;
            }

            // 3. FILTER PENCARIAN TEKS
            bool searchMatch = p.namaAlat.toLowerCase().contains(searchQuery.toLowerCase());

            return catMatch && subMatch && searchMatch;
          }).toList();

          if (filtered.isEmpty) return const Center(child: Text("Produk tidak ditemukan.", style: TextStyle(color: Colors.white)));

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.65),
            itemBuilder: (ctx, i) => ProductItem(produk: filtered[i]),
          );
        },
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final TipeAlat produk;
  const ProductItem({super.key, required this.produk});

  @override
  Widget build(BuildContext context) {
    String imageUrl = 'https://dtadventure.web.id/gambargunung.png';
    if (produk.gambar != null && produk.gambar!.isNotEmpty) {
      imageUrl = produk.gambar!.startsWith('gambar_alat/') ? 'https://dtadventure.web.id/storage/${produk.gambar}' : 'https://dtadventure.web.id/${produk.gambar}';
    }

    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover))),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(produk.namaAlat, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                Text("Rp ${produk.harga.toInt()} / hari", style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              height: 35,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: const Color(0xFF003b46)),
                onPressed: () {
                  // MENGIRIM PRODUK KE KERANJANG REAL-TIME
                  CartManager.tambahProduk(produk);

                  // Menampilkan notifikasi kecil di bawah layar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${produk.namaAlat} masuk ke keranjang sewa"),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text("Sewa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          )
        ],
      ),
    );
  }
}