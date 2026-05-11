import 'package:flutter/material.dart';

typedef ScaleButtonBuilder =
    Widget Function(BuildContext context, bool isPressed);

class ScaleButton extends StatefulWidget {
  /// Static child widget
  final Widget? child;

  /// Builder function if you want dynamic content depending on press
  final ScaleButtonBuilder? builder;

  /// Tap callback
  final VoidCallback? onTap;

  /// Scale factor when pressed (0 < scale <= 1)
  final double pressedScale;

  /// Animation duration
  final Duration duration;

  /// Animation curve
  final Curve curve;

  const ScaleButton({
    super.key,
    this.child,
    this.builder,
    this.onTap,
    this.pressedScale = 0.95,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeOut,
  }) : assert(
         child != null || builder != null,
         'Provide either child or builder',
       );

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.builder != null
        ? widget.builder!(context, _isPressed)
        : widget.child!;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: widget.curve,
        child: content,
      ),
    );
  }
}
