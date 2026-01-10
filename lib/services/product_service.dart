import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static const String _baseUrl =
      'https://iot.sindangraja.com/api/cart/IOT-01';

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List items = jsonData['items'];

      return items.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data produk');
    }
  }
}
