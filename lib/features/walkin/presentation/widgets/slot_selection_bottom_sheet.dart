import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/core/utils/date_formats.dart';
import 'package:noq_business/features/bookings/repository/bookings_repository.dart';
import 'package:noq_business/features/service/data/service_model.dart';
import 'package:noq_business/features/walkin/bloc/walkin_slots_bloc.dart';
import 'package:noq_business/features/walkin/bloc/walkin_slots_event.dart';
import 'package:noq_business/features/walkin/bloc/walkin_slots_state.dart';
import 'package:noq_business/features/walkin/data/walkin_slot_math.dart';
import 'package:noq_business/features/walkin/data/walkin_slot_selection.dart';
import 'package:noq_business/features/walkin/data/walkin_slots_model.dart';
import 'package:noq_business/features/walkin/presentation/widgets/slot_selection_loading_widget.dart';
import 'package:noq_business/features/walkin/repository/walkin_repository.dart';

/// Date + time picker, returning the highlighted run of chips.
///
/// Shared by two flows that read the same slot payload: picking a slot for a
/// new walk-in, and moving an existing booking to a new time.
class SlotSelectionBottomSheet {
  SlotSelectionBottomSheet._();

  /// Slots for a new walk-in covering [services].
  static Future<WalkinSlotSelection?> show(
    BuildContext context, {
    required List<ServiceModel> services,
  }) {
    final serviceIds = services.map((service) => service.id).toList();
    final repository = WalkinRepository();

    return _open(
      context,
      fetchSlots: (date) =>
          repository.getSlots(serviceIds: serviceIds, date: date),
      title: 'Select Slot',
      confirmLabel: 'Confirm Slot',
    );
  }

  /// Slots this booking can be moved to. The services and duration come from
  /// the booking itself, so only its id is needed.
  static Future<WalkinSlotSelection?> showForReschedule(
    BuildContext context, {
    required String bookingId,
  }) {
    final repository = BookingsRepository();

    return _open(
      context,
      fetchSlots: (date) =>
          repository.getRescheduleSlots(bookingId, date: date),
      title: 'Reschedule Booking',
      confirmLabel: 'Confirm New Slot',
    );
  }

  static Future<WalkinSlotSelection?> _open(
    BuildContext context, {
    required SlotsFetcher fetchSlots,
    required String title,
    required String confirmLabel,
  }) {
    return showModalBottomSheet<WalkinSlotSelection>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.13.w)),
      ),
      // A fresh bloc per sheet: the listing is a snapshot with no hold, so it
      // must not be reused across openings or across service changes.
      builder: (_) => BlocProvider<WalkinSlotsBloc>(
        create: (_) =>
            WalkinSlotsBloc(fetchSlots)..add(const WalkinSlotsRequested()),
        child: _SlotSelectionBody(title: title, confirmLabel: confirmLabel),
      ),
    );
  }
}

class _SlotSelectionBody extends StatelessWidget {
  final String title;
  final String confirmLabel;

