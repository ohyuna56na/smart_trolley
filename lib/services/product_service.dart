import 'dart:convert';
import 'package:http/http.dart' as http;
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
}
