import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metode Pembayaran')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('E-Wallet'),
          ),
          ListTile(
            leading: Icon(Icons.credit_card),
            title: Text('Kartu Debit / Kredit'),
          ),
          ListTile(
            leading: Icon(Icons.money),
            title: Text('COD'),
          ),
        ],
      ),
    );
  }
}
