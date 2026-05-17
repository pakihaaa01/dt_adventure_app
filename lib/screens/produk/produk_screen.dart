import 'package:flutter/material.dart';

class ProdukScreen extends StatelessWidget {
  const ProdukScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔍 Search
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Cari alat...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // 📂 KATEGORI (HORIZONTAL)
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              CategoryChip(label: "Tenda & Camp"),
              CategoryChip(label: "Tracking"),
              CategoryChip(label: "Peralatan Masak"),
              CategoryChip(label: "Outfit Outdoor"),
              CategoryChip(label: "Tambahan"),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 📦 PRODUK
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              return ProductItem();
            },
          ),
        ),
      ],
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;

  const CategoryChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.green.withOpacity(0.1),
        labelStyle: const TextStyle(color: Colors.green),
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  const ProductItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Nama
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "Tenda 4 Orang",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 4),

          // Harga
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "Rp 50.000 / hari",
              style: TextStyle(color: Colors.green),
            ),
          ),

          const Spacer(),

          // Button
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Sewa"),
              ),
            ),
          )
        ],
      ),
    );
  }
}