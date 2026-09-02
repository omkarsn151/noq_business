import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_pill_tab_bar.dart';
import 'package:noq_business/core/common/app_snackbar.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/core/utils/date_formats.dart';
import 'package:noq_business/features/promotions/bloc/promotion_action_bloc.dart';
import 'package:noq_business/features/promotions/bloc/promotion_action_event.dart';
import 'package:noq_business/features/promotions/bloc/promotion_action_state.dart';
import 'package:noq_business/features/promotions/bloc/promotions_bloc.dart';
import 'package:noq_business/features/promotions/bloc/promotions_event.dart';
import 'package:noq_business/features/promotions/bloc/promotions_state.dart';
import 'package:noq_business/features/promotions/data/promotion_model.dart';
import 'package:noq_business/features/promotions/data/promotion_status.dart';
import 'package:noq_business/features/promotions/presentation/widgets/promotion_card.dart';

String _formatValidity(PromotionValidity validity) {
  final from = validity.from?.toLocal();
  final until = validity.until?.toLocal();
  if (from == null && until == null) return 'No validity set';

  if (from == null) return 'Until ${formatDate(until)}';
  if (until == null) return 'From ${formatDate(from)}';
  return '${formatDayMonth(from)} - ${formatDate(until)}';
}

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: PromotionStatus.values.length,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _tabController.addListener(_onTabChanged);
    context.read<PromotionsBloc>().add(
      PromotionsRequested(status: PromotionStatus.values.first, refresh: true),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  /// Loads a tab the first time it is opened.
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    context.read<PromotionsBloc>().add(
      PromotionsRequested(status: PromotionStatus.values[_tabController.index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Promotions', subtitle: 'Marketing Hub'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-promotion'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,
        shape: const CircleBorder(),
        child: Icon(Icons.add, size: 20.sp),
      ),
      body: SafeArea(
        child: BlocListener<PromotionActionBloc, PromotionActionState>(
          listener: (context, state) {
            if (state is PromotionActionSuccess) {
              AppSnackbar.success(context, switch (state.kind) {
                PromotionActionKind.pause => 'Promo paused',
                PromotionActionKind.resume => 'Promo resumed',
                PromotionActionKind.publish => 'Promo published',
              });
              context.read<PromotionsBloc>().add(
                PromotionsRefreshRequested(
                  status: PromotionStatus.values[_tabController.index],
                ),
              );
            } else if (state is PromotionActionFailure) {
              AppSnackbar.error(context, state.message);
            }
          },
          child: BlocBuilder<PromotionsBloc, PromotionsState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  AppPillTabBar(
                    controller: _tabController,
                    labels: [
                      for (final status in PromotionStatus.values)
                        '${status.label} ${state.counts.countFor(status)}',
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        for (final status in PromotionStatus.values)
                          _PromotionsList(
                            status: status,
                            tab: state.tabFor(status),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PromotionsList extends StatelessWidget {
  final PromotionStatus status;
  final PromotionsTabState tab;

  const _PromotionsList({required this.status, required this.tab});

  void _loadFirstPage(BuildContext context) {
    context.read<PromotionsBloc>().add(
      PromotionsRequested(status: status, refresh: true),
    );
  }

  void _onCardAction(
    BuildContext context,
    PromotionModel promotion,
    PromotionCardAction action,
  ) {
    if (action == PromotionCardAction.edit) {
      // The list row is the slim model; the details screen holds the full
      // promo needed to prefill the edit form.
      context.push('/promotions/${promotion.id}');
      return;
    }

    final bloc = context.read<PromotionActionBloc>();
    switch (action) {
      case PromotionCardAction.pause:
        bloc.add(
          PromotionActionRequested(
            promotionId: promotion.id,
            kind: PromotionActionKind.pause,
            isActive: false,
          ),
        );
        break;
      case PromotionCardAction.resume:
        bloc.add(
          PromotionActionRequested(
            promotionId: promotion.id,
            kind: PromotionActionKind.resume,
            isActive: true,
          ),
        );
        break;
      case PromotionCardAction.publish:
        bloc.add(
          PromotionActionRequested(
            promotionId: promotion.id,
            kind: PromotionActionKind.publish,
            publish: true,
          ),
        );
        break;
      case PromotionCardAction.edit:
        break;
    }
  }

  /// Requests the next page once the list is scrolled near its end.
  bool _onScroll(BuildContext context, ScrollNotification notification) {
    final position = notification.metrics;
    if (position.axis != Axis.vertical) return false;

    if (tab.hasMore &&
        !tab.isLoadingMore &&
        position.pixels >= position.maxScrollExtent - 200) {
      context.read<PromotionsBloc>().add(
        PromotionsNextPageRequested(status: status),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (tab.status == PromotionsTabStatus.initial ||
        tab.status == PromotionsTabStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tab.status == PromotionsTabStatus.failure) {
      return _PromotionsMessage(
        message: tab.message,
        onRetry: () => _loadFirstPage(context),
      );
    }

    if (tab.promotions.isEmpty) {
      return _PromotionsMessage(
        message: 'No ${status.label.toLowerCase()} promotions yet',
        onRetry: () => _loadFirstPage(context),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _loadFirstPage(context),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _onScroll(context, notification),
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 12.h),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: tab.promotions.length + (tab.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
          itemBuilder: (context, index) {
            if (index == tab.promotions.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final promotion = tab.promotions[index];
            return PromotionCard(
              title: promotion.title,
              schedule: _formatValidity(promotion.validity),
              usedBy: '${promotion.stats.usedByCustomers} Customers',
              discount: promotion.discount.label,
              status: promotion.status,
              imageUrl: promotion.banner?.url,
              onTap: () => context.push('/promotions/${promotion.id}'),
              onAction: (action) => _onCardAction(context, promotion, action),
            );
          },
        ),
      ),
    );
  }
}

class _PromotionsMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PromotionsMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => onRetry(),
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
          SizedBox(height: 1.5.h),
          Center(
            child: TextButton(onPressed: onRetry, child: const Text('Retry')),
          ),
        ],
      ),
    );
  }
}
