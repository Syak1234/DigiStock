# Frontend Security Guidelines

While frontends cannot be fully secured on their own (as all client-side code can theoretically be manipulated), these guidelines ensure we are following best practices to prevent common client-side vulnerabilities.

## 1. Input Validation and Sanitization
- **Client-Side Validation**: All forms (e.g., `AddEditProductPage`) MUST implement rigorous validation to ensure data integrity before submission. We use standard Flutter `TextFormField` validators to catch invalid types (e.g., parsing strings into doubles for prices).
- **Sanitization**: Avoid directly rendering raw HTML or Markdown from untrusted sources without a sanitization library.

## 2. Secure Local Storage
Since this application uses Hive for local data storage:
- Never store highly sensitive information (passwords, auth tokens) in plain text in Hive.
- If tokens are needed in the future, use `flutter_secure_storage` to leverage the native OS keychain (Keychain on iOS, Keystore on Android).

## 3. Dependency Management
- Regularly run `flutter pub outdated` to check for insecure or deprecated packages.
- Ensure all packages in `pubspec.yaml` are sourced from trusted publishers on `pub.dev`.

## 4. Error Handling & Information Disclosure
- **Production Mode**: Never expose stack traces or raw database error messages to the end user.
- **Snackbars**: Use generic, helpful error messages in the `AppSnackBar.showError()` method (e.g., "Failed to load products. Please try again.").
