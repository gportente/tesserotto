import 'package:flutter/material.dart';

const List<Color> kCardPalette = [
  Color(0xFF4F8FFF),
  Color(0xFF6FE7DD),
  Color(0xFFFFB86B),
  Color(0xFFFC5C7D),
  Color(0xFF43E97B),
  Color(0xFF38F9D7),
  Color(0xFF667EEA),
  Color(0xFF764BA2),
  Color(0xFFFF6A6A),
  Color(0xFF36D1C4),
];

Color cardColorFromName(String name) {
  final hash = name.isNotEmpty ? name.codeUnits.reduce((a, b) => a + b) : 0;
  return kCardPalette[hash % kCardPalette.length];
}
