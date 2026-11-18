import 'dart:convert';

import 'package:http/http.dart' as http;

import '../state/basket_controller.dart';

class OrderService {
  static const String baseUrl = String.fromEnvironment(
    'ORDER_API_URL',
    defaultValue: 'http://localhost:3000',
  );

  static Future<String> createOrder({
    required BasketController basket,
    required String name,
    required String phone,
    required String address,
    String notes = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'address': address,
        'notes': notes,
        'items': [
          for (final product in basket.selectedProducts)
            {
              'id': product.id,
              'quantity': basket.quantityOf(product.id),
            },
        ],
      }),
    ).timeout(const Duration(seconds: 25));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Respons server tidak valid (${response.statusCode}).');
    }

    if (response.statusCode != 201) {
      throw Exception(data['message']?.toString() ??
          'Gagal menyimpan pesanan (${response.statusCode}).');
    }
    if (data['success'] != true || data['orderId'] is! String) {
      throw Exception('Server tidak mengirimkan Order ID.');
    }
    return data['orderId'] as String;
  }
}
