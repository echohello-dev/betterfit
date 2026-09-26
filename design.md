# BetterFit Design

BetterFit is a personal strength training coach for iPhone and Apple Watch. It helps people decide what to train, move through a workout with less friction, understand recovery, and keep building momentum.

The brand should feel strong, direct, and energising without becoming aggressive. BetterFit is a capable training partner, not a drill sergeant, lifestyle influencer, or clinical dashboard.

## Brand Idea

**Train with direction. Get better with every session.**

BetterFit turns workout history, performance, and recovery into a clear next action. The product should make training feel more understandable and achievable while still respecting the effort involved.

The name carries the promise: not perfect, extreme, or finished. Better.

## Brand Character

BetterFit is:

- **Strong**: bold type, high contrast, decisive actions.
- **Useful**: information appears when it helps someone train, not to decorate a screen.
- **Adaptive**: recommendations respond to performance, equipment, plans, and recovery.
- **Encouraging**: progress is acknowledged without guilt, hype, or empty praise.
- **Human**: language stays plain and practical. Data supports the person rather than defining them.
- **Focused**: one clear primary action should lead each state.

BetterFit is not:

- Militaristic, macho, or intimidating
- Sterile medical software
- A neon cyberpunk fitness game
- A dense analytics terminal
- A soft wellness or mindfulness brand
- A social feed built around comparison

## Audience

BetterFit is for people who want to become stronger but do not want to spend their training time programming workouts or interpreting raw data. It should work for a new lifter who needs confidence and an experienced lifter who values speed, control, and useful adaptation.

Design for someone who may be tired, moving, wearing headphones, or glancing at a watch between sets. The interface must remain legible and operable under those conditions.

## Voice

Write like a knowledgeable training partner standing nearby.

- Use short, active sentences.
- Lead with the action or useful fact.
- Prefer everyday training language over technical or AI language.
- Explain recommendations when the reason improves trust.
- Celebrate completed work, consistency, and progress without exaggeration.
- Never shame missed sessions, low performance, body shape, or recovery needs.
- Avoid slogans about pain, punishment, domination, or earning food.
- Avoid calling ordinary automation "magic" or repeatedly advertising that it is AI.

Prefer:

- "Start workout"
- "Swap exercise"
- "Chest is still recovering. Train back today."
- "Two workouts this week. One more reaches your goal."
- "Ready for your next set?"

Avoid:

- "Crush your limits!"
- "No excuses"
- "AI-powered gains, unlocked"
- "You failed to meet your goal"
- "Summer body loading"

## Visual Identity

The identity is built from bold black forms on electric yellow. The mark combines three compressed oval forms, which suggest plates on a barbell, repetition, and forward momentum, with a heavy geometric letterform. The wordmark is wide, compact, and unapologetically strong.

Use the supplied logo artwork. Do not redraw it with text, alter its proportions, add effects, or place other elements inside its clear space.

BetterFit is a two-colour brand: yellow and black, with white as the reversed ink. There is no secondary brand hue. Do not introduce an additional accent colour — orange, teal, purple, or otherwise — for actions, illustrations, charts, or marketing. Yellow is the accent everywhere.

### Identity Palette

| Role | Value | Use |
| --- | --- | --- |
| BetterFit yellow | `#FFD60A` | Primary identity field, primary action, high-impact highlights |
| Black | `#000000` | Mark, display type, ink on yellow, strong contrast |
| White | `#FFFFFF` | Reversed marks and type on dark fields |

Large yellow fields always carry black content. Yellow is used with intent: one dominant yellow element per screen, not a yellow wash across every surface.

### Product Palette

The training interface is dark-first, calm, and functional. Yellow carries the primary action and the single most important value on a screen; everything else is neutral so that yellow always means "this is what matters".

| Role | Dark | Light |
| --- | --- | --- |
| Page background | `#0B0B0D` | `#F6F6F8` |
| Elevated background | `#131316` | `#FFFFFF` |
| Surface | `#17171B` | `#FFFFFF` |
| Raised surface | `#1F1F25` | `#EFEFF3` |
| Primary text | `#FFFFFF` | `#131317` |
| Secondary text | `#9C9CA6` | approximately `#61616B` |
| Tertiary text | `#63636D` | approximately `#94949E` |
| Primary action | `#FFD60A` | `#FFD60A` |
| Action ink | `#000000` | `#000000` |
| Action tint (subtle) | `#FFD60A` at 16% | `#FFD60A` at 16% |
| Success | `#4ADE80` | `#4ADE80` |
| Warning | `#F5B83D` | `#F5B83D` |
| Danger | `#F04438` | `#F04438` |
| Information / recovered | `#2E90FA` | `#2E90FA` |

Use semantic colors consistently. Recovery runs from blue for recovered, through green and amber, to red for sore. Never rely on color alone to communicate status.

