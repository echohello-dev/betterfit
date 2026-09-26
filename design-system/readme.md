# BetterFit Design System

BetterFit is a personal strength training coach for iPhone and Apple Watch. It turns workout history, performance and recovery into a clear next action: what to train today, how to get through the session with less friction, and when to back off.

> **Train with direction. Get better with every session.**

The name carries the promise — not perfect, extreme or finished. Better.

This design system is the web-side expression of that product: the real tokens, the real brand artwork, reusable components, and click-through recreations of both shipped surfaces.

---

## Sources

Everything here was read from material the user supplied. You may not have access to these; they are recorded so you can go deeper if you do.

| Source | What it gave us |
| --- | --- |
| `betterfit/` (mounted local codebase — Swift package + iOS/watchOS apps) | Ground truth for every token, component and screen |
| `betterfit/design.md` | The authored brand document: idea, character, voice, palettes, layout, motion, imagery |
| `betterfit/Apps/iOS/BetterFitApp/DesignSystem/` | `BFColors.swift`, `BFTypography.swift`, `BFSpacing.swift`, `BFComponents.swift`, `BFButtonStyles.swift`, `BFRecovery.swift` |
| `betterfit/Apps/iOS/BetterFitApp/AppTheme.swift` | Six user-selectable accent themes |
| `betterfit/Apps/iOS/BetterFitApp/Assets.xcassets/` | Logo artwork and app icons (copied into `assets/`) |
| `betterfit/Apps/iOS/BetterFitApp/Fonts/` | BBH Hegarty Regular (copied into `assets/fonts/`) |
| `betterfit/Apps/iOS/BetterFitWatchApp/` | Watch palette and the three watch screens |
| https://github.com/echohello-dev/betterfit | Public repository for the same project — **read it for anything this system doesn't cover**: services, models, the full SwiftUI view code, and the docs in `docs/` |

Explore the repository above if you need more than this system carries. The Swift views are the best available reference for interaction detail, and `design.md` is the canonical brand statement.

### Products represented

1. **BetterFit for iPhone** — the main product. Tabs: Workout, Body, Targets, Log. Suggested sessions, live set logging, recovery readiness, streaks and personal records, theming. Search, Me and Settings are pushed surfaces rather than tabs.
2. **BetterFit for Apple Watch** — a stripped companion: pick a workout, log sets, see the summary. Bigger controls, glanceable numbers.

There is no marketing website, docs site, or slide template in the supplied material, so this system contains no kits or slides for them.

---

## The redesign

The user asked to reimagine the product. Two things stayed fixed and one thing changed.

**Fixed** — the type scale, the 4-point rhythm, the flat hairline-bordered surfaces, every screen and every piece of copy behaviour. Those come from shipped code and an authored brand doc; they are the product.

**Changed** — the shipped app runs on ember orange `#FF5A3C` with a six-accent theme picker and a four-hue semantic palette, and keeps the identity yellow locked inside the app icon. This system collapses all of that to **two colours: electric yellow and black.**

- **Yellow is the accent.** `--accent` is `#FFD60A` and every primary action is a yellow fill with a **black** label. Ember, the six theme accents, and the green/amber/red/blue semantic hues are gone.
- **Light and dark are peers.** Both schemes carry the same two colours over mirrored neutrals; `[data-scheme="light"]` flips the surfaces, text and the yellow-ladder steps. Nothing is dark-only.
- **Status without hue.** Meaning comes from brightness on a four-step yellow ladder (`#FFE860 → #FFD60A → #C9A800 → #7A6600`) plus the written word. Destructive actions **invert** — white fill, black label on dark — because there is no alarm colour to reach for.
- **A full-bleed yellow slab.** The session you are about to train sits in a squared-off, edge-to-edge yellow field with black display type at 44px (`Slab` in the iPhone kit, `WorkoutCard tone="identity"` as the DS component), and its CTA is a **black pill inside the slab**.
- **One yellow area per screen.** Because the accent *is* the brand colour, two yellow fills on one screen destroy the hierarchy. Either the slab or the primary button — never both.
- **Squared at page level, rounded inside.** Page-width bands use `--radius-band: 0`; everything nested keeps the shipped 16px card / 14px button / 12px control radii.
- **Numbers as the headline.** The conclusion leads in oversized tabular figures; the chart is demoted to context.

