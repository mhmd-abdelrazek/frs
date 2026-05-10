import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frs/src/core/routing/app_routes.dart';
import 'package:frs/src/features/common/widgets/scale_button.dart';
import 'package:frs/src/core/meta/app_assets.dart';
import 'package:frs/src/core/meta/app_colors.dart';
import 'package:frs/src/core/meta/text_styles.dart';
import 'package:go_router/go_router.dart';

class HomeAppbar extends StatelessWidget {
  final double minHeight;
  final double maxHeight;

  const HomeAppbar({
    super.key,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [_buildTitleBar(), _buildAddSession()],
    );
  }

  Widget _buildTitleBar() {
    return Positioned.fill(
      bottom: null,
      child: SizedBox(
        height: minHeight,
        child: Material(
          color: AppColors.contrastBg,
          elevation: 0.5,
          child: Row(
            children: [
              const SizedBox(width: 8),
              SizedBox.square(
                dimension: 55,
                child: Image.asset(AppAssets.appIcons.transparentIcon),
              ),
              const SizedBox(width: 6),
              Text(
                "FRS Home",
                style: TextStyles.nText600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddSession() {
    const padding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    final sessionIcon = Container(
      height: 72,
      width: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha((0.15 * 255).toInt()),
            AppColors.primary.withAlpha((0.05 * 255).toInt()),
          ],
        ),
      ),
      child: Icon(CupertinoIcons.layers, color: AppColors.primary, size: 32),
    );

    final texts = FractionallySizedBox(
      widthFactor: 0.7,
      child: Column(
        children: [
          Text(
            "Add New Session",
            style: TextStyles.nText600.copyWith(fontSize: 15),
          ),

          const SizedBox(height: 6),

          Text(
            "Create a new session to manage, name, and start registration",
            style: TextStyles.nText600.copyWith(
              fontSize: 12,
              color: AppColors.text2,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double currentHeight = constraints.maxHeight;
          final double ratio =
              ((currentHeight - minHeight) / (maxHeight - minHeight)).clamp(
                0,
                1,
              );
          final width = constraints.maxWidth * ratio + 40 * (1 - ratio);
          final height = 250 * ratio + 40 * (1 - ratio);

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12) * (1 - ratio) +
                (padding + EdgeInsets.only(top: minHeight)) * ratio,
            child: Align(
              alignment:
                  Alignment.bottomCenter * ratio +
                  AlignmentDirectional.centerEnd.resolve(
                        Directionality.of(context),
                      ) *
                      (1 - ratio),
              child: SizedBox(
                width: width,
                height: height,
                child: ScaleButton(
                  pressedScale: 1 - 0.05 * ratio,
                  onTap: () => _onTapAddSession(context),
                  builder: (context, isPressed) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      decoration: BoxDecoration(
                        color: AppColors.contrastBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: isPressed
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.text.withAlpha(
                                    (ratio * 0.05 * 255).toInt(),
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 110,
                            child: Opacity(opacity: ratio, child: texts),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: ratio * 24,
                            child: Opacity(opacity: ratio, child: sessionIcon),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: ratio * (24 + 52),
                            child: Center(
                              child: SizedBox(
                                width: 76,
                                child: Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: SizedBox.square(
                                    dimension: 22 + 20 * (1 - ratio),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Color.lerp(
                                          AppColors.contrastBg,
                                          AppColors.primary,
                                          ratio,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withAlpha(
                                              (0.4 * 255 * ratio).toInt(),
                                            ),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        CupertinoIcons.add,
                                        size: 16,
                                        color: Color.lerp(
                                          AppColors.primary,
                                          AppColors.contrastBg,
                                          ratio,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onTapAddSession(BuildContext context) {
    context.push(AppRoutes.createSession);
  }
}
