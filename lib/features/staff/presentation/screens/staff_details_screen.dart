import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_snackbar.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/core/utils/date_formats.dart';
import 'package:noq_business/features/staff/bloc/staff_details_bloc.dart';
import 'package:noq_business/features/staff/bloc/staff_details_event.dart';
import 'package:noq_business/features/staff/bloc/staff_details_state.dart';
import 'package:noq_business/features/staff/data/staff_profile_model.dart';
import 'package:noq_business/features/staff/presentation/widgets/staff_details_loading_widget.dart';

/// Shared card look - matches [StaffListCard] and the dashboard cards.
BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(4.w),
    border: Border.all(color: AppColors.borderLight),
    boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 12)],
  );
}

/// One person's profile - who they are, their hours, the services they cover,
/// and today's full schedule. All of it arrives in a single call, so there is
/// nothing more to fetch for the schedule.
class StaffDetailsScreen extends StatefulWidget {
  final String staffId;

  const StaffDetailsScreen({super.key, required this.staffId});

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => context.read<StaffDetailsBloc>().add(
    StaffDetailsRequested(staffId: widget.staffId),
  );

  /// Null only on a failed first load - a failed toggle keeps the profile
  /// around so the switch can snap back instead of losing the whole page.
  StaffProfileModel? _profileOf(StaffDetailsState state) {
    if (state is StaffDetailsSuccess) return state.profile;
    if (state is StaffDetailsFailure) return state.profile;
    return null;
  }

  /// The edit screen writes through [AddStaffBloc] and refreshes the staff
  /// list itself, so this only has to re-read the profile on the way back.
  Future<void> _openEdit(StaffProfileStaff staff) async {
    await context.push('/add-staff', extra: staff.toStaffModel());
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffDetailsBloc, StaffDetailsState>(
      listener: (context, state) {
        // A failure with the profile still loaded can only be the Active
        // toggle - the switch has already snapped back, so just say why.
        if (state is StaffDetailsFailure && state.profile != null) {
          AppSnackbar.error(context, state.message);
        }
      },
      builder: (context, state) {
        final profile = _profileOf(state);

        return Scaffold(
          appBar: AppAppBar(
            title: 'Staff Profile',
            actions: [
              if (profile != null)
                Padding(
                  padding: EdgeInsets.only(right: 3.w),
                  child: IconButton(
                    tooltip: 'Edit',
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                    onPressed: () => _openEdit(profile.staff),
                  ),
                ),
            ],
          ),
          body: SafeArea(child: _body(state)),
        );
      },
    );
  }

  Widget _body(StaffDetailsState state) {
    if (state is StaffDetailsInitial || state is StaffDetailsLoading) {
      return const StaffDetailsLoadingWidget();
    }

    final profile = _profileOf(state);
    if (profile == null) {
      return _StaffDetailsMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load profile',
        hint: (state as StaffDetailsFailure).message,
        actionLabel: 'Retry',
        onAction: _reload,
        onRefresh: _reload,
      );
    }

    final isTogglingActive =
        state is StaffDetailsSuccess && state.isTogglingActive;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _reload(),
      child: ListView(
        padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 4.h),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          _ProfileHeader(
            staff: profile.staff,
            isBusy: isTogglingActive,
            onActiveChanged: (value) =>
                context.read<StaffDetailsBloc>().add(
                  StaffActiveToggled(staffId: widget.staffId, isActive: value),
                ),
          ),
          SizedBox(height: 3.h),
          const _SectionTitle('Availability'),
          SizedBox(height: 1.5.h),
          _AvailabilityCard(staff: profile.staff),
          SizedBox(height: 3.h),
          const _SectionTitle('Services'),
          SizedBox(height: 1.5.h),
          _ServicesSection(services: profile.staff.services),
          SizedBox(height: 3.h),
          const _SectionTitle("Today's Bookings"),
          SizedBox(height: 1.5.h),
          _TodaysBookingsSection(bookings: profile.todaysBookings),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.bodyLarge);
  }
}

/// Avatar, name and the Active switch that takes them in and out of bookings.
class _ProfileHeader extends StatelessWidget {
  final StaffProfileStaff staff;
  final bool isBusy;
  final ValueChanged<bool> onActiveChanged;

