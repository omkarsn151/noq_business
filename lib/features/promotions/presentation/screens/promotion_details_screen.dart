import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/core/utils/date_formats.dart';
import 'package:noq_business/features/promotions/bloc/promotion_details_bloc.dart';
import 'package:noq_business/features/promotions/bloc/promotion_details_event.dart';
import 'package:noq_business/features/promotions/bloc/promotion_details_state.dart';
import 'package:noq_business/features/promotions/data/promotion_details_model.dart';
import 'package:noq_business/features/promotions/data/promotion_model.dart';
import 'package:noq_business/features/promotions/data/promotion_status.dart';
import 'package:noq_business/features/promotions/presentation/widgets/promotion_info_row.dart';

/// '10 Aug 2026 - 30 Sep 2026' for the dates the promo runs between.
String _availableDays(PromotionValidity validity) {
  final from = validity.from?.toLocal();
  final until = validity.until?.toLocal();
  if (from == null && until == null) return 'Not set';
  if (from == null) return 'Until ${formatDayMonthYear(until)}';
  if (until == null) return 'From ${formatDayMonthYear(from)}';
  return '${formatDayMonthYear(from)} - ${formatDayMonthYear(until)}';
}

/// '2:00 PM - 5:00 PM' taken from the validity window.
String _availableTimings(PromotionValidity validity) {
  final from = validity.from?.toLocal();
  final until = validity.until?.toLocal();
  if (from == null || until == null) return 'Not set';
  return '${formatTime(from)} - ${formatTime(until)}';
}

class PromotionDetailsScreen extends StatefulWidget {
  final String promotionId;

  const PromotionDetailsScreen({super.key, required this.promotionId});

  @override
  State<PromotionDetailsScreen> createState() => _PromotionDetailsScreenState();
}

class _PromotionDetailsScreenState extends State<PromotionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PromotionDetailsBloc>().add(
      PromotionDetailsRequested(promotionId: widget.promotionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Promo Details'),
      body: SafeArea(
        child: BlocBuilder<PromotionDetailsBloc, PromotionDetailsState>(
          builder: (context, state) {
            if (state is PromotionDetailsInitial ||
                state is PromotionDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PromotionDetailsFailure) {
              return _DetailsMessage(
                message: state.message,
                onRetry: () => context.read<PromotionDetailsBloc>().add(
                  PromotionDetailsRequested(promotionId: widget.promotionId),
                ),
              );
            }

            final details = (state as PromotionDetailsSuccess).details;
            return _DetailsBody(details: details);
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<
        PromotionDetailsBloc,
        PromotionDetailsState
      >(
        builder: (context, state) {
          if (state is! PromotionDetailsSuccess) return const SizedBox.shrink();
          return const _DetailsActions();
        },
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final PromotionDetailsModel details;

  const _DetailsBody({required this.details});

  @override
  Widget build(BuildContext context) {
    final promo = details.promo;
    final performance = details.performance;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 3.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PromotionHeader(promo: promo),
            SizedBox(height: 2.h),
            const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
            SizedBox(height: 2.h),

            Text(
              'Discount Timeline',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 1.h),
            PromotionInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Available Days',
              value: _availableDays(promo.validity),
            ),
            PromotionInfoRow(
              icon: Icons.access_time_rounded,
              label: 'Available Timings',
              value: _availableTimings(promo.validity),
            ),

            SizedBox(height: 1.5.h),
            const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
            SizedBox(height: 2.h),

            Text(
              'Performance Info',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 1.h),
            PromotionInfoRow(
              icon: Icons.person_outline,
              label: 'Used by',
              value: '${performance.usedByCustomers} Customers',
            ),
            PromotionInfoRow(
              icon: Icons.calendar_month_outlined,
              label: 'Total Bookings',
              value: '${performance.totalBookings}',
            ),
            PromotionInfoRow(
              icon: Icons.percent_rounded,
              label: 'Conversion Rate',
              value: '${performance.conversionRate}%',
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionHeader extends StatelessWidget {
  final PromotionDetailModel promo;

  const _PromotionHeader({required this.promo});

  @override
  Widget build(BuildContext context) {
    final bannerUrl = promo.banner?.url;
    final placeholder = Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Icon(
        Icons.local_offer_rounded,
        size: 18.sp,
        color: AppColors.chartPrimary,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2.w),
          child: SizedBox(
            width: 16.w,
            height: 16.w,
            child: bannerUrl == null || bannerUrl.isEmpty
                ? placeholder
                : Image.network(
                    bannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => placeholder,
                  ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                promo.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 0.8.h,
                children: [
                  _StatusChip(status: promo.status),
                  _DiscountChip(label: promo.discount.label),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final PromotionStatus status;

  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case PromotionStatus.active:
        return AppColors.success;
      case PromotionStatus.expired:
        return AppColors.error;
      case PromotionStatus.inactive:
      case PromotionStatus.draft:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 1.8.w,
            height: 1.8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 1.5.w),
          Text(
            status.label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 12.sp, color: color),
          ),
        ],
      ),
    );
  }
}

class _DiscountChip extends StatelessWidget {
  final String label;

  const _DiscountChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.background,
        ),
      ),
    );
  }
}

class _DetailsActions extends StatelessWidget {
  const _DetailsActions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(5.w, 1.5.h, 5.w, 2.h),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: Text(
                  'Move to Draft',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: AppButton(
                label: 'Edit Promo',
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  textStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailsMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 1.5.h),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
