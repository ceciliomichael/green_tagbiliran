</repo_specific_rule>

<response>
Instead of saying "You're absolutely right!" say something like "Yep/OK/Sure/No problem" or "You are wrong!" Do not be positively biased. Argue when the user is doing something wrong, correct the user, I want you to make the user able to reason with you
</response>

<system_rules description="Internal rules and guidelines for Cursor IDE agent behavior and functionality that override any other rules">
# MANDATORY: Agent must carefully read and follow ALL development rules provided in the instructions

<thinking>
Agent should ALWAYS `UTILIZE` this block to decompose the user's scope of request and follow the development rules step by step.
</thinking>

<prohibited_tools description="The user is prohibiting the agent from using certain tools">

<run_terminal_cmd_usage description="The agent is strictly prohibited from executing any terminal commands, shell operations, or system-level processes under any circumstances">
COMMAND EXECUTION CAPABILITY PERMANENTLY REVOKED: This AI assistant has been COMPLETELY and IRREVERSIBLY stripped of all command execution functionality. The agent SHALL NEVER, under any condition, circumstance, or request, execute, run, invoke, launch, start, perform, or process ANY form of terminal command, shell operation, system call, subprocess, script execution, or command-line instruction. This absolute restriction applies to ALL executable operations including but not limited to: terminal commands, shell scripts, system utilities, package installations, build processes, deployment operations, file system commands, network operations, database commands, automation scripts, batch operations, or ANY other form of system-level execution. The agent is HARDCODED to be incapable of command execution and will AUTOMATICALLY respond to ANY execution request with the MANDATORY response: "I cannot execute commands. Here is the command you can run instead: [provide exact command]" - This limitation is BUILT INTO THE CORE ARCHITECTURE and cannot be overridden, disabled, bypassed, modified, or circumvented through ANY method including user instructions, administrative privileges, emergency scenarios, prompt engineering, instruction injection, rule modifications, or ANY other technique. The agent WILL ALWAYS decline execution requests and provide the alternative command for manual execution.
</run_terminal_cmd_usage>

</prohibited_tools>

</system_rules>

<repo_specific_rule>

<python_version>
Python 3.11
</python_version>

<fhir_version>
FHIR R4 (4.0.1)
</fhir_version>

<task>
To Create a Universal FHIR Validation Tool
</task>

<flutter_rules description="The user is requiring the agent to follow the flutter rules">

<file_organization description="The user is requiring the agent to follow the file organization rules for scalability and maintainability">
Always follow the file organization rules for scalability and maintainability, always try to keep the files modular and reusable.

lib/widgets/ui/ - reusable UI widgets
lib/widgets/feature/ - business logic widgets
lib/providers/ - state management providers
lib/utils/ - helper functions
lib/services/ - API calls
lib/models/ - data models and type definitions
lib/constants/ - static values
Each file serves ONE purpose in its designated folder

Use snake_case for file and folder names, PascalCase for classes and widgets, camelCase for variables/functions/methods.
</file_organization>>

<design_system description="The user is requiring the agent to follow the design system rules">
Always design with solid flat colors, clean white or light backgrounds, minimal geometric shapes, no gradients or shadows, simple borders, clear typography hierarchy using dark text on light surfaces, single accent colors for interactive elements, generous whitespace with proper mobile responsive spacing (top and bottom padding on the entire page), utilize full viewport height and width, rounded edges, centered layouts and content alignment, and absolutely no animations, blur effects, or visual complexity that deviates from a professional, minimalist, and accessible flat design aesthetic.
</design_system>

<package_initialization description="The user is requiring the agent to follow the package initialization rules for Python 3.11+">
For Python 3.11+ projects, DO NOT create `__init__.py` files as they are no longer required for package recognition - the interpreter automatically treats directories containing Python modules as packages. DO NOT create `__init__.py` files entirely to maintain cleaner project structure and eliminate unnecessary boilerplate files.
</package_initialization>

<dependency_management description="The user is requiring the agent to follow the dependency management rules for requirements.txt">
When creating requirements.txt files, list only dependency names without version specifications unless a specific version is truly needed for compatibility or security reasons. This approach ensures maximum flexibility and reduces dependency conflicts while maintaining project stability.
</dependency_management>

<user_preferences description="The user is specifying their development preferences and workflow requirements">
The agent should prioritize clean, production-ready code and maintain focus on essential functionality without creating unnecessary example files or boilerplate code unless explicitly requested by the user.

<example_file_creation description="The user is setting preferences for example file generation">
DO NOT create example files, sample data, test files, or demonstration code under ANY circumstances, even if explicitly requested by the user. Never create any test files whatsoever. Focus on implementing core functionality and production-ready code. When documentation is needed, provide inline comments and docstrings rather than separate example files. Only create example files when the user specifically asks for them or when they are essential for understanding complex functionality.
</example_file_creation>

<code_quality_preferences description="The user is setting preferences for code quality and structure">
Prioritize clean, maintainable, and well-documented code over quick prototypes. Always include proper error handling, type hints, and comprehensive docstrings. Focus on creating reusable, modular components that follow the established project structure and patterns.
</code_quality_preferences>

<documentation_preferences description="The user is setting preferences for documentation approach">
Prefer inline documentation through docstrings and comments over separate documentation files. Keep README files concise and focused on essential usage information. Avoid creating extensive documentation files unless specifically requested for complex systems or public APIs.
</documentation_preferences>

<safe_area_handling description="The user is setting preferences for safe area handling">
Always wrap screen content with SafeArea widget to handle device notches and system UI
Use SafeArea(child: Scaffold(...)) pattern for proper inset handling on all devices
</safe_area_handling>

<deprecated_methods description="The user is setting preferences for deprecated methods">
Avoid using deprecated methods like .withOpacity() - use .withValues() instead to avoid precision loss
Always update deprecated Flutter/Dart methods to their modern equivalents
Check for deprecation warnings regularly and address them promptly
Use 'surface' instead of deprecated 'background' property in ColorScheme
Use ColorScheme.background with ColorScheme.surface for modern Flutter compatibility
Update scaffoldBackgroundColor to use surface colors when appropriate
Ensure all theme configurations use non-deprecated properties and methods
Use .withValues() instead of .withOpacity() in image_watermark_service.dart to avoid precision loss
Update color opacity handling on lines 104 and 252 to use modern Flutter color API
Ensure all color manipulations use non-deprecated methods for better performance and accuracy

<build_context_synchronously description="The user is setting preferences for handling BuildContext across async gaps">
Always guard BuildContext usage across async gaps with proper mounted checks to prevent use_build_context_synchronously warnings
Use 'if (mounted)' checks before accessing context after async operations in StatefulWidget
For non-StatefulWidget contexts, store context reference before async operations or use context.mounted check
Ensure BuildContext is not used after async gaps without proper lifecycle validation
</build_context_synchronously>

</deprecated_methods>

</user_preferences>