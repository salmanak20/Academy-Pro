import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../screens/splash_screen.dart';
import '../constants/app_constants.dart';

// Import Admin & Feature screens
import '../../features/dashboard/presentation/admin_dashboard.dart';
import '../../features/academy/presentation/manage_academies_screen.dart';
import '../../features/student/presentation/manage_students_screen.dart';
import '../../features/teacher/presentation/manage_teachers_screen.dart';
import '../../screens/admin/fees_management_screen.dart';
import '../../screens/admin/mark_attendance_screen.dart';

// Import Principal screens
import '../../screens/principal/principal_dashboard.dart';
import '../../features/dashboard/presentation/change_password_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final listenable = ValueNotifier<bool>(false);
  
  ref.listen(authControllerProvider, (_, _) {
    listenable.value = !listenable.value;
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final path = state.uri.path;

      if (authState.isLoading) {
        if (path == '/login') {
          return null; // Stay on login screen to show the spinner
        }
        return path == '/splash' ? null : '/splash';
      }

      final user = authState.hasValue ? authState.value : null;

      // Let the splash screen manage its own exit after animations
      if (path == '/splash') {
        return null;
      }

      final isLoginRoute = path == '/login';

      if (user == null) {
        return isLoginRoute ? null : '/login';
      }

      if (isLoginRoute) {
        return _homeForRole(user.role);
      }

      if (path.startsWith('/admin')) {
        final normalizedRole = user.role.toLowerCase();
        if (normalizedRole != AppConstants.roleSuperAdmin.toLowerCase() && normalizedRole != 'admin') {
          return _homeForRole(user.role);
        }
      }

      if (path.startsWith('/principal')) {
        final normalizedRole = user.role.toLowerCase();
        if (normalizedRole != AppConstants.rolePrincipal.toLowerCase()) {
          return _homeForRole(user.role);
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      ),
      // Super Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/admin/academies',
        builder: (context, state) => const ManageAcademiesScreen(),
      ),
      GoRoute(
        path: '/admin/students',
        redirect: (context, state) => '/principal/students',
      ),
      GoRoute(
        path: '/admin/salaries',
        redirect: (context, state) => '/principal/teachers',
      ),
      GoRoute(
        path: '/admin/fees',
        redirect: (context, state) => '/principal/fees',
      ),
      GoRoute(
        path: '/admin/attendance',
        redirect: (context, state) => '/principal/attendance',
      ),
      // Principal Routes
      GoRoute(
        path: '/principal/dashboard',
        builder: (context, state) => const PrincipalDashboard(),
      ),
      GoRoute(
        path: '/principal/students',
        builder: (context, state) => const ManageStudentsScreen(),
      ),
      GoRoute(
        path: '/principal/teachers',
        builder: (context, state) => const ManageTeachersScreen(),
      ),
      GoRoute(
        path: '/principal/fees',
        builder: (context, state) => const FeesManagementScreen(),
      ),
      GoRoute(
        path: '/principal/attendance',
        builder: (context, state) => const MarkAttendanceScreen(),
      ),
      GoRoute(
        path: '/principal/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],
  );
}

String _homeForRole(String role) {
  final normalizedRole = role.toLowerCase();
  if (normalizedRole == AppConstants.roleSuperAdmin.toLowerCase() || normalizedRole == 'admin') {
    return '/admin/dashboard';
  }
  if (normalizedRole == AppConstants.rolePrincipal.toLowerCase()) {
    return '/principal/dashboard';
  }
  return '/login';
}