  const _ProfileHeader({
    required this.staff,
    required this.isBusy,
    required this.onActiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(3.5.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _Avatar(url: staff.photoUrl),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Text(
              staff.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge,
            ),
          ),
          SizedBox(width: 1.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    staff.isActive ? 'Active' : 'Inactive',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Switch(
                    value: staff.isActive,
                    // Disabled while the PATCH is in flight - the switch is
                    // already showing the value we asked for.
                    onChanged: isBusy ? null : onActiveChanged,
                  ),
                ],
              ),
              Text(
                staff.isActive
                    ? 'Available for bookings'
                    : 'Not taking bookings',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Working hours and the break, straight off the staff record.
class _AvailabilityCard extends StatelessWidget {
  final StaffProfileStaff staff;

  const _AvailabilityCard({required this.staff});

  @override
  Widget build(BuildContext context) {
    final breakLabel = staff.breakLabel;

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _AvailabilityRow(
            icon: Icons.schedule,
            color: AppColors.primary,
            label: 'Working today',
            value: staff.hoursLabel,
          ),
          // Hidden rather than shown as a dash - plenty of people take none.
          if (breakLabel != null) ...[
            const Divider(color: AppColors.borderLight, height: 1),
            _AvailabilityRow(
              icon: Icons.free_breakfast_outlined,
              color: AppColors.orange,
              label: 'Break',
              value: breakLabel,
            ),
          ],
        ],
      ),
    );
  }
}

class _AvailabilityRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _AvailabilityRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.all(3.5.w),
      child: Row(
        children: [
          Container(
            width: 11.w,
            height: 11.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16.sp, color: color),
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(value, style: textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The services this person can perform. The profile endpoint is the only one
/// that sends their pictures, so draw the thumbnail when there is one.
class _ServicesSection extends StatelessWidget {
  final List<StaffProfileService> services;

  const _ServicesSection({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Text(
        'No services assigned',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      );
    }

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.2.h,
      children: services.map((service) => _ServiceChip(service)).toList(),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final StaffProfileService service;

  const _ServiceChip(this.service);

  @override
  Widget build(BuildContext context) {
    final url = service.thumbnailUrl;

    return Container(
      padding: EdgeInsets.fromLTRB(1.5.w, 1.5.w, 3.w, 1.5.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.w),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: url == null
                ? Icon(
                    Icons.design_services_rounded,
                    size: 13.sp,
                    color: AppColors.primary,
                  )
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.design_services_rounded,
                      size: 13.sp,
                      color: AppColors.primary,
                    ),
                  ),
          ),
          SizedBox(width: 2.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 55.w),
            child: Text(
              service.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// The complete day, earliest first - the API sends no more than this, so
/// there is nothing to page through.
class _TodaysBookingsSection extends StatelessWidget {
  final List<StaffTodayBooking> bookings;

  const _TodaysBookingsSection({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Text(
        'No bookings today',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
      itemBuilder: (context, index) => _BookingRow(bookings[index]),
    );
  }
}

class _BookingRow extends StatelessWidget {
  final StaffTodayBooking booking;

  const _BookingRow(this.booking);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.push('/bookings/${booking.id}'),
      borderRadius: BorderRadius.circular(4.w),
      child: Container(
        padding: EdgeInsets.all(3.5.w),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Text(
              formatTime(booking.scheduledStart),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge,
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    '${booking.serviceLabel}  •  ${booking.durationLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 1.w),
            Icon(
              Icons.chevron_right,
              size: 18.sp,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;

  const _Avatar({this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? _placeholder()
          : Image.network(
              url!,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Center(
                      child: SizedBox(
                        width: 4.w,
                        height: 4.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
              errorBuilder: (_, _, _) => _placeholder(),
            ),
    );
  }

  Widget _placeholder() =>
      Icon(Icons.person_outline, size: 20.sp, color: AppColors.primary);
}

class _StaffDetailsMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String hint;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onRefresh;

  const _StaffDetailsMessage({
    required this.icon,
    required this.title,
    required this.hint,
    required this.onRefresh,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => onRefresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        children: [
          SizedBox(height: 12.h),
          Center(
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26.sp, color: AppColors.primary),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 0.8.h),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          if (actionLabel != null) ...[
            SizedBox(height: 1.5.h),
            Center(
              child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ),
          ],
        ],
      ),
    );
  }
}
