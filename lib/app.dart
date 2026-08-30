import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/router/app_router.dart';
import 'package:noq_business/core/themes/app_theme.dart';
import 'package:noq_business/features/auth/register/bloc/register_bloc.dart';
import 'package:noq_business/features/business/bloc/business_bloc.dart';
import 'package:noq_business/features/business/repository/business_repository.dart';
import 'package:noq_business/features/business_setup/bloc/business_setup_bloc.dart';
import 'package:noq_business/features/business_setup/bloc/submit_review_bloc.dart';
import 'package:noq_business/features/business_setup/repository/business_setup_repository.dart';
import 'package:noq_business/features/bookings/bloc/booking_details_bloc.dart';
import 'package:noq_business/features/bookings/bloc/bookings_bloc.dart';
import 'package:noq_business/features/bookings/repository/bookings_repository.dart';
import 'package:noq_business/features/promotions/bloc/create_promotion_bloc.dart';
import 'package:noq_business/features/promotions/bloc/promotion_details_bloc.dart';
import 'package:noq_business/features/promotions/bloc/promotions_bloc.dart';
import 'package:noq_business/features/promotions/repository/promotions_repository.dart';
import 'package:noq_business/features/review_status/bloc/review_status_bloc.dart';
import 'package:noq_business/features/review_status/repository/review_status_repository.dart';
import 'package:noq_business/features/categories/bloc/categories_bloc.dart';
import 'package:noq_business/features/categories/repository/categories_repository.dart';
import 'package:noq_business/features/service/bloc/add_service_bloc.dart';
import 'package:noq_business/features/service/bloc/service_bloc.dart';
import 'package:noq_business/features/service/repository/service_repository.dart';
import 'package:noq_business/features/staff/bloc/add_staff_bloc.dart';
import 'package:noq_business/features/staff/bloc/staff_bloc.dart';
import 'package:noq_business/features/staff/repository/staff_repository.dart';
import 'package:noq_business/features/walkin/bloc/create_walkin_bloc.dart';
import 'package:noq_business/features/walkin/repository/walkin_repository.dart';
import 'package:noq_business/features/auth/register/repository/register_repository.dart';
import 'package:noq_business/features/auth/request_otp/bloc/request_otp_bloc.dart';
import 'package:noq_business/features/auth/request_otp/repository/request_otp_repository.dart';
import 'package:noq_business/features/auth/verify_otp/bloc/verify_otp_bloc.dart';
import 'package:noq_business/features/auth/verify_otp/reopsitory/verify_otp_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RequestOtpBloc>(
          create: (_) => RequestOtpBloc(RequestOtpRepository()),
        ),
        BlocProvider<VerifyOtpBloc>(
          create: (_) => VerifyOtpBloc(VerifyOtpRepository()),
        ),
        BlocProvider<RegisterBloc>(
          create: (_) => RegisterBloc(RegisterRepository()),
        ),
        BlocProvider<CategoriesBloc>(
          create: (_) => CategoriesBloc(CategoriesRepository()),
        ),
        BlocProvider<BusinessBloc>(
          create: (_) => BusinessBloc(BusinessRepository()),
        ),
        BlocProvider<BusinessSetupBloc>(
          create: (_) => BusinessSetupBloc(BusinessSetupRepository()),
        ),
        BlocProvider<SubmitReviewBloc>(
          create: (_) => SubmitReviewBloc(BusinessSetupRepository()),
        ),
        BlocProvider<ReviewStatusBloc>(
          create: (_) => ReviewStatusBloc(ReviewStatusRepository()),
        ),
        BlocProvider<ServiceBloc>(
          create: (_) => ServiceBloc(ServiceRepository()),
        ),
        BlocProvider<AddServiceBloc>(
          create: (_) => AddServiceBloc(ServiceRepository()),
        ),
        BlocProvider<StaffBloc>(create: (_) => StaffBloc(StaffRepository())),
        BlocProvider<CreatePromotionBloc>(
          create: (_) => CreatePromotionBloc(PromotionsRepository()),
        ),
        BlocProvider<PromotionDetailsBloc>(
          create: (_) => PromotionDetailsBloc(PromotionsRepository()),
        ),
        BlocProvider<PromotionsBloc>(
          create: (_) => PromotionsBloc(PromotionsRepository()),
        ),
        BlocProvider<BookingsBloc>(
          create: (_) => BookingsBloc(BookingsRepository()),
        ),
        BlocProvider<BookingDetailsBloc>(
          create: (_) => BookingDetailsBloc(BookingsRepository()),
        ),
        BlocProvider<AddStaffBloc>(
          create: (_) => AddStaffBloc(StaffRepository()),
        ),
        BlocProvider<CreateWalkinBloc>(
          create: (_) => CreateWalkinBloc(WalkinRepository()),
        ),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'NoQ Business',
            theme: AppTheme.appTheme,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
