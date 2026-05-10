import 'dart:math';
import 'package:flutter/material.dart';

enum SnackPosition { top, bottom }

class AppSnack {
  static final Map<String, List<_AppSnackEntry>> _entries = {};
  static final _random = Random();

  static void show(
    BuildContext context,
    Widget Function(BuildContext context) builder, {
    String? key,
    Duration displayDuration = const Duration(seconds: 3),
    Duration animationDuration = const Duration(milliseconds: 300),
    SnackPosition position = SnackPosition.bottom,
    double offset = 50,
  }) {
    final safePadding =
        MediaQuery.viewPaddingOf(context) + MediaQuery.viewInsetsOf(context);

    final generatedKey = key ?? _generateRandomKey();
    final overlay = Overlay.of(context);

    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: animationDuration,
    );

    final isBottom = position == SnackPosition.bottom;

    final slide = Tween<Offset>(
      begin: Offset(0, isBottom ? 1 : -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    final scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

    final entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: Align(
          alignment: isBottom ? Alignment.bottomCenter : Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: isBottom ? offset + safePadding.bottom : 0,
              top: isBottom ? 0 : offset + safePadding.top,
            ),
            child: Material(
              color: Colors.transparent,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, child) => SlideTransition(
                  position: slide,
                  child: ScaleTransition(scale: scale, child: child),
                ),
                child: builder(context),
              ),
            ),
          ),
        ),
      ),
    );

    _entries[generatedKey] = [
      ...?_entries[generatedKey],
      _AppSnackEntry(entry, controller),
    ];

    overlay.insert(entry);
    controller.forward();

    Future.delayed(displayDuration + animationDuration, () {
      close(generatedKey);
    });
  }

  static void close(String key) async {
    final entries = _entries.remove(key);
    if (entries != null) {
      for (final entry in entries) {
        await entry.controller.reverse();
        entry.controller.dispose();
        entry.overlayEntry.remove();
      }
    }
  }

  static void closeAll() {
    for (final key in _entries.keys.toList()) {
      close(key);
    }
  }

  static String _generateRandomKey() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        8,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }
}

class _AppSnackEntry {
  final OverlayEntry overlayEntry;
  final AnimationController controller;

  _AppSnackEntry(this.overlayEntry, this.controller);
}
