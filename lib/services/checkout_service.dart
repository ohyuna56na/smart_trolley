import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class CheckoutService {

  /// CHECKOUT QRIS
  static Future<Map<String, dynamic>> checkoutQris({
    required String deviceId,
    required String name,
    required String email,
    required String phone,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.baseUrl}api/cart/checkout'),
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

    _validateResponse(res);

    final data = jsonDecode(res.body);
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Checkout failed');
    }

    return {
      'invoice': data['invoice'],
      'paymentUrl': data['payment_url'],
    };
  }

  /// CHECK PAYMENT STATUS
  static Future<String> checkPaymentStatus(String invoice) async {
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}api/payment/status/$invoice'),
      headers: {
        'Accept': 'application/json',
      },
    );

    _validateResponse(res);

    final data = jsonDecode(res.body);
    print('CHECKOUT RESPONSE: $data');
    print('PAYMENT URL: ${data['payment_url']}');
    /// completed | pending | failed
    return data['status'] ?? 'pending';
  }

  /// GET RECEIPT (ANTI HTML CRASH)
  static Future<Map<String, dynamic>> getReceipt(String invoice) async {
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}api/payment/status/$invoice'),
      headers: {
        'Accept': 'application/json',
      },
    );

    _validateResponse(res);

    return jsonDecode(res.body);
  }

  /// GLOBAL RESPONSE VALIDATION
  static void _validateResponse(http.Response res) {
    if (res.statusCode != 200) {
      throw Exception('Server error (${res.statusCode})');
    }

    final contentType = res.headers['content-type'] ?? '';
    if (!contentType.contains('application/json')) {
      throw Exception('Invalid response format (not JSON)');
    }

    if (res.body.isEmpty) {
      throw Exception('Empty response from server');
    }
  }
}
