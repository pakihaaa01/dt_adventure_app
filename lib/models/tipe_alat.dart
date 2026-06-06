class TipeAlat {
  final int id;
  final int kategoriId;
  final String namaAlat;
  final String? gambar;
  final int stok;
  final double harga;
  final String? deskripsi;
  final int? subKategoriId;

  TipeAlat({
    required this.id,
    required this.kategoriId,
    required this.namaAlat,
    this.gambar,
    required this.stok,
    required this.harga,
    this.deskripsi,
    this.subKategoriId,
  });

  factory TipeAlat.fromJson(Map<String, dynamic> json) {
    return TipeAlat(
      id: json['id'] ?? 0,
      kategoriId: json['kategori_id'] ?? 0,
      namaAlat: json['nama_alat'] ?? 'Tanpa Nama',
      gambar: json['gambar'],
      stok: json['stok'] ?? 0,
      harga: json['harga'] != null ? double.parse(json['harga'].toString()) : 0.0,
      deskripsi: json['deskripsi'],
      subKategoriId: json['sub_kategori_id'] != null ? int.tryParse(json['sub_kategori_id'].toString()) : null,
    );
  }
}