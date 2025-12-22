import 'package:flutter/material.dart';

class ColorHelper {
  const ColorHelper._(); // prevents instantiation

  /// Converts a HEX color code (e.g. "#FF5733") into a [Color].
  /// Assumes full opacity.
  static Color fromHex(String hexCode) {
    assert(hexCode.length == 7 && hexCode.startsWith('#'));

    return Color(
      int.parse(
        'FF${hexCode.substring(1)}',
        radix: 16,
      ),
    );
  }

  /// Converts a HEX color code into a [Color] with adjustable opacity.
  ///
  /// [opacityPercent] ranges from 0 (transparent) to 100 (opaque).
  static Color fromHexWithOpacity(
      String hexCode, [
        double opacityPercent = 100,
      ]) {
    assert(hexCode.length == 7 && hexCode.startsWith('#'));
    assert(opacityPercent >= 0 && opacityPercent <= 100);

    final int alpha =
    ((opacityPercent / 100) * 255).round();

    final String alphaHex =
    alpha.toRadixString(16).padLeft(2, '0').toUpperCase();

    return Color(
      int.parse(
        '$alphaHex${hexCode.substring(1)}',
        radix: 16,
      ),
    );
  }
}