**Tokens, type scale, spacing rhythm and copy behaviour are a faithful recreation** — where one of those differs from the Swift source, the Swift source wins.

**iPhone screen layout is not.** The six training screens (Plan, Body, Targets, Log, Session, Summary) were reimagined on an in-house layout language — ruled rows on the page instead of cards, a 32px monospaced gutter down every list, one squared yellow slab carrying the headline and the single primary action, and bars on a shared left edge instead of rings. That is a deliberate departure from `WorkoutHomeView*.swift` and `ActiveSessionView.swift`, which remain the reference for *interaction* detail and copy, not for composition. `ui_kits/ios_app/README.md` documents the language and states which screens are on it.

---

## CONTENT FUNDAMENTALS

Write like a knowledgeable training partner standing nearby — not a coach shouting, not a dashboard reporting.

**Sentence case everywhere.** Buttons, titles, list rows, settings. The only uppercase is the section label (12px, `0.1em` tracking, secondary colour) and it should appear once or twice per screen at most.

**Lead with the action or the useful fact.** "Start workout", not "Ready to begin your workout?". "Chest is still recovering. Train back today.", not "Recovery status: sub-optimal".

**Short active sentences.** One idea each. Two sentences is a long piece of copy in this product.

**Second person, no first person.** "Your last four sessions", never "we recommend" or "I've planned". The product doesn't refer to itself.

**Explain a recommendation when the reason builds trust,** and only then: "Back and biceps today. Push moves to Thursday."

**Acknowledge progress without hype.** "Two workouts this week. One more reaches your goal." "Twelve weeks unbroken." "Good work."

**Never shame.** Not missed sessions, not low numbers, not body shape, not needing rest. There is no "You failed to…" state in this product.

**Never advertise the automation.** Adaptation is described by what it does ("Regenerate this week"), not by what powers it. No "AI-powered", no "magic".

**No emoji.** None appear in the product UI. (The repository README uses them in its feature bullets; that is developer documentation, not product copy, and it is not a licence to use them in interfaces.)

**Empty states name the gap and offer the step:** "No exercises planned — Add a lift, or generate a session from your recovery."

**Errors say what happened in plain language and offer a way out.** Never a dead end, never a code.

| Prefer | Avoid |
| --- | --- |
| Start workout | Crush your limits! |
| Swap exercise | No excuses |
| Chest is still recovering. Train back today. | Recovery index: 34% (suboptimal) |
| Two workouts this week. One more reaches your goal. | You failed to meet your goal |
| Ready for your next set? | AI-powered gains, unlocked |
| Good work | Summer body loading |

---

## VISUAL FOUNDATIONS

### Colour

Two palettes with different jobs.

**Two colours, no exceptions.** `--bf-yellow #FFD60A` and `--bf-black #000000`, plus white and a neutral grey ladder. There is no third hue anywhere in the system — no orange, no red, no green, no blue, and no theme picker.

**Yellow is the accent as well as the identity.** `--accent` is the yellow; `--text-on-accent` is black. Primary buttons, the active tab, selected chips, progress fills and the identity band all use it. Because it is the brand colour, **a screen gets exactly one yellow area.**

**Yellow ladder** — the only chromatic range: `--yellow-bright #FFE860`, `--bf-yellow #FFD60A`, `--yellow-deep #C9A800`, `--yellow-dim #7A6600`. Everything that used to need a second hue now moves along this ladder.

**Yellow as text** needs care: `--accent` on a light field fails contrast, so text and icons use `--accent-text` — the yellow on dark, `#8A7100` on light. Never set body or link text to `--accent` directly.

