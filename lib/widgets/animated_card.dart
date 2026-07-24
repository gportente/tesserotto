import 'package:flutter/material.dart';
import '../models/fidelity_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// A loyalty-card tile: soft gradient, monogram watermark, name anchored
/// bottom-left like a real wallet card. Enters with a calm fade+scale (no
/// bounce) and gives tactile press feedback.
class AnimatedCard extends StatefulWidget {
  final FidelityCard card;
  final Color cardColor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const AnimatedCard({
    super.key,
    required this.card,
    required this.cardColor,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDuration.base,
      vsync: this,
    );
    _scale = Tween<double>(begin: 0.96, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: AppCurves.out));
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final color = widget.cardColor;
    final initial = widget.card.name.isNotEmpty
        ? widget.card.name[0].toUpperCase()
        : '?';

    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: AppDuration.fast,
            curve: AppCurves.out,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cardColorLight(color), color],
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadow.tinted(color, dark: isDark),
              ),
              child: Stack(
                children: [
                  // Monogram watermark, bottom-right.
                  Positioned(
                    right: -12,
                    bottom: -28,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 128,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        color: Colors.white,
                      ).copyWith(color: Colors.white.withOpacity(0.14)),
                    ),
                  ),

                  // Top row: barcode type chip + favourite star.
                  Positioned(
                    top: AppSpacing.md,
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Row(
                      children: [
                        if (widget.card.barcode != null)
                          _TypePill(type: widget.card.barcodeType),
                        const Spacer(),
                        if (widget.card.isFavorite)
                          Icon(Icons.star_rounded,
                              color: Colors.white.withOpacity(0.95), size: 20),
                      ],
                    ),
                  ),

                  // Name + description, anchored bottom-left.
                  Positioned(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.card.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.card.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.card.description,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withOpacity(0.85),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A translucent pill on the card marking that a code is stored.
class _TypePill extends StatelessWidget {
  final String? type;
  const _TypePill({this.type});

  bool get _is2d => const {'qrCode', 'aztec', 'dataMatrix', 'pdf417'}
      .contains(type);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Icon(
        _is2d ? Icons.qr_code_rounded : Icons.barcode_reader,
        size: 15,
        color: Colors.white,
      ),
    );
  }
}
