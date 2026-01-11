import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/checkout_service.dart';
import 'receipt_screen.dart';

class QrisWebViewScreen extends StatefulWidget {
  final String url;
  final String invoice;

  const QrisWebViewScreen({
    super.key,
    required this.url,
    required this.invoice,
  });

  @override
  State<QrisWebViewScreen> createState() => _QrisWebViewScreenState();
}

class _QrisWebViewScreenState extends State<QrisWebViewScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final status =
      await CheckoutService.checkPaymentStatus(widget.invoice);

      if (status == 'success') {
        _timer?.cancel();
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ReceiptScreen(invoice: widget.invoice),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QRIS')),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(widget.url)),
      ),
    );
  }
}
