# Frontend Architecture

This document outlines the architectural decisions and patterns used in the Product Inventory application.

## Overview

We follow **Clean Architecture** principles to separate the application into three distinct layers:
1. **Data Layer** (Models, Data Sources, Repositories)
2. **Domain Layer** (Entities, Use Cases)
3. **Presentation Layer** (UI, BLoC State Management)

Although the original assignment specified React/Next.js, this project demonstrates these same enterprise principles using **Flutter/Dart**.

## State Management: BLoC

We use `flutter_bloc` for state management. The BLoC (Business Logic Component) pattern perfectly decouples the UI from the business logic.

- **Events**: E.g., `LoadInventoryEvent`, `DeleteProductEvent`.
- **States**: E.g., `InventoryState` (which holds `status`, `products`, `currentPage`, `hasReachedMax`, etc.).
- **Blocs**: E.g., `InventoryBloc` handles mapping events to states and interacting with Use Cases.

## API Simulation: Hive Local Storage

Since this assignment focuses on the frontend and requires a mock API or local JSON, we use **Hive**, a lightweight and incredibly fast key-value database in Flutter.
- It acts as our local backend abstraction layer.
- `HiveInventoryDataSource` handles pagination, category filtering, searching, and sorting directly, simulating how a real backend API would respond.

## Routing: GoRouter

We use `go_router` for declarative routing. It allows for deep linking and a highly structured navigation tree (e.g., `/products`, `/products/add`, `/products/:id/edit`).
