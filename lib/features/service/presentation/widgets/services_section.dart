import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/service/bloc/service_bloc.dart';
import 'package:noq_business/features/service/bloc/service_event.dart';
import 'package:noq_business/features/service/bloc/service_state.dart';
import 'package:noq_business/features/service/presentation/widgets/service_tile.dart';
import 'package:noq_business/features/service/presentation/widgets/add_service_tile.dart';

class ServicesSection extends StatefulWidget {
  const ServicesSection({super.key});

  @override
  State<ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<ServicesSection> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceBloc>().add(const ServicesRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceBloc, ServiceState>(
      builder: (context, state) {
        if (state is ServiceInitial || state is ServiceLoading) {
          return Row(
            children: [
              SizedBox(
                width: 4.1.w,
                height: 4.1.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 2.56.w),
              const Text('Loading services...'),
            ],
          );
        }

        if (state is ServiceFailure) {
          return Text(
            state.message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }

        final services = (state as ServiceSuccess).services;
        if (services.isEmpty) {
          return AppButton(
            label: 'Add Service',
            leading: const Icon(Icons.add, color: AppColors.primary),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => context.push('/add-service'),
          );
        }

        return SizedBox(
          height: 14.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: services.length + 1,
            separatorBuilder: (_, _) => SizedBox(width: 2.56.w),
            itemBuilder: (context, index) {
              if (index == services.length) {
                return AddServiceTile(
                  onTap: () => context.push('/add-service'),
                );
              }
              return ServiceTile(
                service: services[index],
                onTap: () =>
                    context.push('/add-service', extra: services[index]),
              );
            },
          ),
        );
      },
    );
  }
}
