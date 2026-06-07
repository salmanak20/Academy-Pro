import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../academy/application/academy_controller.dart';
import '../../academy/domain/academy.dart';
import '../../../theme.dart';
import '../../../widgets/app_side_nav.dart';
import '../../../widgets/dashboard_shell.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final academiesAsync = ref.watch(academiesStreamProvider);

    return DashboardShell(
      title: 'Platform Overview',
      activeTab: 'Dashboard',
      sidebarTitle: 'Academy Pro',
      sidebarSubtitle: 'Super Admin',
      navItems: [
        NavItemData(
          icon: Icons.dashboard,
          label: 'Dashboard',
          route: '/admin/dashboard',
        ),
        NavItemData(
          icon: Icons.school,
          label: 'Academies',
          route: '/admin/academies',
        ),
        NavItemData(
          icon: Icons.settings,
          label: 'Settings',
          route: '/admin/settings', // Add route if it exists, otherwise keep as is
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
                        'Platform Overview',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage and monitor all academies across the network.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 20),
                    label: const Text('Export Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Stats Bento Grid
              academiesAsync.when(
                data: (academies) {
                  final activeCount = academies.where((a) => a.status == AcademyStatus.active).length;
                  final disabledCount = academies.length - activeCount;

                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Academies',
                          value: academies.length.toString(),
                          icon: Icons.domain,
                          color: AppColors.secondary,
                          bgColor: AppColors.secondary.withOpacity(0.1),
                          trend: '12%',
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _StatCard(
                          title: 'Active Academies',
                          value: activeCount.toString(),
                          icon: Icons.check_circle,
                          color: const Color(0xFF10B981), // Emerald
                          bgColor: const Color(0xFF10B981).withOpacity(0.1),
                          trend: '5%',
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _StatCard(
                          title: 'Disabled Academies',
                          value: disabledCount.toString(),
                          icon: Icons.cancel,
                          color: AppColors.error,
                          bgColor: AppColors.error.withOpacity(0.1),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => SizedBox(
                  height: 140,
                  child: Center(
                    child: Text('Error loading stats: $e', style: const TextStyle(color: AppColors.error)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Chart Area (Mockup)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: _glassDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Academies Growth',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.outlineVariant),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: 'Last 12 Months',
                              isDense: true,
                              items: ['Last 12 Months', 'Last 6 Months', 'This Year']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                                  .toList(),
                              onChanged: (v) {},
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 300,
                      child: CustomPaint(
                        painter: _ChartMockupPainter(),
                        size: Size.infinite,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Academy Management Table
              Container(
                width: double.infinity,
                decoration: _glassDecoration(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Academy Management',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.primary,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.filter_list, color: AppColors.outline),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.outlineVariant),
                    academiesAsync.when(
                      data: (academies) {
                        if (academies.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(child: Text('No academies found.')),
                          );
                        }
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(AppColors.surfaceContainerLow),
                            columns: const [
                              DataColumn(label: Text('Academy Name', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.outline))),
                              DataColumn(label: Text('Principal', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.outline))),
                              DataColumn(label: Text('Contact', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.outline))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.outline))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.outline))),
                            ],
                            rows: academies.map((academy) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                          ),
                                          child: Text(
                                            academy.name.isNotEmpty ? academy.name[0].toUpperCase() : '?',
                                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(academy.name, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.primary)),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(academy.principalId ?? 'Unassigned', style: const TextStyle(color: AppColors.onSurfaceVariant))),
                                  DataCell(Text(academy.contact, style: const TextStyle(color: AppColors.onSurfaceVariant))),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: academy.status == AcademyStatus.active 
                                            ? const Color(0xFF10B981).withOpacity(0.1)
                                            : AppColors.outline.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: academy.status == AcademyStatus.active 
                                              ? const Color(0xFF10B981).withOpacity(0.2)
                                              : AppColors.outline.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: academy.status == AcademyStatus.active ? const Color(0xFF10B981) : AppColors.outline,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            academy.status == AcademyStatus.active ? 'Active' : 'Disabled',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: academy.status == AcademyStatus.active ? const Color(0xFF10B981) : AppColors.outline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 18, color: AppColors.secondary),
                                          onPressed: () {},
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            academy.status == AcademyStatus.active ? Icons.block : Icons.check_circle, 
                                            size: 18, 
                                            color: academy.status == AcademyStatus.active ? AppColors.outline : const Color(0xFF10B981)
                                          ),
                                          onPressed: () {},
                                          tooltip: academy.status == AcademyStatus.active ? 'Disable' : 'Enable',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
                                          onPressed: () {},
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
                        child: Center(child: Text('Error loading academies: $e', style: const TextStyle(color: AppColors.error))),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.outlineVariant),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Showing all academies', style: TextStyle(color: AppColors.outline, fontSize: 12)),
                          Row(
                            children: [
                              IconButton(icon: const Icon(Icons.chevron_left, size: 20), onPressed: null),
                              Container(
                                width: 32, height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              IconButton(icon: const Icon(Icons.chevron_right, size: 20), onPressed: null),
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

  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 51, 102, 0.04),
          blurRadius: 20,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String? trend;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.trend,
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
            color: Color.fromRGBO(0, 51, 102, 0.04),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, size: 16, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(trend!, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartMockupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = AppColors.outlineVariant.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final double stepY = size.height / 4;
    for (int i = 0; i <= 4; i++) {
      double y = i * stepY;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.cubicTo(size.width * 0.2, size.height * 0.7, size.width * 0.4, size.height * 0.9, size.width * 0.5, size.height * 0.5);
    path.cubicTo(size.width * 0.7, size.height * 0.2, size.width * 0.8, size.height * 0.4, size.width, size.height * 0.1);

    final paintLine = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paintLine);

    final areaPath = Path.from(path);
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();

    final paintArea = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.secondary.withOpacity(0.2), AppColors.secondary.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, paintArea);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
