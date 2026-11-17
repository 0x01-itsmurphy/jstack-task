import 'package:flutter/material.dart';

import '../extensions/context_extension.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: 12,
        children: [
          Icon(Icons.error_outline_rounded, color: colors.onErrorContainer),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
