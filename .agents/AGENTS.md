# Project AI Rules

These rules must be followed for all future tasks within this project.

1. **Architecture**: Strictly adhere to **Clean Architecture** principles (separating data, domain, and presentation layers).
2. **Reusability**: Create list widgets and other UI components as **reusable custom widgets** to avoid duplication.
3. **Theming**: ALWAYS use the app's `ThemeData` and `ColorScheme` (e.g., `Theme.of(context).colorScheme.primary`). **Do not use static/hardcoded colors** (like `Colors.red` or `Color(0xFF000000)`).
4. **State Management**: Use the **BLoC pattern** (flutter_bloc) for state management.
5. **State**: Try to **avoid using `setState`**; rely on BLoC for state changes instead.
6. **Simplicity**: Write **clean, concise code** with as little boilerplate as possible. Use modern Dart features (like records, pattern matching) where they help reduce verbosity.
7. **Routing**: Always use the **`go_router`** package for navigation and routing.
8. **Task Management**: Always divide tasks into phases. When a phase is complete, mark it complete in the AI's internal tracking (like `task.md`) so progress is remembered.
9. **Best Practices (App Growth)**: 
    - Write self-documenting code with clear variable/function names.
    - Handle errors and exceptions gracefully, providing meaningful UI feedback.
    - Ensure responsive design, making the app usable on different screen sizes.
    - Favor composition over inheritance.
    - Keep dependencies organized and up to date.
10. **Design System & Aesthetics**: Follow the premium, government-grade DigiLocker-inspired design language:
    - **Overall Theme**: Clean, minimal, trustworthy, with a soft premium aesthetic.
    - **Colors**: Primary: Indigo (#4F46E5), Secondary: Purple (#6D5EF5), Accent: Blue (#2563EB), Success: #22C55E, Warning: #F59E0B, Error: #EF4444. Background: Pure White (#FFFFFF). Surface: #F8FAFC. Card Border: #EEF2F7.
    - **Typography**: Inter font family (via Google Fonts). Heading: 34px/700, Section Heading: 26px/700, Card Title: 18px/600, Body: 15px/400, Caption: 13px/500, Button: 15px/600.
    - **Components**:
      - **Buttons**: Primary has linear gradient (#4F46E5 to #6366F1), 24px border radius, 48px height, 12% opacity blur 20 shadow. Secondary has white background and #D6D6D6 border.
      - **Cards**: 20px border radius, 20px padding, white background, soft indigo shadow (0, 8, 30, rgba(79,70,229,0.08)).
      - **Badges**: Pill shape (999 radius), #EEF2FF background, #4F46E5 text.
      - **Icons**: Outlined Material Symbols, 2px stroke, Indigo color.
    - **Layout**: 24px between cards, 16px internal spacing. Navigation bar: 72px height, white background, #ECECEC bottom border.
    - **Animations**: Fade In, Slide Up, Hero Parallax, Card Hover Lift. Smooth 300ms transitions. Use Shimmer/Skeleton loaders with 18px blur, 0.08 opacity glass effect.
    - **Style**: Google Material 3 base with Apple-like spacing. Pixel-perfect alignment, soft shadows, no clutter.

