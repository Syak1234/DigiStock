import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  /// The [StatefulNavigationShell] manages the indexed stack of tab branches.
  /// Each branch keeps its subtree alive so switching tabs never causes a rebuild.
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final int currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // The navigationShell IS the body — it renders the active branch's page
      // while keeping all other branches alive in the widget tree.
      body: navigationShell,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => context.push('/products/add'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          shape: const CircleBorder(),
          child: Icon(Icons.add_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 32)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 2.seconds,
              ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          color: Theme.of(context).colorScheme.surface,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                isActive: currentIndex == 0,
                onTap: () => navigationShell.goBranch(0),
              ),
              const SizedBox(width: 48), // Space for the FAB
              _buildNavItem(
                context,
                icon: Icons.inventory_2_outlined,
                label: 'Products',
                isActive: currentIndex == 1,
                onTap: () => navigationShell.goBranch(1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: isActive ? 16 : 8,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24)
                .animate(target: isActive ? 1 : 0)
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              color: color,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