**Neutrals, dark (default)** — page `#0B0B0D`, elevated `#131316`, surface `#17171B`, raised `#1F1F25`; white primary text, `#9C9CA6` secondary, `#63636D` tertiary.

**Neutrals, light** — `[data-scheme="light"]` mirrors it: `#F6F6F8` page, white surfaces, `#EFEFF3` raised, `#131317` text, and darker ladder steps so yellow stays legible on white. Light and dark are equal citizens; nothing is dark-only.

**Status carries no hue of its own.** `--success` is the bright ladder step, `--warning` the core yellow, `--info` the deep step, and `--danger` resolves to `--text-primary` — destructive controls **invert** (white fill, black label on dark) rather than turning red. Every status is also written out, so stripping colour strips nothing.

**Recovery** runs by brightness: recovered (brightest) → fresh → fatigued → sore (dimmest), always beside the written status.

Tinted surfaces are the accent or a ladder step at **15%** opacity (recovery badges use 22% with a 45% border). Those are the only tint ratios in the system.

### Type

Display is **BBH Hegarty** at `+0.005em` tracking and `1.05` line-height — the Swift source specifies `-0.02em`, but that assumes the Bold/ExtraBold cut; with only the Regular cut licensed here, negative tracking collides at title sizes. **Restore `-0.02em` once the heavier cuts arrive.** It carries the hero (56px), large title (34), title 1 (28) and title 2 (22). Interface copy is the **native system face**: headline/body 17, callout 16, supporting 15, footnote 13, caption 12. Timers, weights, reps, percentages and any changing statistic use **tabular figures** (`.bf-num`) so they don't jitter; the timer itself (40px) uses the mono stack.

Section labels are 12px semibold uppercase at `0.1em` tracking in secondary text. Nothing else is uppercase.

The scale is a point scale carried to px 1:1 from `BFTypography.swift`. Do not invent intermediate sizes.

### Spacing and layout

A **4-point rhythm** — 4 / 8 / 12 / 16 / 20 / 24 / 32 / 48 — with 8, 12, 16, 20, 24 and 32 doing nearly all the work. Page margins are **20px**. Card padding is **16px**. Layouts are vertically rhythmic, **left-aligned**, and scannable in one pass. Data gets room; not every gap needs a metric.

Fixed elements: the tab bar, and the primary CTA that floats above it (`safeAreaInset` in the shipped app, a gradient-masked footer here). Nothing else is pinned.

### Shape

Continuous rounded corners: **16px** cards, **14px** buttons, **12px** controls, **24px** sheets, full capsules for chips and only chips. The redesign adds **0px** for page-width identity bands. Controls are **54px** (primary CTA), **44px** (standard, and the minimum tap target), **34px** (compact).

### Surfaces, borders and shadows

Flat, solid fills with a **1px hairline border** — `--border` is `rgba(255,255,255,.07)` on dark, `rgba(0,0,0,.08)` on light. Always write `1px solid var(--border)`; there is deliberately no composite `--hairline` token, because a shorthand containing `var(--border)` resolves at `:root` and would freeze the dark value for every scheme. **No shadows on dark**; the light scheme gets a barely-there `0 1px 2px rgba(0,0,0,.05)` on cards and a real shadow only on sheets and popovers. No blur-heavy glass, no glossy gradients, no floating cards without hierarchy.

The single gradient in the system is functional: a page-colour scrim behind the floating CTA so scrolling content passes under it legibly. Protection is a scrim, never a capsule.

### Backgrounds and imagery

Product backgrounds are **solid colour**. No patterns, textures, grain or illustration wallpaper. Imagery, where the brand uses it, is real training photography — diverse bodies, ages and experience levels, believable effort, correct equipment, environments where people actually train. Cropped close enough to feel active, with clear space left for type. Colour is **neutral to warm, natural light**, never teal-orange graded and never fake holographic data overlays. Avoid hyper-muscular stereotypes, transformation and before/after imagery, body comparison, stock smiles, and anything implying pain is the goal. **No photography is supplied with this system** — ask for real assets rather than substituting stock.

