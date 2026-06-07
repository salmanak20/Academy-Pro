import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/student_controller.dart';
import '../domain/student.dart';
import '../../../theme.dart';
import '../../../widgets/app_side_nav.dart';
import '../../../widgets/dashboard_shell.dart';

class ManageStudentsScreen extends ConsumerWidget {
  const ManageStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);

    return DashboardShell(
      title: 'Student Directory',
      activeTab: 'Students',
      sidebarTitle: 'Academy Pro',
      sidebarSubtitle: 'Principal',
      navItems: [
        NavItemData(
          icon: Icons.dashboard,
          label: 'Dashboard',
          route: '/principal/dashboard', // Adjust routes as needed
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
              // Page Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Directory',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage and view all enrolled students.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_list, size: 20),
                        label: const Text('Filters'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _showStudentDialog(context, ref),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Add Student'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Stats Bento
              academiesStatsGrid(studentsAsync),
              
              const SizedBox(height: 24),

              // Data Table Card
              Container(
                width: double.infinity,
                decoration: _glassDecoration(),
                child: Column(
                  children: [
                    // Table Toolbar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'All Students',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.onSurface,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('Active', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.view_column, color: AppColors.onSurfaceVariant, size: 20),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.download, color: AppColors.onSurfaceVariant, size: 20),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.outlineVariant),
                    
                    // Table Content
                    studentsAsync.when(
                      data: (students) {
                        if (students.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(48.0),
                            child: Center(child: Text('No students enrolled yet.', style: TextStyle(color: AppColors.onSurfaceVariant))),
                          );
                        }
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(AppColors.surfaceContainerLowest.withOpacity(0.8)),
                            dataRowMaxHeight: 64,
                            columns: const [
                              DataColumn(label: Text('Student ID', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, fontSize: 12))),
                              DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, fontSize: 12))),
                              DataColumn(label: Text('Class/Grade', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, fontSize: 12))),
                              DataColumn(label: Text('Roll No.', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, fontSize: 12))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, fontSize: 12))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, fontSize: 12))),
                            ],
                            rows: students.map((student) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(student.id.length > 8 ? student.id.substring(0, 8).toUpperCase() : student.id, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.primary))),
                                  DataCell(
                                    Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                            color: AppColors.secondaryContainer,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                                            style: const TextStyle(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(student.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                            if (student.fatherName.isNotEmpty)
                                              Text('D/O ${student.fatherName}', style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(student.studentClass, style: const TextStyle(color: AppColors.onSurface))),
                                  DataCell(Text(student.rollNumber, style: const TextStyle(color: AppColors.onSurfaceVariant))),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                                      ),
                                      child: const Text('Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF10B981))),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                                          onPressed: () => _showStudentDialog(context, ref, student: student),
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
                                          onPressed: () => _confirmDelete(context, ref, student),
                                          tooltip: 'Delete',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(48.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, st) => Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(child: Text('Error loading students: $e', style: const TextStyle(color: AppColors.error))),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.outlineVariant),
                    // Pagination
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Showing all students', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                          Row(
                            children: [
                              IconButton(icon: const Icon(Icons.chevron_left, size: 20, color: AppColors.onSurfaceVariant), onPressed: null),
                              Container(
                                width: 32, height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              IconButton(icon: const Icon(Icons.chevron_right, size: 20, color: AppColors.onSurfaceVariant), onPressed: null),
                            ],
                          ),
                        ],
                      ),
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

  Widget academiesStatsGrid(AsyncValue<List<Student>> studentsAsync) {
    return studentsAsync.when(
      data: (students) {
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Students',
                value: students.length.toString(),
                trend: '+12',
                trendIcon: Icons.trending_up,
                trendColor: const Color(0xFF10B981),
                bgDecoration: const Color(0xFF115CB9).withOpacity(0.05), // Secondary
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'New Enrollments',
                value: '45',
                bgDecoration: const Color(0xFFFFE16D).withOpacity(0.2), // Tertiary
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Action Required',
                value: '3',
                trend: 'Pending Docs',
                trendColor: AppColors.onSurfaceVariant,
                valueColor: AppColors.error,
                bgDecoration: AppColors.error.withOpacity(0.05),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
      error: (e, st) => const SizedBox(),
    );
  }

  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 51, 102, 0.05),
          blurRadius: 6,
          offset: Offset(0, 4),
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 51, 102, 0.03),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
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
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(student == null ? 'Add Student' : 'Edit Student', style: const TextStyle(color: AppColors.primary)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Student Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: fatherNameController,
                    decoration: const InputDecoration(labelText: 'Father Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: classController,
                    decoration: const InputDecoration(labelText: 'Class'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: rollNumberController,
                    decoration: const InputDecoration(labelText: 'Roll Number'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: AppColors.outline)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  showDialog(
                    context: dialogContext,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    if (student == null) {
                      await ref.read(studentControllerProvider.notifier).createStudent(
                            name: nameController.text,
                            fatherName: fatherNameController.text,
                            studentClass: classController.text,
                            rollNumber: rollNumberController.text,
                            phone: phoneController.text,
                            address: addressController.text,
                          );
                    } else {
                      await ref.read(studentControllerProvider.notifier).updateStudent(
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

                    if (!context.mounted) return;
                    final state = ref.read(studentControllerProvider);
                    Navigator.pop(dialogContext); // pop loading

                    if (state.hasError) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(student == null ? 'Student enrolled successfully' : 'Student updated successfully')));
                      Navigator.pop(dialogContext); // pop form dialog
                    }
                  } catch (e) {
                    Navigator.pop(dialogContext); // pop loading
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.outline))),
          TextButton(
            onPressed: () {
              ref.read(studentControllerProvider.notifier).deleteStudent(student.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? trend;
  final IconData? trendIcon;
  final Color? trendColor;
  final Color? valueColor;
  final Color bgDecoration;

  const _StatCard({
    required this.title,
    required this.value,
    this.trend,
    this.trendIcon,
    this.trendColor,
    this.valueColor,
    required this.bgDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 51, 102, 0.05),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: bgDecoration,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: valueColor ?? AppColors.primary,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  if (trend != null) ...[
                    const SizedBox(width: 8),
                    if (trendIcon != null) ...[
                      Icon(trendIcon, size: 16, color: trendColor),
                      const SizedBox(width: 2),
                    ],
                    Text(
                      trend!,
                      style: TextStyle(
                        fontSize: 14,
                        color: trendColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
