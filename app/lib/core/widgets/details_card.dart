import 'package:flutter/material.dart';

import '../extensions/context_extension.dart';

class DetailsCard extends StatelessWidget {
  const DetailsCard({super.key, required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 12,
          children: [
            for (final (label, value) in items)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
