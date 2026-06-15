import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme.dart';
import '../../widgets/app_side_nav.dart';
import '../../widgets/dashboard_shell.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DashboardShell(
      title: 'Reports',
      activeTab: 'Reports',
      sidebarTitle: 'Academy Pro',
      sidebarSubtitle: 'Principal',
      navItems: [
        NavItemData(
          icon: Icons.dashboard,
          label: 'Dashboard',
          route: '/principal/dashboard',
        ),
        NavItemData(
          icon: Icons.school,
          label: 'Students',
          route: '/principal/students',
        ),
        NavItemData(
          icon: Icons.person_4,
          label: 'Teachers',
          route: '/principal/teachers',
        ),
        NavItemData(
          icon: Icons.event_available,
          label: 'Attendance',
          route: '/principal/attendance',
        ),
        NavItemData(
          icon: Icons.payments,
          label: 'Finance',
          route: '/principal/finance',
        ),
        NavItemData(
          icon: Icons.bar_chart,
          label: 'Reports',
          route: '/principal/reports',
        ),
      ],
      body: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reports & Analytics',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'View academy performance, attendance trends, and financial reports.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    Icon(Icons.construction, size: 64, color: AppColors.primary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'Reports Coming Soon',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'We are working on bringing you powerful insights.',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
