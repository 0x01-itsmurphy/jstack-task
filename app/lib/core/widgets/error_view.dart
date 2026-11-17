import 'package:flutter/material.dart';

import '../extensions/context_extension.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: context.colors.error,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge,
            ),
            if (onRetry != null)
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
          ],
        ),
      ),
    );
  }
}
