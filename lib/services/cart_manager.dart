import 'package:flutter/material.dart';
import '../models/tipe_alat.dart';

class CartItem {
  final TipeAlat produk;
  int qty;

  CartItem({required this.produk, this.qty = 1});
}

class CartManager {
  // MENGGUNAKAN ValueNotifier agar setiap perubahan data langsung didengar oleh UI
  static final ValueNotifier<List<CartItem>> tipeAlatCart = ValueNotifier([]);

  static List<CartItem> get items => tipeAlatCart.value;

  static void tambahProduk(TipeAlat produk) {
    final currentItems = List<CartItem>.from(tipeAlatCart.value);
    int index = currentItems.indexWhere((element) => element.produk.id == produk.id);

    if (index >= 0) {
      currentItems[index].qty++;
    } else {
      currentItems.add(CartItem(produk: produk));
    }

    tipeAlatCart.value = currentItems; // Memicu refresh otomatis di UI
  }

  static void kurangiProduk(int index) {
    final currentItems = List<CartItem>.from(tipeAlatCart.value);
    if (currentItems[index].qty > 1) {
      currentItems[index].qty--;
    } else {
      currentItems.removeAt(index);
    }
    tipeAlatCart.value = currentItems; // Memicu refresh otomatis di UI
  }

  static void tambahQty(int index) {
    final currentItems = List<CartItem>.from(tipeAlatCart.value);
    currentItems[index].qty++;
    tipeAlatCart.value = currentItems; // Memicu refresh otomatis di UI
  }

  static double hitungTotal(int durasiHari) {
    double total = 0;
    for (var item in tipeAlatCart.value) {
      total += item.produk.harga * item.qty;
    }
    return total * (durasiHari == 0 ? 1 : durasiHari);
  }

  static void bersihkanKeranjang() {
    tipeAlatCart.value = [];
  }
}

