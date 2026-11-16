import 'package:material_ui/material_ui.dart';
import '../theme/bakery_theme.dart';
import 'bakery_widgets.dart';

/// Nine-slice scaling keeps the pixel-art border and corners intact.
/// Content is a live Flutter widget (never baked into the PNG).
class CuteFrame extends StatelessWidget {
  const CuteFrame({
    super.key,
    required this.asset,
    required this.slice,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  final String asset;
  final Rect slice;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: Image.asset(
            asset,
            centerSlice: slice,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
            isAntiAlias: false,
            excludeFromSemantics: true,
          ),
        ),
        Padding(padding: padding, child: child),
      ],
    );
  }
}

class CuteProductPlate extends StatelessWidget {
  const CuteProductPlate({super.key, required this.asset, this.size = 66});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned.fill(
              child: PixelAsset('assets/ui/frames/product_sprite_plate_blank.png', fit: BoxFit.fill),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: PixelAsset(asset, fit: BoxFit.contain),
            ),
          ],
        ),
      );
}

/// All plus and minus symbols are in the new PNG buttons already; DON'T
/// paint another '+' / '-' on top of them (would duplicate their glyphs).
class CuteQuantityControl extends StatelessWidget {
  const CuteQuantityControl({
    super.key,
    required this.quantity,
    required this.onPlus,
    required this.onMinus,
    this.compact = false,
  });

  final int quantity;
  final VoidCallback onPlus;
  final VoidCallback onMinus;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 31.0 : 37.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CuteQtyButton(
          asset: 'assets/ui/buttons/quantity_minus.png',
          label: 'Kurangi jumlah',
          size: size,
          onPressed: quantity > 0 ? onMinus : null,
        ),
        SizedBox(
          width: compact ? 21 : 27,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: BakeryText.label(compact ? 14 : 17, weight: FontWeight.w900),
          ),
        ),
        _CuteQtyButton(
          asset: 'assets/ui/buttons/quantity_plus.png',
          label: 'Tambah jumlah',
          size: size,
          onPressed: onPlus,
        ),
      ],
    );
  }
}

class _CuteQtyButton extends StatelessWidget {
  const _CuteQtyButton({
    required this.asset,
    required this.label,
    required this.size,
    required this.onPressed,
  });

  final String asset;
  final String label;
  final double size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: Opacity(
        opacity: onPressed == null ? .55 : 1,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: PixelAsset(asset, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}