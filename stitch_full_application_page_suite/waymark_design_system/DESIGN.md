---
name: WayMark Design System
colors:
  surface: '#f6fbf5'
  surface-dim: '#d7dbd6'
  surface-bright: '#f6fbf5'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f5f0'
  surface-container: '#ebefea'
  surface-container-high: '#e5e9e4'
  surface-container-highest: '#dfe4df'
  on-surface: '#181d1a'
  on-surface-variant: '#57423f'
  inverse-surface: '#2c322e'
  inverse-on-surface: '#edf2ed'
  outline: '#8a716e'
  outline-variant: '#ddc0bb'
  surface-tint: '#a23d30'
  primary: '#9f3b2e'
  on-primary: '#ffffff'
  primary-container: '#bf5343'
  on-primary-container: '#fffbff'
  inverse-primary: '#ffb4a8'
  secondary: '#286a46'
  on-secondary: '#ffffff'
  secondary-container: '#adf2c3'
  on-secondary-container: '#2f704b'
  tertiary: '#7a5500'
  on-tertiary: '#ffffff'
  tertiary-container: '#996c00'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad4'
  primary-fixed-dim: '#ffb4a8'
  on-primary-fixed: '#410000'
  on-primary-fixed-variant: '#82261b'
  secondary-fixed: '#adf2c3'
  secondary-fixed-dim: '#92d5a8'
  on-secondary-fixed: '#002110'
  on-secondary-fixed-variant: '#065230'
  tertiary-fixed: '#ffdea9'
  tertiary-fixed-dim: '#ffba27'
  on-tertiary-fixed: '#271900'
  on-tertiary-fixed-variant: '#5e4100'
  background: '#f6fbf5'
  on-background: '#181d1a'
  surface-variant: '#dfe4df'
  surface-canvas: '#FBF9F5'
  surface-card: '#FFFFFF'
  text-secondary: '#6C757D'
  border-divider: '#E9ECEF'
  route-start: '#3B82F6'
  route-mid: '#8B5CF6'
  route-end: '#F43F5E'
  forest-vivid: '#38B000'
typography:
  display-lg:
    fontFamily: Outfit
    fontSize: 44px
    fontWeight: '600'
    lineHeight: 52px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Outfit
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 38px
    letterSpacing: -0.015em
  display-md:
    fontFamily: Outfit
    fontSize: 36px
    fontWeight: '600'
    lineHeight: 44px
    letterSpacing: -0.015em
  headline-lg:
    fontFamily: Outfit
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Outfit
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 26px
    letterSpacing: 0em
  headline-sm:
    fontFamily: Outfit
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
    letterSpacing: 0em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.03em
  caption:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 12px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-tablet: 1.5rem
  margin-desktop: 2.5rem
  space-2xs: 0.25rem
  space-xs: 0.5rem
  space-sm: 0.75rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
  space-2xl: 3rem
---

## Brand & Style

The design system is crafted for mindful travelers, memory keepers, and visual storytellers who treat journeys as personal memoirs rather than mere itineraries. The aesthetic balances contemporary editorial restraint with tactile, analog nostalgia—blending the warmth of archival field notebooks, sun-bleached postcards, and classic photographic prints with modern responsive utility.

The design movement is **Tactile Editorial Modernism**. It rejects sterile, high-gloss tech tropes in favor of organic warmth, generous breathing room, and tangible artifacts. Interfaces evoke emotional resonance through warm paper-like canvas backgrounds, crisp structural white cards, refined humanist and geometric type hierarchies, and physical paper-elevation treatments for cherished media like polaroids, maps, and travel logs.

## Colors

The palette draws directly from geological and natural landscapes:
- **Primary (Earth Terracotta - `#E26D5C`)**: Represents clay, desert trails, and worn passport stamps. Used for key focal actions, the signature journey creation CTA, and high-priority interactive touchpoints.
- **Secondary (Forest Teal - `#2C6E49`)**: Evokes pine ridges, deep fjords, and coastal roads. Applied to secondary navigation tags, active states, and route segments.
- **Tertiary (Sunset Gold - `#FFB703`)**: Captures golden hour warmth. Reserved for celebratory achievements, favorite highlights, and generative postcard badges.
- **Neutral (Deep Peat - `#1F2421`)**: A rich organic carbon that replaces harsh pure black, providing soft yet high-contrast typographic hierarchy over light surfaces.

### Functional & Accent Roles
- **Canvas Base (`#FBF9F5`)**: A warm, unbleached linen-paper tint serving as the global background foundation.
- **Surface Elevation (`#FFFFFF`)**: Pure white reserved for cards, sheets, and polaroid photo borders to establish crisp separation from the warm canvas.
- **Map Polyline Sequence (`#3B82F6` $\rightarrow$ `#8B5CF6` $\rightarrow$ `#F43F5E`)**: A vibrant chromatic progression specifically reserved for chronological route vectors to ensure map legibility across varied map tile styles.

## Typography

The type system blends the geometric, editorial posture of **Outfit** for headlines with the neutral, hyper-legible utility of **Inter** for narrative copy and micro-interface metadata.

- **Display & Headings**: Rendered in Outfit with tightened negative tracking to impart an editorial magazine masthead quality across trip titles, postcard covers, and key metrics.
- **Narrative & Body**: Rendered in Inter with generous line-heights to support effortless scanning and comfortable long-form memoir reading.
- **Labels & Badges**: Set in medium to semi-bold weights with slight letter-spacing expansions to maintain high legibility at micro scales (EXIF data, coordinates, timestamps, and distance tags).

