import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frs/src/core/flushbars/app_snackbars.dart';
import 'package:frs/src/core/meta/app_colors.dart';
import 'package:frs/src/core/meta/text_styles.dart';
import 'package:frs/src/features/common/widgets/app_text_field.dart';
import 'package:frs/src/features/common/widgets/responsive_safe_area.dart';
import 'package:frs/src/features/common/widgets/responsive_zoom.dart';
import 'package:frs/src/features/common/widgets/save_button.dart';
import 'package:frs/src/features/session/data/models/session_record.dart';
import 'package:go_router/go_router.dart';

class EditRecordSheet extends StatefulWidget {
  final SessionRecord record;

  const EditRecordSheet({super.key, required this.record});

  @override
  State<EditRecordSheet> createState() => _EditRecordSheetState();
}

class _EditRecordSheetState extends State<EditRecordSheet> {
  final TextEditingController name = TextEditingController();
  final TextEditingController nationalId = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    name.text = widget.record.name;
    nationalId.text = widget.record.nationalId ?? '';
  }

  @override
  void dispose() {
    name.dispose();
    nationalId.dispose();
    isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = _buildForm();

    return _SheetContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (_, isLoadingValue, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IgnorePointer(ignoring: isLoadingValue, child: form),
              const SizedBox(height: 28),
              SaveButton(isLoading: isLoadingValue, onTap: onTapSave),
              const SizedBox(height: 8),
            ],
          );
        },
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
      if (widget.record.fingerprintId < 0) {
        // Nothing to save — surface this instead of silently succeeding.
        AppSnackbars.error(
          context,
          message: "No fingerprint associated with this record",
        );
        return;
      }

      final fields = {
        "name": name.text.trim(),
        "national_id": nationalId.text.trim(),
      };

      final recordsCollection = FirebaseFirestore.instance.collection(
        "records",
      );

      final query = await recordsCollection
          .where("fingerprint_id", isEqualTo: widget.record.fingerprintId)
          .get();

      final refs = query.docs.isNotEmpty
          ? query.docs.map((d) => d.reference)
          : [recordsCollection.doc(widget.record.id)];

      await Future.wait(refs.map((ref) => ref.update(fields)));

      if (!mounted) return;
      context.pop();
      AppSnackbars.success(context, message: "Record updated successfully");
    } catch (e, st) {
      debugPrint("onSubmit error: $e\n$st");
      if (!mounted) return;
      AppSnackbars.error(context, message: "Failed to update record");
    }
  }

  Widget _buildForm() {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: _SheetDivider()),
          const SizedBox(height: 25),
          Text("Edit Record", style: TextStyles.nText600),
          const SizedBox(height: 22),

          AppTextField(
            controller: name,
            label: "Name",
            hint: "Enter name",
            validator: (value) {
              if (value?.trim().isEmpty != false) {
                return "Provide a valid name";
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          AppTextField(
            controller: nationalId,
            label: "National ID",
            hint: "Enter national ID",
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
