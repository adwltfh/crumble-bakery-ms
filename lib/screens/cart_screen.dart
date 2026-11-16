import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/products.dart';
import '../state/basket_controller.dart';
import '../theme/bakery_theme.dart';
import '../widgets/bakery_widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.basket});
  final BasketController basket;

  Future<void> _copyOrder(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: basket.checkoutText));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Detail pesanan disalin. Bisa kamu kirim ke bakery.'),
      backgroundColor: BakeryColors.cocoa,
    ));
  }

  @override
  Widget build(BuildContext context) => BakeryViewport(
    child: Scaffold(
      backgroundColor: BakeryColors.background,
      body: SafeArea(child: AnimatedBuilder(
        animation: basket,
        builder: (context, _) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [          
            
SliverToBoxAdapter(
                  child: SizedBox(
                    height: 174,
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: PixelAsset(
                            'assets/decor/cart_header_backdrop.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            24,
                            40,
                            24,
                            0,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _BackButton(
                                    onTap: () => Navigator.of(context).pop(),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Keranjang',
                                      textAlign: TextAlign.center,
                                      style: BakeryText.heading(29),
                                    ),
                                  ),
                                  const SizedBox(width: 48),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 2,
                                    color: BakeryColors.border,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${basket.itemCount} item dipilih',
                                    style: BakeryText.label(14),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 48,
                                    height: 2,
                                    color: BakeryColors.border,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CartContents(basket: basket),
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ShippingNotice(basket: basket),
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 15)),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _OrderSummary(basket: basket),
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: DecoratedCheckoutButton(
                label: 'Buat Pesanan',
                onPressed: basket.itemCount == 0
                  ? null : () => _copyOrder(context),
              ),
            )),
            const SliverToBoxAdapter(child: Padding(
              padding: EdgeInsets.fromLTRB(18, 7, 18, 26),
              child: Text('Tahap demo: tombol menyalin rincian pesanan. '
                'Belum ada pembayaran atau pengiriman otomatis.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: BakeryColors.border)),
            )),
            const SliverToBoxAdapter(child: PixelAsset(
              'assets/decor/cart_bottom_scene.png', fit: BoxFit.fitWidth)),
          ],
        ),
      )),
    ),
  );
}


class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Kembali ke menu',
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 46,
          decoration: BoxDecoration(
            color: BakeryColors.cream,
            border: Border.all(
              color: BakeryColors.darkCocoa,
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                color: BakeryColors.border,
                offset: Offset(3, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: BakeryColors.cocoa,
          ),
        ),
      ),
    );
  }
}

class _CartContents extends StatelessWidget {
  const _CartContents({required this.basket});
  final BasketController basket;

  @override
  Widget build(BuildContext context) => PixelFrame(
    asset: 'assets/ui/product_row_frame.png',
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
    child: basket.itemCount == 0
      ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 31),
          child: Column(children: [
            const PixelAsset('assets/decor/basket_light.png',
              width: 75, height: 75),
            const SizedBox(height: 12),
            Text('Keranjangmu masih kosong', style: BakeryText.label(16)),
            const SizedBox(height: 4),
            const Text('Yuk pilih rotinya dulu!',
              style: TextStyle(color: BakeryColors.border)),
          ]),
        )
      : Column(children: [
          for (final product in basket.selectedProducts) ...[
            _CartProduct(product: product, basket: basket),
            if (product != basket.selectedProducts.last)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: BakeryColors.border, thickness: 1)),
          ],
        ]),
  );
}

class _CartProduct extends StatelessWidget {
  const _CartProduct({required this.product, required this.basket});
  final BakeryProduct product;
  final BasketController basket;

  @override
  Widget build(BuildContext context) {
    final quantity = basket.quantityOf(product.id);
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 320;
      return SizedBox(
        height: compact ? 100 : 105,
        child: Row(
  children: [
    PixelAsset(product.asset, width: 58, height: 58),
    const SizedBox(width: 14),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            product.name,
            style: BakeryText.label(16, weight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            rupiah(product.price),
            style: BakeryText.label(13, weight: FontWeight.w500),
          ),
        ],
      ),
    ),
    const SizedBox(width: 14),
    QuantityControl(
      quantity: quantity,
      compact: true,
      onPlus: () => basket.increment(product.id),
      onMinus: () => basket.decrement(product.id),
    ),
  ],
),
      );
    });
  }
}

class _ShippingNotice extends StatelessWidget {
  const _ShippingNotice({required this.basket});
  final BasketController basket;

  @override
  Widget build(BuildContext context) {
    final isEmpty = basket.itemCount == 0;
    final message = isEmpty
      ? 'Gratis ongkir untuk pembelian 6 item atau lebih'
      : basket.qualifiesForFreeShipping
        ? 'Gratis ongkir! Pesananmu sudah 6 item atau lebih.'
        : 'Pesanan kurang dari 6 item dikenakan ongkir '
          '${rupiah(basket.shippingFee)}. Tambah '
          '${basket.remainingForFreeShipping} item untuk gratis ongkir.';
    return SizedBox(
      height: 90,
      child: PixelFrame(
        asset: 'assets/ui/shipping_notice_panel.png',
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
        child: Row(children: [
          const PixelAsset('assets/decor/delivery_truck.png',
            width: 46, height: 47),
          const SizedBox(width: 12),
          Expanded(child: Text(message,
            style: BakeryText.label(14, weight: FontWeight.w700))),
        ]),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.basket});
  final BasketController basket;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 180,
    child: PixelFrame(
      asset: 'assets/ui/order_summary_panel.png',
      padding: const EdgeInsets.fromLTRB(21, 15, 21, 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SummaryRow('Subtotal (${basket.itemCount} item)', rupiah(basket.subtotal)),
          const SizedBox(height: 13),
          _SummaryRow('Ongkir', basket.shipping == 0
            ? (basket.itemCount == 0 ? rupiah(0) : 'Gratis')
            : rupiah(basket.shipping)),
          const SizedBox(height: 14),
          const Divider(color: BakeryColors.border, thickness: 1),
          const SizedBox(height: 5),
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
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(label, style: BakeryText.label(emphasized ? 15 : 14,
      weight: emphasized ? FontWeight.w900 : FontWeight.w500))),
    const SizedBox(width: 8),
    Text(value, style: TextStyle(
      color: emphasized ? BakeryColors.button : BakeryColors.cocoa,
      fontSize: emphasized ? 18 : 14,
      fontWeight: FontWeight.w900,
    )),
  ]);
}
