import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  // Tambahkan fungsi callback agar bisa memberi sinyal ke MainScreen saat diklik
  final Function(int) onCategoryTap;

  const HomeScreen({super.key, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    // Data 7 Kata Mutiara
    final List<Map<String, String>> kataMutiara = [
      {"quote": "Setiap puncak gunung dapat dijangkau jika Anda terus mendaki.", "author": "Barry Finlay"},
      {"quote": "Anda tidak perlu mendaki gunung untuk mengetahui bahwa itu tinggi.", "author": "Paulo Coelho"},
      {"quote": "Gunung terjauh adalah gunung yang menurutmu tidak akan pernah bisa kamu capai dan bahkan mungkin hanya di sisimu!", "author": "Mehmet Murat ildan"},
      {"quote": "Bukan gunung yang kita taklukkan, tapi diri kita sendiri.", "author": "Anonim"},
      {"quote": "Pergi ke gunung seperti pulang ke rumah.", "author": "Anonim"},
      {"quote": "Hidup ini seperti mendaki gunung - jangan pernah melihat ke bawah.", "author": "Sir Edmund Hillary"},
      {"quote": "Ternyata, makin tinggi kaki kita berpijak, makin kita menyadari betapa kecilnya diri kita. Gunung tercipta bukan agar kita bisa menaklukkan puncaknya. Gunung tercipta agar kita mampu menaklukkan ego kita sendiri.", "author": "Fiersa Besari"},
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF004466), Color(0xFF006688)]),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // BANNER UTAMA
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(image: AssetImage('assets/images/gambarGunung.jpg'), fit: BoxFit.cover),
            ),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.black.withOpacity(0.50)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("HI, PETUALANG!", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          "DT Adventure hadir dengan perlengkapan mendaki terbaik, lengkap dengan berbagai pilihan ukuran dan warna untuk kenyamanan aktivitas alam kamu.\n\nYuk, Temukan perlengkapan yang cocok untukmu!",
                          style: TextStyle(color: Colors.white, fontSize: 9, height: 1.3),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // KATEGORI (Dilengkapi fungsi onTap untuk pindah halaman)
          const Text("Kategori", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CategoryItem(icon: Icons.terrain, label: "Tenda", onTap: () => onCategoryTap(1)), // 1 = Tenda
              CategoryItem(icon: Icons.backpack, label: "Tracking", onTap: () => onCategoryTap(2)), // 2 = Tracking
              CategoryItem(icon: Icons.local_fire_department, label: "Memasak", onTap: () => onCategoryTap(3)), // 3 = Memasak
              CategoryItem(icon: Icons.more_horiz, label: "Lainnya", onTap: () => onCategoryTap(5)), // 5 = Perlengkapan Tambahan
            ],
          ),

          const SizedBox(height: 25),

          // INSPIRASI PETUALANGAN (Horizontal Scroll)
          const Text("Inspirasi Petualangan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),

          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kataMutiara.length,
              itemBuilder: (context, index) {
                final item = kataMutiara[index];
                return Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.format_quote, color: Color(0xFFFFD700), size: 28),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            "\"${item['quote']}\"",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "- ${item['author']} -",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700), fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 25),

          // PESANAN BERJALAN
          const Text("Pesanan Berjalan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white24, width: 1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("INV-DT-00123", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(8)),
                      child: const Text("Menunggu Diambil", style: TextStyle(color: Color(0xFF003b46), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.backpack, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Carrier 60L & 3 Item Lainnya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4),
                          Text("Estimasi Ambil: Hari Ini, 14:00 WIB", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Widget Kategori Item yang diperbarui untuk bisa diklik
class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap; // Fungsi saat ditekan

  const CategoryItem({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: const Color(0xFFFFD700), size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }
}