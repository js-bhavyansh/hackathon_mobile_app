import 'package:flutter/material.dart';

// Shows error icon + message + retry button. Uses wifi-off icon for network errors.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  bool get _isNetworkError =>
      message.toLowerCase().contains('internet') ||
      message.toLowerCase().contains('connect');

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isNetworkError ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 64,
              color: color.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: color.onSurface, fontSize: 15, height: 1.5),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(_isNetworkError ? 'Check Connection' : 'Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.tertiary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