Illustration, when needed, uses heavy geometric forms, simplified anatomy, and the same high-contrast confidence as the mark. The shipped app contains hand-built SwiftUI illustrations (`BFIllustrations.swift`: an ember mascot, a body-map companion, athlete poses) which have no exported artwork; they are **not** reproduced here.

### Transparency and blur

Transparency is used for exactly three things: hairline borders, 15% accent tints, and disabled state (40%). **Blur is not used at all.** If a surface needs to separate from what's behind it, it gets a solid fill and a border.

### Motion

Short and responsive. `120ms` press feedback, `180ms` state changes, `250ms` transitions, `350ms` for progress arcs. Easing is `cubic-bezier(.2,.8,.3,1)` by default, a snappier `cubic-bezier(.32,.72,0,1)` for progress, and a light spring for sheets and card stacks. Progress changes, completed sets and advancing to the next exercise animate. Nothing loops, nothing bounces for its own sake, no confetti for routine work, and every duration collapses to zero under `prefers-reduced-motion`.

### Interaction states

- **Hover** — not a primary concern (this is a touch product). Where it applies, it's a small opacity lift, never a colour change.
- **Press** — primary: opacity `0.85` **and** scale `0.985`. Secondary: opacity `0.7`. Ghost: opacity `0.6`. Icon buttons: opacity `0.7`. Never a darker fill; never a bounce.
- **Selected** — yellow fill with a **black** label (chips, tabs, segments, toggles). Toggle knobs go black when on.
- **Disabled** — opacity `0.4`, cursor `not-allowed`, no colour change.
- **Focus** — a `--focus-ring` in `--text-primary`, because yellow is already carrying the selected state.

### Accessibility

WCAG AA minimum. Light and dark, Dynamic Type, VoiceOver, Reduce Motion. Recovery, completion and errors are never encoded by colour alone — completion is a check *and* a strikethrough; recovery is a dot *and* a word. Workout-critical values stay legible one-handed and in motion.

---

## ICONOGRAPHY

**The shipped apps use SF Symbols exclusively** — no icon font, no SVG sprite, no PNG icon set, nothing exportable. Common glyphs across the codebase: `figure.run`, `waveform`, `magnifyingglass`, `person.fill`, `flame.fill`, `heart.fill`, `sparkles`, `calendar`, `chart.bar.fill`, `chevron.right`, `checkmark.circle.fill`, `plus.circle.fill`, `arrow.left.arrow.right`, `timer`, `ellipsis`, `bell`, `gearshape`, `trophy`. Weights are semibold and visually consistent; sizes sit between 12 and 36pt with 44pt circular tinted containers for list-row icons.

