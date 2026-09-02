import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:noq_business/core/common/app_alert_dialog.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/staff/bloc/staff_bloc.dart';
import 'package:noq_business/features/staff/bloc/staff_event.dart';
import 'package:noq_business/features/staff/bloc/staff_state.dart';
import 'package:noq_business/features/staff/data/staff_model.dart';
import 'package:noq_business/features/staff/presentation/widgets/add_staff_tile.dart';
import 'package:noq_business/features/staff/presentation/widgets/staff_tile.dart';

class StaffSection extends StatefulWidget {
  const StaffSection({super.key});

  @override
  State<StaffSection> createState() => _StaffSectionState();
}

class _StaffSectionState extends State<StaffSection> {
  @override
  void initState() {
    super.initState();
    context.read<StaffBloc>().add(const StaffRequested());
  }

  Future<void> _confirmDelete(BuildContext context, StaffModel staff) async {
    final confirmed = await AppAlertDialog.show(
      context,
      icon: Icons.delete_outline,
      title: 'Delete Staff',
      message: 'Are you sure you want to delete "${staff.name}"?',
      primaryLabel: 'Delete',
      secondaryLabel: 'Cancel',
      iconColor: AppColors.error,
      iconBackgroundColor: AppColors.primaryLight,
    );
    if (confirmed && context.mounted) {
      context.read<StaffBloc>().add(StaffDeleteRequested(staffId: staff.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffBloc, StaffState>(
      builder: (context, state) {
        if (state is StaffInitial || state is StaffLoading) {
          return Row(
            children: [
              SizedBox(
                width: 4.1.w,
                height: 4.1.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 2.56.w),
              const Text('Loading staff...'),
            ],
          );
        }

        if (state is StaffFailure) {
          return Text(
            state.message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }

        final staff = (state as StaffSuccess).staff;
        if (staff.isEmpty) {
          return AppButton(
            label: 'Add Staff',
            leading: const Icon(Icons.add),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => context.push('/add-staff'),
          );
        }

        return SizedBox(
          height: 14.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: staff.length + 1,
            separatorBuilder: (_, _) => SizedBox(width: 2.56.w),
            itemBuilder: (context, index) {
              if (index == staff.length) {
                return AddStaffTile(onTap: () => context.push('/add-staff'));
              }
              final member = staff[index];
              return StaffTile(
                name: member.name,
                photoUrl: member.photo?.url,
                onTap: () => context.push('/add-staff', extra: member),
                onDelete: () => _confirmDelete(context, member),
              );
            },
          ),
        );
      },
    );
  }
}
