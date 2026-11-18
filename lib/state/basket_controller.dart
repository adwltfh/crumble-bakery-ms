import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/products.dart';

class BasketController extends ChangeNotifier {
  BasketController({this.shippingFee = 10000});

  static const String _storageKey = 'crumb_oven_basket_v1';

  final int shippingFee;
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  final Map<String, int> _quantities = {};

  // Menjaga urutan penulisan ketika user cepat menekan +/-.
  Future<void> _writeQueue = Future<void>.value();

  /// Buat controller dan pulihkan keranjang sebelum aplikasi tampil.
  static Future<BasketController> create() async {
    final basket = BasketController();
    await basket._restore();
    return basket;
  }

  Future<void> _restore() async {
    try {
      final raw = await _prefs.getString(_storageKey);
      if (raw == null) return;

      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;

      final validIds = products.map((p) => p.id).toSet();

      _quantities.clear();

      for (final entry in decoded.entries) {
        final id = entry.key;
        final quantity = entry.value;

        if (id is String &&
            validIds.contains(id) &&
            quantity is int &&
            quantity > 0) {
          _quantities[id] = quantity;
        }
      }

      notifyListeners();
    } catch (error) {
      debugPrint('Gagal memulihkan keranjang: $error');
    }
  }

  void _save() {
    final snapshot = jsonEncode(_quantities);

    _writeQueue = _writeQueue
        .then((_) => _prefs.setString(_storageKey, snapshot))
        .catchError((Object error, StackTrace stack) {
      debugPrint('Gagal menyimpan keranjang: $error');
    });
  }

  int quantityOf(String productId) => _quantities[productId] ?? 0;

  void increment(String productId) {
    _quantities.update(
      productId,
      (value) => value + 1,
      ifAbsent: () => 1,
    );

    notifyListeners();
    _save();
  }

  void decrement(String productId) {
    final current = quantityOf(productId);
    if (current <= 0) return;

    if (current == 1) {
      _quantities.remove(productId);
    } else {
      _quantities[productId] = current - 1;
    }

    notifyListeners();
    _save();
  }

  void removeItem(String productId) {
    if (_quantities.remove(productId) != null) {
      notifyListeners();
      _save();
    }
  }

  /// Dipanggil HANYA setelah API mengonfirmasi order sukses.
  Future<void> clear() async {
    _quantities.clear();
    notifyListeners();

    _save();
    await _writeQueue;
  }

  int get itemCount => _quantities.values.fold(0, (a, b) => a + b);

  Iterable<BakeryProduct> get selectedProducts =>
      products.where((p) => quantityOf(p.id) > 0);

  int get subtotal => selectedProducts.fold(
        0,
        (sum, product) => sum + product.price * quantityOf(product.id),
      );

  int get shipping => itemCount == 0 ? 0 : shippingFee;

  int get total => subtotal + shipping;

  String get checkoutText {
    final lines = <String>[
      'Halo Crumb & Oven, saya ingin pesan:',
    ];

    for (final product in selectedProducts) {
      final quantity = quantityOf(product.id);

      lines.add(
        '- ${product.name} x$quantity = '
        '${rupiah(product.price * quantity)}',
      );
    }

    lines.add('');
    lines.add('Jumlah item: $itemCount');
    lines.add('Subtotal: ${rupiah(subtotal)}');
    lines.add('Ongkir: ${rupiah(shipping)}');
    lines.add('Total pembayaran: ${rupiah(total)}');
    lines.add('');
    lines.add('Mohon konfirmasi pesanan saya. Terima kasih!');

    return lines.join('\n');
  }
}

String rupiah(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }

  return 'Rp $buffer';
}
