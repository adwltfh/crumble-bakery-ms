import 'package:flutter/material.dart';

abstract final class BakeryColors {
  static const background = Color(0xFFFFEBD1);
  static const cream = Color(0xFFFFF2DD);
  static const panel = Color(0xFFFFE8CA);
  static const panelLight = Color(0xFFFFF5E6);
  static const border = Color(0xFFB17E5C);
  static const cocoa = Color(0xFF572C23);
  static const darkCocoa = Color(0xFF452017);
  static const caramel = Color(0xFFAE6B43);
  static const button = Color(0xFFB95745);
  static const butter = Color(0xFFFFD989);
  static const paleOrange = Color(0xFFFFE3A2);
  static const shadow = Color(0xFF793B2F);
}

abstract final class BakeryText {
  static TextStyle heading(double size) => TextStyle(
    fontFamily: 'Georgia',
    fontSize: size,
    fontWeight: FontWeight.w900,
    height: 1.08,
    color: BakeryColors.cocoa,
  );

  static TextStyle label(double size, {FontWeight weight = FontWeight.w700}) =>
      TextStyle(fontSize: size, fontWeight: weight,
        height: 1.15, color: BakeryColors.cocoa);
}