**Yellow versus amber.** Brand yellow and warning amber sit close together, so they must never compete. Yellow appears as a solid fill on interactive elements and on the hero value of a screen. Amber only ever appears as a small indicator — a dot, a bar segment, an icon, a text colour — and never as a filled button or a large field. If a warning needs emphasis, add an icon and a label rather than more colour.

User-selectable themes may change the background atmosphere and the density of yellow, but they must preserve yellow as the accent, the same hierarchy, semantic colors, contrast, and component behaviour.

## Typography

Typography should feel sturdy and immediate.

- Use BBH Hegarty for branded display headings when licensed assets are available.
- Fall back to a heavy rounded system face for headings.
- Use the native system typeface for interface copy and controls.
- Use bold, high-contrast headings and sentence case for most labels.
- Use monospaced digits for timers, weights, reps, percentages, and changing statistics.
- Use uppercase labels sparingly for compact section markers, with generous tracking.
- Support Dynamic Type. Do not fix layouts around one text size.

The core scale is 34, 28, 22, and 20 points for titles; 17 points for body and primary controls; 15 points for supporting copy; and 12 to 13 points for captions. Workout-critical values may be larger, especially on Apple Watch.

## Layout And Shape

- Build on a 4-point spacing rhythm, using 8, 12, 16, 20, 24, and 32 points most often.
- Use 20 points of standard horizontal page padding on iPhone.
- Keep layouts vertically rhythmic, left aligned, and easy to scan.
- Use continuous rounded corners: 16 points for cards, 14 for buttons, 12 for controls, and full capsules only for compact chips.
- Prefer flat, solid surfaces with a subtle one-pixel border for content.
- Avoid glossy gradients, thick shadows, and floating cards without hierarchy.
- Give data room to breathe. Do not fill every space with a metric.
- Use SF Symbols for familiar interface and fitness concepts. Keep icon weights semibold and visually consistent.
- Lay out screens for BetterFit's own hierarchy. Do not reproduce another training app's screen structure, card order, or navigation model.

### Floating Chrome And Translucency

Chrome floats; content does not. Navigation and the primary action ride over the scrolling page in translucent, blurred containers so the page reads as one continuous surface underneath.

- The tab bar is a floating capsule inset from the screen edges, not a bar welded to the bottom of the layout.
- Translucency is **only** for chrome that overlays scrolling content: the nav, the action dock, and revealed swipe actions. Never for cards, list rows, sheets' content, or any surface that holds data.
- Content surfaces stay flat and opaque. A blurred card is a bug.
- Keep text on glass at full-strength primary or secondary colour and verify AA against the lightest content that can pass beneath it. If a label cannot hold contrast, thicken the glass rather than dimming the type.
- Glass carries a hairline border and a soft shadow so its edge is legible over both dark and light content.

### Reach

Assume one hand, in a gym, mid-session.

- The primary action lives in a floating dock at the bottom of the screen, inside thumb reach — never at the top, never only in a header.
- The dock may carry one primary action plus at most two square icon companions.
- Headers are for orientation — what session this is, what it contains. They do not hold the action.
- Frequent, low-risk operations get a horizontal quick-action strip directly under the header: swap, edit, repeat, trim, change equipment.
- Row-level operations belong on swipe. Swiping a list row reveals actions on both edges: destructive and replace on the trailing edge, reordering and grouping on the leading edge. Every swipe action must also be reachable without swiping, for VoiceOver and Switch Control.
- Anything a person does often — starting a suggested session, restarting a frequent one — should be one tap from the screen they land on.

## Components

### Actions

Use one full-width yellow button with black text for the primary action, docked at the bottom of the screen in thumb reach. Secondary actions use a raised neutral surface with a hairline border. Tertiary actions use yellow text without a container. Destructive confirmation uses red and must be explicit.

At most one yellow fill is visible at a time. On screens that lead with a full yellow field, the field **is** the yellow — the docked action is neutral glass. On screens with a neutral header, the docked action carries the yellow. Never both.

Primary buttons are 54 points high. All controls need at least a 44 by 44 point hit target. On Apple Watch, controls should be larger and full width whenever practical.

### Cards

Cards group related decisions or information. They use a solid surface, a subtle border, 16-point corners, and 16-point internal padding. A card should not exist only to decorate content that could sit directly on the page.

### Data

Make the conclusion more prominent than the chart. Show the current value, a short label, and the next useful interpretation. Charts should use restrained axes and semantic color, with yellow reserved for the series the person is actually being asked to act on. Timers and changing values use monospaced digits so they do not jitter.

### Empty And Loading States

Empty states should explain what will appear and give a useful next step. Loading should preserve layout where possible. Errors should say what happened in plain language and offer recovery rather than a dead end.

## Motion And Feedback

Motion should communicate state and momentum.

