import 'package:flutter/material.dart';
import '../data/products.dart';
import '../state/basket_controller.dart';
import '../theme/bakery_theme.dart';
import '../widgets/bakery_widgets.dart';
import 'cart_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, required this.basket});
  final BasketController basket;

  void _openBasket(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => CartScreen(basket: basket),
    ));
  }

  @override
  Widget build(BuildContext context) => BakeryViewport(
    child: Scaffold(
      backgroundColor: BakeryColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: basket,
          builder: (context, _) => Stack(children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: Column(children: [
                  SizedBox(
                    width: double.infinity,
                    child: const PixelAsset('assets/hero/full_header_approved.png',
                      fit: BoxFit.fitWidth),
                  ),
                  const AspectRatio(
                    aspectRatio: 531 / 303,
                    child: PixelAsset('assets/hero/bakery_interior.png',
                      fit: BoxFit.fill),
                  ),
                  const SizedBox(height: 10),
                ])),
                SliverList.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) => ProductMenuRow(
                    key: ValueKey(products[index].id),
                    product: products[index],
                    basket: basket,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 106)),
              ],
            ),
             // Background bata
               Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: SizedBox(
                      height: 120,
                      child: PixelAsset(
                        'assets/decor/menu_footer_bricks.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
            Positioned(left: 14, right: 14, bottom: 12,
              child: _FloatingBasket(
                basket: basket,
                onTap: () => _openBasket(context),
              )),
          ]),
        ),
      ),
    ),
  );
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: SizedBox(
        height: 118,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;

            return PixelFrame(
              asset: 'assets/ui/product_row_frame_vines.png',
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 24 : 28,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Container(
                    width: compact ? 58 : 68,
                    height: compact ? 58 : 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8EEDD),
                      border: Border.all(
                        color: BakeryColors.border,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: PixelAsset(
                      product.asset,
                      width: compact ? 40 : 48,
                      height: compact ? 40 : 48,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Container(
                  //   width: 2,
                  //   height: 62,
                  //   color: BakeryColors.border,
                  // ),
                  const SizedBox(width: 10),
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
                            compact ? 14 : 18,
                            weight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
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
                  const SizedBox(width: 8),
                  QuantityControl(
                    quantity: basket.quantityOf(product.id),
                    compact: true,
                    onPlus: () => basket.increment(product.id),
                    onMinus: () => basket.decrement(product.id),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


class _FloatingBasket extends StatelessWidget {
  const _FloatingBasket({required this.basket, required this.onTap});
  final BasketController basket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Buka keranjang. ${basket.itemCount} item, '
      '${rupiah(basket.subtotal)}',
    child: InkWell(
      onTap: onTap,
      child: Container(
        height: 82,
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Color(0x4D542C20),
            offset: Offset(0, 4), blurRadius: 7)],
        ),
        child: Stack(alignment: Alignment.center, children: [
          const Positioned.fill(child: PixelAsset(
            'assets/ui/floating_cart_bar.png', fit: BoxFit.fill)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 21),
            child: Row(children: [
              const PixelAsset('assets/decor/basket_light.png',
                width: 55, height: 57),
              const SizedBox(width: 9),
              Container(height: 44, width: 1,
                color: const Color(0xFFFFDFBE)),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${basket.itemCount} item',
                    style: const TextStyle(fontSize: 17,
                      color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(rupiah(basket.subtotal),
                    style: const TextStyle(fontSize: 16,
                      color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              )),
              Container(
                height: 43, width: 43,
                decoration: BoxDecoration(color: BakeryColors.panelLight,
                  border: Border.all(color: BakeryColors.darkCocoa, width: 2),
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_forward_rounded,
                  color: BakeryColors.darkCocoa, size: 26),
              ),
            ]),
          ),
        ]),
      ),
    ),
  );
}
