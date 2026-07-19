import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:product_inventory/core/router/app_router.dart';
import 'package:product_inventory/core/theme/app_theme.dart';
import 'package:product_inventory/features/inventory/domain/usecases/inventory_use_cases.dart';
import 'package:device_preview/device_preview.dart';

class MyApp extends StatelessWidget {
  final InventoryUseCases useCases;
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.useCases, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: useCases,
      child: BlocProvider(
        create: (context) => InventoryBloc(useCases: useCases),
        child: MaterialApp.router(
          title: 'Product Inventory',
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.createRouter(hasSeenOnboarding),
          debugShowCheckedModeBanner: false,
          locale: DevicePreview.locale(context),
          builder: (context, child) {
            final devicePreviewChild = DevicePreview.appBuilder(context, child);
            return GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: devicePreviewChild,
            );
          },
        ),
      ),
    );
  }
}
