import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  static const _apiUrl = 'apiUrl';
  static const _deviceId = 'deviceId';
  static const _invoice = 'invoice';
  static const _paymentUrl = 'paymentUrl';
  static const _paymentPending = 'paymentPending';

  static const _receiptItems = 'receiptItems';
  static const _receiptTotal = 'receiptTotal';

  static const _receiptCustomerName = 'receiptCustomerName';
  static const _receiptCustomerEmail = 'receiptCustomerEmail';
  static const _receiptCustomerPhone = 'receiptCustomerPhone';

  static Future<void> saveCart({
    required String apiUrl,
    required String deviceId,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_apiUrl, apiUrl);
    await p.setString(_deviceId, deviceId);
  }

  static Future<void> clearCartSession() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_apiUrl);
    await p.remove(_deviceId);
  }

  static Future<void> saveReceiptDraft({
    required List<Map<String, dynamic>> items,
    required int total,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    final p = await SharedPreferences.getInstance();

    await p.setString(_receiptItems, jsonEncode(items));
    await p.setInt(_receiptTotal, total);

    await p.setString(_receiptCustomerName, customerName);
    await p.setString(_receiptCustomerEmail, customerEmail);
    await p.setString(_receiptCustomerPhone, customerPhone);
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

  static Future<Map<String, dynamic>> loadReceipt() async {
    final p = await SharedPreferences.getInstance();

    final itemsJson = p.getString(_receiptItems);
    return {
      'items': itemsJson != null ? jsonDecode(itemsJson) : [],
      'total': p.getInt(_receiptTotal) ?? 0,
      'customer_name': p.getString(_receiptCustomerName) ?? '-',
      'customer_email': p.getString(_receiptCustomerEmail) ?? '-',
      'customer_phone': p.getString(_receiptCustomerPhone) ?? '-',
      'invoice': p.getString(_invoice),
    };
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
