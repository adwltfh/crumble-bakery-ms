import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';
import 'state/basket_controller.dart';
import 'theme/bakery_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CrumbAndOvenApp());
}

class CrumbAndOvenApp extends StatefulWidget {
  const CrumbAndOvenApp({super.key});

  @override
  State<CrumbAndOvenApp> createState() => _CrumbAndOvenAppState();
}

class _CrumbAndOvenAppState extends State<CrumbAndOvenApp> {
  // Ongkir sementara Rp12.000 untuk <6 item; ubah sesuai ongkir sebenarnya.
  final BasketController basket = BasketController(
    shippingFee: 12000,
    freeShippingAt: 6,
  );

  @override
  void dispose() {
    basket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Crumb & Oven Bakery',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: BakeryColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: BakeryColors.caramel),
    ),
    home: MenuScreen(basket: basket),
  );
}
