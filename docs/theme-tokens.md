# Design Token and Visual Theme Contract (Theme Tokens Specification)

> This file proposes a set of semantic tokens for a project that needs theme switching. In an existing interface, use the established design system.
> For components that participate in theming, bind colors to semantic tokens. This allows the palette to change through theme definitions.

---

## 1. Basic Semantic Token Contract

When using this example, define the values of the tokens that components rely on. The complete set for the demonstration theme follows.

```css
:root {
  /* Surfaces and background */
  --background: 0 0% 100%;             /* Main page background */
  --foreground: 240 10% 3.9%;           /* Main text color */
  --card: 0 0% 100%;                   /* Background of cards and modules */
  --card-foreground: 240 10% 3.9%;      /* Text on cards */
  --popover: 0 0% 100%;                /* Background of dropdowns and tooltips */
  --popover-foreground: 240 10% 3.9%;   /* Text in popovers */

  /* Primary and accent actions */
  --primary: 240 5.9% 10%;             /* Primary CTA button / accent */
  --primary-foreground: 0 0% 98%;      /* Text on primary button */
  --secondary: 240 4.8% 95.9%;         /* Secondary button / badge */
  --secondary-foreground: 240 5.9% 10%;/* Text on secondary element */
  --accent: 240 4.8% 95.9%;            /* Accent for interactive hover states */
  --accent-foreground: 240 5.9% 10%;   /* Text on accent */

  /* Muted elements and borders */
  --muted: 240 4.8% 95.9%;             /* Muted background (tables, inputs) */
  --muted-foreground: 240 3.8% 46.1%;  /* Secondary muted text / placeholder */
  --border: 240 5.9% 90%;              /* Card borders and dividers */
  --input: 240 5.9% 90%;               /* Input field borders */
  --ring: 240 5.9% 10%;                /* Focus ring (:focus-visible) */

  /* Destructive actions */
  --destructive: 0 84.2% 60.2%;        /* Errors, deletion, dangerous actions */
  --destructive-foreground: 0 0% 98%;  /* Text on destructive button */

  /* Corner radii */
  --radius: 0.5rem;                    /* Base corner radius for buttons and cards */
}

/* Dark theme (Dark Minimalist by default) */
.dark, [data-theme="dark"] {
  --background: 240 10% 3.9%;
  --foreground: 0 0% 98%;
  --card: 240 10% 5.5%;
  --card-foreground: 0 0% 98%;
  --popover: 240 10% 5.5%;
  --popover-foreground: 0 0% 98%;
  --primary: 0 0% 98%;
  --primary-foreground: 240 5.9% 10%;
  --secondary: 240 3.7% 15.9%;
  --secondary-foreground: 0 0% 98%;
  --accent: 240 3.7% 15.9%;
  --accent-foreground: 0 0% 98%;
  --muted: 240 3.7% 15.9%;
  --muted-foreground: 240 5% 64.9%;
  --border: 240 3.7% 15.9%;
  --input: 240 3.7% 15.9%;
  --ring: 240 4.9% 83.9%;
  --destructive: 0 62.8% 30.6%;
  --destructive-foreground: 0 0% 98%;
}
```

---

## 2. How to Add New Themes (Zero Component Edits)

To add a new theme (for example, `Nord`, `Cyberpunk`, or `Corporate Blue`), simply declare a new selector in the project's theme CSS file:

```css
/* Example: Nordic palette (Nord Theme) */
[data-theme="nord"] {
  --background: 220 16% 22%;
  --foreground: 218 27% 94%;
  --card: 222 16% 28%;
  --card-foreground: 218 27% 94%;
  --popover: 222 16% 28%;
  --popover-foreground: 218 27% 94%;
  --primary: 193 43% 67%;
  --primary-foreground: 220 16% 22%;
  --secondary: 213 32% 52%;
  --secondary-foreground: 218 27% 94%;
  --accent: 193 43% 67%;
  --accent-foreground: 220 16% 22%;
  --muted: 220 17% 32%;
  --muted-foreground: 219 14% 71%;
  --border: 220 17% 32%;
  --input: 220 17% 32%;
  --ring: 193 43% 67%;
  --destructive: 354 42% 54%;
  --destructive-foreground: 0 0% 98%;
  --radius: 0.375rem;
}
```

**Components remain unchanged.** Switch the theme by changing the attribute:
```html
<html data-theme="nord">
```

---

## 3. Mapping to Tailwind CSS / Frameworks

In the Tailwind configuration file (`tailwind.config.ts` or v4 CSS variables):

```typescript
// Example of token integration in Tailwind v3/v4:
colors: {
  background: "hsl(var(--background) / <alpha-value>)",
  foreground: "hsl(var(--foreground) / <alpha-value>)",
  card: {
    DEFAULT: "hsl(var(--card) / <alpha-value>)",
    foreground: "hsl(var(--card-foreground) / <alpha-value>)",
  },
  primary: {
    DEFAULT: "hsl(var(--primary) / <alpha-value>)",
    foreground: "hsl(var(--primary-foreground) / <alpha-value>)",
  },
  muted: {
    DEFAULT: "hsl(var(--muted) / <alpha-value>)",
    foreground: "hsl(var(--muted-foreground) / <alpha-value>)",
  },
  border: "hsl(var(--border) / <alpha-value>)",
}
```

---

## 4. UI Implementation Invariants for the AI Agent

1. ❌ **Prohibited:** `<div className="bg-[#121212] text-gray-400">`
2. ✅ **Required:** `<div className="bg-card text-muted-foreground border border-border">`
3. ❌ **Prohibited:** `<button className="bg-blue-600 hover:bg-blue-700">`
4. ✅ **Required:** `<button className="bg-primary text-primary-foreground hover:bg-primary/90 focus-visible:ring-2 focus-visible:ring-ring">`
5. ❌ **Prohibited:** A clickable `div` with a click listener.
6. ✅ **Required:** A semantic `<button>` with the explicit type `type="button"`.
