import 'package:material_ui/material_ui.dart';
import '../theme/bakery_theme.dart';
import 'bakery_widgets.dart';

class DecoratedProductFrame extends StatelessWidget {
  const DecoratedProductFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(18, 16, 22, 16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PixelFrame(
          asset: 'assets/ui/frames/cart_products_panel_blank.png',
          padding: padding,
          child: child,
        ),

        // ornamen pojok kiri atas
        const Positioned(
          top: -4,
          left: -2,
          child: _LeafCurl(
            icon: Icons.eco_rounded,
            size: 16,
            rotation: -0.35,
          ),
        ),

        // ornamen pojok kanan bawah
        const Positioned(
          right: 2,
          bottom: -2,
          child: _LeafCurl(
            icon: Icons.local_florist_rounded,
            size: 14,
            rotation: 0.45,
          ),
        ),
      ],
    );
  }
}

class _LeafCurl extends StatelessWidget {
  const _LeafCurl({
    required this.icon,
    required this.size,
    required this.rotation,
  });

  final IconData icon;
  final double size;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size + 8,
        height: size + 8,
        decoration: BoxDecoration(
          color: BakeryColors.background,
          border: Border.all(
            color: BakeryColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: size,
          color: BakeryColors.cocoa,
        ),
      ),
    );
  }
}
