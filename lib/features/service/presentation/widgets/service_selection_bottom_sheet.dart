import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/features/service/bloc/service_bloc.dart';
import 'package:noq_business/features/service/bloc/service_event.dart';
import 'package:noq_business/features/service/bloc/service_state.dart';
import 'package:noq_business/features/service/data/service_model.dart';

class ServiceSelectionBottomSheet {
  ServiceSelectionBottomSheet._();

  static Future<List<ServiceModel>?> show(
    BuildContext context, {
    List<ServiceModel> selected = const [],
  }) {
    context.read<ServiceBloc>().add(const ServicesRequested());
    return showModalBottomSheet<List<ServiceModel>>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.13.w)),
      ),
      builder: (_) => _ServiceSelectionBody(selected: selected),
    );
  }
}

class _ServiceSelectionBody extends StatefulWidget {
  final List<ServiceModel> selected;

  const _ServiceSelectionBody({required this.selected});

  @override
  State<_ServiceSelectionBody> createState() => _ServiceSelectionBodyState();
}

class _ServiceSelectionBodyState extends State<_ServiceSelectionBody> {
  late final Set<String> _selectedIds = widget.selected
      .map((s) => s.id)
      .toSet();
  List<ServiceModel> _services = [];

  void _toggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75.sh,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.62.w, 1.42.h, 4.62.w, 2.13.h),
        child: Column(
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
            Text(
              'Select Services',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 1.42.h),
            Expanded(
              child: BlocConsumer<ServiceBloc, ServiceState>(
                listener: (context, state) {
                  if (state is ServiceSuccess) {
                    _services = state.services;
                  }
                },
                builder: (context, state) {
                  if (state is ServiceInitial || state is ServiceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ServiceFailure) {
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
                          Text(state.message, textAlign: TextAlign.center),
                          SizedBox(height: 1.42.h),
                          AppButton(
                            label: 'Retry',
                            onPressed: () => context.read<ServiceBloc>().add(
                              const ServicesRequested(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final services = (state as ServiceSuccess).services;
                  if (services.isEmpty) {
                    return const Center(child: Text('No services available'));
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(vertical: 1.42.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 1.42.h,
                      crossAxisSpacing: 3.08.w,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      final isSelected = _selectedIds.contains(service.id);
                      return _ServiceGridTile(
                        service: service,
                        isSelected: isSelected,
                        onTap: () => _toggle(service.id),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 0.95.h),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Apply',
                onPressed: () {
                  final result = _services
                      .where((s) => _selectedIds.contains(s.id))
                      .toList();
                  Navigator.pop(context, result);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceGridTile extends StatelessWidget {
  final ServiceModel service;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceGridTile({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  String? get _thumbnailUrl {
    if (service.images.thumbnails.isEmpty) return null;
    final url = service.images.thumbnails.first.url;
    return url.isNotEmpty ? url : null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3.08.w),
      child: Container(
        padding: EdgeInsets.all(2.56.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.08.w),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.06)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2.05.w),
              ),
              clipBehavior: Clip.antiAlias,
              child: _thumbnailUrl != null
                  ? Image.network(
                      _thumbnailUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                      errorBuilder: (_, _, _) =>
                          Icon(Icons.design_services_outlined, size: 26.sp),
                    )
                  : Icon(Icons.design_services_outlined, size: 26.sp),
            ),
            SizedBox(height: 0.95.h),
            Text(
              service.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
