import 'package:flutter/material.dart';
import '../models/fidelity_card.dart';

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

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.cardColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: widget.cardColor.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
									decoration: BoxDecoration(
										color: widget.cardColor,
										borderRadius: BorderRadius.circular(28),
										boxShadow: [
											BoxShadow(
												color: widget.cardColor.withOpacity(0.25),
												blurRadius: 16,
												offset: const Offset(0, 8),
											),
										],
									),
									child: Stack(
										children: [
											Positioned(
												left: 16,
												top: 0,
												child: Opacity(
													opacity: 0.08,
													child: Text(
														widget.card.name.isNotEmpty ? widget.card.name[0].toUpperCase() : '?',
														style: const TextStyle(
															fontSize: 120,
															fontWeight: FontWeight.bold,
															letterSpacing: -8,
														),
													),
												),
											),
											if (widget.card.barcode != null)
												Positioned(
													top: 12,
													right: 16,
													child: Container(
														padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
														decoration: BoxDecoration(
															color: Colors.white.withOpacity(0.85),
															borderRadius: BorderRadius.circular(16),
														),
														child: const Row(
															children: [
																Icon(Icons.qr_code, size: 16, color: Colors.black87),
															],
														),
													),
												),
											Center(
												child: Padding(
													padding: const EdgeInsets.symmetric(horizontal: 12.0),
													child: Column(
														mainAxisAlignment: MainAxisAlignment.center,
														children: [
															Text(
																widget.card.name,
																textAlign: TextAlign.center,
																style: const TextStyle(
																	fontSize: 20,
																	fontWeight: FontWeight.bold,
																	color: Colors.white,
																	letterSpacing: 1.2,
																),
																maxLines: 2,
																overflow: TextOverflow.ellipsis,
															),
															if (widget.card.description.isNotEmpty) ...[
																const SizedBox(height: 4),
																Text(
																	widget.card.description,
																	textAlign: TextAlign.center,
																	style: TextStyle(
																		fontSize: 13,
																		color: Colors.white.withOpacity(0.9),
																	),
																	maxLines: 1,
																	overflow: TextOverflow.ellipsis,
																),
															],
														],
													),
												),
											),
										],
									),
								),
              ),
            ),
          ),
        );
      },
    );
  }
} 