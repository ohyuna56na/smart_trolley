import 'dart:convert';
import 'package:http/http.dart' as http;

class CheckoutService {
  static Future<Map<String, dynamic>> checkoutQris({
    required String deviceId,
    required String name,
    required String email,
    required String phone,
  }) async {
    final res = await http.post(
      Uri.parse('https://iot.sindangraja.com/api/cart/checkout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'device_id': deviceId,
        'payment_method': 'midtrans',
        'customer_name': name,
        'customer_email': email,
        'customer_phone': phone,
      }),
    );

    final data = jsonDecode(res.body);
    print('CHECKOUT RESPONSE: $data');
    if (!data['success']) throw Exception(data['message']);

    return {
      'invoice': data['invoice'],
      'paymentUrl': data['payment_url'],
    };
  }

  static Future<String> checkPaymentStatus(String invoice) async {
    final res = await http.get(
      Uri.parse(
        'https://iot.sindangraja.com/api/payment/status/$invoice',
      ),
    );

    final data = jsonDecode(res.body);
    return data['status'];
  }

  static Future<Map<String, dynamic>> getReceipt(String invoice) async {
    final res = await http.get(
      Uri.parse(
        'https://iot.sindangraja.com/api/payment/receipt/$invoice',
      ),
    );
    return jsonDecode(res.body);
  }
}