import 'dart:math' as math;
import 'package:flutter/material.dart';

class UpdateMotionWidget extends StatelessWidget {
  final bool isUpdated;
  final Widget child;
  final Duration duration;

  const UpdateMotionWidget({
    super.key,
    required this.isUpdated,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(
        begin: isUpdated ? 1 : 0,
        end: 0,
      ),
      builder: (context, value, child) {
        final shake = math.sin(value * math.pi * 8) * 4 * value;

        return Transform.translate(
          offset: Offset(shake, 0),
          child: AnimatedContainer(
            duration: duration,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                if (value > 0)
                  BoxShadow(
                    blurRadius: 12 * value,
                    spreadRadius: 1 * value,
                    color: Colors.blue.withValues(alpha: 0.35 * value),
                  ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}