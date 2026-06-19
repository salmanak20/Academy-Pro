import 'package:flutter/material.dart';
import '../../widgets/app_side_nav.dart';

/// Shared sidebar nav items for all Principal-role screens.
/// Update here to reflect changes across every principal screen.
const List<NavItemData> principalNavItems = [
  NavItemData(icon: Icons.dashboard, label: 'Dashboard', route: '/principal/dashboard'),
  NavItemData(icon: Icons.school, label: 'Students', route: '/principal/students'),
  NavItemData(icon: Icons.person_4, label: 'Teachers', route: '/principal/teachers'),
  NavItemData(icon: Icons.payments, label: 'Finance', route: '/principal/finance'),
  NavItemData(icon: Icons.event_available, label: 'Attendance', route: '/principal/attendance'),
  NavItemData(icon: Icons.bar_chart, label: 'Reports', route: '/principal/reports'),
];

/// Shared sidebar nav items for all Admin/SuperAdmin-role screens.
const List<NavItemData> adminNavItems = [
  NavItemData(icon: Icons.dashboard, label: 'Dashboard', route: '/admin/dashboard'),
  NavItemData(icon: Icons.school, label: 'Academies', route: '/admin/academies'),
];
