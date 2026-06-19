import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme.dart';
import '../../widgets/app_side_nav.dart';
import '../../widgets/dashboard_shell.dart';
import '../../features/student/application/student_controller.dart';
import '../../features/teacher/application/teacher_controller.dart';
import '../../features/attendance/application/attendance_controller.dart';
import '../../features/attendance/domain/attendance.dart';
import '../../core/constants/nav_items.dart';
import '../../core/widgets/app_error_widget.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);
    final teachersAsync = ref.watch(teachersStreamProvider);
    final attendanceAsync = ref.watch(attendanceStreamProvider);

    return DashboardShell(
      title: 'Reports & Analytics',
      activeTab: 'Reports',
      sidebarTitle: 'Academy Pro',
      sidebarSubtitle: 'Principal',
      navItems: principalNavItems,
      body: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Reports & Analytics',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Overview of academy performance, enrollment, and attendance.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),

              // Summary Stat Cards
              _buildSummaryCards(context, studentsAsync, teachersAsync, attendanceAsync),
              const SizedBox(height: 32),

              // Attendance Breakdown
              _buildAttendanceReport(context, attendanceAsync),
              const SizedBox(height: 32),

              // Enrollment Summary
              _buildEnrollmentSummary(context, studentsAsync),
              const SizedBox(height: 32),

              // Teacher Summary
              _buildTeacherSummary(context, teachersAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    AsyncValue studentsAsync,
    AsyncValue teachersAsync,
    AsyncValue<List<Attendance>> attendanceAsync,
  ) {
    final studentCount = studentsAsync.maybeWhen(data: (list) => list.length, orElse: () => null);
    final teacherCount = teachersAsync.maybeWhen(data: (list) => list.length, orElse: () => null);
    final attendanceData = attendanceAsync.maybeWhen(data: (list) => list, orElse: () => null);
    final presentCount = attendanceData?.where((a) => a.status == AttendanceStatus.present).length ?? 0;
    final totalAttendance = attendanceData?.length ?? 0;
    final attendanceRate = totalAttendance > 0 ? (presentCount / totalAttendance * 100).toStringAsFixed(1) : '--';

    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth >= 900 ? 4 : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.7,
        children: [
          _ReportStatCard(
            label: 'Total Students',
            value: studentCount != null ? '$studentCount' : '...',
            icon: Icons.school,
            color: AppColors.primary,
          ),
          _ReportStatCard(
            label: 'Total Teachers',
            value: teacherCount != null ? '$teacherCount' : '...',
            icon: Icons.person_4,
            color: AppColors.secondary,
          ),
          _ReportStatCard(
            label: "Today's Attendance",
            value: totalAttendance > 0 ? '$presentCount / $totalAttendance' : 'N/A',
            icon: Icons.fact_check,
            color: const Color(0xFF10B981),
          ),
          _ReportStatCard(
            label: 'Attendance Rate',
            value: totalAttendance > 0 ? '$attendanceRate%' : 'N/A',
            icon: Icons.pie_chart,
            color: const Color(0xFFF59E0B),
          ),
        ],
      );
    });
  }

  Widget _buildAttendanceReport(BuildContext context, AsyncValue<List<Attendance>> attendanceAsync) {
    return _ReportCard(
      title: "Today's Attendance Summary",
      icon: Icons.event_available,
      child: attendanceAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: AppColors.outlineVariant),
                    SizedBox(height: 12),
                    Text(
                      'No attendance marked for today.',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Go to the Attendance module to mark attendance.',
                      style: TextStyle(fontSize: 12, color: AppColors.outlineVariant),
                    ),
                  ],
                ),
              ),
            );
          }
          final present = records.where((a) => a.status == AttendanceStatus.present).length;
          final absent = records.where((a) => a.status == AttendanceStatus.absent).length;
          final leave = records.where((a) => a.status == AttendanceStatus.leave).length;
          final total = records.length;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    _AttendanceBar(
                      label: 'Present',
                      count: present,
                      total: total,
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 16),
                    _AttendanceBar(
                      label: 'Absent',
                      count: absent,
                      total: total,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 16),
                    _AttendanceBar(
                      label: 'On Leave',
                      count: leave,
                      total: total,
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      if (present > 0)
                        Expanded(
                          flex: present,
                          child: Container(height: 12, color: const Color(0xFF10B981)),
                        ),
                      if (absent > 0)
                        Expanded(
                          flex: absent,
                          child: Container(height: 12, color: AppColors.error),
                        ),
                      if (leave > 0)
                        Expanded(
                          flex: leave,
                          child: Container(height: 12, color: const Color(0xFFF59E0B)),
                        ),
                      if (total == 0)
                        Expanded(
                          child: Container(height: 12, color: AppColors.outlineVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: AppErrorWidget(error: e, compact: true),
        ),
      ),
    );
  }

  Widget _buildEnrollmentSummary(BuildContext context, AsyncValue studentsAsync) {
    return _ReportCard(
      title: 'Student Enrollment',
      icon: Icons.school,
      child: studentsAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No students enrolled yet.', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
            );
          }

          // Group by class
          final Map<String, int> byClass = {};
          for (final student in students) {
            final cls = student.studentClass.isNotEmpty ? student.studentClass : 'Unassigned';
            byClass[cls] = (byClass[cls] ?? 0) + 1;
          }
          final sorted = byClass.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
          final maxCount = sorted.isEmpty ? 1 : sorted.first.value;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Enrolled: ${students.length} students',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                ...sorted.map((entry) {
                  final pct = entry.value / maxCount;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 10,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: AppErrorWidget(error: e, compact: true),
        ),
      ),
    );
  }

  Widget _buildTeacherSummary(BuildContext context, AsyncValue teachersAsync) {
    return _ReportCard(
      title: 'Teaching Staff Summary',
      icon: Icons.person_4,
      child: teachersAsync.when(
        data: (teachers) {
          if (teachers.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No teachers added yet.', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
            );
          }

          // Group by subject
          final Map<String, int> bySubject = {};
          double totalSalary = 0;
          for (final teacher in teachers) {
            final subj = teacher.subject.isNotEmpty ? teacher.subject : 'General';
            bySubject[subj] = (bySubject[subj] ?? 0) + 1;
            totalSalary += teacher.salary;
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        label: 'Total Faculty',
                        value: '${teachers.length}',
                        icon: Icons.group,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _InfoTile(
                        label: 'Monthly Salary Budget',
                        value: 'Rs ${totalSalary.toStringAsFixed(0)}',
                        icon: Icons.account_balance_wallet,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Subjects Covered',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: bySubject.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                      ),
                      child: Text(
                        '${entry.key} (${entry.value})',
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: AppErrorWidget(error: e, compact: true),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ReportCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 24, color: AppColors.outlineVariant),
          child,
        ],
      ),
    );
  }
}

class _ReportStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _AttendanceBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text('$pct%', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
