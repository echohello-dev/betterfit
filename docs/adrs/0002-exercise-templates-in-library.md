---
date: 2026-01-04
status: Accepted
---

# 0002: Consolidate Exercise Templates in Swift Library

## Context

Exercise template data (names, categories, muscle groups) was duplicated across iOS UI files:

- `AddExerciseSheet.swift` defined 24 exercises with a private `ExerciseTemplate` struct
- `AppSearchView.swift` defined 18 exercises with a private `SearchExercise` struct

This duplication caused:

- Inconsistencies when adding new exercises (had to update multiple files)
- No access to exercise data from watchOS app
- Harder to maintain a single source of truth

We needed to decide where to consolidate this data:

1. **Library layer** (`Sources/BetterFit/Models/`) – hardcoded but shared
2. **Seeded database** (Supabase) – updatable without app release

## Decision

We will consolidate exercise templates in the Swift library at `Sources/BetterFit/Models/ExerciseTemplate.swift`.

Key implementation:

- `ExerciseTemplateCategory` enum with cases: chest, back, shoulders, arms, legs, core
- `ExerciseTemplate` struct with id, name, subtitle, category
- `ExerciseTemplate.allTemplates` static property with 24 built-in exercises
- Helper methods: `templates(for:)` and `search(_:)`
- `exerciseCategory` computed property on `ExerciseTemplateCategory` to map to `ExerciseCategory`

Guardrails:

- Add new exercises to `ExerciseTemplate.allTemplates` only
- Keep category-to-ExerciseCategory mapping in `ExerciseTemplateCategory.exerciseCategory`
- UI files import from library; never duplicate exercise definitions

## Alternatives considered

### Seeded database (Supabase)

Would allow OTA updates without app releases and support user-created exercises.

Rejected because:

- Requires network for initial load or bundled seed data
- More complex to implement for a stable exercise catalog
- Overkill until we need user-created exercises or frequent catalog updates

We can evolve to database storage later if requirements change.

### Keep duplicated in UI files

Would avoid touching library layer.

Rejected because:

- Already caused inconsistencies (18 vs 24 exercises)
- watchOS app couldn't access exercise data
- Violates DRY principle

## Consequences

### Positive

- Single source of truth for exercise templates
- Shared between iOS and watchOS apps
- Easier to add new exercises (one file to update)
- Static helper methods for filtering and searching

### Negative

- Requires app update to add new exercises
- Library now has UI-adjacent data (template display info)

### Follow-up work

- If user-created exercises are needed, add Supabase `exercises` table with migration
- Consider adding equipment, video URLs, or instructions to `ExerciseTemplate`

## References

- File: `Sources/BetterFit/Models/ExerciseTemplate.swift`
- Updated: `Apps/iOS/BetterFitApp/Components/AddExerciseSheet.swift`
- Updated: `Apps/iOS/BetterFitApp/Features/AppSearch/AppSearchView.swift`
