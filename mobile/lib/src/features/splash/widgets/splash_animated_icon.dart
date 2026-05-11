import 'package:flutter/material.dart';
import 'package:frs/src/core/meta/app_assets.dart';

class SplashAnimatedIcon extends StatefulWidget {
  const SplashAnimatedIcon({super.key});

  @override
  State<SplashAnimatedIcon> createState() => _SplashAnimatedIconState();
}

class _SplashAnimatedIconState extends State<SplashAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final List<String> _icons = AppAssets.appIcons.splashIcons;
  static const Duration _duration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _duration)
      ..repeat(reverse: true, );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.5,
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value = Curves.easeOut.transform(_controller.value); // 0 → 1

            final double scaled = value * _icons.length;
            final int index = scaled.floor();
            final double t = scaled - index;

            final current = _icons[index % _icons.length];
            final next = _icons[(index + 1) % _icons.length];

            return Stack(
              children: [
                Positioned.fill(
                  child: Opacity(opacity: 1 - t, child: Image.asset(current)),
                ),
                Positioned.fill(
                  child: Opacity(opacity: t, child: Image.asset(next)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
