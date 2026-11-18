import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import '../data/products.dart';

/// Crumb & Oven cart storage rules:
/// - survives navigation and page refresh in the same tab;
/// - resets after the browser tab session ends;
/// - resets on the first page load of a new APP_BUILD_ID;
/// - resets after successful checkout via clear().
///
/// This controller is intended for Flutter Web only.
class BasketController extends ChangeNotifier {
  BasketController({this.shippingFee = 10000});

  static const String _cartKey = 'crumb_oven_cart_session_v1';
  static const String _buildKey = 'crumb_oven_cart_build_id';
  static const String _buildId = String.fromEnvironment(
    'APP_BUILD_ID',
    defaultValue: 'local-dev',
  );

  final int shippingFee;
  final Map<String, int> _quantities = <String, int>{};

  /// Keep the async factory used by the existing main.dart.
  static Future<BasketController> create() async {
    final controller = BasketController();
    controller._restore();
    return controller;
  }

  void _restore() {
    // Erase data from the previous shared_preferences implementation.
    // Do not clear other website storage keys.
    try {
      final oldStorage = web.window.localStorage;
      oldStorage.removeItem('flutter.crumb_oven_basket_v1');
      oldStorage.removeItem('crumb_oven_basket_v1');
    } catch (_) {
      // Browser may block persistent storage; in-memory cart still works.
    }

    try {
      final session = web.window.sessionStorage;
      final storedBuild = session.getItem(_buildKey);
      if (storedBuild != _buildId) {
        session.removeItem(_cartKey);
        session.setItem(_buildKey, _buildId);
        return;
      }

      final raw = session.getItem(_cartKey);
      if (raw == null || raw.isEmpty) return;

      final saved = jsonDecode(raw);
      if (saved is! Map) return;

      for (final product in products) {
        final rawQuantity = saved[product.id];
        if (rawQuantity is int && rawQuantity > 0) {
          _quantities[product.id] = rawQuantity;
        }
      }
    } catch (_) {
      // Keep basket empty when storage is unavailable/corrupt.
      _quantities.clear();
    }
  }

  void _save() {
    try {
      final session = web.window.sessionStorage;
      session.setItem(_buildKey, _buildId);
      if (_quantities.isEmpty) {
        session.removeItem(_cartKey);
      } else {
        session.setItem(_cartKey, jsonEncode(_quantities));
      }
    } catch (_) {
      // Allow ordering in environments where storage is blocked.
    }
  }

  int quantityOf(String productId) => _quantities[productId] ?? 0;

  void increment(String productId) {
    if (!products.any((product) => product.id == productId)) return;
    _quantities.update(productId, (value) => value + 1, ifAbsent: () => 1);
    _save();
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
    _save();
    notifyListeners();
  }

  void removeItem(String productId) {
    if (_quantities.remove(productId) == null) return;
    _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _quantities.clear();
    _save();
    notifyListeners();
  }

  int get itemCount => _quantities.values.fold(0, (a, b) => a + b);

  Iterable<BakeryProduct> get selectedProducts =>
      products.where((product) => quantityOf(product.id) > 0);

  int get subtotal => selectedProducts.fold(
        0,
        (sum, product) => sum + product.price * quantityOf(product.id),
      );

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
    lines.add('Total: ${rupiah(total)}');
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
