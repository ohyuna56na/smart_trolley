import 'package:flutter/material.dart';
import 'package:smart_trolley/screen/order_summary_screen.dart';
import 'package:smart_trolley/screen/splash_screen.dart';
import 'package:smart_trolley/theme/app_colors.dart';

import 'models/product.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ummi Mart',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      routes: {
        'order-summary': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>;

          return OrderSummaryScreen(
            products: args['products'] as List<Product>,
            deviceId: args['deviceId'] as String,
          );
        },
      },
      home: const SplashScreen(),
    );
  }
}