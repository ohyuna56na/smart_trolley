import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:smart_trolley/screen/qris_webview_screen.dart';

import '../constants/api_constants.dart';
import '../models/product.dart';
import '../services/app_session.dart';
import '../services/product_service.dart';
import '../theme/app_colors.dart';
import '../utils/currency.dart';

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
              QrisWebViewScreen(
                  url: session['paymentUrl'],
                  invoice: session['invoice'], onPaymentFailed: () {  },
              ),
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
            fontSize: 18,
          ),
        ),
        actions: apiUrl == null
            ? []
            : [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _confirmClearCart,
          ),
        ],
      ),

      body: apiUrl == null ? _buildScanView() : _buildProductView(),
    );
  }

  void _confirmClearCart() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Keranjang'),
        content: const Text('Yakin ingin menghapus semua produk?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearCart();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCart() async {
    if (deviceId == null) return;

    try {
      await ProductService.clearCart(deviceId!);

      setState(() {
        products.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang berhasil dikosongkan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
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

  void increaseQty(int index) async {
    final p = products[index];

    try {
      _timer?.cancel();

      await ProductService.updateQuantity(
        deviceId: deviceId!,
        itemId: p.id,
        quantity: p.qty + 1,
      );

      await fetchProducts();
      startAutoUpdate();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void decreaseQty(int index) async {
    final p = products[index];
    if (p.qty <= 1) return;

    try {
      _timer?.cancel();

      await ProductService.updateQuantity(
        deviceId: deviceId!,
        itemId: p.id,
        quantity: p.qty - 1,
      );

      await fetchProducts();
      startAutoUpdate();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _buildProductImage(Product p) {
    if (p.image == null || p.image!.isEmpty) {
      return const Icon(Icons.inventory, size: 40);
    }

    final imageUrl = '${ApiConstants.baseUrl}storage/${p.image}';

    debugPrint('IMAGE URL: $imageUrl');

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('IMAGE ERROR: $error');
          return const Icon(Icons.inventory, size: 40);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Menunggu produk dimasukkan ke keranjang...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.buttonText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Kembali Scan QR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Kembali ke Scan'),
                  content: const Text(
                    'Keranjang akan dilepas dan bisa dipakai ulang.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        resetCart();
                      },
                      child: const Text('Ya'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// ================== VIEW 2 : PRODUK ==================
  Widget _buildProductView() {
    return Column(
      children: [
        if (isLoading) const LinearProgressIndicator(),

        Expanded(
          child: products.isEmpty
              ? _buildEmptyCartView()
              : ListView.builder(
          itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: _buildProductImage(p),
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
                  : () async {
                final session = await AppSession.load();

                Navigator.pushNamed(
                  context,
                  'order-summary',
                  arguments: {
                    'products': products,
                    'deviceId': session['deviceId'],
                  },
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
