import 'package:flutter/material.dart';

import '../services/app_session.dart';
import '../services/checkout_service.dart';
import '../utils/currency.dart';
import 'home_screen.dart';

class ReceiptScreen extends StatefulWidget {
  final String invoice;
  const ReceiptScreen({super.key, required this.invoice});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final _key = GlobalKey();
  bool saved = false;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    data = await CheckoutService.getReceipt(widget.invoice);
    setState(() {});
  }

  Future<void> _finish() async {
    await AppSession.clearAll();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Struk Pembelian')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RepaintBoundary(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invoice ${data!['invoice']}'),
                  Text('Customer: ${data!['customer_name']}'),
                  Text('Total: ${formatRupiah(data!['total'])}'),
                  const Divider(),
                  ...data!['items'].map<Widget>((i) => Text(
                    '${i['qty']} x ${i['name']} = ${formatRupiah(i['price'])}',
                  )),
                  const Divider(),
                  Text(
                    'TOTAL: ${formatRupiah(data!['total'])}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saved ? _finish : null,
              child: const Text('Selesai Belanja'),
            ),
          ],
        ),
      ),
    );
  }
}
