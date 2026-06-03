import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme.dart';
import '../../widgets/dashboard_shell.dart';
import '../../widgets/app_side_nav.dart';
import 'widgets/add_academy_dialog.dart';
import '../../features/academy/application/academy_controller.dart';
import '../../features/academy/domain/academy.dart';

class ManageAcademiesScreen extends ConsumerWidget {
  const ManageAcademiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DashboardShell(
      title: 'Manage Academies',
      activeTab: 'Academies',
      navItems: const [
        NavItemData(icon: Icons.dashboard, label: 'Dashboard', route: '/admin/dashboard'),
        NavItemData(icon: Icons.business, label: 'Academies', route: '/admin/academies'),
      ],
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AddAcademyDialog(),
            );
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Academy'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryContainer,
            foregroundColor: AppColors.onSecondaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(),
            const SizedBox(height: 32),
            _buildAcademyGrid(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'STATUS FILTER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _FilterButton(label: 'All', isActive: true),
                  _FilterButton(label: 'Active'),
                  _FilterButton(label: 'Disabled'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcademyGrid(BuildContext context, WidgetRef ref) {
    final academiesAsyncValue = ref.watch(academiesStreamProvider);

    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount = 1;
      if (constraints.maxWidth >= 1200) {
        crossAxisCount = 3;
      } else if (constraints.maxWidth >= 800) {
        crossAxisCount = 2;
      }
      
      return academiesAsyncValue.when(
        data: (academies) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              mainAxisExtent: 380,
            ),
            itemCount: academies.length + 1,
            itemBuilder: (context, index) {
              if (index == academies.length) return _buildAddPlaceholder(context);
              return _AcademyCardView(academy: academies[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      );
    });
  }

  Widget _buildAddPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.5),
          width: 2,
          style: BorderStyle.none, // Can't easily do dashed in Flutter without package
        ),
        color: AppColors.surfaceContainerHigh.withOpacity(0.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Starting onboarding process...')),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_business, size: 32, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Register New Institution',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              const Text(
                'Click to begin the onboarding process',
                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;

  const _FilterButton({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                )
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _AcademyCardView extends StatelessWidget {
  final Academy academy;
  const _AcademyCardView({required this.academy});

  @override
  Widget build(BuildContext context) {
    final status = academy.status == AcademyStatus.active ? 'Active' : 'Disabled';
    final statusColor = academy.status == AcademyStatus.active ? Colors.green : AppColors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.account_balance, color: AppColors.primary, size: 32),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status == 'Active')
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            academy.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Address: ${academy.address}',
                  style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: AppColors.outlineVariant.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL STUDENTS',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                      ),
                      Row(
                        children: [
                          const Text(
                            '1,240',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.secondary),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.groups, size: 16, color: AppColors.secondary.withOpacity(0.3)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL TEACHERS',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                      ),
                      Row(
                        children: [
                          const Text(
                            '142',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.psychology, size: 16, color: AppColors.primary.withOpacity(0.3)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Editing/Updating ${academy.name}')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Edit', style: TextStyle(color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${status == 'Active' ? 'Disabling' : 'Enabling'} ${academy.name}')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: status == 'Active' ? AppColors.error : Colors.green),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(status == 'Active' ? 'Disable' : 'Enable', style: TextStyle(color: status == 'Active' ? AppColors.error : Colors.green)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deleting ${academy.name}')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
