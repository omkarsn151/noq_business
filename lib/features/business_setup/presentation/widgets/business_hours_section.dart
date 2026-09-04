import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_text_field.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/business_setup/data/business_hour_model.dart';

class BusinessHoursSection extends StatelessWidget {
  const BusinessHoursSection({
    super.key,
    required this.selectedDays,
    required this.startTime,
    required this.endTime,
    required this.breakStart,
    required this.breakEnd,
    required this.onDayToggled,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onBreakStartChanged,
    required this.onBreakEndChanged,
    required this.onAddBreak,
    required this.onRemoveBreak,
    this.error,
  });

  final Set<int> selectedDays;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final TimeOfDay? breakStart;
  final TimeOfDay? breakEnd;
  final ValueChanged<int> onDayToggled;
  final ValueChanged<TimeOfDay> onStartChanged;
  final ValueChanged<TimeOfDay> onEndChanged;
  final ValueChanged<TimeOfDay> onBreakStartChanged;
  final ValueChanged<TimeOfDay> onBreakEndChanged;
  final VoidCallback onAddBreak;
  final VoidCallback onRemoveBreak;

  /// Shown under the section once the user has attempted to submit.
  final String? error;

  /// Chip order is Monday-first; the values are the API's `day_of_week`.
  static const List<int> _displayOrder = [1, 2, 3, 4, 5, 6, 0];

  /// Chip captions keyed by `day_of_week` (Sunday 0 … Saturday 6).
  static const List<String> _dayLabels = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thr',
    'Fri',
    'Sat',
  ];

  bool get _hasBreak => breakStart != null || breakEnd != null;

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initial,
    ValueChanged<TimeOfDay> onPicked,
  ) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _RequiredLabel(text: 'Working Days'),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [
            for (final day in _displayOrder)
              _DayChip(
                label: _dayLabels[day],
                isSelected: selectedDays.contains(day),
                onTap: () => onDayToggled(day),
              ),
          ],
        ),
        SizedBox(height: 2.h),
        const _RequiredLabel(text: 'Working Hours'),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: _TimeField(
                label: 'Start Time',
                value: startTime,
                onTap: () => _pickTime(context, startTime, onStartChanged),
              ),
            ),
            SizedBox(width: 2.56.w),
            Expanded(
              child: _TimeField(
                label: 'End Time',
                value: endTime,
                onTap: () => _pickTime(context, endTime, onEndChanged),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        if (!_hasBreak)
          _InlineAction(
            icon: Icons.add,
            label: 'Add break',
            color: AppColors.primary,
            onTap: onAddBreak,
          )
        else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Break Time', style: theme.textTheme.labelLarge),

              _InlineAction(
                icon: Icons.close,
                label: 'Remove break',
                color: AppColors.textSecondary,
                onTap: onRemoveBreak,
              ),
            ],
          ),
          SizedBox(height: 0.6.h),
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  label: 'Break Start',
                  value: breakStart,
                  onTap: () => _pickTime(
                    context,
                    breakStart ?? BusinessHourModel.defaultBreakStart,
                    onBreakStartChanged,
                  ),
                ),
              ),
              SizedBox(width: 2.56.w),
              Expanded(
                child: _TimeField(
                  label: 'Break End',
                  value: breakEnd,
                  onTap: () => _pickTime(
                    context,
                    breakEnd ?? BusinessHourModel.defaultBreakEnd,
                    onBreakEndChanged,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
        ],
        if (error != null) ...[
          SizedBox(height: 1.h),
          Text(
            error!,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        text: text,
        style: theme.textTheme.labelLarge,
        children: [
          TextSpan(
            text: ' *',
            style: theme.textTheme.labelLarge?.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 15.w,
        padding: EdgeInsets.symmetric(vertical: 1.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : AppColors.background,
          borderRadius: BorderRadius.circular(18.sp),
          border: Border.all(
            color: isSelected ? primaryColor : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? theme.colorScheme.onPrimary : primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _InlineAction extends StatelessWidget {
  const _InlineAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.5.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 4.w, color: color),
            SizedBox(width: 1.w),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final TimeOfDay? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? '' : value!.format(context);
    return AppTextField(
      // The field is read-only, so re-seed it via the key whenever the picked
      // time changes.
      key: ValueKey('$label|$text'),
      labelText: label,
      hintText: '--:--',
      initialValue: text,
      readOnly: true,
      onTap: onTap,
      suffixIcon: Icon(
        Icons.access_time,
        size: 4.w,
        color: AppColors.textSecondary,
      ),
    );
  }
}
