import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/app_session.dart';
import '../theme/app_colors.dart';

class QrisWebViewScreen extends StatefulWidget {
  final String url;

  const QrisWebViewScreen({super.key, required this.url});

  @override
  State<QrisWebViewScreen> createState() => _QrisWebViewScreenState();
}

class _QrisWebViewScreenState extends State<QrisWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    /// 🔥 PAYMENT SELESAI / USER KELUAR → CLEAR SESSION
    AppSession.clearPayment();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
              'Scan QRIS',
            style: TextStyle(
              color: AppColors.buttonText,
              fontWeight: FontWeight.bold,
            ),
          )
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
