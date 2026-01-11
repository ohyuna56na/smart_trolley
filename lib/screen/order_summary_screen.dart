import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/app_session.dart';
import '../theme/app_colors.dart';
import '../utils/currency.dart';
import 'payment_screen.dart';

class OrderSummaryScreen extends StatelessWidget {
  final List<Product> products;
  final String deviceId;

  const OrderSummaryScreen({
    super.key,
    required this.products,
    required this.deviceId,
  });

  int get totalPrice {
    return products.fold(
      0,
          (sum, item) => sum + (item.price * item.qty),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.buttonText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ringkasan Pesanan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.buttonText,
          ),
        ),
      ),
      body: Column(
        children: [
          /// LIST RINGKASAN
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('Tidak ada produk'))
                : ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(thickness: 0.5),
              ),
              itemBuilder: (context, index) {
                final p = products[index];
                return ListTile(
                  leading: const Icon(
                    Icons.shopping_cart,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    p.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${p.qty} x ${formatRupiah(p.price)}',
                  ),
                  trailing: Text(
                    formatRupiah(p.qty * p.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          /// TOTAL & PAYMENT
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black12),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Belanja',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatRupiah(totalPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.price,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: products.isEmpty
                        ? null
                        : () async {

                      await AppSession.saveReceiptDraft(
                        items: products.map((p) => {
                          'name': p.name,
                          'qty': p.qty,
                          'price': p.price,
                          'subtotal': p.price * p.qty,
                        }).toList(),
                        total: totalPrice, customerName: '', customerEmail: '', customerPhone: '',
                      );

                      if (!context.mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(deviceId: deviceId),
                        ),
                      );
                    },

                    child: const Text(
                      'Bayar',
                      style: TextStyle(
                        color: AppColors.buttonText,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
