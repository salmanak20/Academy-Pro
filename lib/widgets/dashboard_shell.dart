import 'package:flutter/material.dart';
import '../theme.dart';
import 'app_side_nav.dart';

class DashboardShell extends StatelessWidget {
  final String title;
  final Widget body;
  final String activeTab;
  final List<NavItemData> navItems;
  final String sidebarTitle;
  final String sidebarSubtitle;
  final List<Widget>? actions;

  const DashboardShell({
    super.key,
    required this.title,
    required this.body,
    required this.activeTab,
    required this.navItems,
    this.sidebarTitle = 'Academy Pro',
    this.sidebarSubtitle = 'Elite Management',
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      drawer: isDesktop
          ? null
          : AppSideNav(
              title: sidebarTitle,
              subtitle: sidebarSubtitle,
              activeTab: activeTab,
              items: navItems,
            ),
      body: Row(
        children: [
          if (isDesktop)
            AppSideNav(
              title: sidebarTitle,
              subtitle: sidebarSubtitle,
              activeTab: activeTab,
              items: navItems,
            ),
          Expanded(
            child: Column(
              children: [
                _Header(
                  title: title,
                  showMenu: !isDesktop,
                  actions: actions,
                ),
                Expanded(
                  child: body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final bool showMenu;
  final List<Widget>? actions;

  const _Header({
    required this.title,
    this.showMenu = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.primary,
                ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
          const SizedBox(width: 16),
          const _SearchBar(),
          const SizedBox(width: 16),
          const _HeaderIcons(),
          const SizedBox(width: 16),
          const _UserProfile(),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 768) return const SizedBox();
    return Container(
      width: 280,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

class _HeaderIcons extends StatelessWidget {
  const _HeaderIcons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.history_edu, color: AppColors.primary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Viewing recent activity...')),
            );
          },
        ),
      ],
    );
  }
}

class _UserProfile extends StatelessWidget {
  const _UserProfile();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening user profile...')),
        );
      },
      child: const Icon(
        Icons.account_circle,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }
}
