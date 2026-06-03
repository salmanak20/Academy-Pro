import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/teacher_controller.dart';
import '../domain/teacher.dart';

class ManageTeachersScreen extends ConsumerWidget {
  const ManageTeachersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teachersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Teachers'),
      ),
      body: teachersAsync.when(
        data: (teachers) {
          if (teachers.isEmpty) {
            return const Center(child: Text('No teachers added yet.'));
          }
          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    child: Text(teacher.name.substring(0, 1).toUpperCase()),
                  ),
                  title: Text('${teacher.id} - ${teacher.name}'),
                  subtitle: Text('${teacher.subject} | ${teacher.qualification}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showTeacherDialog(context, ref, teacher: teacher),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, ref, teacher),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTeacherDialog(context, ref),
        child: const Icon(Icons.add),
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
          title: Text(teacher == null ? 'Add Teacher' : 'Edit Teacher'),
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
                  TextFormField(
                    controller: subjectController,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: qualificationController,
                    decoration: const InputDecoration(labelText: 'Qualification'),
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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