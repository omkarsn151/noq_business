import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_search_field.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/staff/bloc/staff_bloc.dart';
import 'package:noq_business/features/staff/bloc/staff_event.dart';
import 'package:noq_business/features/staff/bloc/staff_state.dart';
import 'package:noq_business/features/staff/data/staff_model.dart';
import 'package:noq_business/features/staff/presentation/widgets/staff_list_card.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<StaffBloc>().add(const StaffRequested());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() => context.read<StaffBloc>().add(const StaffRequested());

  List<StaffModel> _filter(List<StaffModel> staff) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return staff;
    return staff
        .where((member) => member.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffBloc, StaffState>(
      builder: (context, state) {
        final staff = state is StaffSuccess ? state.staff : null;

        return Scaffold(
          appBar: AppAppBar(
            title: 'Staff',
            subtitle: staff == null
                ? 'Business Profile'
                : '${staff.length} '
                      '${staff.length == 1 ? 'member' : 'members'}',
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/add-staff'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            elevation: 0,
            shape: const CircleBorder(),
            child: Icon(Icons.add, size: 20.sp),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Hidden until there is someone to search, so the first-run
                // empty state stays clean.
                if (staff != null && staff.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                    child: AppSearchField(
                      controller: _search,
                      hintText: 'Search staff',
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

  Widget _body(StaffState state) {
    if (state is StaffInitial || state is StaffLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is StaffFailure) {
      return _StaffMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load staff',
        hint: state.message,
        actionLabel: 'Retry',
        onAction: _reload,
        onRefresh: _reload,
      );
    }

    final staff = (state as StaffSuccess).staff;
    if (staff.isEmpty) {
      return _StaffMessage(
        icon: Icons.groups_outlined,
        title: 'No staff yet',
        hint: 'Add the team members who take bookings.',
        actionLabel: 'Add Staff',
        onAction: () => context.push('/add-staff'),
        onRefresh: _reload,
      );
    }

    final filtered = _filter(staff);
    if (filtered.isEmpty) {
      return _StaffMessage(
        icon: Icons.search_off,
        title: 'No staff match "${_query.trim()}"',
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
          // Tapping a card opens editing - wired up in a later change.
          return StaffListCard(staff: filtered[index]);
        },
      ),
    );
  }
}

class _StaffMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String hint;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onRefresh;

  const _StaffMessage({
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
