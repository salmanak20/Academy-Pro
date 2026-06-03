import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../theme.dart';

class AppSideNav extends ConsumerWidget {
  final String title;
  final String subtitle;
  final String activeTab;
  final List<NavItemData> items;
  final VoidCallback? onSwitchRole;

  const AppSideNav({
    super.key,
    required this.title,
    required this.subtitle,
    required this.activeTab,
    required this.items,
    this.onSwitchRole,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(
          right: BorderSide(
            color: AppColors.primary.withOpacity(0.05),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: items.map((item) {
                return _AnimatedNavItem(
                  icon: item.icon,
                  label: item.label,
                  isActive: activeTab == item.label,
                  route: item.route,
                  onTap: item.onTap,
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (onSwitchRole != null)
                  OutlinedButton(
                    onPressed: onSwitchRole,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('Switch Role'),
                  ),
                const SizedBox(height: 12),
                _AnimatedNavItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  onTap: () => ref.read(authControllerProvider.notifier).logout(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final String? route;
  final VoidCallback? onTap;

  const _AnimatedNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.route,
    this.onTap,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: widget.isActive ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: widget.isActive
              ? const Border(
                  left: BorderSide(color: AppColors.secondary, width: 4),
                )
              : null,
        ),
        child: ListTile(
          leading: AnimatedScale(
            scale: _isHovered ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Icon(
              widget.icon,
              color: widget.isActive ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
          title: Text(
            widget.label,
            style: TextStyle(
              color: widget.isActive ? Colors.white : AppColors.onSurfaceVariant,
              fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            } else if (widget.route != null) {
              context.go(widget.route!);
            }
          },
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class NavItemData {
  final IconData icon;
  final String label;
  final String? route;
  final VoidCallback? onTap;

  const NavItemData({
    required this.icon,
    required this.label,
    this.route,
    this.onTap,
  });
}
