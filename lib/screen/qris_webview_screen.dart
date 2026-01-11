import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/checkout_service.dart';
import 'receipt_screen.dart';

class QrisWebViewScreen extends StatefulWidget {
  final String url;
  final String invoice;
  final VoidCallback onPaymentFailed;

  const QrisWebViewScreen({
    super.key,
    required this.url,
    required this.invoice,
    required this.onPaymentFailed,
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

      if (!mounted) return;

      /// =========================
      /// PAYMENT SUCCESS
      /// =========================
      if (status == 'completed' || status == 'success') {
        _timer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptScreen(invoice: widget.invoice),
          ),
        );
      }

      /// =========================
      /// PAYMENT FAILED / EXPIRED
      /// =========================
      if (status == 'expired' ||
          status == 'cancelled' ||
          status == 'failed' ||
          status == 'deny') {
        _timer?.cancel();
        widget.onPaymentFailed();
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
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) {
                final url = request.url;

                if (url.contains('transaction_status=settlement') ||
                    url.contains('transaction_status=success')) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReceiptScreen(invoice: widget.invoice),
                    ),
                  );
                  return NavigationDecision.prevent;
                }

                if (url.contains('transaction_status=expire') ||
                    url.contains('transaction_status=cancel') ||
                    url.contains('transaction_status=deny') ||
                    url.contains('transaction_status=failure')) {
                  widget.onPaymentFailed();
                  return NavigationDecision.prevent;
                }

                if (url.startsWith('http://example.com')) {
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url)),
      ),
    );
  }
}
