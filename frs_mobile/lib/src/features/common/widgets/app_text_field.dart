import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frs/src/core/meta/app_colors.dart';
import 'package:frs/src/core/meta/text_styles.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(widget.label!, style: TextStyles.ssiiText700),
          ),
          const SizedBox(height: 6),
        ],

        // Field
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: AppColors.contrastBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary.withAlpha(160)
                  : AppColors.contrastBg2.withAlpha(204),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.text.withAlpha(_isFocused ? 10 : 20),
                blurRadius: _isFocused ? 6 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Prefix icon
              if (widget.prefixIcon != null) ...[
                const SizedBox(width: 12),
                Icon(
                  widget.prefixIcon,
                  size: 18,
                  color: _isFocused ? AppColors.primary : AppColors.text2,
                ),
              ],

              // Text field
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: TextFormField(
                    focusNode: _focusNode,
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    obscureText: widget.obscureText,
                    validator: widget.validator,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: widget.onChanged,
                    maxLines: widget.maxLines,
                    style: TextStyles.siText600,
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: TextStyles.ssiiText2400,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // Suffix icon
              if (widget.suffixIcon != null) ...[
                GestureDetector(
                  onTap: widget.onSuffixTap,
                  child: Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.suffixIcon,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ] else
                const SizedBox(width: 14),
            ],
          ),
        ),
      ],
    );
  }
}
