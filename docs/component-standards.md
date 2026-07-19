# Component Standards

This document establishes the rules and standards for creating and using UI components in our application.

## Core Principle: Reusability
Do not duplicate UI code. If a UI element appears in more than one place (like a styled button, a specific card layout, or a customized snackbar), it **must** be extracted into a reusable widget inside `lib/core/widgets/` or `lib/core/utils/`.

## Shared Global Components

### `PremiumCard`
- **Purpose**: The standard container for all grouped content.
- **Rules**: Replaces `Container` with complex `BoxDecoration`. Automatically applies the correct border radii and shadow.
- **Location**: `lib/core/widgets/premium_card.dart`

### `PremiumButton`
- **Purpose**: Primary and secondary action buttons.
- **Rules**: Always use this instead of raw `ElevatedButton` or `TextButton`. It handles its own `CircularProgressIndicator` loading state seamlessly.
- **Location**: `lib/core/widgets/premium_button.dart`

### `PremiumIconButton`
- **Purpose**: Circular action icons (Back, Edit, Delete, Menu, Notifications).
- **Rules**: Replaces `InkWell` + `Container` combos. Supports notification badges out of the box.
- **Location**: `lib/core/widgets/premium_icon_button.dart`

### `AppSnackBar`
- **Purpose**: Global feedback mechanism for CRUD operations.
- **Rules**: Never call `ScaffoldMessenger...` manually with inline styles. Use `AppSnackBar.showSuccess()`, `AppSnackBar.showError()`, or `AppSnackBar.showInfo()`.
- **Location**: `lib/core/utils/app_snackbar.dart`

## Organization
- Feature-specific widgets (e.g., `ProductCard`) live in `lib/features/{feature}/presentation/widgets/`.
- Global reusable widgets live in `lib/core/widgets/`.
