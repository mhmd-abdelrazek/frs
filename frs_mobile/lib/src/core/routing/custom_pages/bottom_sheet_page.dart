import 'package:flutter/material.dart';

class BottomSheetPage<T> extends Page<T> {
  final Widget child;

  const BottomSheetPage({required this.child, super.key});

  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      settings: this,
      isScrollControlled: true,
      builder: (_) => child,
    );
  }
}