- Use short, responsive transitions and native spring or snappy timing.
- Give pressed controls a subtle opacity or scale response.
- Animate progress changes, completed sets, and transitions to the next exercise.
- Use haptics for consequential workout actions when supported.
- Avoid ambient looping animation, bouncing icons, confetti for routine actions, and effects that compete with workout data.
- Respect Reduce Motion and other system accessibility settings.

## Imagery

Prefer real, purposeful training imagery with diverse bodies, ages, and experience levels. Show believable effort, correct equipment use, and environments where people actually train. Crop closely enough to feel active, but leave clear space for type.

Avoid hyper-muscular stereotypes, transformation imagery, body comparison, fake holographic data, generic stock smiles, and imagery that suggests pain is the goal.

Illustration, when needed, should use heavy geometric forms, simplified anatomy, and the same high-contrast confidence as the mark, drawn in yellow, black, and white only.

## Accessibility

- Meet WCAG AA contrast at minimum.
- Always pair yellow with black ink, never with white. White on `#FFD60A` fails AA.
- Support Dynamic Type, VoiceOver, Reduce Motion, increased contrast, and light and dark appearances.
- Give controls descriptive labels and meaningful values.
- Do not encode recovery, completion, or errors through color alone.
- Keep workout-critical information visible at a glance and operable with one hand.
- Reaching the primary action must never require moving your hand up the screen.
- Provide a non-swipe route to every swipe action.
- Respect Reduce Transparency: fall back to an opaque chrome fill with the same border and shadow.
- Test the largest accessibility text sizes and the smallest supported Apple Watch display.

## Product Design Test

Before shipping a screen, ask:

1. Is the next action obvious within a glance?
2. Does every metric help the person decide or understand something?
3. Can this be used between sets with one hand?
4. Does it feel strong without becoming aggressive?
5. Does it encourage progress without judgement?
6. Does it still work with large text, VoiceOver, and without color?
7. Is there exactly one thing on this screen wearing yellow?

## Reusable Design Prompt

```text
Design a [screen, flow, campaign, or asset] for BetterFit, a personal strength training coach for iPhone and Apple Watch. BetterFit helps people decide what to train, complete workouts with less friction, understand recovery, and make steady progress.

The brand is strong, direct, useful, adaptive, encouraging, and human. It should feel like a knowledgeable training partner, not a drill sergeant, influencer, clinical dashboard, neon fitness game, or soft wellness app. Make the next action obvious and keep information practical enough to use while moving or between sets.

BetterFit is a two-colour brand: electric yellow #FFD60A and black, with white as reversed ink. Do not introduce any additional accent hue. Use heavy geometric typography and compressed forms inspired by weight plates and repetition. For product UI, use a calm dark-first system with #0B0B0D backgrounds, #17171B surfaces, subtle hairline borders, white primary text, and muted gray secondary text, with yellow #FFD60A carrying the single primary action and always paired with black ink. Use green #4ADE80 for success, amber #F5B83D for warning as a small indicator only, red #F04438 for danger, and blue #2E90FA for information or recovered status.

Use bold headings, native system body text, and monospaced digits for weights, reps, timers, percentages, and stats. Build on a 4-point spacing rhythm with 20-point page margins, flat solid cards, continuous 16-point corners, 54-point primary buttons, and 44-point minimum tap targets. Float the navigation and the primary action as translucent blurred chrome over the scrolling page, and keep the primary action in thumb reach at the bottom; keep content surfaces flat and opaque. Put frequent operations in a quick-action strip and row operations on swipe. Prefer native navigation and controls. Use restrained SF Symbols and short, responsive motion. Invent BetterFit's own screen hierarchy rather than restating another fitness app's layout. Avoid glossy gradients, excessive shadows, dashboard clutter, generic AI visuals, motivational cliches, shame, and macho gym imagery.

Write short, active copy in plain training language. Explain recommendations when it builds trust. Celebrate effort and consistency without hype. The result must support light and dark appearance, Dynamic Type, VoiceOver, Reduce Motion, one-handed use, and WCAG AA contrast.

Create [required deliverable and states]. Include [specific content, constraints, or platform details].
```

## Implementation Reference

The current source of truth for product tokens and primitives lives in:

- `Apps/iOS/BetterFitApp/DesignSystem/BFColors.swift`
- `Apps/iOS/BetterFitApp/DesignSystem/BFTypography.swift`
- `Apps/iOS/BetterFitApp/DesignSystem/BFSpacing.swift`
- `Apps/iOS/BetterFitApp/DesignSystem/BFComponents.swift`
- `Apps/iOS/BetterFitApp/DesignSystem/BFButtonStyles.swift`
- `Apps/iOS/BetterFitApp/AppTheme.swift`
- `Apps/iOS/BetterFitApp/Assets.xcassets/`

`BFColors.brandAccent` (#FF5A3C) is deprecated and must not be used. Point accent usage at the identity yellow token and its black ink pairing. When this document and shipped tokens disagree, resolve the difference intentionally. Do not create a third visual language at the call site.
