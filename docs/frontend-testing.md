# Frontend Testing Strategy

A robust testing strategy ensures our Product Inventory dashboard remains stable as new features are added. We divide our testing into three primary layers:

## 1. Unit Testing (Domain & Data Layers)
Unit tests ensure that our core business logic and data processing work perfectly in isolation.
- **Targets**: `InventoryUseCases`, `ProductModel` conversions.
- **Mocking**: Use `mockito` or `mocktail` to mock the `HiveInventoryDataSource` when testing Use Cases.

## 2. BLoC Testing (State Management Layer)
Since our app is entirely driven by `flutter_bloc`, testing the BLoC is critical.
- **Library**: `bloc_test`
- **Focus**: Ensure that `LoadInventoryEvent` correctly transitions the state from `loading` to `success` and that `hasReachedMax` accurately updates during pagination.

## 3. Widget Testing (Presentation Layer)
Widget testing verifies that the UI renders correctly and handles user interactions.
- **Targets**: Our global reusable widgets (`PremiumCard`, `PremiumButton`) and core screens (`DashboardPage`).
- **Guidelines**: Use `pumpWidget` combined with a mocked `BlocProvider` to simulate different states (e.g., pumping the `ProductListPage` while the BLoC is in `InventoryStatus.loading` to ensure the `ProductCardSkeleton` is rendered).

## 4. Integration Testing
End-to-end (E2E) testing ensures the entire app works flawlessly from the user's perspective on a real device or emulator.
- **Package**: `integration_test`
- **Scenarios**: 
  - Navigating from the Dashboard to the Product List.
  - Adding a new product, filling out the form, and verifying it appears in the list.
  - Opening the sort/filter bottom sheet and verifying the list updates.
