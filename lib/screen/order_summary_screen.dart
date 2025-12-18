import 'package:flutter/material.dart';
import '../models/product.dart';
import 'payment_screen.dart';

class OrderSummaryScreen extends StatelessWidget {
  final List<Product> products;

  const OrderSummaryScreen({super.key, required this.products});

  int get totalPrice {
    return products.fold(
        0, (sum, item) => sum + (item.price * item.qty));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Pesanan')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: products.map((p) {
                return ListTile(
                  leading: Image.asset(p.image, width: 50),
                  title: Text(p.name),
                  subtitle: Text('${p.qty} x Rp ${p.price}'),
                  trailing: Text('Rp ${p.qty * p.price}'),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Belanja',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Rp $totalPrice',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PaymentScreen()),
                    );
                  },
                  child: const Text('Pilih Metode Pembayaran'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