## Layout & Spacing

The layout is built on a responsive multi-column fluid grid, moving dynamically from a single-column layout on mobile to an adaptive master-detail dual-pane format on tablet and desktop screens ($768\text{px}+$ breakpoint). 

- **Mobile Viewports ($<768\text{px}$)**: Single-column scroll flow with `margin: 1rem` and edge-to-edge media previews with integrated gutter padding.
- **Tablet & Desktop ($\ge 768\text{px}$)**: Dual-pane split-screen architecture featuring a fixed `380px` journey master list on the left, paired with an expanded detail timeline and interactive map canvas on the right. Section margins expand to `2.5rem` to emphasize canvas spaciousness.
- **Vertical Rhythm**: Built upon an 8px baseline rhythm (`0.5rem` increments). Content groupings, timeline milestone nodes, and card interiors utilize uniform spacing scales to maintain clean vertical pacing.

## Elevation & Depth

Visual hierarchy combines warm tonal layering with skeuomorphic physical print references:

- **Level 0 (Base Canvas)**: Flat `#FBF9F5` warm paper tint. No shadows.
- **Level 1 (Structural Cards & Timelines)**: Crisp `#FFFFFF` surfaces sitting atop the canvas, defined by hairline `#E9ECEF` borders with an ambient soft drop shadow: `0 2px 8px rgba(31, 36, 33, 0.04)`.
- **Level 2 (Popovers, Dropdowns, Segment Controls)**: Elevated floating surfaces using `0 8px 18px rgba(31, 36, 33, 0.08)`.
- **Level 3 (Interactive Polaroids & Memory Artifacts)**: Tangible, lifted photo cards styled after classic physical prints, utilizing `0 10px 25px rgba(31, 36, 33, 0.15)` paired with a subtle $-1.5^\circ$ to $+2^\circ$ dynamic tilt on hover or selection.
- **Level 4 (Floating Action Buttons & Dialog Modals)**: Critical interactive CTAs cast a warm tinted shadow: `0 12px 28px rgba(226, 109, 92, 0.28)`.

## Shapes

The shape vocabulary emphasizes approachable softness grounded by architectural discipline:

- **Primary Radius (`rounded-md` / `0.5rem`)**: Standard interactive inputs, entry preview cards, and bottom sheet containers.
- **Expanded Radius (`rounded-lg` / `1rem` & `rounded-xl` / `1.5rem`)**: Generative postcard previews, modals, and photo frames.
- **Pill Shape (`9999px` / fully rounded)**: Context tags (e.g., `Sightseeing`, `Coffee`, `Hiking`), distance chips (`142.8 km`), timeline status pills, and the floating navigation switcher.
- **Polaroid Framing**: Rigid geometric rectangular frames with unequal borders (symmetrical $8\text{px}$ top/sides, heavy $24\text{px}$ bottom chin) to evoke vintage instant film cartridges.

## Components

### Buttons & Action Triggers
- **Primary Action (FAB & Journey Creation)**: Pill-shaped or soft-rounded container filled with Earth Terracotta (`#E26D5C`), text in pure white Outfit SemiBold, casting a warm terracotta-tinted glow shadow. Accompanied by tactile haptic feedback on touch devices.
- **Secondary Action**: Bordered button with a $1.5\text{px}$ outline in Forest Teal (`#2C6E49`), warm canvas background, and matching green text.
- **Ghost / Utility**: Neutral Peat text with no border, tinted with a 5% black wash on hover.

### Chips & Badges
- **Status & Category Pills**: Height of `28px`, fully rounded pill radius, padding `0.25rem 0.75rem`. Rendered in low-opacity color tints (e.g., Terracotta at 10% opacity with solid `#E26D5C` text).
- **Postcard Generator Badge**: Sunset Gold (`#FFB703`) icon badge with crisp, high-contrast black typography.

### Form Inputs & Text Areas
- **Input Fields**: Crisp `#FFFFFF` surface with a subtle $1\text{px}$ border in `#E9ECEF`, transitioning to `#E26D5C` upon focus with a $2\text{px}$ ambient focus ring.
- **Story Memoir Field**: Multi-line expandable text area (capped at 5 visible lines before internal scroll), featuring placeholder text styled in editorial italic Inter. Includes clear (`✕`) action icons on the right edge.

### Cards & Timelines
- **WayMark Place Card**: Pure white background, `rounded-md`, hairline border, housing location title, time stamp, and transit type tag.
- **Timeline Connector**: Vertical dashed/dotted path linking consecutive milestone cards ($P_1 \rightarrow P_2 \rightarrow P_3$) with a $2\text{px}$ stroke in `#E9ECEF` and primary accent numbered pins.
- **Polaroid Photo Cards**: White structural border ($8\text{px}$ sides/top, $24\text{px}$ bottom), displaying high-resolution imagery, subtle shadow, and bottom-aligned handwritten caption or EXIF location stamp.

### Selection Controls & Toggles
- **Checkboxes & Radios**: Custom rounded controls; checked state features a filled Earth Terracotta background with a crisp white interior icon.
- **Segmented View Switcher**: Pill-shaped container in `#E9ECEF` hosting sliding active white capsules that indicate list, grid, or map view modes.