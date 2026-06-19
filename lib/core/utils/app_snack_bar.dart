import 'package:flutter/material.dart';

enum _SnackBarType { success, error, info, warning }

class AppSnackBar {
  // ─── Public API ──────────────────────────────────────────────────────────────

  static void showSuccess(BuildContext context, String message, {String? detail}) {
    _show(context, message, detail: detail, type: _SnackBarType.success);
  }

  static void showError(BuildContext context, String message, {String? detail}) {
    _show(context, message, detail: detail, type: _SnackBarType.error);
  }

  static void showInfo(BuildContext context, String message, {String? detail}) {
    _show(context, message, detail: detail, type: _SnackBarType.info);
  }

  static void showWarning(BuildContext context, String message, {String? detail}) {
    _show(context, message, detail: detail, type: _SnackBarType.warning);
  }

  // ─── Internal ────────────────────────────────────────────────────────────────

  static void _show(
    BuildContext context,
    String message, {
    String? detail,
    required _SnackBarType type,
  }) {
    final theme = _themeFor(type);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: Duration(seconds: type == _SnackBarType.error ? 5 : 3),
          content: _SnackBarContent(
            message: message,
            detail: detail,
            icon: theme.icon,
            accentColor: theme.accentColor,
            iconBgColor: theme.iconBgColor,
          ),
        ),
      );
  }
}

// ─── Visual Theme ─────────────────────────────────────────────────────────────

class _SnackTheme {
  final IconData icon;
  final Color accentColor;
  final Color iconBgColor;
  const _SnackTheme({
    required this.icon,
    required this.accentColor,
    required this.iconBgColor,
  });
}

_SnackTheme _themeFor(_SnackBarType type) {
  switch (type) {
    case _SnackBarType.success:
      return const _SnackTheme(
        icon: Icons.check_circle_rounded,
        accentColor: Color(0xFF10B981),
        iconBgColor: Color(0xFFD1FAE5),
      );
    case _SnackBarType.error:
      return const _SnackTheme(
        icon: Icons.error_rounded,
        accentColor: Color(0xFFBA1A1A),
        iconBgColor: Color(0xFFFFDAD6),
      );
    case _SnackBarType.warning:
      return const _SnackTheme(
        icon: Icons.warning_amber_rounded,
        accentColor: Color(0xFFF59E0B),
        iconBgColor: Color(0xFFFEF3C7),
      );
    case _SnackBarType.info:
      return const _SnackTheme(
        icon: Icons.info_rounded,
        accentColor: Color(0xFF115CB9),
        iconBgColor: Color(0xFFDBEAFE),
      );
  }
}

// ─── Content Widget ───────────────────────────────────────────────────────────

class _SnackBarContent extends StatelessWidget {
  final String message;
  final String? detail;
  final IconData icon;
  final Color accentColor;
  final Color iconBgColor;

  const _SnackBarContent({
    required this.message,
    this.detail,
    required this.icon,
    required this.accentColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191C1E),
                    height: 1.3,
                  ),
                ),
                if (detail != null && detail!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF43474F),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Left accent bar (decorative)
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
