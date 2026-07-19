import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:product_inventory/features/inventory/presentation/pages/dashboard_page.dart';
import 'package:product_inventory/features/inventory/presentation/pages/product_list_page.dart';
import 'package:product_inventory/features/inventory/presentation/pages/product_details_page.dart';
import 'package:product_inventory/features/inventory/presentation/pages/add_edit_product_page.dart';
import 'package:product_inventory/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:product_inventory/core/widgets/scaffold_with_nav_bar.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(bool hasSeenOnboarding) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/onboarding',
      // initialLocation: hasSeenOnboarding ? '/' : '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const OnboardingPage(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return ScaffoldWithNavBar(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              name: 'dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
            GoRoute(
              path: '/products',
              name: 'products',
              builder: (context, state) => const ProductListPage(),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'add_product',
                  parentNavigatorKey: _rootNavigatorKey, // Covers bottom nav
                  builder: (context, state) => const AddEditProductPage(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'product_details',
                  parentNavigatorKey: _rootNavigatorKey, // Covers bottom nav
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return ProductDetailsPage(productId: id);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      name: 'edit_product',
                      parentNavigatorKey: _rootNavigatorKey, // Covers bottom nav
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return AddEditProductPage(productId: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
