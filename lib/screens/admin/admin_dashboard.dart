import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme.dart';
import '../../widgets/app_side_nav.dart';
import 'package:fl_chart/fl_chart.dart';
import 'widgets/add_academy_dialog.dart';
import '../../features/academy/application/academy_controller.dart';
import '../../features/academy/domain/academy.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      drawer: isDesktop ? null : _buildSideNav(context),
      body: Row(
        children: [
          if (isDesktop) _buildSideNav(context),
          Expanded(
            child: Column(
              children: [
                const _Header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPageHeader(context),
                        const SizedBox(height: 32),
                        const _StatsGrid(),
                        const SizedBox(height: 32),
                        const _ChartsSection(),
                      ],
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

  Widget _buildSideNav(BuildContext context) {
    return const AppSideNav(
      title: 'Academy Pro',
      subtitle: 'Super Admin Portal',
      activeTab: 'Dashboard',
      items: [
        NavItemData(icon: Icons.dashboard, label: 'Dashboard', route: '/admin/dashboard'),
        NavItemData(icon: Icons.business, label: 'Academies', route: '/admin/academies'),
      ],
      onSwitchRole: null,
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Overview',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Global metrics and analytics across all registered institutions.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildHeaderButton(
              context,
              label: 'Add Academy',
              icon: Icons.add,
              isPrimary: true,
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AddAcademyDialog(),
                );
              },
            ),
            _buildHeaderButton(
              context,
              label: 'Disable',
              icon: Icons.block,
            ),
            _buildHeaderButton(
              context,
              label: 'Export',
              icon: Icons.download,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    bool isPrimary = false,
    VoidCallback? onPressed,
  }) {
    return Container(
      decoration: isPrimary
          ? BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A2E73), Color(0xFF003EA8)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: ElevatedButton.icon(
        onPressed: onPressed ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label action triggered')),
          );
        },
        icon: Icon(
          icon,
          size: 18,
          color: isPrimary ? Colors.white : AppColors.primary,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isPrimary ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.transparent : Colors.white,
          shadowColor: Colors.transparent,
          side: isPrimary ? null : const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width < 1024)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onSubmitted: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Searching for: $value')),
                  );
                },
                decoration: const InputDecoration(
                  hintText: 'Search academies, students...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile settings opened')),
              );
            },
            child: const Icon(
              Icons.account_circle,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends ConsumerWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final academiesAsync = ref.watch(academiesStreamProvider);

    return academiesAsync.when(
      data: (academies) {
        int totalAcademies = academies.length;
        int activeAcademies = academies.where((a) => a.status == AcademyStatus.active).length;
        int disabledAcademies = totalAcademies - activeAcademies;
        
        int totalStudents = 0;
        int totalTeachers = 0;
        
        for (var academy in academies) {
          totalStudents += (academy.stats['students'] ?? 0) as int;
          totalTeachers += (academy.stats['teachers'] ?? 0) as int;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
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
              childAspectRatio: 2,
              children: [
                _StatCard(
                  title: 'Total Academies',
                  value: '$totalAcademies',
                  subtitle: 'Registered institutions',
                  progress: totalAcademies == 0 ? 0 : activeAcademies / totalAcademies,
                  icon: Icons.account_balance,
                  iconColor: AppColors.secondary,
                  iconBgColor: AppColors.secondaryFixed,
                  hasGlow: true,
                ),
                _StatCard(
                  title: 'Active Academies',
                  value: '$activeAcademies',
                  trend: '$disabledAcademies disabled',
                  icon: Icons.verified,
                  iconColor: AppColors.primary,
                  iconBgColor: AppColors.primaryFixed,
                ),
                _StatCard(
                  title: 'Disabled Academies',
                  value: '$disabledAcademies',
                  icon: Icons.gpp_bad,
                  iconColor: AppColors.error,
                  iconBgColor: AppColors.errorContainer,
                  borderColor: AppColors.error,
                ),
                _StatCard(
                  title: 'Total Students',
                  value: '$totalStudents',
                  icon: Icons.groups,
                  iconColor: AppColors.primaryContainer,
                  iconBgColor: AppColors.primaryFixed,
                ),
                _StatCard(
                  title: 'Total Teachers',
                  value: '$totalTeachers',
                  icon: Icons.psychology,
                  iconColor: AppColors.primaryContainer,
                  iconBgColor: AppColors.primaryFixed,
                ),
                const _StatCard(
                  title: 'Monthly Revenue',
                  value: 'N/A', // Assuming revenue calculation not fully defined
                  icon: Icons.monetization_on,
                  iconColor: AppColors.secondary,
                  iconBgColor: AppColors.secondaryFixed,
                  hasGlow: true,
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? trend;
  final String? subtitle;
  final double? progress;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color? borderColor;
  final bool hasGlow;

  const _StatCard({
    required this.title,
    required this.value,
    this.trend,
    this.subtitle,
    this.progress,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.borderColor,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? AppColors.primary.withOpacity(0.1),
          width: borderColor != null ? 2 : 1,
        ),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: iconColor.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 4),
              if (trend != null)
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppColors.secondary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      trend!,
                      style: const TextStyle(color: AppColors.secondary, fontSize: 12),
                    ),
                  ],
                ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                ),
              if (progress != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surfaceContainerHighest,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primaryContainer),
                      minHeight: 6,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartsSection extends StatelessWidget {
  const _ChartsSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _GrowthChart()),
              SizedBox(width: 24),
              Expanded(flex: 1, child: _RevenueChart()),
            ],
          );
        } else {
          return const Column(
            children: [
              _GrowthChart(),
              SizedBox(height: 24),
              _RevenueChart(),
            ],
          );
        }
      },
    );
  }
}

class _GrowthChart extends StatelessWidget {
  const _GrowthChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Academy Growth',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('This Year'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['Jan', 'Mar', 'Jun', 'Sep', 'Dec'];
                        if (value % 2 == 0 && value < months.length * 2) {
                          return Text(months[(value / 2).toInt()]);
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('0');
                        if (value == 500) return const Text('500');
                        if (value == 1000) return const Text('1.0k');
                        if (value == 1500) return const Text('1.5k');
                        return const SizedBox();
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
                    left: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 200),
                      FlSpot(2, 400),
                      FlSpot(4, 700),
                      FlSpot(6, 1100),
                      FlSpot(8, 1400),
                    ],
                    isCurved: true,
                    color: AppColors.primaryContainer,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primaryContainer.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue Analytics',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Icon(Icons.more_vert),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const quarters = ['Q1', 'Q2', 'Q3', 'Q4'];
                        if (value.toInt() < quarters.length) {
                          return Text(quarters[value.toInt()]);
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: 1.2,
                        color: AppColors.primaryContainer.withOpacity(0.2),
                        width: 40,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: 2.1,
                        color: AppColors.primaryContainer.withOpacity(0.4),
                        width: 40,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: 1.8,
                        color: AppColors.primaryContainer.withOpacity(0.7),
                        width: 40,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(
                        toY: 3.4,
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryContainer, AppColors.secondary],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 40,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
