import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/product.dart';

class ProductService {
  static Future<List<Product>> fetchProducts(String apiUrl) async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List items = jsonData['items'];

      return items
          .map<Product>((e) => Product.fromJson(e))
          .toList();
    } else {
      throw Exception('Gagal mengambil data produk');
    }
  }

  static Future<void> clearCart(String deviceId) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}api/cart/clear'),
      body: {
        'device_id': deviceId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus keranjang');
    }
  }

  static Future<void> updateQuantity({
    required String deviceId,
    required int itemId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}api/cart/update-quantity'),
      body: {
        'device_id': deviceId,
        'item_id': itemId.toString(),   // ⬅️ Product.id
        'quantity': quantity.toString(),
      },
    );

    print('UPDATE QTY RESPONSE: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal update quantity');
    }

    final json = jsonDecode(response.body);
    if (json['success'] != true) {
      throw Exception(json['message'] ?? 'Update gagal');
    }
  }
}
