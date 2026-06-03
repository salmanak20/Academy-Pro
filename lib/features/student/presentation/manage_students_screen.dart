import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/student_controller.dart';
import '../domain/student.dart';

class ManageStudentsScreen extends ConsumerWidget {
  const ManageStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
      ),
      body: studentsAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('No students enrolled yet.'));
          }
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(student.name.substring(0, 1).toUpperCase()),
                  ),
                  title: Text('${student.id} - ${student.name}'),
                  subtitle: Text('Class: ${student.studentClass} | Roll: ${student.rollNumber}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showStudentDialog(context, ref, student: student),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, ref, student),
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
        onPressed: () => _showStudentDialog(context, ref),
        child: const Icon(Icons.add),
      ),
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
          title: Text(student == null ? 'Add Student' : 'Edit Student'),
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
                  TextFormField(
                    controller: fatherNameController,
                    decoration: const InputDecoration(labelText: 'Father Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: classController,
                    decoration: const InputDecoration(labelText: 'Class'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: rollNumberController,
                    decoration: const InputDecoration(labelText: 'Roll Number'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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