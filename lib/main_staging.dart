import 'package:product_inventory/app.dart';
import 'package:product_inventory/bootstrap.dart';

void main() {
  bootstrap(
    (useCases, authUseCases, hasSeenOnboarding) => MyApp(
      useCases: useCases,
      authUseCases: authUseCases,
      hasSeenOnboarding: hasSeenOnboarding,
    ),
  );
}
