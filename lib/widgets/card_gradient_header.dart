import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardGradientHeader extends StatelessWidget {
  final Color cardColor;
  final String title;
  final String watermarkChar;
  final double height;
  final double titleFontSize;
  final double watermarkFontSize;

  const CardGradientHeader({
    super.key,
    required this.cardColor,
    required this.title,
    required this.watermarkChar,
    this.height = 120,
    this.titleFontSize = 28,
    this.watermarkFontSize = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor, cardColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 32,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.10,
              child: Text(
                watermarkChar,
                style: TextStyle(
                  fontSize: watermarkFontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -8,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
