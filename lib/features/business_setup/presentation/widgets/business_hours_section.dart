import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/business_setup/data/business_hour_model.dart';

/// Weekly opening hours editor.
///
/// Renders one collapsible card per day (Sunday first, matching the API's
/// `day_of_week`). Only one day is expanded at a time so the whole week stays
/// scannable, and each expanded day can push its timings onto the rest of the
/// week in a single tap.
class BusinessHoursSection extends StatefulWidget {
  const BusinessHoursSection({
    super.key,
    required this.hours,
    required this.onChanged,
    this.showErrors = false,
  });

  final List<BusinessHourModel> hours;
  final ValueChanged<List<BusinessHourModel>> onChanged;

  /// Set once the user has attempted to submit, so errors aren't shown while
  /// the form is still being filled in.
  final bool showErrors;

  @override
  State<BusinessHoursSection> createState() => _BusinessHoursSectionState();
}

class _BusinessHoursSectionState extends State<BusinessHoursSection> {
  int? _expandedDay;

  void _updateDay(int dayOfWeek, BusinessHourModel updated) {
    final next = [...widget.hours];
    next[dayOfWeek] = updated;
    widget.onChanged(next);
  }

  /// Copies one day's timings onto every other day that is already open.
  /// Closed days stay closed — a business that shuts on Sunday shouldn't have
  /// that undone by a convenience action.
  void _applyToAllOpenDays(BusinessHourModel source) {
    final next = [
      for (final day in widget.hours)
        (day.dayOfWeek == source.dayOfWeek || day.isClosed)
            ? day
            : day.withTimingsOf(source),
    ];
    widget.onChanged(next);
  }

  void _onOpenChanged(BusinessHourModel day, bool isOpen) {
    // Opening a day for the first time seeds sensible defaults so the user only
    // has to adjust, never start from an empty row.
    final updated = isOpen
        ? day.copyWith(
            isClosed: false,
            opensAt: day.opensAt ?? BusinessHourModel.defaultOpensAt,
            closesAt: day.closesAt ?? BusinessHourModel.defaultClosesAt,
          )
        : day.copyWith(isClosed: true);
    _updateDay(day.dayOfWeek, updated);
    setState(() => _expandedDay = isOpen ? day.dayOfWeek : null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final openDays = widget.hours.where((day) => !day.isClosed).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Business Hours', style: theme.textTheme.labelLarge),
            Text(
              openDays == 0 ? 'No open days' : '$openDays of 7 days open',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.75.h),
        for (final day in widget.hours) ...[
          _DayCard(
            day: day,
            isExpanded: _expandedDay == day.dayOfWeek,
            showError: widget.showErrors,
            onToggleExpanded: () {
              setState(() {
                _expandedDay = _expandedDay == day.dayOfWeek
                    ? null
                    : day.dayOfWeek;
              });
            },
            onChanged: (updated) => _updateDay(day.dayOfWeek, updated),
            onOpenChanged: (isOpen) => _onOpenChanged(day, isOpen),
            onApplyToAll: () => _applyToAllOpenDays(day),
          ),
          SizedBox(height: 1.h),
        ],
      ],
    );
  }
}

