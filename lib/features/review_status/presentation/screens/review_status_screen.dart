import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:noq_business/core/utils/app_assets.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noq_business/core/auth/auth_session.dart';
import 'package:noq_business/core/common/app_alert_dialog.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/enums/business_status.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/review_status/bloc/review_status_bloc.dart';
import 'package:noq_business/features/review_status/bloc/review_status_event.dart';
import 'package:noq_business/features/review_status/bloc/review_status_state.dart';
import 'package:noq_business/features/review_status/data/review_status_model.dart';

enum _StepState { done, current, pending }

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();
  return '${_monthNames[local.month - 1]} ${local.day}, ${local.year}';
}

_StepState _stepStateFromString(String state) {
  switch (state) {
    case 'completed':
      return _StepState.done;
    case 'current':
      return _StepState.current;
    default:
      return _StepState.pending;
  }
}

class ReviewStatusScreen extends StatefulWidget {
  const ReviewStatusScreen({super.key});

  @override
  State<ReviewStatusScreen> createState() => _ReviewStatusScreenState();
}

class _ReviewStatusScreenState extends State<ReviewStatusScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewStatusBloc>().add(const ReviewStatusRequested());
  }

  Future<void> _onCancelReviewPressed(BuildContext context) async {
    final wantsToLogout = await AppAlertDialog.show(
      context,
      icon: Icons.construction_outlined,
      title: 'Feature Under Development',
      message:
          "The features ahead are still under development. For now, you can log out and test by creating another business.",
      primaryLabel: 'Logout',
      secondaryLabel: 'OK',
    );
    if (!wantsToLogout) return;

    if (!context.mounted) return;
    final confirmed = await AppAlertDialog.show(
      context,
      icon: Icons.logout,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      primaryLabel: 'Logout',
      secondaryLabel: 'Cancel',
    );
    if (!confirmed) return;

    await AuthSession.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ReviewStatusBloc, ReviewStatusState>(
          builder: (context, state) {
            if (state is ReviewStatusLoading || state is ReviewStatusInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReviewStatusFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 2.h),
                      AppButton(
                        label: 'Retry',
                        onPressed: () => context
                            .read<ReviewStatusBloc>()
                            .add(const ReviewStatusRequested()),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = (state as ReviewStatusLoaded).data;
            final isApproved = data.reviewStatus == BusinessStatus.approved;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ReviewStatusIcon(status: data.reviewStatus),
                    SizedBox(height: 2.5.h),
                    Text(
                      data.header.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      data.header.subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColors.textfieldFilledColor,
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(3.5.w),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            label: 'Business Name',
                            value: data.summary.businessName,
                          ),
                          SizedBox(height: 1.5.h),
                          _InfoRow(
                            label: 'Category',
                            value: data.summary.categoryName,
                          ),
                          SizedBox(height: 1.5.h),
                          _InfoRow(
                            label: 'Submitted Date',
                            value: _formatDate(data.summary.submittedAt),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildTimelineChildren(data.timeline),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    isApproved
                        ? AppButton(
                            onPressed: () => context.go('/dashboard'),
                            label: 'Get Started',
                          )
                        : AppButton(
                            onPressed: () => _onCancelReviewPressed(context),
                            label: 'Cancel Review',
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildTimelineChildren(
    List<ReviewStatusTimelineItemModel> timeline,
  ) {
    final children = <Widget>[];
    for (var i = 0; i < timeline.length; i++) {
      final item = timeline[i];
      children.add(
        Expanded(
          child: _Step(
            label: item.label,
            state: _stepStateFromString(item.state),
          ),
        ),
      );
      if (i < timeline.length - 1) {
        children.add(
          _StepConnector(active: _stepStateFromString(item.state) == _StepState.done),
        );
      }
    }
    return children;
  }
}

class _ReviewStatusIcon extends StatelessWidget {
  final BusinessStatus? status;

  const _ReviewStatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case BusinessStatus.approved:
        return Container(
          width: 22.56.w,
          height: 22.56.w,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle_outlined, size: 11.w, color: AppColors.success),
        );
      case BusinessStatus.rejected:
        return Container(
          width: 22.56.w,
          height: 22.56.w,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close_rounded, size: 11.w, color: AppColors.error),
        );
      default:
        return Container(
          width: 22.56.w,
          height: 22.56.w,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(5.64.w),
          child: SvgPicture.asset(AppAssets.timmer),
        );
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final String label;
  final _StepState state;

  const _Step({required this.label, required this.state});

  @override
  Widget build(BuildContext context) {
    final isActive = state != _StepState.pending;
    return Column(
      children: [
        Container(
          width: 8.21.w,
          height: 8.21.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.borderLight,
              width: 1.5,
            ),
          ),
          child: state == _StepState.done
              ? Icon(Icons.check, size: 16.sp, color: Colors.white)
              : state == _StepState.current
              ? Center(
                  child: Container(
                    width: 2.56.w,
                    height: 2.56.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        ),
        SizedBox(height: 0.95.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool active;

  const _StepConnector({required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 1.5.h),
      child: SizedBox(
        width: 8.72.w,
        height: 2,
        child: ColoredBox(
          color: active ? AppColors.primary : AppColors.borderLight,
        ),
      ),
    );
  }
}
