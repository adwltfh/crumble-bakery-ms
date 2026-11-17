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
      headers: {
        'Content-Type': 'application/json',
      },
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
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw Exception(
        data['message'] ?? 'Gagal membuat pesanan',
      );
    }

    return data['orderId'] as String;
  }

  static Future<bool> isOrderOpen() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders'),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengecek jadwal pre-order');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return data['open'] == true;
  }
}
