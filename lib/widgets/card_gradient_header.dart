import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Warm gradient banner shown at the top of the card detail / add screens.
/// Mirrors the wallet-card language: soft gradient, monogram watermark,
/// title anchored bottom-left.
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
    this.height = 150,
    this.titleFontSize = 28,
    this.watermarkFontSize = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColorLight(cardColor), cardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            bottom: -40,
            child: Text(
              watermarkChar,
              style: TextStyle(
                fontSize: watermarkFontSize,
                fontWeight: FontWeight.w800,
                height: 1,
                color: Colors.white.withOpacity(0.13),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            bottom: AppSpacing.xl,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
