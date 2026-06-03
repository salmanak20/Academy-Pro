import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme.dart';
import '../../widgets/dashboard_shell.dart';
import '../../widgets/app_side_nav.dart';
import '../../features/student/application/student_controller.dart';
import '../../features/student/domain/student.dart';

class StudentsDirectoryScreen extends ConsumerWidget {
  const StudentsDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);

    return DashboardShell(
      title: 'Students Registry',
      activeTab: 'Students',
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
          onPressed: () => _showStudentDialog(context, ref),
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Add Student'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            _buildFilters(),
            const SizedBox(height: 32),
            studentsAsync.when(
              data: (students) {
                if (students.isEmpty) {
                  return const Center(child: Text('No students enrolled yet.'));
                }
                return _buildStudentGrid(context, students, ref);
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
        Text(
          'Student Body Registry',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Manage enrollments, academic performance, and financial status for the 2024-2025 semester.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: AppColors.outline),
          const SizedBox(width: 12),
          const Text(
            'Quick Filters',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(width: 24),
          _buildDropdown('All Classes'),
          const SizedBox(width: 16),
          _buildDropdown('Payment Status'),
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Text(hint, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }

  Widget _buildStudentGrid(BuildContext context, List<Student> students, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount = 1;
      if (constraints.maxWidth >= 1400) {
        crossAxisCount = 4;
      } else if (constraints.maxWidth >= 1000) {
        crossAxisCount = 3;
      } else if (constraints.maxWidth >= 600) {
        crossAxisCount = 2;
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          mainAxisExtent: 400,
        ),
        itemCount: students.length,
        itemBuilder: (context, index) {
          return _StudentCard(
            student: students[index],
            index: index,
            onEdit: () => _showStudentDialog(context, ref, student: students[index]),
            onDelete: () => _confirmDelete(context, ref, students[index]),
          );
        },
      );
    });
  }

  void _showStudentDialog(BuildContext context, WidgetRef ref, {Student? student}) {
    final nameController = TextEditingController(text: student?.name ?? '');
    final fatherNameController = TextEditingController(text: student?.fatherName ?? '');
    final classController = TextEditingController(text: student?.studentClass ?? '');
    final rollNumberController = TextEditingController(text: student?.rollNumber ?? '');
    final phoneController = TextEditingController(text: student?.phone ?? '');
    final addressController = TextEditingController(text: student?.address ?? '');
    
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(student == null ? 'Add Student' : 'Edit Student'),
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
                      decoration: const InputDecoration(labelText: 'Student Name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: fatherNameController,
                      decoration: const InputDecoration(labelText: 'Father Name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: classController,
                      decoration: const InputDecoration(labelText: 'Class'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: rollNumberController,
                      decoration: const InputDecoration(labelText: 'Roll Number'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
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
                  if (student == null) {
                    ref.read(studentControllerProvider.notifier).createStudent(
                          name: nameController.text,
                          fatherName: fatherNameController.text,
                          studentClass: classController.text,
                          rollNumber: rollNumberController.text,
                          phone: phoneController.text,
                          address: addressController.text,
                        );
                  } else {
                    ref.read(studentControllerProvider.notifier).updateStudent(
                          student.copyWith(
                            name: nameController.text,
                            fatherName: fatherNameController.text,
                            studentClass: classController.text,
                            rollNumber: rollNumberController.text,
                            phone: phoneController.text,
                            address: addressController.text,
                          ),
                        );
                  }
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(student == null ? 'Enroll' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(studentControllerProvider.notifier).deleteStudent(student.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StudentCard({
    required this.student,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final gpa = 'N/A'; // Mock for now
    final attendance = 90.0; // Mock for now
    final feeStatus = 'Pending'; // Mock for now

    final isDark = index % 3 == 2;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryContainer : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary.withOpacity(0.5)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              width: MediaQuery.of(context).size.width * (attendance / 100),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              student.name.isNotEmpty ? student.name.substring(0, 1).toUpperCase() : '?',
                              style: const TextStyle(fontSize: 32, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'GPA $gpa',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, size: 18, color: isDark ? Colors.white : AppColors.primary),
                          onPressed: onEdit,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  student.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ),
                Text(
                  student.id,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Class', student.studentClass, isDark),
                const SizedBox(height: 8),
                _buildInfoRow('Fee Status', feeStatus, isDark, isChip: true),
                const SizedBox(height: 16),
                Text(
                  'Attendance',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: attendance / 100,
                          backgroundColor: isDark ? Colors.white10 : AppColors.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(isDark ? AppColors.secondary : AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${attendance.toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: isDark ? Colors.white24 : AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'View Academic Profile',
                      style: TextStyle(color: isDark ? Colors.white : AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark, {bool isChip = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : AppColors.onSurfaceVariant,
          ),
        ),
        if (isChip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: value == 'Paid' ? AppColors.secondaryContainer : AppColors.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: value == 'Paid' ? AppColors.onSecondaryContainer : AppColors.error,
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
      ],
    );
  }
}
