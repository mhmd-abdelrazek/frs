import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frs/src/core/flushbars/app_snack.dart';
import 'package:frs/src/core/meta/app_colors.dart';
import 'package:frs/src/core/meta/text_styles.dart';

class AppSnackbars {
  static void success(
    BuildContext context, {
    required String message,
    String title = 'Success',
  }) {
    _show(
      context,
      title: title,
      message: message,
      icon: CupertinoIcons.checkmark_circle_fill,
      accentColor: const Color(0xFF3DA35D),
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    String title = 'Error',
  }) {
    _show(
      context,
      title: title,
      message: message,
      icon: CupertinoIcons.xmark_circle_fill,
      accentColor: AppColors.primary,
    );
  }

  static void _show(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color accentColor,
  }) {
    AppSnack.show(
      context,
      position: SnackPosition.top,
      offset: 55,
      (ctx) => _SnackCard(
        title: title,
        message: message,
        icon: icon,
        accentColor: accentColor,
      ),
    );
  }
}

class _SnackCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;

  const _SnackCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.contrastBg,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accentColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyles.siText600),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyles.ssiiText2400,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
