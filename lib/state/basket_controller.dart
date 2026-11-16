import 'package:flutter/foundation.dart';
import '../data/products.dart';

/// UI-only shopping basket. Persists while app is open; no database/backend.
class BasketController extends ChangeNotifier {
  BasketController({this.shippingFee = 12000, this.freeShippingAt = 6});

  /// Dummy ongkir, ganti setelah aturan pengiriman diputuskan.
  final int shippingFee;
  final int freeShippingAt;
  final Map<String, int> _quantities = {};

  int quantityOf(String productId) => _quantities[productId] ?? 0;

  void increment(String productId) {
    _quantities.update(productId, (value) => value + 1, ifAbsent: () => 1);
    notifyListeners();
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
  }

  int get itemCount => _quantities.values.fold(0, (a, b) => a + b);

  Iterable<BakeryProduct> get selectedProducts =>
      products.where((product) => quantityOf(product.id) > 0);

  int get subtotal => selectedProducts.fold(
        0, (sum, product) => sum + product.price * quantityOf(product.id),
      );

  int get remainingForFreeShipping {
    final remaining = freeShippingAt - itemCount;
    return remaining > 0 ? remaining : 0;
  }

  bool get qualifiesForFreeShipping => itemCount >= freeShippingAt;

  /// Shipping is zero when cart is empty, then free at 6+ items.
  int get shipping =>
      itemCount == 0 || qualifiesForFreeShipping ? 0 : shippingFee;

  int get total => subtotal + shipping;

  String get checkoutText {
    final lines = <String>['Halo Crumb & Oven, saya ingin pesan:'];
    for (final product in selectedProducts) {
      final quantity = quantityOf(product.id);
      lines.add('- ${product.name} x$quantity = '
          '${rupiah(product.price * quantity)}');
    }
    lines.add('');
    lines.add('Jumlah item: $itemCount');
    lines.add('Subtotal: ${rupiah(subtotal)}');
    lines.add('Estimasi ongkir: ${rupiah(shipping)}');
    lines.add('Estimasi total: ${rupiah(total)}');
    lines.add('');
    lines.add('Mohon konfirmasi stok, ongkir, dan total akhir. Terima kasih!');
    return lines.join('\n');
  }
}

String rupiah(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return 'Rp $buffer';
}
