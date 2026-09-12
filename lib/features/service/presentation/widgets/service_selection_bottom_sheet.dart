import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/common/app_search_field.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/core/utils/currency_format.dart';
import 'package:noq_business/features/service/bloc/service_bloc.dart';
import 'package:noq_business/features/service/bloc/service_event.dart';
import 'package:noq_business/features/service/bloc/service_state.dart';
import 'package:noq_business/features/service/data/service_model.dart';

/// Multi-select service picker. Unlike the category pickers this one is a
/// checkable list: a thumbnail, the service name and - for walk-ins - the
/// duration / price meta, with a live summary above the Apply button.
class ServiceSelectionBottomSheet {
  ServiceSelectionBottomSheet._();

  /// [showPriceAndDuration] is on for walk-ins, where the visit length and
  /// amount matter, and off when assigning services to a staff member.
  static Future<List<ServiceModel>?> show(
    BuildContext context, {
    List<ServiceModel> selected = const [],
    bool showPriceAndDuration = false,
  }) {
    context.read<ServiceBloc>().add(const ServicesRequested());
    return showModalBottomSheet<List<ServiceModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.13.w)),
      ),
      builder: (_) => _ServiceSelectionBody(
        selected: selected,
        showPriceAndDuration: showPriceAndDuration,
      ),
    );
  }
}

class _ServiceSelectionBody extends StatefulWidget {
  final List<ServiceModel> selected;
  final bool showPriceAndDuration;

  const _ServiceSelectionBody({
    required this.selected,
    required this.showPriceAndDuration,
  });

  @override
  State<_ServiceSelectionBody> createState() => _ServiceSelectionBodyState();
}

class _ServiceSelectionBodyState extends State<_ServiceSelectionBody> {
  final _searchController = TextEditingController();
  late final Set<String> _selectedIds = widget.selected
      .map((s) => s.id)
      .toSet();

