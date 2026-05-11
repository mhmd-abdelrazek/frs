import 'package:flutter/cupertino.dart';
import 'package:frs/src/core/routing/app_routes.dart';
import 'package:frs/src/features/session/data/models/session_record.dart';
import 'package:frs/src/core/meta/app_colors.dart';
import 'package:frs/src/core/meta/text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SessionRecordWidget extends StatelessWidget {
  final SessionRecord record;

  const SessionRecordWidget({super.key, required this.record});

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return DateFormat('MMM d, yyyy · h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final btnChild = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          // Avatar / Fingerprint badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.contrastBg2.withAlpha(180),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.person_fill,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.name,
                  style: TextStyles.siText600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (record.nationalId != null)
                      _InfoChip(
                        icon: CupertinoIcons.creditcard,
                        label: record.nationalId!,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 11,
                      color: AppColors.text2,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(record.createdAt),
                      style: TextStyles.ssiiText2400,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Edit icon
          GestureDetector(
            onTap: () {
              context.push(AppRoutes.editRecord, extra: {"record": record});
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                CupertinoIcons.pencil,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.contrastBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.contrastBg2.withAlpha(204),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: btnChild,
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.contrastBg2.withAlpha(180),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.text2),
          const SizedBox(width: 3),
          Text(label, style: TextStyles.ssiiText2400),
        ],
      ),
    );
  }
}
