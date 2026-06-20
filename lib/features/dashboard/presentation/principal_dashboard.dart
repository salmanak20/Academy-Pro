import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../student/application/student_controller.dart';
import '../../teacher/application/teacher_controller.dart';
import '../../../core/widgets/app_error_widget.dart';

class PrincipalDashboard extends ConsumerWidget {
  const PrincipalDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final studentsAsync = ref.watch(studentsStreamProvider);
    final teachersAsync = ref.watch(teachersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Principal Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      drawer: NavigationDrawer(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Academy Pro',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => context.pop(), // Close drawer
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Students'),
            onTap: () {
              context.pop();
              context.push('/principal/students');
            },
          ),
          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('Manage Teachers'),
            onTap: () {
              context.pop();
              context.push('/principal/teachers');
            },
          ),
          ListTile(
            leading: const Icon(Icons.payments),
            title: const Text('Fees'),
            onTap: () {
              context.pop();
              context.push('/principal/fees');
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_available),
            title: const Text('Attendance'),
            onTap: () {
              context.pop();
              context.push('/principal/attendance');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              context.pop();
              context.push('/principal/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text(
                'Welcome, ${user.name ?? 'Principal'}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                'Role: ${user.role}',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Academy Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                if (isMobile) {
                  return Column(
                    children: [
                      _buildStatCard(
                        context,
                        title: 'Total Students',
                        asyncValue: studentsAsync,
                        icon: Icons.school,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        context,
                        title: 'Total Teachers',
                        asyncValue: teachersAsync,
                        icon: Icons.person,
                        color: Colors.purple,
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Total Students',
                        asyncValue: studentsAsync,
                        icon: Icons.school,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Total Teachers',
                        asyncValue: teachersAsync,
                        icon: Icons.person,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required AsyncValue<List<dynamic>> asyncValue, required IconData icon, required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            asyncValue.when(
              data: (list) => Text(
                list.length.toString(),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => const Icon(Icons.error_outline, color: Color(0xFFBA1A1A)),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color),
            ),
          ],
        ),
      ),
    );
  }
}