  /// Keeps every service that has been selected, even ones filtered out by the
  /// current search, so Apply never drops a hidden selection.
  late final Map<String, ServiceModel> _selectedById = {
    for (final s in widget.selected) s.id: s,
  };

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value.trim().toLowerCase());
  }

  void _toggle(ServiceModel service) {
    setState(() {
      if (_selectedIds.remove(service.id)) {
        _selectedById.remove(service.id);
      } else {
        _selectedIds.add(service.id);
        _selectedById[service.id] = service;
      }
    });
  }

  List<ServiceModel> _filter(List<ServiceModel> services) {
    if (_query.isEmpty) return services;
    return services
        .where((s) => s.name.toLowerCase().contains(_query))
        .toList();
  }

  int get _totalMinutes =>
      _selectedById.values.fold(0, (sum, s) => sum + s.durationMinutes);

  String get _totalAmount {
    if (_selectedById.isEmpty) return '';
    final total = _selectedById.values.fold<double>(
      0,
      (sum, s) => sum + (double.tryParse(s.price.trim()) ?? 0),
    );
    final currency = _selectedById.values.first.currencyCode;
    return formatAmount(total.toStringAsFixed(2), currency);
  }

  String get _summaryLabel {
    final count = _selectedIds.length;
    if (count == 0) return 'No services selected yet';
    final base = '$count service${count == 1 ? '' : 's'} selected';
    if (!widget.showPriceAndDuration) return base;
    return '$base  ·  $_totalMinutes min  ·  $_totalAmount';
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedIds.isNotEmpty;

    return SizedBox(
      height: 80.sh,
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
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(0.51.w),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Services',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 0.4.h),
                      Text(
                        widget.showPriceAndDuration
                            ? 'Pick everything this customer is here for'
                            : 'Pick the services this staff member can do',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: EdgeInsets.all(1.6.w),
                    decoration: const BoxDecoration(
                      color: AppColors.textfieldFilledColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 17.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.8.h),
            AppSearchField(
              controller: _searchController,
              hintText: 'Search services',
              onChanged: _onQueryChanged,
              onClear: () {
                _searchController.clear();
                _onQueryChanged('');
              },
            ),
            Expanded(
              child: BlocBuilder<ServiceBloc, ServiceState>(
                builder: (context, state) {
                  if (state is ServiceFailure) {
                    return _MessageState(
                      icon: Icons.wifi_off_rounded,
                      iconColor: AppColors.error,
                      title: 'Could not load services',
                      message: state.message,
                      actionLabel: 'Retry',
                      onAction: () => context.read<ServiceBloc>().add(
                        const ServicesRequested(),
                      ),
                    );
                  }

                  if (state is! ServiceSuccess) {
                    return const _ServiceListSkeleton();
                  }

                  if (state.services.isEmpty) {
                    return const _MessageState(
                      icon: Icons.design_services_outlined,
                      title: 'No services yet',
                      message: 'Add a service first, then assign it here.',
                    );
                  }

                  final services = _filter(state.services);
                  if (services.isEmpty) {
                    return _MessageState(
                      icon: Icons.search_off_rounded,
                      title: 'No matches found',
                      message:
                          'No service matches "${_searchController.text}".',
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 1.6.h),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: services.length,
                    separatorBuilder: (_, _) => SizedBox(height: 1.2.h),
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return _ServiceRow(
                        service: service,
                        isSelected: _selectedIds.contains(service.id),
                        showPriceAndDuration: widget.showPriceAndDuration,
                        onTap: () => _toggle(service),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Icon(
                  hasSelection
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  size: 16.sp,
                  color: hasSelection
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    _summaryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: hasSelection
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: hasSelection
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.2.h),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: hasSelection
                    ? 'Apply (${_selectedIds.length})'
                    : 'Apply',
                onPressed: () =>
                    Navigator.pop(context, _selectedById.values.toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One selectable row - thumbnail, name, optional description and meta chips,
/// and a checkbox that doubles as the selected indicator.
class _ServiceRow extends StatelessWidget {
  final ServiceModel service;
  final bool isSelected;
  final bool showPriceAndDuration;
  final VoidCallback onTap;

  const _ServiceRow({
    required this.service,
    required this.isSelected,
    required this.showPriceAndDuration,
    required this.onTap,
  });

  String? get _thumbnailUrl {
    if (service.images.thumbnails.isEmpty) return null;
    final url = service.images.thumbnails.first.url;
    return url.isNotEmpty ? url : null;
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(3.08.w);

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(2.8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.textfieldFilledColor,
          borderRadius: radius,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            _Thumbnail(url: _thumbnailUrl),
            SizedBox(width: 3.2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (service.description != null &&
                      service.description!.trim().isNotEmpty) ...[
                    SizedBox(height: 0.3.h),
                    Text(
                      service.description!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (showPriceAndDuration) ...[
                    SizedBox(height: 0.8.h),
                    Row(
                      children: [
                        _MetaChip(
                          icon: Icons.schedule_rounded,
                          label: '${service.durationMinutes} min',
                          color: AppColors.blue,
                        ),
                        SizedBox(width: 2.w),
                        _MetaChip(
                          icon: Icons.currency_rupee_rounded,
                          label: formatAmount(
                            service.price,
                            service.currencyCode,
                          ),
                          color: AppColors.success,
                          showIcon: false,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 2.w),
            _SelectionBox(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? url;

  const _Thumbnail({this.url});

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;

    return Container(
      width: 13.w,
      height: 13.w,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(2.6.w),
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? _placeholder()
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(),
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : _placeholder(),
            ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Icon(
        Icons.design_services_outlined,
        size: 19.sp,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool showIcon;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 0.35.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 12.sp, color: color),
            SizedBox(width: 1.2.w),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionBox extends StatelessWidget {
  final bool isSelected;

  const _SelectionBox({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 5.5.w,
      height: 5.5.w,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(1.6.w),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 1.4,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check_rounded, size: 14.sp, color: AppColors.background)
          : null,
    );
  }
}

/// Shimmering row placeholders shown while the services load, shaped to
/// match [_ServiceRow].
class _ServiceListSkeleton extends StatelessWidget {
  const _ServiceListSkeleton();

  static const int itemCount = 5;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 1.6.h),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: 1.2.h),
        itemBuilder: (context, index) => const _ServiceRowSkeleton(),
      ),
    );
  }
}

class _ServiceRowSkeleton extends StatelessWidget {
  const _ServiceRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(3.08.w);

    return Container(
      padding: EdgeInsets.all(2.8.w),
      decoration: BoxDecoration(
        color: AppColors.textfieldFilledColor,
        borderRadius: radius,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Bone(
            width: 13.w,
            height: 13.w,
            borderRadius: BorderRadius.circular(2.6.w),
          ),
          SizedBox(width: 3.2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Bone.text(width: 35.w, fontSize: 14.5),
                SizedBox(height: 0.6.h),
                Bone.text(width: 45.w),
                SizedBox(height: 0.8.h),
                Row(
                  children: [
                    Bone(
                      width: 16.w,
                      height: 2.5.h,
                      borderRadius: BorderRadius.circular(5.w),
                    ),
                    SizedBox(width: 2.w),
                    Bone(
                      width: 14.w,
                      height: 2.5.h,
                      borderRadius: BorderRadius.circular(5.w),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Bone(
            width: 5.5.w,
            height: 5.5.w,
            borderRadius: BorderRadius.circular(1.6.w),
          ),
        ],
      ),
    );
  }
}

/// Centered icon + message used for the error, empty and no-match states.
class _MessageState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    this.iconColor = AppColors.textSecondary,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28.sp, color: iconColor),
            ),
            SizedBox(height: 1.8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (message != null && message!.isNotEmpty) ...[
              SizedBox(height: 0.6.h),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 2.2.h),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                padding: EdgeInsets.symmetric(vertical: 1.4.h, horizontal: 8.w),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
