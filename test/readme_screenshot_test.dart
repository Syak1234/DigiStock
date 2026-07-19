import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:product_inventory/core/theme/app_theme.dart';
import 'package:product_inventory/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:product_inventory/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:product_inventory/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:product_inventory/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:product_inventory/features/auth/presentation/pages/login_page.dart';
import 'package:product_inventory/features/inventory/data/datasources/hive_inventory_data_source.dart';
import 'package:product_inventory/features/inventory/data/models/product_model.dart';
import 'package:product_inventory/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:product_inventory/features/inventory/domain/usecases/inventory_use_cases.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:product_inventory/features/inventory/presentation/pages/add_edit_product_page.dart';
import 'package:product_inventory/features/inventory/presentation/pages/dashboard_page.dart';
import 'package:product_inventory/features/inventory/presentation/pages/product_details_page.dart';
import 'package:product_inventory/features/inventory/presentation/pages/product_list_page.dart';
import 'package:product_inventory/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDirectory;
  late InventoryUseCases inventoryUseCases;
  late AuthUseCases authUseCases;

  setUpAll(() async {
    final markerDirectory = Directory(
      '/Users/sayakmishra/Sayak_Flutter_Project/product_inventory/assets/readme',
    );
    await markerDirectory.create(recursive: true);
    await File('${markerDirectory.path}/capture-progress.txt').writeAsString(
      'setup started\n',
    );

    SharedPreferences.setMockInitialValues({});
    hiveDirectory = await Directory.systemTemp.createTemp(
      'product_inventory_readme_screens_',
    );
    await File('${markerDirectory.path}/capture-progress.txt').writeAsString(
      'temp hive directory created\n',
    );
    Hive.init(hiveDirectory.path);

    if (!Hive.isAdapterRegistered(ProductModelAdapter().typeId)) {
      Hive.registerAdapter(ProductModelAdapter());
    }
    await File('${markerDirectory.path}/capture-progress.txt').writeAsString(
      'hive adapter ready\n',
    );

    final productBox = await Hive.openBox<ProductModel>(
      HiveInventoryDataSource.boxName,
    );
    await File('${markerDirectory.path}/capture-progress.txt').writeAsString(
      'box opened\n',
    );
    await productBox.clear();

    final inventoryDataSource = HiveInventoryDataSource(productBox);
    await inventoryDataSource.init();
    await File('${markerDirectory.path}/capture-progress.txt').writeAsString(
      'inventory seeded\n',
    );

    inventoryUseCases = InventoryUseCases(
      InventoryRepositoryImpl(inventoryDataSource),
    );
    authUseCases = AuthUseCases(AuthRepositoryImpl(AuthLocalDataSource()));
    await File('${markerDirectory.path}/capture-progress.txt').writeAsString(
      'setup complete\n',
    );
  });

  tearDownAll(() async {
    await Hive.close();
    if (await hiveDirectory.exists()) {
      await hiveDirectory.delete(recursive: true);
    }
  });

  testWidgets('capture README screenshots', (tester) async {
    final outputDirectory = Directory(
      '/Users/sayakmishra/Sayak_Flutter_Project/product_inventory/assets/readme',
    );
    await outputDirectory.create(recursive: true);
    await File('${outputDirectory.path}/capture-progress.txt').writeAsString(
      'entered widget test\n',
    );

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await File('${outputDirectory.path}/capture-progress.txt').writeAsString(
      'sized view\n',
    );

    // ignore: avoid_print
    print('Capturing onboarding');
    await _captureScreen(
      tester,
      outputDirectory,
      'onboarding.png',
      _materialApp(home: const OnboardingPage()),
    );

    // ignore: avoid_print
    print('Capturing login');
    await _captureScreen(
      tester,
      outputDirectory,
      'login.png',
      _withBlocs(
        inventoryUseCases: inventoryUseCases,
        authUseCases: authUseCases,
        child: _materialApp(home: const LoginPage()),
      ),
    );

    // ignore: avoid_print
    print('Capturing dashboard');
    await _captureScreen(
      tester,
      outputDirectory,
      'dashboard.png',
      _withBlocs(
        inventoryUseCases: inventoryUseCases,
        authUseCases: authUseCases,
        child: _materialApp(home: const DashboardPage()),
      ),
    );

    // ignore: avoid_print
    print('Capturing products');
    await _captureScreen(
      tester,
      outputDirectory,
      'products.png',
      _withBlocs(
        inventoryUseCases: inventoryUseCases,
        authUseCases: authUseCases,
        child: MaterialApp.router(
          title: 'Product Inventory',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          routerConfig: GoRouter(
            initialLocation: '/products',
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductListPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddEditProductPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => ProductDetailsPage(
                      productId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  });
}

Widget _materialApp({required Widget home}) {
  return MaterialApp(
    title: 'Product Inventory',
    theme: AppTheme.lightTheme,
    debugShowCheckedModeBanner: false,
    home: home,
  );
}

Widget _withBlocs({
  required InventoryUseCases inventoryUseCases,
  required AuthUseCases authUseCases,
  required Widget child,
}) {
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: inventoryUseCases),
      RepositoryProvider.value(value: authUseCases),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => InventoryBloc(useCases: inventoryUseCases),
        ),
        BlocProvider(create: (context) => AuthBloc(useCases: authUseCases)),
      ],
      child: child,
    ),
  );
}

Future<void> _captureScreen(
  WidgetTester tester,
  Directory outputDirectory,
  String fileName,
  Widget app,
) async {
  final boundaryKey = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(key: boundaryKey, child: app));

  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(seconds: 2));

  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 2);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  await File(
    '${outputDirectory.path}/$fileName',
  ).writeAsBytes(bytes!.buffer.asUint8List());

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 100));
}
