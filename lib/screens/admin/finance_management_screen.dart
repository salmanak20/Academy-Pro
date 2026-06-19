import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/dashboard_shell.dart';
import '../../widgets/app_side_nav.dart';
import '../../core/constants/nav_items.dart';
import '../../core/utils/app_snack_bar.dart';

class FinanceManagementScreen extends StatelessWidget {
  const FinanceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Finance Module',
      activeTab: 'Finance',
      navItems: principalNavItems,
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            AppSnackBar.showInfo(context, 'Generating Financial Report...');
          },
          icon: const Icon(Icons.receipt_long, size: 18),
          label: const Text('Generate Report'),
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
            label: 'Total Collected (Fees)',
            value: 'Rs. 0',
            trend: 'No recent collections',
            icon: Icons.account_balance_wallet,
            color: AppColors.primary,
          ),
          _SummaryCard(
            label: 'Total Paid (Salaries)',
            value: 'Rs. 0',
            trend: 'No recent payouts',
            icon: Icons.payments,
            color: AppColors.secondary,
            isSecondary: true,
          ),
          _SummaryCard(
            label: 'Pending Dues',
            value: 'Rs. 0',
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
          child: const Row(
            children: [
              _ActionButton(label: 'All Transactions', isActive: true),
              _ActionButton(label: 'Student Fees'),
              _ActionButton(label: 'Teacher Salaries'),
            ],
          ),
        ),
        const Spacer(),
        const _IconButton(icon: Icons.filter_list),
        const SizedBox(width: 12),
        const _IconButton(icon: Icons.download),
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
                  'Financial Transactions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
                ),
                const Text(
                  'Showing 0 Records',
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
                DataColumn(label: Text('NAME')),
                DataColumn(label: Text('ROLE / CLASS')),
                DataColumn(label: Text('TYPE')),
                DataColumn(label: Text('AMOUNT')),
                DataColumn(label: Text('DATE')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTION')),
              ],
              rows: const [], // Demo data removed as per request
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No financial records found.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
          )
        ],
      ),
    );
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
