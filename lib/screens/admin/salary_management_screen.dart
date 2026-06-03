import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme.dart';
import '../../widgets/dashboard_shell.dart';
import '../../widgets/app_side_nav.dart';
import '../../features/teacher/application/teacher_controller.dart';
import '../../features/teacher/domain/teacher.dart';

class SalaryManagementScreen extends ConsumerWidget {
  const SalaryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teachersStreamProvider);

    return DashboardShell(
      title: 'Teacher Salary Management',
      activeTab: 'Salaries',
      navItems: const [
        NavItemData(icon: Icons.dashboard, label: 'Dashboard', route: '/principal/dashboard'),
        NavItemData(icon: Icons.group, label: 'Students', route: '/principal/students'),
        NavItemData(icon: Icons.person, label: 'Teachers', route: '/principal/teachers'),
        NavItemData(icon: Icons.payments, label: 'Fees', route: '/principal/fees'),
        NavItemData(icon: Icons.event_available, label: 'Attendance', route: '/principal/attendance'),
        NavItemData(icon: Icons.analytics, label: 'Reports'),
        NavItemData(icon: Icons.settings, label: 'Settings'),
      ],
      actions: [
        ElevatedButton.icon(
          onPressed: () => _showTeacherDialog(context, ref),
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Add Teacher'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(context),
            const SizedBox(height: 32),
            _buildSummaryGrid(),
            const SizedBox(height: 32),
            teachersAsync.when(
              data: (teachers) {
                return _buildPayrollSection(context, teachers, ref);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text('Financials', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
            Text(' / ', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
            Text('Teacher Payroll', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Teacher Salary Registry',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Manage disbursements, bonuses, and historical salary records for the current term.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount = 1;
      if (constraints.maxWidth >= 1024) {
        crossAxisCount = 3;
      } else if (constraints.maxWidth >= 600) {
        crossAxisCount = 2;
      }
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 2.2,
        children: const [
          _SalarySummaryCard(
            label: 'Paid Salaries',
            value: '\$482,500',
            subtitle: '84% of total budget disbursed',
            icon: Icons.check_circle,
            color: AppColors.primary,
            tag: 'Current Month',
          ),
          _SalarySummaryCard(
            label: 'Pending Salaries',
            value: '\$92,300',
            subtitle: '12 departments awaiting approval',
            icon: Icons.pending,
            color: AppColors.secondary,
            tag: 'Action Required',
          ),
          _SalarySummaryCard(
            label: 'Bonus Disbursed',
            value: '\$34,200',
            subtitle: 'Performance based incentives',
            icon: Icons.workspace_premium,
            color: AppColors.primary,
            tag: 'Term Total',
          ),
        ],
      );
    });
  }

  Widget _buildPayrollSection(BuildContext context, List<Teacher> teachers, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                _buildDropdown('All Departments'),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search teacher name...',
                        prefixIcon: Icon(Icons.search, size: 18),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildIconBtn(Icons.filter_list),
                const SizedBox(width: 12),
                _buildIconBtn(Icons.download),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 30,
              columns: const [
                DataColumn(label: Text('TEACHER NAME')),
                DataColumn(label: Text('SUBJECT')),
                DataColumn(label: Text('BASE SALARY')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows: teachers.map((teacher) {
                return _buildPayrollRow(
                  context: context,
                  ref: ref,
                  teacher: teacher,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          const Icon(Icons.expand_more, size: 18),
        ],
      ),
    );
  }

  Widget _buildIconBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
    );
  }

  DataRow _buildPayrollRow({
    required BuildContext context,
    required WidgetRef ref,
    required Teacher teacher,
  }) {
    final status = 'Pending';
    final isPaid = status == 'Paid';
    return DataRow(cells: [
      DataCell(Row(
        children: [
          const Icon(
            Icons.account_circle,
            size: 32,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(teacher.id, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      )),
      DataCell(Text(teacher.subject)),
      DataCell(Text('\$${teacher.salary.toStringAsFixed(2)}')),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 10),
        ),
      )),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () => _showTeacherDialog(context, ref, teacher: teacher),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref, teacher),
          ),
        ],
      )),
    ]);
  }

  void _showTeacherDialog(BuildContext context, WidgetRef ref, {Teacher? teacher}) {
    final nameController = TextEditingController(text: teacher?.name ?? '');
    final subjectController = TextEditingController(text: teacher?.subject ?? '');
    final qualificationController = TextEditingController(text: teacher?.qualification ?? '');
    final phoneController = TextEditingController(text: teacher?.phone ?? '');
    final salaryController = TextEditingController(text: teacher?.salary.toString() ?? '');
    
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(teacher == null ? 'Add Teacher' : 'Edit Teacher'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Teacher Name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: subjectController,
                      decoration: const InputDecoration(labelText: 'Subject'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: qualificationController,
                      decoration: const InputDecoration(labelText: 'Qualification'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: salaryController,
                      decoration: const InputDecoration(labelText: 'Salary'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty || double.tryParse(v) == null ? 'Invalid number' : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final salary = double.parse(salaryController.text);
                  if (teacher == null) {
                    ref.read(teacherControllerProvider.notifier).createTeacher(
                          name: nameController.text,
                          subject: subjectController.text,
                          qualification: qualificationController.text,
                          phone: phoneController.text,
                          salary: salary,
                        );
                  } else {
                    ref.read(teacherControllerProvider.notifier).updateTeacher(
                          teacher.copyWith(
                            name: nameController.text,
                            subject: subjectController.text,
                            qualification: qualificationController.text,
                            phone: phoneController.text,
                            salary: salary,
                          ),
                        );
                  }
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(teacher == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Teacher teacher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to delete ${teacher.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(teacherControllerProvider.notifier).deleteTeacher(teacher.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SalarySummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String tag;

  const _SalarySummaryCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 1.1),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, color: color),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.trending_up, size: 14, color: color.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
