import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';

class CuteDashedFrame extends StatelessWidget {
  const CuteDashedFrame({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.outerBorderColor,
    required this.dashColor,
    this.radius = 18,
    this.padding = const EdgeInsets.all(16),
    this.shadowColor = const Color(0xFF6D3127),
    this.showShadow = true,
  });

  final Widget child;
  final Color backgroundColor;
  final Color outerBorderColor;
  final Color dashColor;
  final double radius;
  final EdgeInsets padding;
  final Color shadowColor;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CuteDashedFramePainter(
        backgroundColor: backgroundColor,
        outerBorderColor: outerBorderColor,
        dashColor: dashColor,
        radius: radius,
        shadowColor: shadowColor,
        showShadow: showShadow,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _CuteDashedFramePainter extends CustomPainter {
  _CuteDashedFramePainter({
    required this.backgroundColor,
    required this.outerBorderColor,
    required this.dashColor,
    required this.radius,
    required this.shadowColor,
    required this.showShadow,
  });

  final Color backgroundColor;
  final Color outerBorderColor;
  final Color dashColor;
  final double radius;
  final Color shadowColor;
  final bool showShadow;

  @override
  void paint(Canvas canvas, Size size) {
    final outerRect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (showShadow) {
      final shadowRRect = RRect.fromRectAndRadius(
        outerRect.shift(const Offset(0, 3)),
        Radius.circular(radius),
      );
      canvas.drawRRect(
        shadowRRect,
        Paint()..color = shadowColor,
      );
    }

    final mainRRect = RRect.fromRectAndRadius(
      outerRect,
      Radius.circular(radius),
    );

    // Fill
    canvas.drawRRect(
      mainRRect,
      Paint()..color = backgroundColor,
    );

    // Outer solid border
    canvas.drawRRect(
      mainRRect.deflate(1),
      Paint()
        ..color = outerBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Inner dashed border
    final dashedRRect = RRect.fromRectAndRadius(
      outerRect.deflate(10),
      Radius.circular(math.max(0, radius - 6)),
    );

    final path = Path()..addRRect(dashedRRect);

    final dashPaint = Paint()
      ..color = dashColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;

    const dashLength = 7.0;
    const dashGap = 5.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = math.min(distance + dashLength, metric.length);
        canvas.drawPath(
          metric.extractPath(distance, next),
          dashPaint,
        );
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CuteDashedFramePainter oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor ||
        outerBorderColor != oldDelegate.outerBorderColor ||
        dashColor != oldDelegate.dashColor ||
        radius != oldDelegate.radius ||
        shadowColor != oldDelegate.shadowColor ||
        showShadow != oldDelegate.showShadow;
  }
}
