import 'package:go_router/go_router.dart';
import 'package:noq_business/features/auth/request_otp/presentation/screens/login_screen.dart';
import 'package:noq_business/features/auth/verify_otp/presentation/screens/otp_verification_scren.dart';
import 'package:noq_business/features/auth/register/presentation/screens/register_screen.dart';
import 'package:noq_business/features/bookings/bookings_screen.dart';
import 'package:noq_business/features/business_setup/presentation/screens/business_operation_screen.dart';
import 'package:noq_business/features/business_setup/presentation/screens/business_setup_screen.dart';
import 'package:noq_business/features/review_status/presentation/screens/review_status_screen.dart';
import 'package:noq_business/features/dashboard/dashboard_screen.dart';
import 'package:noq_business/features/main_screen/main_screen.dart';
import 'package:noq_business/features/onboarding/presentation/onboarding_screen.dart';
import 'package:noq_business/features/privacy/privacy_policy_screen.dart';
import 'package:noq_business/features/service/data/service_model.dart';
import 'package:noq_business/features/service/presentation/screens/add_service_screen.dart';
import 'package:noq_business/features/settings/settings_screen.dart';
import 'package:noq_business/features/splash/splash_screen.dart';
import 'package:noq_business/features/staff/data/staff_model.dart';
import 'package:noq_business/features/staff/presentation/screen/add_staff_screen.dart';
import 'package:noq_business/features/stats/stats_screen.dart';
import 'package:noq_business/features/tnc/tnc_screen.dart';
import 'package:noq_business/features/walkin/walkin_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/splash'),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return OtpVerificationScren(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/business-setup',
        builder: (context, state) => const BusinessSetupScreen(),
      ),
      GoRoute(
        path: '/operation-setup',
        builder: (context, state) => const BusinessOperationScreen(),
      ),
      GoRoute(
        path: '/review-status',
        builder: (context, state) => const ReviewStatusScreen(),
      ),
      GoRoute(
        path: '/add-service',
        builder: (context, state) =>
            AddServiceScreen(service: state.extra as ServiceModel?),
      ),
      GoRoute(
        path: '/add-staff',
        builder: (context, state) =>
            AddStaffScreen(staff: state.extra as StaffModel?),
      ),

      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(path: '/tnc', builder: (context, state) => const TncScreen()),

      // Bottom nav shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: '/home',
          //       builder: (context, state) => const HomeScreen(),
          //       routes: [
          //         // nested screens within Home tab go here, e.g.:
          //         GoRoute(
          //           path: 'details/:id', // -> /home/details/123
          //           builder: (context, state) {
          //             final id = state.pathParameters['id']!;
          //             return HomeDetailsScreen(id: id);
          //           },
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DasboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (context, state) => const BookingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/walkin',
                builder: (context, state) => const WalkinScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
