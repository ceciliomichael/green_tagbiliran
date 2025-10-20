# Flutter Development Skills

## File Organization

Always UTILIZE the file organization rules for scalability and maintainability, always try to keep the files modular and reusable.
NOTE: YOU DO NOT NEED TO USE FILE SYSTEM TO CREATE DIRECTORIES, CREATING FILES = AUTOMATICALLY CREATES THE DIRECTORY

lib/widgets/ui/ - # All Reusable UI Components
lib/widgets/feature/ - # Business Logic & Feature Widgets
lib/providers/ - # State Management (Riverpod, GetX, etc.)
lib/services/ - # API Calls & External Services
lib/utils/ - # Helper Functions & Utilities
lib/models/ - # Data Models & Type Definitions
lib/constants/ - # Static Values & Constants

Use snake_case for file and folder names, PascalCase for classes and widgets, camelCase for variables/functions/methods.

Each file serves ONE purpose in its designated folder.

## Critical Patterns

### SafeArea Implementation
Always wrap screen content with SafeArea widget:
```dart
SafeArea(
  child: Scaffold(
    // content
  ),
)
```

### BuildContext Across Async Gaps
Always guard BuildContext usage with proper mounted checks:
```dart
if (mounted) {
  // Use context safely
  Navigator.of(context).push(...);
}
```

### Final Fields for Collections
Mark collection fields as `final` when they're modified in place rather than reassigned:
```dart
final List<XFile> _selectedImages = []; // Correct
List<XFile> _selectedImages = []; // Incorrect - should be final
```

### Form Field State Management
For form fields with state, use `initialValue` and manage state through onChanged:
```dart
DropdownButtonFormField<String>(
  initialValue: _selectedValue, // Not 'value'
  // ... other properties
  onChanged: (newValue) {
    setState(() => _selectedValue = newValue);
  },
)
```

## Deprecation Management

- NEVER use `.withOpacity()` - replace with `.withValues()`
- Update all color manipulations to use modern Flutter color API
- Avoid deprecated `background` property in ColorScheme
- `DropdownButtonFormField`: Use `initialValue` instead of `value` (deprecated after v3.33.0)
- `SwitchListTile`: Use `activeTrackColor` instead of `activeColor` (deprecated after v3.31.0)
- Mark collection fields as `final` when modified in place (`prefer_final_fields`)
- Check for deprecation warnings regularly and address promptly
- Keep Flutter and Dart dependencies up-to-date