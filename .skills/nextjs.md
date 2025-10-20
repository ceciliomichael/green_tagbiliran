# NextJS Development Skills

## File Organization

Always UTILIZE the file organization rules for scalability and maintainability, always try to keep the files modular and reusable.
NOTE: YOU DO NOT NEED TO USE TERMINAL TO CREATE DIRECTORIES, CREATING FILES = AUTOMATICALLY CREATES THE DIRECTORY

src/components/ui - # All Reusable UI Components
src/components/forms - # All Form-specific Components
src/lib - # All Utilities, Configs, Database Connections
src/hooks - # All Custom React Hooks
src/stores - # All Global State Management
src/types - # All Shared TypeScript Interfaces
src/utils - # All Pure Utility Functions
src/constants - # All App-wide Constants
src/app - # All Next.js App Router Pages and Layouts

Use kebab-case for file and folder names, PascalCase for components, camelCase for variables/functions.

## Preferences

- NEVER use NEXT_PUBLIC_ prefix
- use kebab-case for file and folder names, PascalCase for components, camelCase for variables/functions.
Always use Next.js API routes (e.g., `/api/...`) for all API functions, and have client-side code call only these routes—not external APIs directly—to prevent CORS issues.
- NEVER pass event handlers as props to Client Components from Server Components - convert Server Components to Client Components using "use client" directive when interactivity is needed
- ALWAYS ensure server-side and client-side render identical HTML to prevent hydration errors - NEVER initialize state from localStorage, window, Date.now(), or Math.random() directly in useState. Always initialize with static default values, then load from localStorage in useEffect after mount. Use isMounted pattern to defer saves to localStorage until after hydration is complete.

