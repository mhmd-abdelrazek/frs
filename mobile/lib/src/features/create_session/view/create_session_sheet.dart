import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frs/src/core/flushbars/app_snackbars.dart';
import 'package:frs/src/core/meta/app_colors.dart';
import 'package:frs/src/core/meta/text_styles.dart';
import 'package:frs/src/features/common/widgets/app_text_field.dart';
import 'package:frs/src/features/common/widgets/responsive_safe_area.dart';
import 'package:frs/src/features/common/widgets/responsive_zoom.dart';
import 'package:frs/src/features/common/widgets/save_button.dart';
import 'package:go_router/go_router.dart';

class CreateSessionSheet extends StatefulWidget {
  const CreateSessionSheet({super.key});

  @override
  State<CreateSessionSheet> createState() => _CreateSessionSheetState();
}

class _CreateSessionSheetState extends State<CreateSessionSheet> {
  final TextEditingController name = .new();
  final ValueNotifier<bool> isLoading = .new(false);
  final GlobalKey<FormState> formKey = .new();

  @override
  Widget build(BuildContext context) {
    final form = _buildForm();

    return _SheetContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (_, isLoadingValue, _) => Column(
          mainAxisSize: .min,
          children: [
            IgnorePointer(ignoring: isLoadingValue, child: form),
            const SizedBox(height: 28),
            SaveButton(isLoading: isLoadingValue, onTap: onTapSave),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void onTapSave() async {
    if (isLoading.value) return;
    if (formKey.currentState?.validate() != true) return;
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    await onSubmit();

    isLoading.value = false;
  }

  Future<void> onSubmit() async {
    try {
      await FirebaseFirestore.instance.collection("sessions").add({
        "name": name.text,
        "start_time": Timestamp.fromDate(DateTime.now()),
      });

      if (!mounted) return;

      context.pop();

      AppSnackbars.success(context, message: "Successfully Added!");
    } catch (e) {
      if (!mounted) return;

      AppSnackbars.error(context, message: "Failed to add session");
    }
  }

  Widget _buildForm() {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          const Center(child: _SheetDivider()),
          const SizedBox(height: 25),
          Text("Create New Session", style: TextStyles.nText600),
          const SizedBox(height: 22),
          AppTextField(
            controller: name,
            label: "Session name",
            hint: "Enter Session Name",
            validator: (value) {
              if (value?.isEmpty != false) return "Provide a valid name";
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _SheetContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _SheetContainer({required this.child, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    final EdgeInsets insetsPadding =
        MediaQuery.of(context).viewInsets * ResponsiveZoom.zoom;

    return GestureDetector(
      onTap: context.pop,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IntrinsicHeight(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: padding + insetsPadding,
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: ResponsiveSafeArea(top: false, child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 3.5,
      decoration: BoxDecoration(color: AppColors.text2),
    );
  }
}
