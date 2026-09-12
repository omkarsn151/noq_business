import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_snackbar.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/profile/data/business_overview_model.dart';
import 'package:noq_business/features/ratings/bloc/ratings_bloc.dart';
import 'package:noq_business/features/ratings/bloc/ratings_event.dart';
import 'package:noq_business/features/ratings/bloc/ratings_state.dart';
import 'package:noq_business/features/ratings/presentation/widgets/ratings_loading_widget.dart';
import 'package:noq_business/features/ratings/presentation/widgets/ratings_summary_header.dart';
import 'package:noq_business/features/ratings/presentation/widgets/review_card.dart';

class RatingsAndReviewsScreen extends StatefulWidget {
  final OverviewRating? summary;

  const RatingsAndReviewsScreen({super.key, this.summary});

  @override
  State<RatingsAndReviewsScreen> createState() =>
      _RatingsAndReviewsScreenState();
}

class _RatingsAndReviewsScreenState extends State<RatingsAndReviewsScreen> {
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    context.read<RatingsBloc>().add(const RatingsRequested());
  }

  bool _onScroll(ScrollNotification notification) {
    final position = notification.metrics;
    if (position.axis != Axis.vertical) return false;

    final state = context.read<RatingsBloc>().state;
    if (state.hasMore &&
        !state.isLoadingMore &&
        position.pixels >= position.maxScrollExtent - 200) {
      context.read<RatingsBloc>().add(const RatingsNextPageRequested());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'Ratings & Reviews',
        onLeadingPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: BlocConsumer<RatingsBloc, RatingsState>(
          listenWhen: (prev, curr) =>
              curr.status == RatingsStatus.success &&
              curr.message.isNotEmpty &&
              prev.message != curr.message,
          listener: (context, state) =>
              AppSnackbar.error(context, state.message),
          builder: (context, state) => _body(state),
        ),
      ),
    );
  }

  Widget _body(RatingsState state) {
    if (state.status == RatingsStatus.initial ||
        state.status == RatingsStatus.loading) {
      return RatingsLoadingWidget(showSummary: widget.summary != null);
    }

    if (state.status == RatingsStatus.failure) {
      return _RatingsMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load reviews',
        hint: state.message,
        actionLabel: 'Retry',
        onAction: _reload,
      );
    }

    if (state.reviews.isEmpty) {
      return _RatingsMessage(
        icon: Icons.reviews_outlined,
        title: 'No reviews yet',
        hint: 'Reviews from your customers will show up here.',
        actionLabel: 'Refresh',
        onAction: _reload,
      );
    }

    final summary = widget.summary;
    final headerCount = summary != null ? 1 : 0;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          context.read<RatingsBloc>().add(const RatingsRefreshRequested()),
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 12.h),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: headerCount +
              state.reviews.length +
              (state.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
          itemBuilder: (context, index) {
            if (summary != null && index == 0) {
              return RatingsSummaryHeader(summary: summary);
            }

            final reviewIndex = index - headerCount;
            if (reviewIndex >= state.reviews.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return ReviewCard(review: state.reviews[reviewIndex]);
          },
        ),
      ),
    );
  }
}

/// Empty and error states - scrollable so pull to refresh still works.
class _RatingsMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String hint;
  final String actionLabel;
  final VoidCallback onAction;

  const _RatingsMessage({
    required this.icon,
    required this.title,
    required this.hint,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => onAction(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        children: [
          SizedBox(height: 12.h),
          Center(
            child: Container(
              height: 22.w,
              width: 22.w,
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
          if (hint.isNotEmpty) ...[
            SizedBox(height: 0.8.h),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          SizedBox(height: 1.5.h),
          Center(
            child: TextButton(onPressed: onAction, child: Text(actionLabel)),
          ),
        ],
      ),
    );
  }
}
