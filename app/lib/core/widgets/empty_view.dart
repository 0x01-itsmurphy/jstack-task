import 'package:flutter/material.dart';

import '../extensions/context_extension.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(icon, size: 56, color: context.colors.outline),
            Text(title, style: context.textTheme.titleMedium),
            if (message != null)
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
