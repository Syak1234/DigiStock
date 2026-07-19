import 'package:product_inventory/app.dart';
import 'package:product_inventory/bootstrap.dart';

void main() {
  bootstrap((useCases, authRepository, hasSeenOnboarding) => MyApp(useCases: useCases, authRepository: authRepository, hasSeenOnboarding: hasSeenOnboarding));
}
