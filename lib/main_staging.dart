import 'package:product_inventory/app.dart';
import 'package:product_inventory/bootstrap.dart';

void main() {
  bootstrap((useCases, hasSeenOnboarding) => MyApp(useCases: useCases, hasSeenOnboarding: hasSeenOnboarding));
}
