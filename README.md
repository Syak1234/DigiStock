# Product Inventory Dashboard

A premium, state-of-the-art Flutter application built for the Frontend Engineering Assignment. This project showcases a deep collaboration between a frontend engineer and Agentic AI to rapidly build a fully functional, architecturally sound application.

## 🚀 Features
- **Dashboard**: Real-time KPI cards showing Total Products, Total Value, and Low Stock alerts with a beautifully animated bar chart.
- **Product List**: Paginated, horizontally-scrollable category filters, and a bottom sheet for complex sorting & filtering.
- **Product Details**: Clean, card-based layout showing deep details and inventory levels.
- **Add/Edit Product**: Fully validated forms with instant BLoC state updates.
- **Premium UI**: Custom design system using `Inter` font, soft shadow elevations, glassmorphism elements, and micro-animations.

## 🏗️ Architecture
This app follows **Clean Architecture** combined with the **BLoC** (Business Logic Component) pattern for state management.
- **Data Layer**: Powered by `Hive`, a blazing-fast local NoSQL database that simulates our backend APIs (handling pagination, sorting, and filtering locally).
- **Domain Layer**: Clean use cases (`InventoryUseCases`) that abstract the data source from the UI.
- **Presentation Layer**: Built with `flutter_bloc` to ensure the UI is purely reactive and free of business logic.

## 📁 Folder Structure
```text
/lib
 ├── core/
 │   ├── router/         # go_router configuration
 │   ├── theme/          # ThemeData and ColorSchemes
 │   ├── utils/          # Global utilities (e.g., AppSnackBar)
 │   └── widgets/        # Global reusable UI (PremiumCard, PremiumButton)
 ├── features/
 │   ├── inventory/      # The core inventory feature
 │   │   ├── data/       # Hive models and data sources
 │   │   ├── domain/     # Entities and Use Cases
 │   │   └── presentation/
 │   │       ├── bloc/   # InventoryBloc and States
 │   │       ├── pages/  # Dashboard, List, Add/Edit pages
 │   │       └── widgets/# Feature-specific widgets (ProductCard)
 ├── bootstrap.dart      # App initialization
 └── main_development.dart
```

## 🛠️ Setup Instructions

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- Dart SDK

### Installation

1. Clone the repository and navigate to the project root.
2. Get the dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app in development mode:
   ```bash
   flutter run -t lib/main_development.dart
   ```

*(Note: The app is configured with Very Good CLI flavors. You can also run `main_staging.dart` or `main_production.dart`).*

## 🤖 Context Engineering
Please review the `/docs` folder for our mandatory context files that guided the AI workflow:
- `frontend-architecture.md`
- `component-standards.md`
- `ui-guidelines.md`
- `frontend-security.md`
- `frontend-testing.md`

Be sure to also read the `AI_WORKFLOW_REPORT.md` for a full breakdown of how AI was utilized to build this app.
# DigiStock
