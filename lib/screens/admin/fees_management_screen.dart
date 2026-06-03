import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/dashboard_shell.dart';
import '../../widgets/app_side_nav.dart';

class FeesManagementScreen extends StatelessWidget {
  const FeesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Student Fees Module',
      activeTab: 'Fees',
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Generating Monthly Fees...')),
            );
          },
          icon: const Icon(Icons.receipt_long, size: 18),
          label: const Text('Generate Monthly Fees'),
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
            _buildSummaryBento(),
            const SizedBox(height: 32),
            _buildActionBar(),
            const SizedBox(height: 32),
            _buildTransactionsTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBento() {
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
        childAspectRatio: 2.5,
        children: const [
          _SummaryCard(
            label: 'Total Collected',
            value: '\$452,800',
            trend: '12% increase from last term',
            icon: Icons.account_balance_wallet,
            color: AppColors.primary,
          ),
          _SummaryCard(
            label: 'Pending Fees',
            value: '\$84,200',
            trend: 'Expected by end of month',
            icon: Icons.stars,
            color: AppColors.secondary,
            isSecondary: true,
          ),
          _SummaryCard(
            label: 'Overdue Fees',
            value: '\$12,450',
            trend: 'Requires immediate attention',
            icon: Icons.report,
            color: AppColors.error,
            isError: true,
          ),
        ],
      );
    });
  }

  Widget _buildActionBar() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _ActionButton(label: 'All Students', isActive: true),
              _ActionButton(label: 'Paid'),
              _ActionButton(label: 'Unpaid'),
            ],
          ),
        ),
        const Spacer(),
        _IconButton(icon: Icons.filter_list),
        const SizedBox(width: 12),
        _IconButton(icon: Icons.download),
      ],
    );
  }

  Widget _buildTransactionsTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fee Transactions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
                ),
                const Text(
                  'Showing 48 Students',
                  style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 40,
              columns: const [
                DataColumn(label: Text('STUDENT NAME')),
                DataColumn(label: Text('CLASS')),
                DataColumn(label: Text('FEE TYPE')),
                DataColumn(label: Text('AMOUNT')),
                DataColumn(label: Text('DUE DATE')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTION')),
              ],
              rows: [
                _buildDataRow(
                  context: context,
                  name: 'Elizabeth Alexandra',
                  id: '#STU-2024-001',
                  className: 'Year 12 (Science)',
                  type: 'Tuition + Lab',
                  amount: '\$4,500.00',
                  date: 'Oct 15, 2023',
                  status: 'PAID',
                  initials: 'EA',
                ),
                _buildDataRow(
                  context: context,
                  name: 'Julian Windermere',
                  id: '#STU-2024-042',
                  className: 'Year 10 (Arts)',
                  type: 'Enrollment Fee',
                  amount: '\$2,800.00',
                  date: 'Sep 30, 2023',
                  status: 'OVERDUE',
                  initials: 'JW',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow({
    required BuildContext context,
    required String name,
    required String id,
    required String className,
    required String type,
    required String amount,
    required String date,
    required String status,
    required String initials,
  }) {
    Color statusColor = status == 'PAID' ? Colors.green : (status == 'OVERDUE' ? AppColors.error : AppColors.secondary);
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
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text(id, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      )),
      DataCell(Text(className)),
      DataCell(Text(type)),
      DataCell(Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
      DataCell(Text(date)),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
        ),
      )),
      DataCell(TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing fee action for $name')),
          );
        },
        child: const Text('Action'),
      )),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;
  final bool isSecondary;
  final bool isError;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
    this.isSecondary = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isError ? AppColors.errorContainer.withOpacity(0.1) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isError ? AppColors.error : AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 32,
                      color: isSecondary ? AppColors.secondary : (isError ? AppColors.error : AppColors.primary),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                trend,
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.7)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isActive;

  const _ActionButton({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.surfaceContainerHigh : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  const _IconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}
