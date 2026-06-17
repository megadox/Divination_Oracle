import 'package:flutter/material.dart';

class PageIndexCard extends StatelessWidget {
  const PageIndexCard({
    required this.index,
    required this.label,
    super.key,
  });

  final String index;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              index,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
