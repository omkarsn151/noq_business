import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/common/app_text_field.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Collects the optional note that goes with a reject or a cancel.
///
/// Returns the trimmed text. Note the two empty answers mean different things:
/// `null` is a dismissed sheet - abort the action - while `''` is a deliberate
/// submit with nothing typed, which the API accepts as "no reason given".
class ReasonBottomSheet {
  ReasonBottomSheet._();

  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? hintText,
    String confirmLabel = 'Submit',
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.13.w)),
      ),
      builder: (_) => _ReasonBody(
        title: title,
        subtitle: subtitle,
        hintText: hintText,
        confirmLabel: confirmLabel,
      ),
    );
  }
}

class _ReasonBody extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? hintText;
  final String confirmLabel;

  const _ReasonBody({
    required this.title,
    required this.subtitle,
    required this.hintText,
    required this.confirmLabel,
  });

  @override
  State<_ReasonBody> createState() => _ReasonBodyState();
}

class _ReasonBodyState extends State<_ReasonBody> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      // Lifts the sheet clear of the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.62.w, 1.42.h, 4.62.w, 2.13.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 10.26.w,
                  height: 0.47.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(0.51.w),
                  ),
                ),
              ),
              SizedBox(height: 1.9.h),
              Text(widget.title, style: textTheme.titleMedium),
              if (widget.subtitle != null) ...[
                SizedBox(height: 0.5.h),
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              SizedBox(height: 2.h),
              AppTextField(
                controller: _controller,
                hintText: widget.hintText ?? 'Add a note (optional)',
                maxLines: 4,
                minLines: 3,
                maxLength: 250,
                textCapitalization: TextCapitalization.sentences,
              ),
              SizedBox(height: 1.h),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: widget.confirmLabel,
                  onPressed: () =>
                      Navigator.pop(context, _controller.text.trim()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
