import 'package:flutter/material.dart';
import '../services/app_session.dart';
import '../theme/app_colors.dart';
import 'qris_webview_screen.dart';
import '../services/checkout_service.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';


class PaymentScreen extends StatefulWidget {
  final String deviceId;
  const PaymentScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  Future<void> _payWithQris() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final receipt = await AppSession.loadReceipt();

      final List<Map<String, dynamic>> items =
      List<Map<String, dynamic>>.from(
        (receipt['items'] as List).map(
              (e) => Map<String, dynamic>.from(e),
        ),
      );

      await AppSession.saveReceiptDraft(
        items: items,
        total: receipt['total'] as int,
        customerName: _nameController.text,
        customerEmail: _emailController.text,
        customerPhone: _phoneController.text,
      );

      final result = await CheckoutService.checkoutQris(
        deviceId: widget.deviceId,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );

      await AppSession.savePayment(
        invoice: result['invoice'],
        paymentUrl: result['paymentUrl'],
      );

      final url = Uri.parse(result['paymentUrl']);

      if (kIsWeb) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QrisWebViewScreen(
            url: result['paymentUrl'],
            invoice: result['invoice'],
            onPaymentFailed: () {
              Navigator.popUntil(
                context,
                    (route) => route.settings.name == 'order-summary',
              );
            },
          ),
        ),
      );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
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
              'Data Pembeli',
            style: TextStyle(
              color: AppColors.buttonText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// NAMA
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pembeli',
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              /// EMAIL
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email wajib diisi';
                  if (!v.contains('@')) return 'Email tidak valid';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              /// TELP
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'No. Telepon',
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'No. telp wajib diisi' : null,
              ),

              const SizedBox(height: 24),

              /// BUTTON BAYAR
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _payWithQris,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                      'Bayar dengan E-Wallet',
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
      ),
    );
  }
}
