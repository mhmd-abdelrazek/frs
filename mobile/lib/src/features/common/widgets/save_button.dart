import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frs/src/core/meta/app_colors.dart';
import 'package:frs/src/core/meta/text_styles.dart';
import 'package:frs/src/features/common/widgets/scale_button.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const SaveButton({super.key, this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onTap: isLoading ? () {} : (onTap ?? () {}),
      builder: (context, isPressed) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        decoration: BoxDecoration(
          color: isPressed ? AppColors.darkPrimary : AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(isPressed ? 60 : 100),
              blurRadius: isPressed ? 8 : 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.bg,
                ),
              )
            else ...[
              Icon(CupertinoIcons.checkmark_alt, size: 18, color: AppColors.bg),
              const SizedBox(width: 8),
              Text('Save', style: TextStyles.siiiBg600),
            ],
          ],
        ),
      ),
    );
  }
}
