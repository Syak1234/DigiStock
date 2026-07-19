import 'package:flutter/material.dart';

class PremiumIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final double borderRadius;
  final bool hasShadow;
  final Widget? badge;

  const PremiumIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.size = 48,
    this.iconSize = 24,
    this.borderRadius = 16,
    this.hasShadow = true,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finalIconColor = iconColor ?? theme.colorScheme.primary;
    final finalBgColor = backgroundColor ?? theme.colorScheme.onPrimary;

    Widget button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: finalBgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: finalIconColor,
          size: iconSize,
        ),
      ),
    );

    if (badge != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            right: size * 0.1,
            top: size * 0.1,
            child: badge!,
          ),
        ],
      );
    }

    return button;
  }
}
