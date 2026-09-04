import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/profile/data/business_overview_model.dart';
import 'package:noq_business/features/profile/presentation/widgets/section_card.dart';

class ReviewsCard extends StatefulWidget {
  final OverviewRating rating;
  final OverviewReviews reviews;
  final VoidCallback? onViewAllTap;

  const ReviewsCard({
    super.key,
    required this.rating,
    required this.reviews,
    this.onViewAllTap,
  });

  @override
  State<ReviewsCard> createState() => _ReviewsCardState();
}

class _ReviewsCardState extends State<ReviewsCard> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.reviews.items;
    return SectionCard(
      title: 'Ratings & Reviews',
      actionLabel: 'View All',
      onActionTap: widget.onViewAllTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 22.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.rating.averageLabel,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final filled = (widget.rating.average ?? 0) >= index + 1;
                      return Icon(
                        filled ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 15.sp,
                        color: AppColors.orange,
                      );
                    }),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    widget.rating.reviewsCountLabel,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 3.w),
            Container(width: 1, height: 12.h, color: AppColors.borderLight),
            SizedBox(width: 3.w),
            Expanded(
              child: items.isEmpty
                  ? Text(
                      'No written reviews yet',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 14.h,
                          child: PageView.builder(
                            controller: _controller,
                            itemCount: items.length,
                            onPageChanged: (index) =>
                                setState(() => _page = index),
                            itemBuilder: (context, index) =>
                                _ReviewQuote(review: items[index]),
                          ),
                        ),
                        if (items.length > 1) ...[
                          SizedBox(height: 1.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(items.length, (index) {
                              final active = index == _page;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                                width: active ? 4.w : 1.5.w,
                                height: 1.5.w,
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppColors.primary
                                      : AppColors.borderLight,
                                  borderRadius: BorderRadius.circular(1.w),
                                ),
                              );
                            }),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewQuote extends StatelessWidget {
  final OverviewReview review;

  const _ReviewQuote({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.format_quote_rounded,
          size: 18.sp,
          color: AppColors.primaryLight,
        ),
        SizedBox(height: 0.5.h),
        Expanded(
          child: Text(
            review.comment,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          review.attributionLabel,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
