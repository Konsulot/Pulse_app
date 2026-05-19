import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/presentation/screens/access_disabled_screen.dart';
import '../features/auth/presentation/screens/auth_check_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/waiting_approval_screen.dart';
import '../features/admin/presentation/screens/admin_doctors_screen.dart';
import '../features/examinations/presentation/screens/exam_e42_screen.dart';
import '../features/examinations/presentation/screens/exam_energy_screen.dart';
import '../features/examinations/presentation/screens/exam_foot_screen.dart';
import '../features/examinations/presentation/screens/exam_p9_screen.dart';
import '../features/examinations/presentation/screens/exam_star1_part2_screen.dart';
import '../features/examinations/presentation/screens/exam_star1_screen.dart';
import '../features/examinations/presentation/screens/exam_star2_screen.dart';
import '../features/examinations/presentation/screens/exam_parameters_screen.dart';
import '../features/examinations/presentation/screens/examination_create_screen.dart';
import '../features/examinations/presentation/screens/current_examinations_screen.dart';
import '../features/examinations/presentation/screens/examination_result_screen.dart';
import '../features/examinations/presentation/screens/examination_hexagram_screen.dart';
import '../features/examinations/presentation/screens/examination_meridians_screen.dart';
import '../features/patients/presentation/screens/patient_create_screen.dart';
import '../features/patients/presentation/screens/patient_details_screen.dart';
import '../features/patients/presentation/screens/patient_edit_screen.dart';
import '../features/patients/presentation/screens/patients_list_screen.dart';
import '../features/profiles/presentation/screens/doctor_profile_screen.dart';

final _supabase = Supabase.instance.client;

final appRouter = GoRouter(
  initialLocation: '/auth-check',
  redirect: (context, state) {
    final isLoggedIn = _supabase.auth.currentSession != null;
    final location = state.matchedLocation;
    final isPublicRoute = location == '/login' ||
        location == '/register' ||
        location == '/forgot-password' ||
        location == '/reset-password';

    if (!isLoggedIn && !isPublicRoute) return '/login';

    if (isLoggedIn &&
        (location == '/login' ||
            location == '/register' ||
            location == '/forgot-password')) {
      return '/auth-check';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/auth-check', builder: (context, state) => const AuthCheckScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),
    GoRoute(path: '/waiting-approval', builder: (context, state) => const WaitingApprovalScreen()),
    GoRoute(path: '/access-disabled', builder: (context, state) => const AccessDisabledScreen()),
    GoRoute(path: '/admin', builder: (context, state) => const AdminDoctorsScreen()),
    GoRoute(path: '/patients', builder: (context, state) => const PatientsListScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const DoctorProfileScreen()),
    GoRoute(path: '/examinations/current', builder: (context, state) => const CurrentExaminationsScreen()),
    GoRoute(path: '/patients/create', builder: (context, state) => const PatientCreateScreen()),
    GoRoute(
      path: '/patients/:id',
      builder: (context, state) => PatientDetailsScreen(patientId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/patients/:id/edit',
      builder: (context, state) => PatientEditScreen(patientId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/patients/:id/examinations/create',
      builder: (context, state) => ExaminationCreateScreen(patientId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/examinations/:id/star1',
      builder: (context, state) => ExamStar1Screen(
        examinationId: state.pathParameters['id']!,
        from: state.uri.queryParameters['from'],
      ),
    ),
    GoRoute(
      path: '/examinations/:id/star1-part2',
      builder: (context, state) => ExamStar1Part2Screen(
        examinationId: state.pathParameters['id']!,
        from: state.uri.queryParameters['from'],
      ),
    ),
    GoRoute(
      path: '/examinations/:id/star2',
      builder: (context, state) => ExamStar2Screen(
        examinationId: state.pathParameters['id']!,
        from: state.uri.queryParameters['from'],
      ),
    ),
    GoRoute(
      path: '/examinations/:id/parameters',
      builder: (context, state) => ExamParametersScreen(
        examinationId: state.pathParameters['id']!,
        from: state.uri.queryParameters['from'],
      ),
    ),
    GoRoute(
      path: '/examinations/:id/energy',
      builder: (context, state) => ExamEnergyScreen(
        examinationId: state.pathParameters['id']!,
        from: state.uri.queryParameters['from'],
      ),
    ),
    GoRoute(
      path: '/examinations/:id/p9',
      builder: (context, state) => ExamP9Screen(
        examinationId: state.pathParameters['id']!,
        from: state.uri.queryParameters['from'],
      ),
    ),
    GoRoute(
      path: '/examinations/:id/e42',
      builder: (context, state) => ExamE42Screen(
        examinationId: state.pathParameters['id']!,
        from: state.uri.queryParameters['from'],
      ),
    ),
    GoRoute(
      path: '/examinations/:id/foot',
      builder: (context, state) => ExamFootScreen(
        examinationId: state.pathParameters['id']!,
        from: state.uri.queryParameters['from'],
      ),
    ),
    GoRoute(
      path: '/examinations/:id/result',
      builder: (context, state) => ExaminationResultScreen(examinationId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/examinations/:id/meridians',
      builder: (context, state) => ExaminationMeridiansScreen(examinationId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/examinations/:id/hexagram',
      builder: (context, state) => ExaminationHexagramScreen(examinationId: state.pathParameters['id']!),
    ),
  ],
);
