import 'package:flutter/material.dart';

/// A polished inline error widget to replace plain `Text('Error: ...')` patterns.
/// 
/// Usage:
/// ```dart
/// error: (e, _) => AppErrorWidget(error: e),
/// ```
class AppErrorWidget extends StatelessWidget {
  final Object error;
  final String? title;
  final VoidCallback? onRetry;
  /// When true, renders a compact banner (for inside cards/tables).
  /// When false (default), renders a centred full-size panel.
  final bool compact;

  const AppErrorWidget({
    super.key,
    required this.error,
    this.title,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return compact ? _CompactError(error: error, title: title, onRetry: onRetry)
                   : _FullError(error: error, title: title, onRetry: onRetry);
  }
}

// ─── Full-size (centred panel) ────────────────────────────────────────────────

class _FullError extends StatelessWidget {
  final Object error;
  final String? title;
  final VoidCallback? onRetry;

  const _FullError({required this.error, this.title, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAD6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFFBA1A1A),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'Something went wrong',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191C1E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _friendlyMessage(error),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF43474F),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF115CB9),
                  side: const BorderSide(color: Color(0xFF115CB9)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Compact (inline banner) ──────────────────────────────────────────────────

class _CompactError extends StatelessWidget {
  final Object error;
  final String? title;
  final VoidCallback? onRetry;

  const _CompactError({required this.error, this.title, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFDAD6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFBA1A1A).withOpacity(0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFBA1A1A), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title ?? 'Failed to load data',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF93000A),
                    ),
                  ),
                  Text(
                    _friendlyMessage(error),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF93000A)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF93000A),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Retry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

String _friendlyMessage(Object error) {
  final raw = error.toString();
  // Strip common Flutter/Firebase prefixes for a cleaner look
  if (raw.startsWith('Exception: ')) return raw.substring('Exception: '.length);
  if (raw.startsWith('FirebaseException: ')) return raw.substring('FirebaseException: '.length);
  return raw;
}
