import 'package:product_inventory/app.dart';
import 'package:product_inventory/bootstrap.dart';
import 'package:device_preview/device_preview.dart';
// import 'package:flutter/foundation.dart';

void main() {
  bootstrap(
    (useCases, hasSeenOnboarding) => DevicePreview(
      enabled: false,
      builder: (context) =>
          MyApp(useCases: useCases, hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}
