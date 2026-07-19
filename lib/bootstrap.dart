import 'dart:async';
import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:product_inventory/features/inventory/data/models/product_model.dart';
import 'package:product_inventory/features/inventory/data/datasources/hive_inventory_data_source.dart';
import 'package:product_inventory/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:product_inventory/features/inventory/domain/usecases/inventory_use_cases.dart';

void bootstrap(FutureOr<Widget> Function(InventoryUseCases useCases, bool hasSeenOnboarding) builder) {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Hive.initFlutter();
    Hive.registerAdapter(ProductModelAdapter());
    final box = await Hive.openBox<ProductModel>(
      HiveInventoryDataSource.boxName,
    );

    final settingsBox = await Hive.openBox('settings_box');
    final hasSeenOnboarding = settingsBox.get('has_seen_onboarding', defaultValue: false) as bool;
    
    final dataSource = HiveInventoryDataSource(box);
    await dataSource.init(); // Seed data if empty
    
    final repository = InventoryRepositoryImpl(dataSource);
    final useCases = InventoryUseCases(repository);
    
    runApp(await builder(useCases, hasSeenOnboarding));
  }, (error, stackTrace) => log(error.toString(), stackTrace: stackTrace));
}
