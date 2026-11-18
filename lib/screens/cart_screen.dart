import 'package:material_ui/material_ui.dart';
import '../data/products.dart';
import '../state/basket_controller.dart';
import '../theme/bakery_theme.dart';
import '../widgets/bakery_widgets.dart';
import '../widgets/cute_bakery_widgets.dart';
import '../widgets/cute_dashed_frame.dart';
import '../widgets/order_checkout_sheet.dart';
import '../services/order_service.dart';

/// Cart is a real order summary; the approved artwork is only its decoration.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.basket});
  final BasketController basket;

  Future<void> _openCheckout(BuildContext context) async {
    final orderId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderCheckoutSheet(
        basket: basket,
        onSubmit: (details) => OrderService.createOrder(
          basket: basket,
          name: details.name,
          phone: details.phone,
          address: details.address,
          notes: details.notes,
        ),
      ),
    );

   
if (!context.mounted || orderId == null) return;

// Pastikan keranjang kosong setelah checkout sukses.
    await basket.clear();

    if (!context.mounted) return;

// Kembali ke halaman Menu.
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );

  }

  @override
  Widget build(BuildContext context) => BakeryViewport(
        child: Scaffold(
          backgroundColor: BakeryColors.background,
          body: SafeArea(
            child: AnimatedBuilder(
              animation: basket,
              builder: (context, _) => Stack(
                children: [
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFF2DC), Color(0xFFFFE4C3)],
                        ),
                      ),
                    ),
                  ),
                  // Fixed illustrated lower scene; not an item in the scroll list.
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: SizedBox(
                        height: 190,
                        child: PixelAsset(
                          'assets/backgrounds/cart_footer_scene_exact.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _CartHeader(basket: basket)),      
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          child: _CartContents(basket: basket),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _ShippingNotice(basket: basket),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 14)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _OrderSummary(basket: basket),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _CuteCheckoutButton(
                            onTap: basket.itemCount == 0
                                ? null
                                : () => _openCheckout(context),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(28, 10, 28, 0),
                          child: Text(
                            'Demo: pesanan disalin ke clipboard. '
                            'Pembayaran dan pengiriman belum otomatis.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, color: BakeryColors.border),
                          ),
                        ),
                      ),
                      // Space to scroll above the fixed decorative scene.
                      const SliverToBoxAdapter(child: SizedBox(height: 215)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.basket});
  final BasketController basket;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = width * 183 / 579;
      return SizedBox(
        height: height + 15,
        child: Stack(
          children: [
            Positioned.fill(
              bottom: 15,
              child: const PixelAsset(
                'assets/backgrounds/cart_header_decor_no_text.png',
                fit: BoxFit.fill,
              ),
            ),
            // Original back-button drawing already exists in PNG: hitbox only.
            Positioned(
              left: width * 0.052,
              top: height * 0.30,
              width: width * 0.108,
              height: height * 0.34,
              child: Semantics(
                button: true,
                label: 'Kembali ke menu',
                child: InkWell(onTap: () => Navigator.of(context).pop()),
              ),
            ),
            Positioned(
              top: height * 0.40,
              left: width * 0.23,
              right: width * 0.23,
              child: Text(
                'Keranjang',
                textAlign: TextAlign.center,
                maxLines: 1,
                style: BakeryText.heading(width < 380 ? 23 : 27),
              ),
            ),
            Positioned(
              top: height * 0.75,
              left: width * 0.28,
              right: width * 0.28,
              child: Text(
                '${basket.itemCount} item dipilih',
                textAlign: TextAlign.center,
                maxLines: 1,
                style: BakeryText.label(width < 380 ? 11 : 13),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _CartContents extends StatelessWidget {
  const _CartContents({required this.basket});
  final BasketController basket;

  @override
  Widget build(BuildContext context) => CuteFrame(
        asset: 'assets/ui/frames/cart_products_panel_blank.png',
        slice: const Rect.fromLTRB(36, 32, 540, 262),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: basket.itemCount == 0
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Column(
                  children: [
                    const PixelAsset('assets/ui/icons/basket_from_mockup.png', width: 70, height: 70),
                    const SizedBox(height: 10),
                    Text('Keranjangmu masih kosong', style: BakeryText.label(16)),
                    const SizedBox(height: 5),
                    Text('Yuk pilih roti favoritmu dulu!', style: BakeryText.label(12)),
                  ],
                ),
              )
            : Column(
                children: [
                  for (final product in basket.selectedProducts) ...[
                    _CartProduct(product: product, basket: basket),
                    if (product != basket.selectedProducts.last)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: _DashedSeparator(),
                      ),
                  ],
                ],
              ),
      );
}

class _CartProduct extends StatelessWidget {
  const _CartProduct({required this.product, required this.basket});
  final BakeryProduct product;
  final BasketController basket;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 325;
          final qty = basket.quantityOf(product.id);
          return SizedBox(
            height: 100,
            child: Row(
              children: [
                SizedBox(
                  width: compact ? 56 : 68,
                  height: compact ? 56 : 68,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CuteProductPlate(
                        asset: product.asset,
                        size: compact ? 56 : 68,
                      ),
                      Positioned(
                        top: -7,
                        right: -7,
                        child: Material(
                          color: const Color(0xFFFFE8D3),
                          borderRadius: BorderRadius.circular(5),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            onTap: () => basket.removeItem(product.id),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFB47A61),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Color(0xFF8B4938),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: BakeryText.label(compact ? 13 : 16,
                            weight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rupiah(product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: BakeryText.label(compact ? 11 : 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CuteQuantityControl(
                      quantity: qty,
                      compact: true,
                      onPlus: () => basket.increment(product.id),
                      onMinus: () => basket.decrement(product.id),
                    ),
                    const SizedBox(height: 8),
                    Text(rupiah(product.price * qty),
                        style: BakeryText.label(compact ? 11 : 13)),
                  ],
                ),
              ],
            ),
          );
        },
      );
}

class _DashedSeparator extends StatelessWidget {
  const _DashedSeparator();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Row(
          children: List.generate(
            (constraints.maxWidth / 11).floor(),
            (_) => const Padding(
              padding: EdgeInsets.only(right: 5),
              child: SizedBox(
                width: 6,
                height: 1.5,
                child: ColoredBox(color: Color(0xFFD8A584)),
              ),
            ),
          ),
        ),
      );
}

class _ShippingNotice extends StatelessWidget {
  const _ShippingNotice({required this.basket});
  final BasketController basket;

  @override
  Widget build(BuildContext context) {
    const text = 'Setiap pemesan dikenakan ongkir Rp10.000 :3';

    return SizedBox(
      height: 86,
      child: CuteDashedFrame(
        radius: 16,
        backgroundColor: const Color(0xFFF4E5BE),
        outerBorderColor: const Color(0xFFE4A640),
        dashColor: const Color(0xFFD98A34),
        shadowColor: const Color(0x00000000),
        showShadow: false,    
        padding: const EdgeInsets.symmetric(
          horizontal: 26,
          vertical: 12,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              size: 28,
              color: BakeryColors.cocoa,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: BakeryText.label(
                  13,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.basket});
  final BasketController basket;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 166,
        child: CuteFrame(
          asset: 'assets/ui/frames/order_summary_blank.png',
          slice: const Rect.fromLTRB(35, 35, 541, 148),
          padding: const EdgeInsets.fromLTRB(
            24, // Kiri
            20, // Atas
            24, // Kanan
            20, // Bawah
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SummaryRow(
                  'Subtotal (${basket.itemCount} item)', rupiah(basket.subtotal)),
              const SizedBox(height: 10),
              _SummaryRow(
                'Ongkir',
                basket.shipping == 0
                    ? (basket.itemCount == 0 ? rupiah(0) : 'Gratis')
                    : rupiah(basket.shipping),
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xFFCE9B78), height: 1.5, thickness: 1.5),
              const SizedBox(height: 10),
              _SummaryRow('Total Pembayaran', rupiah(basket.total),
                  emphasized: true),
            ],
          ),
        ),
      );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.emphasized = false});
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: BakeryText.label(emphasized ? 14 : 13,
                  weight: emphasized ? FontWeight.w900 : FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: emphasized ? BakeryColors.button : BakeryColors.cocoa,
              fontSize: emphasized ? 18 : 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
}

class _CuteCheckoutButton extends StatelessWidget {
  const _CuteCheckoutButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 62,
            child: CuteDashedFrame(
              radius: 20,
              backgroundColor: const Color(0xFFD6654F),
              outerBorderColor: const Color(0xFF7A342B),
              dashColor: const Color(0xFFFFBE8D),
              shadowColor: const Color(0xFF6A2A23),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 14,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Buat Pesanan',
                    style: BakeryText.label(
                      16,
                      weight: FontWeight.w900,
                    ).copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: Color(0xFFFFD36F),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
