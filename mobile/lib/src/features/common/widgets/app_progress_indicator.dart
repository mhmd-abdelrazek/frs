import 'package:flutter/material.dart';
import 'package:frs/src/core/meta/app_colors.dart';

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator.adaptive(
      valueColor: AlwaysStoppedAnimation(AppColors.primary),
      strokeWidth: 3,
    );
  }
}
