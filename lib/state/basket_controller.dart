import 'package:flutter/foundation.dart';
import '../data/products.dart';

/// UI-only shopping basket. Persists while app is open; no database/backend.
class BasketController extends ChangeNotifier {
  
  BasketController({this.shippingFee = 10000});
  /// Ongkir flat Rp10.000 per pemesan.
  final int shippingFee;

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


  void removeItem(String productId) {
    if (_quantities.remove(productId) != null) {
      notifyListeners();
    }
  }


  int get itemCount => _quantities.values.fold(0, (a, b) => a + b);

  Iterable<BakeryProduct> get selectedProducts =>
      products.where((product) => quantityOf(product.id) > 0);

  int get subtotal => selectedProducts.fold(
        0, (sum, product) => sum + product.price * quantityOf(product.id),
      );
  
  /// Ongkir flat per pesanan, tanpa minimum quantity.
  int get shipping => itemCount == 0 ? 0 : shippingFee;

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
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return 'Rp $buffer';
}
