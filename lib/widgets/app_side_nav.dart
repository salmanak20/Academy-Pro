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
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        border: Border(
          right: BorderSide(
            color: AppColors.outlineVariant,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.local_police,
                  color: AppColors.tertiaryFixed,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white24),
              ),
            ),
            child: Column(
              children: [
                if (onSwitchRole != null)
                  ElevatedButton.icon(
                    onPressed: onSwitchRole,
                    icon: const Icon(Icons.swap_horiz, size: 20, color: AppColors.onSecondary),
                    label: const Text('Switch Role', style: TextStyle(color: AppColors.onSecondary)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: widget.isActive 
              ? Colors.white.withOpacity(0.1) 
              : (_isHovered ? Colors.white.withOpacity(0.05) : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
          border: widget.isActive
              ? const Border(
                  left: BorderSide(color: AppColors.tertiaryFixed, width: 4),
                )
              : const Border(
                  left: BorderSide(color: Colors.transparent, width: 4),
                ),
        ),
        child: ListTile(
          leading: AnimatedScale(
            scale: _isHovered ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Icon(
              widget.icon,
              color: widget.isActive ? AppColors.tertiaryFixed : (_isHovered ? Colors.white : Colors.white.withOpacity(0.6)),
            ),
          ),
          title: Text(
            widget.label,
            style: TextStyle(
              color: widget.isActive ? AppColors.tertiaryFixed : (_isHovered ? Colors.white : Colors.white.withOpacity(0.6)),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