  const _SlotSelectionBody({required this.title, required this.confirmLabel});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 85.sh,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.62.w, 1.42.h, 4.62.w, 2.13.h),
        child: BlocBuilder<WalkinSlotsBloc, WalkinSlotsState>(
          builder: (context, state) {
            return Column(
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
                Text(title, style: textTheme.titleMedium),
                SizedBox(height: 1.42.h),
                Expanded(child: _SheetContent(state: state)),
                if (state.status == WalkinSlotsStatus.success) ...[
                  Divider(height: 1, color: AppColors.borderLight),
                  SizedBox(height: 1.42.h),
                  _SlotFooter(state: state, confirmLabel: confirmLabel),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SheetContent extends StatelessWidget {
  final WalkinSlotsState state;

  const _SheetContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.status == WalkinSlotsStatus.initial ||
        state.status == WalkinSlotsStatus.loading) {
      return const SlotSelectionLoadingWidget();
    }

    if (state.status == WalkinSlotsStatus.failure) {
      return _SheetError(
        message: state.message,
        onRetry: () =>
            context.read<WalkinSlotsBloc>().add(const WalkinSlotsRetried()),
      );
    }

    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select your date', style: textTheme.titleMedium),
          SizedBox(height: 1.5.h),
          _DateStrip(state: state),
          SizedBox(height: 2.5.h),
          Text('Select Availability Time', style: textTheme.titleMedium),
          if (state.requiredSlots > 1) ...[
            SizedBox(height: 0.5.h),
            Text(
              'This visit needs ${state.requiredSlots} back-to-back slots',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: 1.5.h),
          _TimeSection(state: state),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }
}

class _SheetError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SheetError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 40.sp,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 0.95.h),
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: 1.42.h),
          AppButton(label: 'Retry', onPressed: onRetry),
        ],
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  final WalkinSlotsState state;

  const _DateStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dates = state.model?.window.dates ?? const <WalkinDate>[];

    return SizedBox(
      height: 10.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.date == state.selectedDate;

          final Color background;
          final Color borderColor;
          final Color labelColor;
          if (isSelected) {
            background = AppColors.primary;
            borderColor = AppColors.primary;
            labelColor = AppColors.background;
          } else if (date.isClosed) {
            background = AppColors.borderLight.withValues(alpha: 0.3);
            borderColor = AppColors.borderLight;
            labelColor = AppColors.textSecondary;
          } else {
            background = AppColors.background;
            borderColor = AppColors.borderLight;
            labelColor = AppColors.textSecondary;
          }

          return Padding(
            padding: EdgeInsets.only(right: 1.5.w),
            child: GestureDetector(
              onTap: () => context.read<WalkinSlotsBloc>().add(
                WalkinSlotsDateSelected(date),
              ),
              child: Container(
                width: 14.w,
                decoration: BoxDecoration(
                  color: background,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(20.sp),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.weekday,
                      style: textTheme.bodySmall!.copyWith(color: labelColor),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.background
                            : AppColors.borderLight.withValues(alpha: 0.5),
                      ),
                      child: Text(date.dayNumber, style: textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeSection extends StatelessWidget {
  final WalkinSlotsState state;

  const _TimeSection({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isDayClosed) {
      return const _TimeMessage(message: 'Business is closed on this day');
    }

    if (state.isTimesLoading) {
      return SizedBox(
        height: 20.h,
        child: const SlotTimeGridLoadingWidget(),
      );
    }

    // A date switch that failed - the grid still holds the previous day.
    if (state.message.isNotEmpty) {
      return _TimeMessage(
        message: state.message,
        onRetry: () {
          final dates = state.model?.window.dates ?? const <WalkinDate>[];
          for (final date in dates) {
            if (date.date == state.selectedDate) {
              context.read<WalkinSlotsBloc>().add(
                WalkinSlotsDateSelected(date),
              );
              return;
            }
          }
        },
      );
    }

    if (state.times.isEmpty) {
      return const _TimeMessage(message: 'No slots available for this day');
    }

    return _TimeGrid(state: state);
  }
}

class _TimeMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _TimeMessage({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 15.h,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _TimeGrid extends StatelessWidget {
  final WalkinSlotsState state;

  const _TimeGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final times = state.times;
    final requiredSlots = state.requiredSlots;
    final blockMinutes = state.operations.blockMinutes;
    final selected = state.selectedIndexes;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 1.5.h,
      ),
      itemCount: times.length,
      itemBuilder: (context, index) {
        final slot = times[index];
        final isSelected = selected.contains(index);
        // Only a chip that can carry the whole run is a valid start; a chip
        // already inside the run stays tappable so it can be cleared.
        final canStart = canStartRunAt(
          times,
          index,
          requiredSlots,
          blockMinutes,
        );

        final Color background;
        final Color borderColor;
        final Color labelColor;
        if (isSelected) {
          background = AppColors.primary;
          borderColor = AppColors.primary;
          labelColor = AppColors.background;
        } else if (!canStart) {
          background = AppColors.borderLight.withValues(alpha: 0.3);
          borderColor = AppColors.borderLight;
          labelColor = AppColors.textSecondary;
        } else {
          background = AppColors.background;
          borderColor = AppColors.borderLight;
          labelColor = AppColors.primary;
        }

        return GestureDetector(
          onTap: isSelected
              ? () => context.read<WalkinSlotsBloc>().add(
                  const WalkinSlotSelectionCleared(),
                )
              : canStart
              ? () => context.read<WalkinSlotsBloc>().add(
                  WalkinSlotStartSelected(slot.start!),
                )
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: background,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: Center(
              child: Text(
                formatTime(slot.start),
                style: textTheme.bodySmall!.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SlotFooter extends StatelessWidget {
  final WalkinSlotsState state;
  final String confirmLabel;

  const _SlotFooter({required this.state, required this.confirmLabel});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final summary = state.model?.summary ?? const WalkinSummary();
    final starts = state.selectedStarts;
    final hasFullRun = starts.length == state.requiredSlots;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              summary.priceLabel,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 0.4.h),
            Text(
              '${summary.servicesCount} Services - '
              '${summary.totalDurationMinutes} Min',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(
          width: 45.w,
          height: 5.h,
          child: AppButton(
            label: confirmLabel,
            onPressed: hasFullRun
                ? () => Navigator.pop(
                    context,
                    WalkinSlotSelection(
                      starts: starts,
                      date: state.selectedDate,
                      end: state.selectedEnd,
                    ),
                  )
                : null,
            style: ElevatedButton.styleFrom(
              textStyle: textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
