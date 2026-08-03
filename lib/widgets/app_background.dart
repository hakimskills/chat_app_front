import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(gradient: colors.backgroundGradient),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _Orb(color: colors.orbA.withOpacity(0.5), size: 220),
          ),
          Positioned(
            bottom: -100,
            left: -70,
            child: _Orb(color: colors.orbB.withOpacity(0.45), size: 260),
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

class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
              gradient: colors.primaryGradient,
              borderRadius: BorderRadius.circular(size * 0.32),
              boxShadow: [
                BoxShadow(
                  color: colors.primaryEnd.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(Icons.chat_bubble_rounded,
                color: Colors.white, size: size * 0.5),
          ),
          Positioned(
            top: -size * 0.06,
            right: -size * 0.06,
            child: Container(
              width: size * 0.26,
              height: size * 0.26,
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: colors.bgTop, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
