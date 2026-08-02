import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Wraps a screen body with the app's signature backdrop: a soft
/// top-to-bottom gradient with two large, blurred color orbs sitting
/// behind the content. Used on every auth screen so the brand feels
/// consistent without repeating layout code.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _Orb(color: AppColors.orbA.withOpacity(0.55), size: 220),
          ),
          Positioned(
            bottom: -100,
            left: -70,
            child: _Orb(color: AppColors.orbB.withOpacity(0.5), size: 260),
          ),
          child,
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double size;

  const _Orb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

/// The brand mark: a gradient speech-bubble with a small spark dot.
/// Used on the splash screen and the top of the login/register forms.
class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(size * 0.32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryEnd.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(Icons.chat_bubble_rounded, color: Colors.white, size: size * 0.5),
          ),
          Positioned(
            top: -size * 0.06,
            right: -size * 0.06,
            child: Container(
              width: size * 0.26,
              height: size * 0.26,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.bgTop, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
