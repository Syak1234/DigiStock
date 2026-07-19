import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:product_inventory/features/inventory/presentation/pages/dashboard_page.dart';
import 'package:product_inventory/features/inventory/presentation/pages/product_list_page.dart';
import 'package:product_inventory/features/inventory/presentation/pages/product_details_page.dart';
import 'package:product_inventory/features/inventory/presentation/pages/add_edit_product_page.dart';
import 'package:product_inventory/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:product_inventory/features/auth/presentation/pages/login_page.dart';
import 'package:product_inventory/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:product_inventory/features/auth/presentation/bloc/auth_state.dart';
import 'package:product_inventory/core/widgets/scaffold_with_nav_bar.dart';
import 'dart:async';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  // Separate navigator key per branch — each tab keeps its own widget subtree alive
  static final _dashboardNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
  static final _productsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'products');

  static GoRouter createRouter(bool hasSeenOnboarding, AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: hasSeenOnboarding ? '/' : '/onboarding',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state.status;
        final isAuth = authState == AuthStatus.authenticated;
        final isLoggingIn = state.uri.toString() == '/login';
        final isOnboarding = state.uri.toString() == '/onboarding';

        if (!hasSeenOnboarding && !isOnboarding) return '/onboarding';
        if (hasSeenOnboarding && !isAuth && !isLoggingIn) return '/login';
        if (isAuth && isLoggingIn) return '/';

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const OnboardingPage(),
        ),
        // StatefulShellRoute.indexedStack keeps each branch's subtree alive.
        // Switching tabs no longer rebuilds or resets the page state.
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ScaffoldWithNavBar(navigationShell: navigationShell);
          },
          branches: [
            // Branch 0 — Dashboard tab
            StatefulShellBranch(
              navigatorKey: _dashboardNavigatorKey,
              routes: [
                GoRoute(
                  path: '/',
                  name: 'dashboard',
                  builder: (context, state) => const DashboardPage(),
                ),
              ],
            ),
            // Branch 1 — Products tab
            StatefulShellBranch(
              navigatorKey: _productsNavigatorKey,
              routes: [
                GoRoute(
                  path: '/products',
                  name: 'products',
                  builder: (context, state) => const ProductListPage(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      name: 'add_product',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => const AddEditProductPage(),
                    ),
                    GoRoute(
                      path: ':id',
                      name: 'product_details',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return ProductDetailsPage(productId: id);
                      },
                      routes: [
                        GoRoute(
                          path: 'edit',
                          name: 'edit_product',
                          parentNavigatorKey: _rootNavigatorKey,
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
        ),
      ],
    );
  }
}
