import 'dart:math' as math;
import 'package:flutter/material.dart';

class ResponsiveZoom extends StatelessWidget {
  final Widget child;
  final bool handleBottomInsets;

  const ResponsiveZoom({
    super.key,
    required this.child,
    this.handleBottomInsets = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewInsets = handleBottomInsets
              ? MediaQuery.viewInsetsOf(context) * zoom
              : EdgeInsets.zero;

          return DefaultTextStyle(
            style: const TextStyle(),
            child: SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: FittedBox(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: (constraints.maxWidth) * (zoom),
                    maxHeight: (constraints.maxHeight) * (zoom),
                  ),
                  child: Padding(padding: viewInsets, child: child),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static double _zoomX() {
    return 440 / _screenSize.width;
  }

  static double _zoomY() {
    return 950 / _screenSize.height;
  }

  static double get zoom {
    return math.sqrt(_zoomX() * _zoomY());
  }

  static double bottomInsets(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom * zoom;
  }

  static Size get _screenSize {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;

    return view.physicalSize / view.devicePixelRatio;
  }
}

class ResponsiveBottomInsets extends StatelessWidget {
  final Widget? child;
  const ResponsiveBottomInsets({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.viewInsetsOf(context) * ResponsiveZoom.zoom;

    return Padding(padding: padding, child: child);
  }
}
