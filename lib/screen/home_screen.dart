import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/currency.dart';
import 'order_summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [
    Product(
      name: 'Kodomo Tisu Basah Bayi',
      price: 11500,
      image: 'assets/images/logo.png',
    ),
    Product(
      name: 'Alfamart Tisu Wajah',
      price: 24100,
      image: 'assets/images/logo.png',
    ),
    Product(
      name: 'Mama Lemon Sabun Cuci',
      price: 27200,
      image: 'assets/images/logo.png',
    ),
  ];

  int get totalPrice {
    return products.fold(
        0, (sum, item) => sum + (item.price * item.qty));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          product.image,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Rp ${product.price}'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      if (product.qty > 1) {
                                        setState(() => product.qty--);
                                      }
                                    },
                                  ),
                                  Text('${product.qty}'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() => product.qty++);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon:
                          const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => products.removeAt(index));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// Bottom Checkout Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderSummaryScreen(products: products),
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
                      ),
                    ),
                    const Text(
                      'Checkout',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
