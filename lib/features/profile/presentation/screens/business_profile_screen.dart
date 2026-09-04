import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/profile/bloc/business_profile_bloc.dart';
import 'package:noq_business/features/profile/bloc/business_profile_event.dart';
import 'package:noq_business/features/profile/bloc/business_profile_state.dart';
import 'package:noq_business/features/profile/data/business_overview_model.dart';
import 'package:noq_business/features/profile/presentation/widgets/overview_gallery_card.dart';
import 'package:noq_business/features/profile/presentation/widgets/overview_services_card.dart';
import 'package:noq_business/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:noq_business/features/profile/presentation/widgets/reviews_card.dart';
import 'package:noq_business/features/profile/presentation/widgets/verification_card.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<BusinessProfileBloc>().add(
      const BusinessProfileRequested(refresh: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'Business Profile',
        onLeadingPressed: () => context.pop(),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<BusinessProfileBloc, BusinessProfileState>(
          builder: (context, state) => _body(state),
        ),
      ),
    );
  }

  Widget _body(BusinessProfileState state) {
    if (state is BusinessProfileInitial || state is BusinessProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BusinessProfileFailure) {
      return _ProfileMessage(
        message: state.businessNotFound
            ? "You don't have a business yet. Set one up to see your profile."
            : state.message,
        onRetry: state.businessNotFound ? null : _load,
      );
    }

    return _ProfileContent(
      overview: (state as BusinessProfileSuccess).overview,
      onRefresh: _load,
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final BusinessOverviewModel overview;
  final VoidCallback onRefresh;

  const _ProfileContent({required this.overview, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeaderCard(
              profile: overview.profile,
              stats: overview.stats,
              onEditTap: () {},
              onPreviewTap: () {},
            ),
            SizedBox(height: 2.h),
            ReviewsCard(
              rating: overview.stats.rating,
              reviews: overview.reviews,
              onViewAllTap: () {},
            ),
            SizedBox(height: 2.h),
            OverviewServicesCard(
              services: overview.services,
              onManageTap: () => context.push('/services'),
              onAddTap: () => context.push('/add-service'),
              // The overview carries the slim OverviewService; the edit form
              // needs a full ServiceModel, so send the shop to the list.
              onServiceTap: (_) => context.push('/services'),
            ),
            SizedBox(height: 2.h),
            OverviewGalleryCard(
              gallery: overview.gallery,
              onManageTap: () => context.push('/gallery'),
              onAddTap: () {},
            ),
            SizedBox(height: 2.h),
            VerificationCard(
              verification: overview.verification,
              onManageTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ProfileMessage({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => onRetry?.call(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: 1.5.h),
            Center(
              child: TextButton(onPressed: onRetry, child: const Text('Retry')),
            ),
          ],
        ],
      ),
    );
  }
}
