import re

with open('lib/features/auth/presentation/pages/login_page.dart', 'r') as f:
    code = f.read()

# Remove 'const ' before widgets/objects
code = re.sub(r'\bconst\s+', '', code)

# Define color mappings
replacements = {
    r'Color\(0xFFF0EEFF\)': 'Theme.of(context).colorScheme.surface',
    r'Color\(0xFF5D5FEF\)': 'Theme.of(context).colorScheme.primary',
    r'Color\(0xFF1A1A2E\)': 'Theme.of(context).colorScheme.onSurface',
    r'Color\(0xFF4F46E5\)': 'Theme.of(context).colorScheme.primary',
    r'Color\(0xFF6B7280\)': 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)',
    r'Color\(0x144F46E5\)': 'Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)',
    r'Color\(0x0A4F46E5\)': 'Theme.of(context).colorScheme.primary.withValues(alpha: 0.04)',
    r'Color\(0xFF9CA3AF\)': 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)',
    r'Color\(0xFFE5E7EB\)': 'Theme.of(context).colorScheme.outlineVariant',
    r'Color\(0xFF475569\)': 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)',
    r'Color\(0xFFF8F9FA\)': 'Theme.of(context).colorScheme.surface',
    r'Color\(0xFFF1F5F9\)': 'Theme.of(context).colorScheme.surfaceContainerHighest',
    r'Color\(0xFF1F2937\)': 'Theme.of(context).colorScheme.onSurface',
    r'Color\(0xFFF3F0FF\)': 'Theme.of(context).colorScheme.primaryContainer',
    r'Color\(0xFF6366F1\)': 'Theme.of(context).colorScheme.primary',
    r'Color\(0x206366F1\)': 'Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)',
    r'Color\(0xFFF5F3FF\)': 'Theme.of(context).colorScheme.primaryContainer',
    r'Color\(0xFFDDD6FE\)': 'Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)',
    r'Color\(0xFF374151\)': 'Theme.of(context).colorScheme.onSurface',
}

for pattern, repl in replacements.items():
    code = re.sub(pattern, repl, code)

with open('lib/features/auth/presentation/pages/login_page.dart', 'w') as f:
    f.write(code)

