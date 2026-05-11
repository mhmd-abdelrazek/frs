import 'package:flutter/material.dart';

class ShowHideWidget extends StatefulWidget {
  /// Was the widget present in the previous frame?
  final bool wasPresent;

  /// Should the widget be visible now?
  final bool isVisible;

  /// Did the content just update? Triggers a brief highlight flash.
  final bool isUpdated;

  final Widget child;
  final Duration duration;
  final Curve curve;
  final AlignmentGeometry alignment;
  final bool animateScale;
  final bool maintainState;

  const ShowHideWidget({
    super.key,
    required this.wasPresent,
    required this.isVisible,
    required this.isUpdated,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.topCenter,
    this.animateScale = false,
    this.maintainState = false,
  });

  @override
  State<ShowHideWidget> createState() => _ShowHideWidgetState();
}

class _ShowHideWidgetState extends State<ShowHideWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flashAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 70),
      ],
    ).animate(CurvedAnimation(parent: _flashController, curve: Curves.easeOut));

    if (widget.isUpdated && widget.isVisible) {
      _flashController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(ShowHideWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUpdated && !oldWidget.isUpdated && widget.isVisible) {
      _flashController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  bool get _shouldMountChild =>
      widget.isVisible || widget.wasPresent || widget.maintainState;

  @override
  Widget build(BuildContext context) {
    if (!_shouldMountChild) {
      return const SizedBox.shrink();
    }

    Widget child = Align(
      alignment: widget.alignment,
      heightFactor: widget.isVisible ? 1.0 : 0.0,
      child: widget.child,
    );

    child = AnimatedOpacity(
      duration: widget.duration,
      curve: widget.curve,
      opacity: widget.isVisible ? 1.0 : 0.0,
      child: child,
    );

    if (widget.animateScale) {
      child = AnimatedScale(
        duration: widget.duration,
        curve: widget.curve,
        scale: widget.isVisible ? 1.0 : 0.9,
        child: child,
      );
    }

    // Wrap with flash overlay when updated
    child = AnimatedBuilder(
      animation: _flashAnimation,
      builder: (context, inner) {
        return Stack(
          children: [
            inner!,
            if (_flashAnimation.value > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(
                        alpha: _flashAnimation.value * 0.15,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: child,
    );

    return Semantics(
      hidden: !widget.isVisible,
      child: AnimatedSize(
        duration: widget.duration,
        curve: widget.curve,
        clipBehavior: Clip.hardEdge,
        child: child,
      ),
    );
  }
}
