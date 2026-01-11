import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  static const _apiUrl = 'api_url';
  static const _deviceId = 'device_id';
  static const _paymentUrl = 'payment_url';
  static const _paymentPending = 'payment_pending';

  static Future<void> saveCart({
    required String apiUrl,
    required String deviceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiUrl, apiUrl);
    await prefs.setString(_deviceId, deviceId);
  }

  static Future<void> savePayment(String paymentUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paymentUrl, paymentUrl);
    await prefs.setBool(_paymentPending, true);
  }

  static Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'apiUrl': prefs.getString(_apiUrl),
      'deviceId': prefs.getString(_deviceId),
      'paymentUrl': prefs.getString(_paymentUrl),
      'paymentPending': prefs.getBool(_paymentPending) ?? false,
    };
  }

  static Future<void> clearPayment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_paymentUrl);
    await prefs.setBool(_paymentPending, false);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
