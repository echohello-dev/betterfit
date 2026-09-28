# BetterFit iPhone — UI kit

A click-through recreation of the BetterFit iPhone app, composed entirely from this design system's components.

Open `index.html`. The pills under the phone jump between screens; the tab bar and buttons inside the phone work. Toggle light and dark with the last pill.

## Which layout language each screen uses

Two conventions live here on purpose. **The Ledger** is the current language for every screen whose job is to show training data or drive a session. Standard DS list and form components carry the screen classes where a ledger would be wrong — settings forms, search results, sign-in.

| Screen | File | Language | Recreated from |
| --- | --- | --- | --- |
| Plan (today's session) | `MyPlanScreen.jsx` | **Ledger** | `Features/WorkoutHome/WorkoutHomeView*.swift`, `Features/Trends/PlanView.swift` |
| Body (recovery) | `BodyScreen.jsx` | **Ledger** | `Features/Recovery/RecoveryView.swift` |
| Targets | `TargetsScreen.jsx` | **Ledger** | *No counterpart — see below* |
| Log | `LogScreen.jsx` | **Ledger** | *No counterpart* |
| Live session | `SessionScreen.jsx` | **Ledger** | `Features/ActiveWorkout/ActiveSessionView.swift` |
| Workout summary | `SummaryScreen.jsx` | **Ledger** | *No counterpart* |
| Add exercise (sheet) | `AddExerciseSheet.jsx` | Sheet + DS lists | *No counterpart* |
| Search | `SearchScreen.jsx` | DS lists | `Features/AppSearch/AppSearchView.swift` |
| Me | `ProfileScreen.jsx` | DS lists + cards | `Features/Profile/ProfileView.swift` |
| Settings | `SettingsScreen.jsx` | DS `SettingsRow` form | `Features/Profile/SettingsView.swift`, `Features/Theme/ThemePickerView.swift` |
| Sign in | `SignInScreen.jsx` | Brand moment | `Features/Auth/SignInView.swift` |

Profile, Settings, Search and Sign in are **intentionally not** on the Ledger: a settings form is a form, and a search result list is a result list. If you are building a new data or session screen, use the Ledger.

Two screens were **removed** in the reimagining rather than ported. The old `HomeScreen` duplicated what the Plan tab now does, and the old `PlanScreen` showed the same recovery data as Body in a ring-and-card language the system no longer uses. Their territory is folded into `MyPlanScreen` and `BodyScreen`. Previous versions of all six reimagined screens are archived as `v1/*.jsx.bak` (renamed off `.jsx` so the compiler does not read them as duplicate components).

## The Ledger

**Rules, not cards.** Lists are hairline-separated rows on the page background. No card fills, no radii, no photo thumbnails, no nested containers. Density comes from the rule, hierarchy from type weight.

**A 32px mono gutter runs down every list.** It carries the exercise index (`01`–`07`), the date, the set number, the weekday, or a single glyph — so every screen shares one left axis and reads like a spec sheet.

**One squared yellow field per screen — or one yellow docked action, never both.** Outcome and reading screens (Summary, Targets) lead with a full-bleed yellow `Slab` carrying the headline and the mono facts that qualify it (`SpecStrip`); their docked action is neutral glass. Action screens (Plan, Session) use a neutral `HeaderBlock` and put the yellow on the primary button in the bottom dock, where a thumb can reach it. Body and Log open on a `Readout` instead: one huge mono value, its label, and the sentence that interprets it — conclusion before chart.

**Chrome floats, content doesn't.** The tab bar is a translucent blurred capsule inset from the screen edges (`TabBar`), and the primary action sits in a floating `GlassDock` above it — so the page scrolls as one continuous surface and nothing important sits out of thumb reach. Translucency is confined to chrome: nav, dock, quick-action chips and revealed swipe actions. Content surfaces stay flat and opaque.

**Editing is where your thumb already is.** A horizontal `QuickActions` strip sits directly under the header for the operations people repeat — swap session, edit, repeat last, trim to 30 minutes, change gym. `SwipeRow` gives every exercise row actions on both edges: **Replace** and **Remove** trailing, **To top** and **Superset** leading. Remove is inverted (white fill, black glyph) because the system has no alarm colour.

**Sessions are sourced, not searched.** Under the work list, a two-option switch offers **Suggested** (ordered by recovery, with the reason written out) and **Frequent** (ordered by how often you actually run it), each row one tap from starting.

**Charts are bars on a shared left edge, never rings.** Recovery, targets and post-session fatigue all use the same 4px `Bar` on the yellow ladder, always paired with the written status. `ProgressRing` and `Gauge` remain in the system for the Watch kit and specimen cards, but no iPhone screen uses them.

The primitives are exported from `AppShell.jsx`: `Slab`, `SlabAction`, `SpecStrip`, `HeaderBlock`, `SectionRule`, `LedgerRow`, `SwipeRow`, `Readout`, `Bar`, `AddRow`, `LedgerHead`, `Eyebrow`, `GlassDock`, `PrimaryAction`, `DockButton`, `QuickActions` — alongside the chrome (`Phone`, `StatusBar`, `NavBar`, `TabBar`, `Scroll`). Glass values come from tokens (`--glass-fill`, `--glass-fill-strong`, `--glass-border`, `--glass-highlight`, `--glass-blur`, `--glass-shadow`), defined for both schemes. `IdentityBand` was retired: `Slab` does the same job and is the one full-bleed yellow field in the kit. Fake content lives in `data.js`.

Structural departures worth noting: the Log is a vertical date ledger rather than a month calendar grid; Body needs no muscle-map artwork because readiness is carried by ruled bars; the live Session leads with the current set as the largest thing on screen and pushes the set list below it; and "Add exercise" is the last ruled row of a list rather than a dashed box.

## Screens without a source

Four screens have no counterpart in the attached codebase. They were requested from screenshots of a **different, commercial** strength-training app, so they are **not** recreations — that product's palette, wordmark, scoring names, share card, hexagon target ring and photo-thumbnail timeline are its own and are deliberately absent.

What was taken is the *functional territory* only — which surfaces the product needs. Each is designed in BetterFit's own language.

| Screen | The job it does |
| --- | --- |
| `TargetsScreen` | Weekly targets, the week ahead, streak, and records |
| `LogScreen` | Streak, consistency over 26 weeks, a month ledger of sessions, and lifetime counters |
| `SummaryScreen` | A finished session: duration, volume, sets, records, per-exercise results, and its effect on recovery |
| `AddExerciseSheet` | Search, browse by muscle or category, multi-select exercises, optionally group them as a circuit |

`AddExerciseSheet` opens from three places, all of which return to where they were called: the **Add exercise** row at the foot of the plan list, the row beside "Up next" during a live session, and the equivalent rows on the summary and log screens. Selection is multi-pick with a yellow check; the footer CTA counts what's chosen and stays disabled at zero.

## What the redesign changed

The shipped app runs on ember orange with a six-accent theme picker. This kit reduces the palette to **electric yellow and black in light and dark**, and — because the accent *is* the brand yellow — the primary action lives **inside** the yellow slab as a black pill rather than floating above the tab bar. One yellow area per screen.

Tabs match the shipped `AppTab` enum: Workout, Body, Targets, Log.
