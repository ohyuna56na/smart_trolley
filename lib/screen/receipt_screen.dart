import 'package:flutter/material.dart';

import '../services/app_session.dart';
import '../services/checkout_service.dart';
import '../theme/app_colors.dart';
import '../utils/currency.dart';
import 'home_screen.dart';

class ReceiptScreen extends StatefulWidget {
  final String invoice;
  const ReceiptScreen({super.key, required this.invoice});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final local = await AppSession.loadReceipt();

      Map<String, dynamic>? server;
      try {
        server = await CheckoutService.getReceipt(widget.invoice);
      } catch (_) {}

      setState(() {
        data = {
          'invoice': widget.invoice,
          'customer_name': local['customer_name'],
          'items': local['items'],
          'total': local['total'],
          'payment_method': server?['payment_method'],
        };
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _finish() async {
    await AppSession.clearAll();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    /// =========================
    /// LOADING
    /// =========================
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    /// =========================
    /// ERROR FALLBACK (PAYMENT SUKSES TAPI RECEIPT GAGAL)
    /// =========================
    if (error != null || data == null) {
      return Scaffold(
        appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: const Text(
                'Struk Pembelian',
              style: const TextStyle(
                  color: AppColors.buttonText,
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
            )
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 72, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Payment Successful',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Invoice: ${widget.invoice}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Struk tidak dapat dimuat dari server.\nSilakan hubungi kasir jika diperlukan.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _finish,
                  child: const Text('Selesai Belanja'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// =========================
    /// STRUK NORMAL
    /// =========================
    final items = (data!['items'] ?? []) as List;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
              'Struk Pembelian',
            style: const TextStyle(
                color: AppColors.buttonText,
                fontWeight: FontWeight.bold,
                fontSize: 18
            ),
          )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text(
                    'Invoice',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(data!['invoice'] ?? widget.invoice),
                  const SizedBox(height: 8),

                  if (data!['customer_name'] != null)
                    Text('Customer: ${data!['customer_name']}'),

                  Text('Email: ${data!['customer_email']}'),
                  Text('Phone: ${data!['customer_phone']}'),

                  if (data!['payment_method'] != null)
                    Text('Payment: ${data!['payment_method']}'),

                  const Divider(height: 32),

                  ...items.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${i['qty']} x ${i['name']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(formatRupiah(i['price'])),
                      ],
                    ),
                  )),

                  const Divider(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatRupiah(data!['total']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// =========================
            /// SELESAI
            /// =========================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _finish,
                child: const Text(
                    'Selesai Belanja',
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
    );
  }
}
