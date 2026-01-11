import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  static const _apiUrl = 'apiUrl';
  static const _deviceId = 'deviceId';
  static const _invoice = 'invoice';
  static const _paymentUrl = 'paymentUrl';
  static const _paymentPending = 'paymentPending';

  static Future<void> saveCart({
    required String apiUrl,
    required String deviceId,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_apiUrl, apiUrl);
    await p.setString(_deviceId, deviceId);
  }

  static Future<void> savePayment({
    required String invoice,
    required String paymentUrl,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_invoice, invoice);
    await p.setString(_paymentUrl, paymentUrl);
    await p.setBool(_paymentPending, true);
  }

  static Future<Map<String, dynamic>> load() async {
    final p = await SharedPreferences.getInstance();
    return {
      'apiUrl': p.getString(_apiUrl),
      'deviceId': p.getString(_deviceId),
      'invoice': p.getString(_invoice),
      'paymentUrl': p.getString(_paymentUrl),
      'paymentPending': p.getBool(_paymentPending) ?? false,
    };
  }

  static Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
  }
}
