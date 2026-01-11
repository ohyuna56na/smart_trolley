import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:smart_trolley/screen/qris_webview_screen.dart';

import '../models/product.dart';
import '../services/app_session.dart';
import '../services/product_service.dart';
import '../theme/app_colors.dart';
import '../utils/currency.dart';
import 'order_summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? apiUrl;
  String? deviceId;
  List<Product> products = [];
  bool isLoading = false;
  Timer? _timer;

  /// FETCH DATA PRODUK DARI API QR
  Future<void> fetchProducts() async {
    if (apiUrl == null) return;

    try {
      final data = await ProductService.fetchProducts(apiUrl!);
      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => isLoading = false);
    }
    debugPrint('API URL: $apiUrl');
  }

  /// AUTO REFRESH (IoT polling)
  void startAutoUpdate() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => fetchProducts(),
    );
  }

  /// RESET KE AWAL
  void resetCart() {
    _timer?.cancel();
    setState(() {
      apiUrl = null;
      products.clear();
    });
  }

  /// TOTAL HARGA
  int get totalPrice =>
      products.fold(0, (sum, p) => sum + p.price * p.qty);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final session = await AppSession.load();

    if (session['paymentPending'] == true &&
        session['paymentUrl'] != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              QrisWebViewScreen(url: session['paymentUrl']),
        ),
      );
      return;
    }

    if (session['apiUrl'] != null && session['deviceId'] != null) {
      setState(() {
        apiUrl = session['apiUrl'];
        deviceId = session['deviceId'];
        isLoading = true;
      });
      fetchProducts();
      startAutoUpdate();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          apiUrl == null ? 'Smart Trolley' : 'Daftar Produk',
          style: const TextStyle(
            color: AppColors.buttonText,
            fontWeight: FontWeight.bold,
            fontSize: 18
          ),
        ),
      ),
      body: apiUrl == null ? _buildScanView() : _buildProductView(),
    );
  }

  /// ================== VIEW 1 : SCAN QR ==================
  Widget _buildScanView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart, size: 120),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('SCAN QR KERANJANG'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AiBarcodeScanner(
                    onDetect: (capture) async {
                      final code = capture.barcodes.first.rawValue;
                      if (code == null) return;

                      final uri = Uri.parse(code);
                      final scannedDeviceId = uri.pathSegments.last;

                      await AppSession.saveCart(
                        apiUrl: code,
                        deviceId: scannedDeviceId,
                      );

                      if (!mounted) return;

                      setState(() {
                        apiUrl = code;
                        deviceId = scannedDeviceId;
                        isLoading = true;
                      });

                      fetchProducts();
                      startAutoUpdate();

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void increaseQty(int index) {
    setState(() {
      products[index].qty++;
    });
  }

  void decreaseQty(int index) {
    setState(() {
      if (products[index].qty > 1) {
        products[index].qty--;
      }
    });
  }

  /// ================== VIEW 2 : PRODUK ==================
  Widget _buildProductView() {
    return Column(
      children: [
        if (isLoading) const LinearProgressIndicator(),

        Expanded(
          child: products.isEmpty
              ? const Center(
            child: Text(
              'Menunggu produk dimasukkan ke keranjang...',
            ),
          )
              : ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.inventory),
                  title: Text(p.name),
                  subtitle: Text(formatRupiah(p.price)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// BUTTON -
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => decreaseQty(index),
                      ),

                      /// QTY
                      Text(
                        '${p.qty}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      /// BUTTON +
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => increaseQty(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        /// CHECKOUT
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
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
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        OrderSummaryScreen(products: products, deviceId: deviceId!),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatRupiah(totalPrice),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.buttonText,
                    ),
                  ),
                  const Text(
                    'Checkout',
                    style: TextStyle(
                      color: AppColors.buttonText,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
