import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_search_field.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/service/bloc/service_bloc.dart';
import 'package:noq_business/features/service/bloc/service_event.dart';
import 'package:noq_business/features/service/bloc/service_state.dart';
import 'package:noq_business/features/service/data/service_model.dart';
import 'package:noq_business/features/service/presentation/widgets/service_list_card.dart';
import 'package:noq_business/features/service/presentation/widgets/services_loading_widget.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<ServiceBloc>().add(const ServicesRequested());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() => context.read<ServiceBloc>().add(const ServicesRequested());

  /// Name and description are matched so a shop can find a service by what it
  /// covers, not just what it is called.
  List<ServiceModel> _filter(List<ServiceModel> services) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return services;
    return services
        .where(
          (service) =>
              service.name.toLowerCase().contains(query) ||
              (service.description ?? '').toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceBloc, ServiceState>(
      builder: (context, state) {
        final services = state is ServiceSuccess ? state.services : null;

        return Scaffold(
          appBar: AppAppBar(
            title: 'Services',
            subtitle: services == null
                ? 'Business Profile'
                : '${services.length} '
                      '${services.length == 1 ? 'service' : 'services'}',
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/add-service'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            elevation: 0,
            shape: const CircleBorder(),
            child: Icon(Icons.add, size: 20.sp),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Hidden until there is something to search, so the first-run
                // empty state stays clean.
                if (services != null && services.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                    child: AppSearchField(
                      controller: _search,
                      hintText: 'Search services',
                      onChanged: (value) => setState(() => _query = value),
                      onClear: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    ),
                  ),
                Expanded(child: _body(state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(ServiceState state) {
    if (state is ServiceInitial || state is ServiceLoading) {
      return const ServicesLoadingWidget();
    }

    if (state is ServiceFailure) {
      return _ServicesMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load services',
        hint: state.message,
        actionLabel: 'Retry',
        onAction: _reload,
        onRefresh: _reload,
      );
    }

    final services = (state as ServiceSuccess).services;
    if (services.isEmpty) {
      return _ServicesMessage(
        icon: Icons.design_services_outlined,
        title: 'No services yet',
        hint: 'Add the services your customers can book.',
        actionLabel: 'Add Service',
        onAction: () => context.push('/add-service'),
        onRefresh: _reload,
      );
    }

    final filtered = _filter(services);
    if (filtered.isEmpty) {
      return _ServicesMessage(
        icon: Icons.search_off,
        title: 'No services match "${_query.trim()}"',
        hint: 'Try a different name or clear the search.',
        onRefresh: _reload,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _reload(),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 12.h),
        physics: const BouncingScrollPhysics(),
        itemCount: filtered.length,
        separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
        itemBuilder: (context, index) {
          final service = filtered[index];
          return ServiceListCard(
            service: service,
            onTap: () => context.push('/add-service', extra: service),
          );
        },
      ),
    );
  }
}

class _ServicesMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String hint;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onRefresh;

  const _ServicesMessage({
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
