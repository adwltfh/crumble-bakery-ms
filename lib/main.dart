import 'package:material_ui/material_ui.dart';
import 'screens/menu_screen.dart';
import 'state/basket_controller.dart';
import 'theme/bakery_theme.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final basket = await BasketController.create();

  runApp(CrumbAndOvenApp(basket: basket));
}


class CrumbAndOvenApp extends StatefulWidget {
  const CrumbAndOvenApp({
    super.key,
    required this.basket,
  });

  final BasketController basket;

  @override
  State<CrumbAndOvenApp> createState() => _CrumbAndOvenAppState();
}


class _CrumbAndOvenAppState extends State<CrumbAndOvenApp> {
  late final BasketController basket = widget.basket;

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
