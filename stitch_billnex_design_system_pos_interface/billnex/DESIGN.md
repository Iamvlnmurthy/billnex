---
name: BillNex
colors:
  surface: '#f9f9ff'
  surface-dim: '#d0daf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e8eeff'
  surface-container-high: '#dfe8ff'
  surface-container-highest: '#d9e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#424655'
  inverse-surface: '#273143'
  inverse-on-surface: '#ecf0ff'
  outline: '#727687'
  outline-variant: '#c2c6d8'
  surface-tint: '#0055d3'
  primary: '#0055d1'
  on-primary: '#ffffff'
  primary-container: '#146cff'
  on-primary-container: '#ffffff'
  inverse-primary: '#b2c5ff'
  secondary: '#4d5f7d'
  on-secondary: '#ffffff'
  secondary-container: '#c8dbfe'
  on-secondary-container: '#4e607e'
  tertiary: '#9a4400'
  on-tertiary: '#ffffff'
  tertiary-container: '#c15700'
  on-tertiary-container: '#ffffff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2ff'
  primary-fixed-dim: '#b2c5ff'
  on-primary-fixed: '#001848'
  on-primary-fixed-variant: '#0040a1'
  secondary-fixed: '#d6e3ff'
  secondary-fixed-dim: '#b5c7ea'
  on-secondary-fixed: '#071c36'
  on-secondary-fixed-variant: '#364764'
  tertiary-fixed: '#ffdbca'
  tertiary-fixed-dim: '#ffb68e'
  on-tertiary-fixed: '#331200'
  on-tertiary-fixed-variant: '#773300'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d9e3fb'
typography:
  page-title:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  page-title-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  section-title:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  card-title:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  primary-value:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  body-main:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  supporting-info:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  metadata:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 18px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 32px
---

## Brand & Style
The design system is built on a foundation of **Modern Corporate** aesthetics, blending the reliability of traditional enterprise software with the speed and friendliness of a modern SaaS. It targets business owners who require a tool that feels authoritative yet effortless to navigate.

The visual direction emphasizes clarity and precision through high-quality typography, a structured 8pt grid, and a sophisticated color palette. By utilizing subtle depth and generous whitespace, the interface remains approachable even when displaying complex financial data. The emotional response should be one of "controlled efficiency"—users should feel that their business operations are organized, secure, and moving forward.

## Colors
The palette is anchored by **Deep Navy** to establish professional gravity and **Primary Blue** for active, energetic touchpoints. 

- **Primary & Secondary:** Use Deep Navy for sidebars or header backgrounds to project authority. Primary Blue is reserved exclusively for interactive elements like primary buttons and active states.
- **Functional Colors:** Success, Warning, and Error colors follow industry standards to ensure immediate cognitive recognition for financial status (e.g., Paid vs. Overdue).
- **Surfaces:** The App Background is a cool grey-blue to reduce eye strain, while the Light Blue Surface is used for subtle highlights or container backgrounds to group related financial information without the harshness of a pure white-on-white layout.

## Typography
This design system utilizes **Inter** for its exceptional legibility in data-heavy environments and its neutral, systematic character.

- **Currency Display:** When displaying the ₹ (Rupee) symbol, use the same weight as the adjacent value but consider a slightly reduced opacity for the symbol itself to keep the focus on the numerical data.
- **Hierarchy:** Use `page-title` for primary dashboard views. `primary-value` is specifically optimized for displaying total balances, invoice amounts, and GST totals.
- **Labels:** Use `metadata` in uppercase for table headers or small category labels to provide structural contrast.

## Layout & Spacing
The layout follows a strict **8-point spacing system** to ensure mathematical harmony across all components.

- **Grid:** Use a 12-column fluid grid for desktop and a 4-column fluid grid for mobile. 
- **Touch Targets:** All interactive elements must maintain a minimum height of 44px to ensure ease of use on mobile devices during fast-paced business operations.
- **Consistency:** Use `md (16px)` for standard padding within cards and `lg (24px)` for spacing between major sections or layout blocks.

## Elevation & Depth
Hierarchy is established through **Tonal Layers** and **Ambient Shadows**. 

- **Surface Tiers:** Background is `#F7F9FC`. Primary content containers (Cards) are `#FFFFFF`. 
- **Shadows:** Use a single, soft shadow style for cards: `0px 4px 6px -2px rgba(16, 24, 40, 0.03), 0px 12px 16px -4px rgba(16, 24, 40, 0.08)`. Shadows should feel "heavy" enough to lift the card but "soft" enough to remain professional.
- **Borders:** Use a 1px solid border (`#D0D5DD`) for all input fields and secondary buttons to maintain a structured, grounded appearance.

## Shapes
The shape language uses **Rounded** geometry to soften the professional tone and make the app feel modern.

- **Standard Radius:** 8px (`rounded`) for small components like buttons and inputs.
- **Container Radius:** 12px to 16px (`rounded-lg` to `rounded-xl`) for cards and modal sheets. 
- **Consistency:** Avoid mixing sharp corners with rounded elements. All "New Action" floating buttons should use the pill-shape (full radius) to distinguish them from static structural elements.

## Components

### Buttons
- **Primary:** Solid `#146CFF` with white text. 44px height. 8px corner radius.
- **Secondary:** White background with `#D0D5DD` border and `#1D2939` text.
- **Action (New Bill):** A prominent, high-contrast button in the bottom navigation bar, potentially using a pill shape or a slight elevation increase to signify its importance.

### Inputs & Form Fields
- **Default State:** 1px border (`#D0D5DD`), 8px radius, 44px height.
- **Active/Focus State:** 1px border `#146CFF` with a subtle 2px light blue outer glow.
- **GST/Currency Fields:** Prefix fields with the ₹ symbol or a "GST" tag inside the input container to provide immediate context.

### Cards
- White background, 12px corner radius, soft ambient shadow. 
- Used for "Quick Stats" (e.g., Total Receivables, Pending Invoices) and "Recent Activity" list containers.

### Navigation
- **Bottom Nav:** Persistent on mobile. Icons should be 24px, accompanied by `metadata` style labels. The active state is indicated by the Primary Blue color.
- **List Items:** Use 16px horizontal padding and a subtle `#D0D5DD` bottom divider. Ensure ample vertical rhythm between list items (min 12px padding).

### Chips/Badges
- Small, 4px radius. Use low-saturation backgrounds with high-saturation text for status (e.g., "Paid" uses a light green background with `#12B76A` text).