**Substitution (please confirm):** SF Symbols cannot be licensed onto the web, so this system uses **[Phosphor Icons](https://phosphoricons.com) at `fill` weight** from CDN, which is the closest match to SF Symbols semibold in stroke mass and terminal shape. `bold` weight is also loaded for chevrons and checks. Every icon goes through the `Icon` component so the whole set can be swapped in one place.

```html
<link rel="stylesheet" href="https://unpkg.com/@phosphor-icons/web@2.1.1/src/fill/style.css">
<link rel="stylesheet" href="https://unpkg.com/@phosphor-icons/web@2.1.1/src/bold/style.css">
```

Rules: one weight per screen, never mix stroke and fill. Icons are decorative next to a label and carry an `aria-label` only when they stand alone. **Emoji are never used in the interface.** Unicode characters are not used as icons; the middle dot `·` is used as a separator in metadata strings ("6 exercises · 48 min") and that is its only decorative role.

The brand marks in `assets/` are real supplied artwork and are placed via the `Logo` component — never redrawn, retyped, recoloured or reconstructed.

**Asset defect worth knowing:** only `logo.png` (the yellow primary lockup) actually contains the three-oval mark. In `logo-stacked.png` and `logo-stacked-dark.png` the mark area renders the same colour as its field, so those two files are wordmark-only. On dark screens use the yellow lockup or the square lettermark. **Please re-export the stacked lockups.**

---

## Font substitutions — please confirm

- **BBH Hegarty** ships as **Regular (400) only** (`assets/fonts/BBHHegarty-Regular.ttf`, OFL). The identity wordmark is far heavier than 400 and the shipped app asks for `BBHHegarty-ExtraBold` / `-Bold` first, falling back to a heavy rounded system face. **If you have licensed Bold / ExtraBold cuts, please add them** — display headings are currently rendering at 400 with tight tracking, which reads deliberate but is not the intended weight.
- **SF Pro / the system UI face** is not a webfont. Body copy uses `-apple-system, BlinkMacSystemFont, "Segoe UI", system-ui` so Apple platforms get the real face and others get their native equivalent.
- **SF Symbols → Phosphor Icons (fill)**, as above.

---

## Components

Thirty-two components, grouped by concern. The inventory maps 1:1 onto what the codebase defines — nothing was invented to round out a "standard set".

**`components/core/`** — `Button`, `IconButton`, `Card`, `SectionHeader`, `Divider`, `Chip`, `DropdownChip`, `MetricPill`, `Icon`, `Logo`, `PhotoSlot`

**`components/data/`** — `ProgressRing`, `Gauge`, `StatTile`, `OverviewStat`, `LegendDot`, `MuscleChip`, `ContributionHeatmap`

`ProgressRing` and `Gauge` are for the Apple Watch kit and the specimen cards only. No iPhone screen uses them — on iPhone, progress and readiness are ruled bars on a shared left edge, never rings.

**`components/lists/`** — `ListRow`, `ChevronRow`, `ExerciseRow`, `SettingsRow`

**`components/feedback/`** — `RecoveryDot`, `RecoveryBadge`, `EmptyState`, `RestTimerBar`, `Banner`

**`components/workout/`** — `WorkoutCard`, `SetLogField`, `WeightUnitToggle`, `SupersetIndicator`

Every component has a sibling `.d.ts` (props contract) and `.prompt.md` (what & when, a usage example, notable variants). Each group directory has one gallery card.

<details>
<summary>Where each one comes from</summary>

| Component | Swift source |
| --- | --- |
| `Button` | `BFButtonStyles.swift` — `BFPrimary/Secondary/Ghost/Destructive ButtonStyle` (destructive re-expressed as inversion) |
| `IconButton` | `BFButtonStyles.swift` `BFIconButton`, `UIComponents.swift` `BFChromeIconButton` |
| `Card` | `BFComponents.swift` `BFDSCard`, `UIComponents` `BFCard` |
| `SectionHeader` | `BFComponents.swift` `BFSectionHeader` |
| `Divider` | `BFComponents.swift` `BFDivider` |
| `Chip` | `BFComponents.swift` `BFChip` |
| `MetricPill` | `UIComponents.swift` `MetricPill` |
| `ProgressRing` | `BFComponents.swift` `BFProgressRing`, `UIComponents` `ProgressRing` |
| `Gauge` | `WorkoutHomeComponents.swift` `SemiCircularGauge` |
| `StatTile` | `BFComponents.swift` `BFStatTile` |
| `OverviewStat` | `WorkoutHomeComponents.swift` `OverviewStat`, `GoalStat` |
| `LegendDot` | `WorkoutHomeComponents.swift` `CategoryLegendDot` |
| `MuscleChip` | `WorkoutHomeComponents.swift` `CompactMuscleChip`, `TargetMuscleView` |
| `ContributionHeatmap` | `WorkoutHomeComponents.swift` `ContributionHeatmap` |
| `ListRow` | `BFComponents.swift` `BFListRow` |
| `ChevronRow` | `BFComponents.swift` `BFChevronRow` |
| `ExerciseRow` | `WorkoutHomeView+Sections.swift` `StaticTimelineRow`, `CompactExerciseRow`, `ExercisePreviewRow` |
| `SettingsRow` | `SettingsView.swift` `SettingsToggleRow` / `RadioRow` / `StaticRow` / `LinkRow` |
| `RecoveryDot`, `RecoveryBadge` | `BFRecovery.swift` |
| `EmptyState` | `BFComponents.swift` `BFEmptyState` |
| `RestTimerBar` | `ActiveSessionView.swift` `RestTimerBar` |
| `Banner` | `HealthKitComponents.swift` `AppleHealthReminderBanner` |
| `WorkoutCard` | `WorkoutHomeComponents.swift` `WorkoutSwipeCard`, `WorkoutSuggestionCard`, `PlayingCardWorkoutCard` |
| `SetLogField` | `ActiveSessionView.swift` `ActiveSessionField` |
| `WeightUnitToggle` | `UnifiedExerciseTimeline.swift` `WeightUnitToggle` |
| `SupersetIndicator` | `UnifiedExerciseTimeline.swift` `SupersetIndicator` |

</details>

### Intentional additions

- **`Icon`** — a wrapper over the substituted Phosphor set. The Swift code calls `Image(systemName:)` inline; the web needs one seam so the whole icon set can be replaced at once.
- **`Logo`** — places the supplied artwork from `assets/`. Exists so nobody is ever tempted to retype the wordmark.
- **`DropdownChip`** — a capsule showing a current selection that opens a menu. The Swift source builds this inline as a `Menu` label in several places (heatmap range, equipment); the web needs it as one component.
- **`PhotoSlot`** — a labelled placeholder for photography. BetterFit ships no image assets, so this keeps every missing photo visible instead of silently filling it with stock.

### Deliberately not built

`BFIllustrations.swift` (`EmberMascot`, `BodyMapCompanion`, `AthleteIllustration`) is drawn in SwiftUI shapes with no exported artwork. Reproducing it would mean hand-drawing brand illustration, so it is omitted. **Ask for exported illustration assets** if a screen needs them.

---

## Index

```
readme.md                  this file — the design guide
SKILL.md                   Agent Skills entry point
github.md                  upstream repository association
styles.css                 the one file consumers link (@import list only)
thumbnail.html             homepage tile

tokens/                    fonts · colors · typography · spacing · radii · elevation · motion · base
                           colors.css is the whole palette: yellow, black, neutrals, one ladder
assets/                    logo.png · logo-stacked.png · logo-stacked-dark.png
                           icon-lettermark.png · icon-combo.png · app-icon-1024.png
                           fonts/BBHHegarty-Regular.ttf · fonts/OFL.txt
guidelines/                23 foundation specimen cards (Brand · Colors · Type · Spacing · Motion)
components/<group>/        30 components — .jsx + .d.ts + .prompt.md, one gallery card per group
ui_kits/ios_app/           7-screen click-through iPhone recreation (README.md · index.html)
ui_kits/watch_app/         3-screen Apple Watch recreation (README.md · index.html)
templates/                 starting folders consuming projects can copy
```

### UI kits

| Kit | Entry | Screens |
| --- | --- | --- |
| iPhone app | `ui_kits/ios_app/index.html` | Plan · Live session · Body (recovery + strength) · Targets · Log & calendar · Workout summary · Sign in · Home · Search · Me · Settings |
| Apple Watch app | `ui_kits/watch_app/index.html` | Workout list · Active workout · Summary |

### Product design test

Before shipping a screen, ask:

1. Is the next action obvious within a glance?
2. Does every metric help the person decide or understand something?
3. Can this be used between sets with one hand?
4. Does it feel strong without becoming aggressive?
5. Does it encourage progress without judgement?
6. Does it still work with large text, VoiceOver, and without colour?
