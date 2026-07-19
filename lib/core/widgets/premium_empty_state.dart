import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PremiumEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const PremiumEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/premium_empty_state.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ).animate().fade(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ).animate().fade(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ).animate().fade(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
