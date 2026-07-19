import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:product_inventory/features/auth/domain/repositories/auth_repository.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:product_inventory/core/router/app_router.dart';
import 'package:product_inventory/core/theme/app_theme.dart';
import 'package:product_inventory/features/inventory/domain/usecases/inventory_use_cases.dart';
import 'package:device_preview/device_preview.dart';
import 'package:product_inventory/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:product_inventory/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:product_inventory/features/auth/presentation/bloc/auth_event.dart';

class MyApp extends StatefulWidget {
  final InventoryUseCases useCases;
  final AuthUseCases authUseCases;
  final bool hasSeenOnboarding;

  const MyApp({
    super.key,
    required this.useCases,
    required this.authUseCases,
    required this.hasSeenOnboarding,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(useCases: widget.authUseCases)
      ..add(CheckAuthStatusEvent());
    _router = AppRouter.createRouter(widget.hasSeenOnboarding, _authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.useCases),
        RepositoryProvider.value(value: widget.authUseCases),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => InventoryBloc(useCases: widget.useCases),
          ),
          BlocProvider.value(value: _authBloc),
        ],
        child: MaterialApp.router(
          title: 'Product Inventory',
          theme: AppTheme.lightTheme,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          locale: DevicePreview.locale(context),
          builder: (context, child) {
            final devicePreviewChild = DevicePreview.appBuilder(context, child);
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: devicePreviewChild,
            );
          },
        ),
      ),
    );
  }
}
