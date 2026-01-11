import 'dart:convert';
import 'package:http/http.dart' as http;

class CheckoutService {
  static Future<String> checkoutQris({
    required String deviceId,
    required String name,
    required String email,
    required String phone,
  }) async {
    final response = await http.post(
      Uri.parse('https://iot.sindangraja.com/api/cart/checkout'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'device_id': deviceId,
        'payment_method': 'midtrans',
        'customer_name': name,
        'customer_email': email,
        'customer_phone': phone,
      }),
    );

    final data = jsonDecode(response.body);
    print('CHECKOUT RESPONSE: $data');

    if (response.statusCode == 200 && data['success'] == true) {
      final paymentUrl = data['payment_url'];

      if (paymentUrl == null || paymentUrl.toString().isEmpty) {
        throw Exception('Payment URL tidak ditemukan dari API');
      }

      return paymentUrl;
    } else {
      throw Exception(data['message'] ?? 'Checkout QRIS gagal');
    }
  }
}
