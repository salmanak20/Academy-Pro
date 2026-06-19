import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/teacher_controller.dart';
import '../domain/teacher.dart';
import '../../../theme.dart';
import '../../../widgets/app_side_nav.dart';
import '../../../widgets/dashboard_shell.dart';
import '../../../core/constants/nav_items.dart';

class ManageTeachersScreen extends ConsumerWidget {
  const ManageTeachersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teachersStreamProvider);

    return DashboardShell(
      title: 'Manage Teachers',
      activeTab: 'Teachers',
      sidebarTitle: 'Academy Pro',
      sidebarSubtitle: 'Principal',
      navItems: principalNavItems,
      actions: [
        ElevatedButton.icon(
          onPressed: () => _showTeacherDialog(context, ref),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add Teacher'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 2,
          ),
        ),
      ],
      body: Container(
        color: AppColors.background,
        child: teachersAsync.when(
          data: (teachers) {
            if (teachers.isEmpty) {
              return const Center(child: Text('No teachers added yet.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final teacher = teachers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                  ),
                  elevation: 0,
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        teacher.name.isNotEmpty ? teacher.name.substring(0, 1).toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      teacher.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    subtitle: Text(
                      '${teacher.subject} | ${teacher.qualification} | Rs. ${teacher.salary}',
                      style: const TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
                          onPressed: () => _showTeacherDialog(context, ref, teacher: teacher),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                          onPressed: () => _confirmDelete(context, ref, teacher),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
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
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(teacher == null ? 'Add Teacher' : 'Edit Teacher', style: const TextStyle(color: AppColors.primary)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Teacher Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: subjectController,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: qualificationController,
                    decoration: const InputDecoration(labelText: 'Qualification'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: salaryController,
                    decoration: const InputDecoration(labelText: 'Salary (Rs.)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty || double.tryParse(v) == null ? 'Invalid number' : null,
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
                  final salary = double.parse(salaryController.text);
                  
                  showDialog(
                    context: dialogContext,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    if (teacher == null) {
                      await ref.read(teacherControllerProvider.notifier).createTeacher(
                            name: nameController.text,
                            subject: subjectController.text,
                            qualification: qualificationController.text,
                            phone: phoneController.text,
                            salary: salary,
                          );
                    } else {
                      await ref.read(teacherControllerProvider.notifier).updateTeacher(
                            teacher.copyWith(
                              name: nameController.text,
                              subject: subjectController.text,
                              qualification: qualificationController.text,
                              phone: phoneController.text,
                              salary: salary,
                            ),
                          );
                    }
                    
                    if (!context.mounted) return;
                    final state = ref.read(teacherControllerProvider);
                    Navigator.pop(dialogContext); // pop loading

                    if (state.hasError) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teacher == null ? 'Teacher added successfully' : 'Teacher updated successfully')));
                      Navigator.pop(dialogContext); // pop form dialog
                    }
                  } catch (e) {
                    Navigator.pop(dialogContext); // pop loading
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to delete ${teacher.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.outline))),
          TextButton(
            onPressed: () {
              ref.read(teacherControllerProvider.notifier).deleteTeacher(teacher.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
