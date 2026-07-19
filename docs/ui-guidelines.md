# UI Guidelines

This document serves as the single source of truth for the Product Inventory app's premium design language.

## Design Philosophy
We aim for a "Premium, Government-grade DigiLocker-inspired" design language.
- **Overall Theme**: Clean, minimal, trustworthy, with a soft premium aesthetic.
- **Vibe**: State of the art, dynamic but not overwhelming.

## Typography
We use the **Inter** font family (via Google Fonts) across the entire application to ensure a modern, clean, and highly readable interface.
- **Heading 1**: 34px / 700 weight
- **Section Heading**: 26px / 700 weight
- **Card Title**: 18px / 600 weight
- **Body**: 15px / 400 weight
- **Caption**: 13px / 500 weight
- **Button**: 15px / 600 weight

## Color Palette
Always use the app's `ThemeData` and `ColorScheme`. Do not use static/hardcoded colors.
- **Primary**: Indigo (`#4F46E5`)
- **Secondary**: Purple (`#6D5EF5`)
- **Accent**: Blue (`#2563EB`)
- **Success**: Green (`#22C55E`)
- **Warning**: Amber (`#F59E0B`)
- **Error**: Red (`#EF4444`)
- **Background**: Pure White (`#FFFFFF`)
- **Surface**: Light Slate (`#F8FAFC`)

## Spacing & Layout
- **Global Padding**: 20px - 24px standard padding on all root screens.
- **Card Spacing**: 24px between cards, 16px internal padding.
- **Corner Radii**: 20px to 24px for large containers (Cards, Modals), 999px (pill-shape) for badges and buttons.

## Shadows & Elevations
- We use very soft, tinted shadows instead of harsh black dropshadows.
- **Card Shadow**: `rgba(79, 70, 229, 0.08)` (8% opacity Primary color) with an offset of `(0, 8)` and blur of `20`.

## Micro-Animations
We utilize `flutter_animate` to bring the UI to life:
- **Lists**: Cascading fade-in and slide-up animations (staggered by 100ms per index).
- **Page Transitions**: Smooth 300ms transitions.
- **Loading States**: Shimmer/Skeleton loaders with an 18px blur and 0.08 opacity glass effect instead of standard circular spinners where applicable.
