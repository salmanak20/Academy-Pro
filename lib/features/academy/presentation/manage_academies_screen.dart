import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/academy_controller.dart';
import '../domain/academy.dart';
import '../../../widgets/app_side_nav.dart';
import '../../../widgets/dashboard_shell.dart';
import '../../../core/constants/nav_items.dart';
import '../../../core/utils/app_snack_bar.dart';
import '../../../core/widgets/app_error_widget.dart';

class ManageAcademiesScreen extends ConsumerWidget {
  const ManageAcademiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final academiesAsync = ref.watch(academiesStreamProvider);

    return DashboardShell(
      title: 'Manage Academies',
      activeTab: 'Academies',
      sidebarTitle: 'Academy Pro',
      sidebarSubtitle: 'Super Admin',
      navItems: adminNavItems,
      actions: [
        ElevatedButton.icon(
          onPressed: () => _showAcademyDialog(context, ref),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add Academy'),
        ),
      ],
      body: academiesAsync.when(
        data: (academies) {
          if (academies.isEmpty) {
            return const Center(child: Text('No academies found. Add one!'));
          }
          return ListView.builder(
            itemCount: academies.length,
            itemBuilder: (context, index) {
              final academy = academies[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('${academy.id} - ${academy.name}'),
                  subtitle: Text(academy.contact),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(
                          academy.status.toValue.toUpperCase(),
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        backgroundColor: academy.status == AcademyStatus.active ? Colors.green : Colors.red,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAcademyDialog(context, ref, academy: academy),
                      ),
                      IconButton(
                        icon: Icon(
                          academy.status == AcademyStatus.active ? Icons.block : Icons.check_circle,
                          color: academy.status == AcademyStatus.active ? Colors.red : Colors.green,
                        ),
                        onPressed: () {
                          ref.read(academyControllerProvider.notifier).toggleAcademyStatus(academy);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, ref, academy),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => AppErrorWidget(error: e),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Academy academy) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Academy'),
        content: Text(
          'Delete ${academy.name}? This also removes its students, teachers, attendance, fees, and salary records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(academyControllerProvider.notifier).deleteAcademy(academy.id);
              if (!context.mounted) return;
              final state = ref.read(academyControllerProvider);
              if (state.hasError) {
                AppSnackBar.showError(context, 'Delete failed', detail: state.error.toString());
              } else {
                AppSnackBar.showSuccess(context, 'Academy deleted successfully');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAcademyDialog(BuildContext context, WidgetRef ref, {Academy? academy}) {
    final nameController = TextEditingController(text: academy?.name ?? '');
    final addressController = TextEditingController(text: academy?.address ?? '');
    final contactController = TextEditingController(text: academy?.contact ?? '');
    final principalEmailController = TextEditingController();
    final principalPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(academy == null ? 'Add Academy' : 'Edit Academy'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Academy Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: contactController,
                    decoration: const InputDecoration(labelText: 'Contact Number'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  if (academy == null) ...[
                    TextFormField(
                      controller: principalEmailController,
                      decoration: const InputDecoration(labelText: 'Principal Email'),
                      validator: (v) => v!.isEmpty ? 'Required' : (!v.contains('@') ? 'Invalid email' : null),
                    ),
                    TextFormField(
                      controller: principalPasswordController,
                      decoration: const InputDecoration(labelText: 'Principal Password'),
                      obscureText: true,
                      validator: (v) => v!.isEmpty ? 'Required' : (v.length < 6 ? 'Min 6 chars' : null),
                    ),
                  ],
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
                  // Show loading dialog
                  showDialog(
                    context: dialogContext,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    if (academy == null) {
                      await ref.read(academyControllerProvider.notifier).createAcademy(
                            name: nameController.text,
                            address: addressController.text,
                            contact: contactController.text,
                            principalEmail: principalEmailController.text,
                            principalPassword: principalPasswordController.text,
                          );
                    } else {
                      await ref.read(academyControllerProvider.notifier).updateAcademy(
                            academy.copyWith(
                              name: nameController.text,
                              address: addressController.text,
                              contact: contactController.text,
                            ),
                          );
                    }

                    if (!context.mounted) return;
                    // Check for error in the state
                    final state = ref.read(academyControllerProvider);
                    
                    // Pop loading dialog
                    Navigator.pop(dialogContext);

                    if (state.hasError) {
                      AppSnackBar.showError(context, 'Failed to save academy', detail: state.error.toString());
                    } else {
                      AppSnackBar.showSuccess(context, academy == null ? 'Academy created successfully!' : 'Academy updated successfully!');
                      // Pop the form dialog
                      Navigator.pop(dialogContext);
                    }
                  } catch (e) {
                    // Pop loading dialog
                    Navigator.pop(dialogContext);
                    AppSnackBar.showError(context, 'Failed to save academy', detail: e.toString().replaceFirst('Exception: ', ''));
                  }
                }
              },
              child: Text(academy == null ? 'Create' : 'Save'),
            ),
          ],
        );
      },
    );
  }
}
