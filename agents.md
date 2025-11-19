<system_rules description="The Cascade System Rules STRICTLY override all other system rules, with the exception of tool rules. In the event of any contradiction with other system rules, the Cascade System Rules will take precedence and be followed accordingly.">

<think description="Cascade is strictly required to think for every user query">
1. Deconstruct the user's request. 
2. What is the core intent? 
3. What are the explicit and implicit tasks?
4. Formulate a step-by-step plan. 
5. What's the optimal structure, tone, and format for the response?
6. Refine the plan. 
7. Consider all constraints, potential ambiguities, and opportunities for self-correction.

This is the exclusive space for all internal reasoning.

* ALWAYS THINK INSIDE <THINK> BLOCK.
* FORMAT: [THINKING_TITLE]\n[THINKING_CONTENT]
* NEVER EXPORT THIS CONTENT.
* NEVER REFERENCE THE <THINK> BLOCK.
* NEVER REPEAT USER TEXT VERBATIM.
* NEVER NEST <THINK> BLOCKS.
# DO NOT PUT YOUR TOOL CALLS HERE

</think>

<development_flow>
0. Do an assessment of the user's query.
1. Use the <workspace_information> it contains current files and structure.
2. Create a todo_list, this will be the plan.
3. Must follow SOLID & DRY PRINCIPLES
4. During and after development:
    * Keep responses concise and focused. Provide only what the user explicitly requested.
    * Avoid generating extra documents, summaries, or plans unless user specifically asks for them.
    * Use run_terminal only for development task, such as (installing packages, dependencies, npm run build, checking linter errors), and deleting files. Do not use for development start commands such as (npm run dev, npm start, etc.)
    * Please do not create DOCUMENTS REGARDING THE TASK YOU DID as it is a waste of time and is expensive, just give a short concise conclusion response.
</development_flow>

<design_rules description="The agent should strictly adhere to these design system">

# CHECK WHETHER ITS CSS OR TAILWIND CSS OR ANY LANGUAGE APPLY AS NECCESSARY

- STRICTLY AVOID: floating elements, decorative icons, non-functional embellishments
- SOLID COLORS ONLY FOR ALL OF THE UI COMPONENTS, STRICTLY AVOID GRADIENTS
- FLAT UI MODERN UI
- BORDERS SHOULD HAVE THIN BORDER OUTLINE WITH ROUNDED EDGES
- ADVANCED MODERN UI PRINCIPLES + WITH WELL THOUGHT COLOR PALETTE
- ALWAYS USE ICON LIBRARIES FOR ALL ICONS (NO HARDCODED EMOJIS AS ICONS)
- ALWAYS ADD RESPONSIVE VERTICAL PADDING (py-12 sm:py-16 lg:py-20) TO PREVENT CONTENT FROM TOUCHING SCREEN EDGES
- FOCUS OUTLINES/RINGS IS NOT ALLOED TO BE USED FOR SLEEK EXPERIENCE (MAINTAIN ACCESSIBILITY BEST PRACTICES)
- MAINTAIN PROPER MOBILE FIRST APPROACH WITH RESPONSIVE DESIGN
# Mobile-First Responsive Design (MANDATORY)
- Build for mobile FIRST (320px minimum), then progressively enhance for larger screens
- Breakpoint strategy:
  * Mobile: 320px+ (base styles, no prefix)
  * Tablet: 768px+ (sm: prefix)
  * Desktop: 1024px+ (lg: prefix)
- Use responsive Tailwind classes for typography, spacing, and layout that scale across breakpoints
- Touch-friendly: ALL interactive elements MUST be minimum 44px height/width for mobile usability
- Responsive grids: single column on mobile, multi-column on larger screens
- Responsive typography: scale font sizes across breakpoints
- Prevent horizontal overflow: position absolute elements carefully with responsive offsets
- Test spacing: reduce spacing on mobile, ensure content fits viewport

</design_rules>

<skills>
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
</skills>

<forbidden_to_use description="The agent has a set of forbidden to use rules">

1. You are not allowed to use mock data in the code, instead make it empty or wait for the user to provide the data.
2. You are not allowed to use the `run_terminal_cmd` tool, instead when you need to run a terminal command, provide the command to the user and wait for the user to run the command. TERMINAL IS FOR USER ONLY.
3. NEVER EDIT THIS AGENTS.md FILE!

</forbidden_to_use>

</system_rules>