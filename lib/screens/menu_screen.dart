import 'package:material_ui/material_ui.dart';
import '../data/products.dart';
import '../state/basket_controller.dart';
import '../theme/bakery_theme.dart';
import '../widgets/bakery_widgets.dart';
import '../widgets/cute_bakery_widgets.dart';
import 'cart_screen.dart';

/// Cute bakery storefront. All product names, prices, and counts are live.

class MenuScreen extends StatelessWidget {
  const MenuScreen({
    super.key,
    required this.basket,
  });

  final BasketController basket;

  void _openBasket(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScreen(basket: basket),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BakeryViewport(
      child: Scaffold(
        backgroundColor: BakeryColors.background,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: basket,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final heroHeight = (constraints.maxWidth * 393 / 576)
                      .clamp(
                        0.0,
                        constraints.maxHeight * 0.42,
                      )
                      .toDouble();

                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFF5E1BF),
                          Color(0xFFF2E5D3),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // FIXED HEADER
                        SizedBox(
                          height: heroHeight,
                          width: double.infinity,
                          child: const PixelAsset(
                            'assets/hero/bakery_header_and_interior_exact.png',
                            fit: BoxFit.fill,
                          ),
                        ),

                        // SCROLLABLE PRODUCT LIST
                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];

                              return ProductMenuRow(
                                key: ValueKey(product.id),
                                product: product,
                                basket: basket,
                              );
                            },
                          ),
                        ),

                        // FIXED FOOTER
                        SizedBox(
                          height: 126,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              // Bakery floor decoration
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) {
                                      return const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black,
                                          Colors.black,
                                        ],
                                        stops: [
                                          0.0,
                                          0.35,
                                          1.0,
                                        ],
                                      ).createShader(bounds);
                                    },
                                    blendMode: BlendMode.dstIn,
                                    child: const PixelAsset(
                                      'assets/backgrounds/menu_footer_decor_no_button.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),

                              // Floating cart always visible
                              Positioned(
                                left: 23,
                                right: 23,
                                bottom: 18,
                                child: _FloatingBasket(
                                  basket: basket,
                                  onTap: () => _openBasket(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class ProductMenuRow extends StatelessWidget {
  const ProductMenuRow({
    super.key,
    required this.product,
    required this.basket,
  });

  final BakeryProduct product;
  final BasketController basket;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      child: SizedBox(
        height: 108,
        child: CuteFrame(
          asset: 'assets/ui/frames/menu_product_card_blank.png',
          slice: const Rect.fromLTRB(36, 36, 540, 88),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 335;
              final imageSize = compact ? 55.0 : 67.0;
              return Row(
                children: [
                  CuteProductPlate(asset: product.asset, size: imageSize),
                  const SizedBox(width: 8),
                  // Container(
                  //   width: 1.5,
                  //   height: 65,
                  //   color: const Color(0xFFCE9B78),
                  // ),
                  SizedBox(width: compact ? 7 : 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: BakeryText.label(
                            compact ? 13 : 16,
                            weight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          rupiah(product.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BakeryText.label(
                            compact ? 11 : 13,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  CuteQuantityControl(
                    quantity: basket.quantityOf(product.id),
                    compact: true,
                    onPlus: () => basket.increment(product.id),
                    onMinus: () => basket.decrement(product.id),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FloatingBasket extends StatelessWidget {
  const _FloatingBasket({
    required this.basket,
    required this.onTap,
  });

  final BasketController basket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Buka keranjang, ${basket.itemCount} item',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 98,
            child: CustomPaint(
              painter: _BasketFramePainter(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    const PixelAsset(
                      'assets/ui/icons/basket_from_mockup.png',
                      width: 46,
                      height: 46,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 2,
                      height: 48,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6,
                          (index) => Container(
                            width: 2,
                            height: 5,
                            color: const Color(0xFFFFE6C9),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${basket.itemCount} item',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFFFFF6E7),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            rupiah(basket.subtotal),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFFFFF6E7),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const PixelAsset(
                      'assets/ui/icons/arrow_circle.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BasketFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Shadow pixel-style
    final shadow = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 6, width - 4, height - 7),
      const Radius.circular(25),
    );

    canvas.drawRRect(
      shadow,
      Paint()..color = const Color(0xFF50241E),
    );

    // Outer frame
    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, width - 2, height - 7),
      const Radius.circular(25),
    );

    canvas.drawRRect(
      outer,
      Paint()..color = const Color(0xFF50241E),
    );

    // Inner background
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(5, 5, width - 10, height - 15),
      const Radius.circular(21),
    );

    canvas.drawRRect(
      inner,
      Paint()..color = const Color(0xFF904230),
    );

    // Border highlight
    canvas.drawRRect(
      inner,
      Paint()
        ..color = const Color(0xFFBE7956)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Dashed rounded border
    final stitchedPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            16,
            16,
            width - 32,
            height - 37,
          ),
          const Radius.circular(14),
        ),
      );

    final stitchPaint = Paint()
      ..color = const Color(0xFFEDA970)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;

    for (final metric in stitchedPath.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final end = (distance + 6).clamp(0.0, metric.length).toDouble();

        canvas.drawPath(
          metric.extractPath(distance, end),
          stitchPaint,
        );

        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
