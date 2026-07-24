import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared page route: a calm fade + short upward slide, tuned to the system's
/// motion tokens (no bounce).
class PageTransition extends PageRouteBuilder {
  final Widget page;
  final bool reverse;

  PageTransition({required this.page, this.reverse = false})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.06),
              end: Offset.zero,
            ).chain(CurveTween(curve: AppCurves.out)).animate(animation);

            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(position: offsetAnimation, child: child),
            );
          },
          transitionDuration: AppDuration.base,
          reverseTransitionDuration: AppDuration.base,
        );
}
