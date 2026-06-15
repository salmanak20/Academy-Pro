import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../screens/admin/finance_management_screen.dart';
import '../../screens/admin/mark_attendance_screen.dart';

// Import Principal screens
import '../../screens/principal/principal_dashboard.dart';
import '../../features/dashboard/presentation/change_password_screen.dart';
import '../../screens/principal/reports_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  // Use a simpler notify logic to avoid ProviderSubscription errors
  final listenable = ValueNotifier<int>(0);
  
  ref.listen(authControllerProvider, (previous, next) {
    listenable.value++;
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final path = state.uri.path;

      // Handle loading state
      if (authState.isLoading) {
        return (path == '/splash' || path == '/login') ? null : '/splash';
      }

      final user = authState.value;

      // Redirect logic
      if (user == null) {
        return (path == '/login' || path == '/splash') ? null : '/login';
      }

      // If user is logged in but on splash or login, send them home
      if (path == '/splash' || path == '/login') {
        return _homeForRole(user.role);
      }

      // Role protection
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
        builder: (context, state) => const LoginScreen(),
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
        path: '/admin/finance',
        redirect: (context, state) => '/principal/finance',
      ),
      GoRoute(
        path: '/admin/attendance',
        redirect: (context, state) => '/principal/attendance',
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: const Center(child: Text('Settings Coming Soon')),
        ),
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
        path: '/principal/finance',
        builder: (context, state) => const FinanceManagementScreen(),
      ),
      GoRoute(
        path: '/principal/attendance',
        builder: (context, state) => const MarkAttendanceScreen(),
      ),
      GoRoute(
        path: '/principal/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/principal/reports',
        builder: (context, state) => const ReportsScreen(),
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
