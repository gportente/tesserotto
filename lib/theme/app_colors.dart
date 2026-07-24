import 'package:flutter/material.dart';

/// Card palette — harmonious, mid-saturation earth tones that sit calmly on the
/// warm-cream Soft & Warm background and always carry white foreground text.
/// (Replaces the old high-saturation "candy" gradient set.)
const List<Color> kCardPalette = [
  Color(0xFFBF5A45), // terracotta
  Color(0xFFA96C3C), // rust
  Color(0xFFA17C34), // ochre
  Color(0xFF71824A), // olive
  Color(0xFF4A8266), // sage
  Color(0xFF3B8380), // teal
  Color(0xFF587C9E), // dusty blue
  Color(0xFF5F5F97), // muted indigo
  Color(0xFF8E5787), // plum
  Color(0xFFB0655F), // rose clay
];

/// Deterministic colour for a card with no explicit colour set.
Color cardColorFromName(String name) {
  final hash = name.isNotEmpty ? name.codeUnits.reduce((a, b) => a + b) : 0;
  return kCardPalette[hash % kCardPalette.length];
}

/// Slightly lightened companion used for the subtle top-down gradient on cards.
Color cardColorLight(Color base) {
  final hsl = HSLColor.fromColor(base);
  return hsl
      .withLightness((hsl.lightness + 0.10).clamp(0.0, 1.0))
      .withSaturation((hsl.saturation - 0.05).clamp(0.0, 1.0))
      .toColor();
}
