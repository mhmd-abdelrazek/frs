import 'package:flutter/cupertino.dart';
import 'package:frs/src/features/common/widgets/scale_button.dart';
import 'package:frs/src/features/home/data/models/session.dart';
import 'package:frs/src/core/meta/app_colors.dart';
import 'package:frs/src/core/meta/text_styles.dart';
import 'package:frs/src/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SessionWidget extends StatelessWidget {
  final Session session;
  const SessionWidget({super.key, required this.session});

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return DateFormat('MMM d, yyyy · h:mm a').format(date);
  }

  void onTap(BuildContext context) {
    context.push(AppRoutes.session, extra: {"session": session});
  }

  @override
  Widget build(BuildContext context) {
    final btnChild = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  style: TextStyles.siText600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 12,
                      color: AppColors.text2,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(session.createdAt),
                      style: TextStyles.ssiiText2400,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Trailing icon
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              CupertinoIcons.chevron_forward,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );

    return ScaleButton(
      onTap: () => onTap(context),
      builder: (context, isPressed) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.contrastBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPressed
                ? AppColors.primary.withAlpha(122)
                : AppColors.contrastBg2.withAlpha(204),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.text.withAlpha(isPressed ? 10 : 20),
              blurRadius: isPressed ? 6 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: btnChild,
      ),
    );
  }
}
