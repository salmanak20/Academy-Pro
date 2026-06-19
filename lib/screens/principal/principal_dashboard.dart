import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';
import '../../widgets/dashboard_shell.dart';
import '../../widgets/app_side_nav.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/academy/application/academy_controller.dart';
import '../../core/constants/nav_items.dart';
import '../../core/utils/app_snack_bar.dart';
import '../../core/widgets/app_error_widget.dart';

class PrincipalDashboard extends ConsumerWidget {
  const PrincipalDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DashboardShell(
      title: 'Institutional Overview',
      sidebarTitle: 'Academy Pro',
      sidebarSubtitle: 'Elite Management',
      activeTab: 'Dashboard',
      navItems: principalNavItems,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(context),
            const SizedBox(height: 32),
            _buildStatsBento(ref),
            const SizedBox(height: 32),
            _buildChartsAndActions(context),
            const SizedBox(height: 32),
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Institutional Overview',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Academic Year 2024-25 | Spring Term Phase II',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildStatsBento(WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final academiesAsync = ref.watch(academiesStreamProvider);

    return academiesAsync.when(
      data: (academies) {
        if (academies.isEmpty || user?.academyId == null) {
          return const Center(child: Text('Academy profile is not available.'));
        }
        final academy = academies.firstWhere(
          (a) => a.id == user?.academyId,
          orElse: () => academies.first,
        );

        final totalStudents = academy.stats['students'] ?? 0;
        final totalTeachers = academy.stats['teachers'] ?? 0;
        final feesCollected = academy.stats['fees'] ?? 0;
        final salariesPaid = academy.stats['salary'] ?? 0;
        final attendance = academy.stats['attendance'] ?? 0;

        return LayoutBuilder(builder: (context, constraints) {
          int crossAxisCount = 2;
          if (constraints.maxWidth >= 1400) {
            crossAxisCount = 6;
          } else if (constraints.maxWidth >= 1000) {
            crossAxisCount = 3;
          }

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.5,
            children: [
              _PrincipalStatCard(
                label: 'Total Students',
                value: '$totalStudents',
                trend: 'Live',
                icon: Icons.groups,
              ),
              _PrincipalStatCard(
                label: 'Total Faculty',
                value: '$totalTeachers',
                icon: Icons.record_voice_over,
              ),
              _PrincipalStatCard(
                label: 'Fees Collected',
                value: 'Rs $feesCollected',
                icon: Icons.payments,
                isPremium: true,
              ),
              const _PrincipalStatCard(
                label: 'Pending Fees',
                value: '\$0',
                icon: Icons.pending_actions,
                isError: true,
              ),
              _PrincipalStatCard(
                label: 'Avg Attendance',
                value: '$attendance%',
                icon: Icons.fact_check,
              ),
              _PrincipalStatCard(
                label: 'Salaries Paid',
                value: 'Rs $salariesPaid',
                icon: Icons.account_balance_wallet,
              ),
            ],
          );
        });
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => AppErrorWidget(error: e),
    );
  }

  Widget _buildChartsAndActions(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 1100) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildRevenueTrends()),
            const SizedBox(width: 24),
            Expanded(flex: 1, child: _buildExecutiveActions(context)),
          ],
        );
      } else {
        return Column(
          children: [
            _buildRevenueTrends(),
            const SizedBox(height: 24),
            _buildExecutiveActions(context),
          ],
        );
      }
    });
  }

  Widget _buildRevenueTrends() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Revenue Trends', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  Text('Monthly Fee Collection Analysis', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
              _buildSimpleDropdown('Last 6 Months'),
            ],
          ),
          const Spacer(),
          const Center(
            child: Icon(Icons.show_chart, size: 120, color: Colors.black12),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildExecutiveActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text('EXECUTIVE ACTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.onSurfaceVariant)),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _ActionButton(
              icon: Icons.person_add, 
              label: 'Add Student', 
              onTap: () => AppSnackBar.showInfo(context, 'Add Student', detail: 'Navigate to the Students section to enroll.'),
            ),
            _ActionButton(
              icon: Icons.assignment_ind, 
              label: 'Add Teacher',
              onTap: () => AppSnackBar.showInfo(context, 'Add Teacher', detail: 'Navigate to the Teachers section to register.'),
            ),
            _ActionButton(
              icon: Icons.checklist, 
              label: 'Mark Attendance',
              onTap: () => context.go('/principal/attendance'),
            ),
            _ActionButton(
              icon: Icons.summarize, 
              label: 'Generate Reports', 
              isSecondary: true,
              onTap: () => AppSnackBar.showInfo(context, 'Generating Report', detail: 'Report generation coming soon.'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return const SizedBox.shrink(); // Demo attendance and faculty sections removed
  }

  Widget _buildAttendanceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Student Presence', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  Text('Weekly Attendance Breakdown', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
              Row(
                children: [
                  _buildLegend(AppColors.primary, 'PRESENT'),
                  const SizedBox(width: 12),
                  _buildLegend(AppColors.error, 'ABSENT'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildAttendanceBar('MON', 0.96),
          _buildAttendanceBar('TUE', 0.92),
          _buildAttendanceBar('WED', 0.95),
          _buildAttendanceBar('THU', 0.88),
          _buildAttendanceBar('FRI', 0.98),
        ],
      ),
    );
  }

  Widget _buildAttendanceBar(String day, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDepartmentLeads(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Department Leads', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
              TextButton(
                onPressed: () {
                  AppSnackBar.showInfo(context, 'Faculty Directory', detail: 'Viewing All Faculty Directory...');
                }, 
                child: const Text('View All Faculty'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFacultyItem('Dr. Julian Thorne', 'Head of Mathematics', 'In Lecture', AppColors.secondary),
          _buildFacultyItem('Sarah Jenkins, M.Sc.', 'Director of Arts', 'Available', Colors.green),
          _buildFacultyItem('Prof. Robert Sterling', 'Science & Research', 'On Break', AppColors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildFacultyItem(String name, String role, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                Text(role, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('STATUS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
              Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
            ],
          ),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSimpleDropdown(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 18),
        ],
      ),
    );
  }
}

class _PrincipalStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? trend;
  final IconData icon;
  final bool isPremium;
  final bool isError;

  const _PrincipalStatCard({
    required this.label,
    required this.value,
    this.trend,
    required this.icon,
    this.isPremium = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isPremium ? AppColors.secondary.withOpacity(0.3) : AppColors.primary.withOpacity(0.05)),
        boxShadow: isPremium ? [BoxShadow(color: AppColors.secondary.withOpacity(0.1), blurRadius: 30)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isError ? AppColors.errorContainer : (isPremium ? AppColors.secondaryFixed : AppColors.primaryFixed),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: isError ? AppColors.error : (isPremium ? AppColors.secondary : AppColors.primary), size: 20),
              ),
              if (trend != null)
                Text(trend!, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 1.1)),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: isError ? AppColors.error : AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSecondary;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, this.isSecondary = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: isSecondary ? AppColors.secondary : AppColors.primary),
              const SizedBox(height: 12),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
