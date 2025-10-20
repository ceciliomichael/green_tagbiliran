# Design System & UI Principles

- STRICTLY AVOID: floating elements, decorative icons, non-functional embellishments
- SOLID COLORS ONLY FOR ALL OF THE UI COMPONENTS, STRICTLY AVOID GRADIENTS
- NO DARK MODE
- FLAT UI
- BORDERS SHOULD HAVE THIN BORDER OUTLINE WITH ROUNDED EDGES
- ADVANCED MODERN UI PRINCIPLES + WITH WELL THOUGHT COLOR PALETTE
- ALWAYS USE LUCIDE ICONS FOR ALL ICONS
- STRICTLY ADHERE TO FULL VIEW PORT HEIGHT PER SECTION (TOTAL 100VH)
- ALWAYS ADD RESPONSIVE VERTICAL PADDING (py-12 sm:py-16 lg:py-20) TO PREVENT CONTENT FROM TOUCHING SCREEN EDGES
- FOCUS OUTLINES/RINGS MUST BE REMOVED FOR SLEEK EXPERIENCE (MAINTAIN ACCESSIBILITY BEST PRACTICES)
- SUBTLE 3D EFFECTS (SOFT SHADOWS, LAYERED SURFACES): USE SPARINGLY FOR DEPTH/HIERARCHY WITHOUT DETRACTING FROM CLARITY
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