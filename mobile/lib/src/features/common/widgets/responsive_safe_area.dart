import 'package:flutter/material.dart';
import 'responsive_zoom.dart';

class ResponsiveSafeArea extends StatefulWidget {
  final Widget? child;
  final bool constPadding;
  final bool top, bottom;

  const ResponsiveSafeArea({
    super.key,
    required this.child,
    this.constPadding = false,
    this.top = true,
    this.bottom = true,
  });

  @override
  State<ResponsiveSafeArea> createState() => _ResponsiveSafeAreaState();

  static EdgeInsets paddingOf(BuildContext context) {
    final viewPadding = MediaQuery.paddingOf(context);
    return viewPadding.copyWith(left: 0, right: 0) * ResponsiveZoom.zoom;
  }
}

class _ResponsiveSafeAreaState extends State<ResponsiveSafeArea> {
  EdgeInsets? _cachedPadding;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.constPadding) {
      _cachedPadding ??= ResponsiveSafeArea.paddingOf(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = widget.constPadding
        ? _cachedPadding!
        : ResponsiveSafeArea.paddingOf(context);

    return Padding(
      padding: padding.copyWith(
        top: widget.top ? null : 0,
        bottom: widget.bottom ? null : 0,
      ),
      child: widget.child,
    );
  }
}