typedef _PickTime =
    Future<void> Function(
      BuildContext context, {
      required TimeOfDay? initial,
      required TimeOfDay fallback,
      required ValueChanged<TimeOfDay> onPicked,
    });

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.isExpanded,
    required this.showError,
    required this.onToggleExpanded,
    required this.onChanged,
    required this.onOpenChanged,
    required this.onApplyToAll,
  });

  final BusinessHourModel day;
  final bool isExpanded;
  final bool showError;
  final VoidCallback onToggleExpanded;
  final ValueChanged<BusinessHourModel> onChanged;
  final ValueChanged<bool> onOpenChanged;
  final VoidCallback onApplyToAll;

  Future<void> _pickTime(
    BuildContext context, {
    required TimeOfDay? initial,
    required TimeOfDay fallback,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial ?? fallback,
    );
    if (picked != null) onPicked(picked);
  }

  String _workSummary(BuildContext context) {
    if (day.isClosed) return 'Closed';
    if (day.opensAt == null || day.closesAt == null) return 'Timings not set';
    return 'Work Time  ${day.opensAt!.format(context)} - '
        '${day.closesAt!.format(context)}';
  }

  /// The second summary line, shown only when the day has a full break set.
  String? _breakSummary(BuildContext context) {
    if (day.isClosed || day.breakStart == null || day.breakEnd == null) {
      return null;
    }
    return 'Break Time  ${day.breakStart!.format(context)} - '
        '${day.breakEnd!.format(context)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = showError ? day.error : null;
    final isOpen = !day.isClosed;
    final breakSummary = _breakSummary(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: AppColors.textfieldFilledColor,
        border: Border.all(
          color: error != null
              ? AppColors.error
              : (isExpanded ? AppColors.primary : AppColors.borderLight),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: isOpen ? onToggleExpanded : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          day.dayName,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isOpen
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _workSummary(context),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (breakSummary != null)
                          Text(
                            breakSummary,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (isOpen)
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary,
                      size: 5.w,
                    ),
                  Switch(value: isOpen, onChanged: onOpenChanged),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            alignment: Alignment.topCenter,
            child: (isOpen && isExpanded)
                ? _DayCardBody(
                    day: day,
                    onChanged: onChanged,
                    onApplyToAll: onApplyToAll,
                    pickTime: _pickTime,
                  )
                : const SizedBox(width: double.infinity),
          ),
          if (error != null)
            Padding(
              padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 1.h),
              child: Text(
                error,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCardBody extends StatelessWidget {
  const _DayCardBody({
    required this.day,
    required this.onChanged,
    required this.onApplyToAll,
    required this.pickTime,
  });

  final BusinessHourModel day;
  final ValueChanged<BusinessHourModel> onChanged;
  final VoidCallback onApplyToAll;
  final _PickTime pickTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AppColors.borderLight, height: 1),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  label: 'Opens at',
                  value: day.opensAt,
                  onTap: () => pickTime(
                    context,
                    initial: day.opensAt,
                    fallback: BusinessHourModel.defaultOpensAt,
                    onPicked: (time) => onChanged(day.copyWith(opensAt: time)),
                  ),
                ),
              ),
              SizedBox(width: 2.56.w),
              Expanded(
                child: _TimeField(
                  label: 'Closes at',
                  value: day.closesAt,
                  onTap: () => pickTime(
                    context,
                    initial: day.closesAt,
                    fallback: BusinessHourModel.defaultClosesAt,
                    onPicked: (time) => onChanged(day.copyWith(closesAt: time)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          if (!day.hasBreak)
            _InlineAction(
              icon: Icons.add,
              label: 'Add break',
              color: AppColors.primary,
              onTap: () => onChanged(
                day.copyWith(
                  breakStart: BusinessHourModel.defaultBreakStart,
                  breakEnd: BusinessHourModel.defaultBreakEnd,
                ),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: 'Break start',
                    value: day.breakStart,
                    onTap: () => pickTime(
                      context,
                      initial: day.breakStart,
                      fallback: BusinessHourModel.defaultBreakStart,
                      onPicked: (time) =>
                          onChanged(day.copyWith(breakStart: time)),
                    ),
                  ),
                ),
                SizedBox(width: 2.56.w),
                Expanded(
                  child: _TimeField(
                    label: 'Break end',
                    value: day.breakEnd,
                    onTap: () => pickTime(
                      context,
                      initial: day.breakEnd,
                      fallback: BusinessHourModel.defaultBreakEnd,
                      onPicked: (time) =>
                          onChanged(day.copyWith(breakEnd: time)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.5.h),
            _InlineAction(
              icon: Icons.close,
              label: 'Remove break',
              color: AppColors.textSecondary,
              onTap: () => onChanged(day.copyWith(clearBreak: true)),
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onApplyToAll,
              icon: Icon(Icons.copy_all_outlined, size: 4.w),
              label: const Text('Apply to all open days'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                visualDensity: VisualDensity.compact,
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 0.4.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.borderLight, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 4.w,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: Text(
                    value?.format(context) ?? '--:--',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: value == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
