---
date: 2025-12-28
status: Proposed
---

# 0001: Supabase for Authentication and Data Persistence

## Context

BetterFit is a strength training iOS + Apple Watch app with plans to expand to Android and potentially web platforms. Users need to:

- Try the app in guest mode without account creation
- Persist workouts across app launches (local or cloud)
- Sign in and sync data across their devices
- Eventually sync data across platforms (iOS, Android, Web)

We evaluated three approaches:

1. **Apple Stack (Sign in with Apple + CloudKit)**: Zero backend, iOS-native, but iOS/Mac only
2. **Firebase (Auth + Firestore)**: Multi-platform, but higher per-user costs at scale ($1,825/mo at 100k users)
3. **Supabase (Auth + PostgreSQL)**: Multi-platform, open source, lower cost ($25/mo at 100k users)

Key constraints:
- Open source philosophy (align with repo values)
- Indie/small-team maintainable (no DevOps heavy infrastructure)
- Privacy-first (fitness data is sensitive)
- Future Android/Web support (multi-platform)
- Cost scales predictably

## Decision

**We will use Supabase Auth + PostgreSQL** for authentication and data persistence.

### Implementation approach:

1. **Authentication**: Supabase Auth with Apple Sign In as primary provider
   - Leverages native iOS `AuthenticationServices` framework
   - Wraps Apple ID login through Supabase OAuth
   - Supports future Google/Email providers for Android

2. **Data Persistence**: Two-tier architecture
   - **Guest mode** (unauthenticated): `UserDefaults` for local-only storage (workouts, plans, preferences)
   - **Authenticated mode** (signed in): PostgreSQL (workouts, user profile, recovery maps, streaks, templates)

3. **Key modules/touchpoints**:
   - New: `Sources/BetterFit/Services/Auth/AuthService.swift` (Supabase auth wrapper + state management)
   - New: `Sources/BetterFit/Services/Persistence/PersistenceProtocol.swift` (abstract interface)
   - New: `Sources/BetterFit/Services/Persistence/LocalPersistenceService.swift` (UserDefaults for guests)
   - New: `Sources/BetterFit/Services/Persistence/SupabasePersistenceService.swift` (PostgreSQL for authenticated)
   - Update: `Sources/BetterFit/BetterFit.swift` (inject persistence service + auth service)
   - New: `Apps/iOS/BetterFitApp/Features/Auth/SignInView.swift` (Apple Sign In UI)
   - Update: `Apps/iOS/BetterFitApp/BetterFitApp.swift` (initialize Supabase, auth state listening)

4. **Guardrails**:
   - Keep persistence protocol abstract—never hardcode Supabase clients into features
   - Workouts and user profile must serialize to JSON (JSONB in PostgreSQL)
   - On login, migrate guest data to PostgreSQL before switching persistence services
   - Do not delete guest data after successful migration (keep as backup)
   - All Supabase keys stored in `Info.plist` with gitignore rules

## Alternatives considered

### 1. Apple Stack (CloudKit + Sign in with Apple)

**Pros:**
- Zero backend to manage
- Free tier generous (use user's iCloud quota)
- Automatic sync across Apple devices
- iOS-native, minimal external dependencies

**Cons:**
- iOS/Mac only—blocks future Android expansion
- Migration to multi-platform backend later would be 3 months of painful work (CloudKit has no bulk export)
- Locks in to 28% global market share (iOS only)
- Depends on user's iCloud storage quota (if full, sync stops silently)
- Limited query capabilities (not SQL)

**Why we didn't choose it:**
We want global reach eventually. Paying 3 months of engineering time to migrate CloudKit→Supabase later is more expensive than using Supabase from day one.

### 2. Firebase (Auth + Firestore)

**Pros:**
- Multi-platform (iOS, Android, Web)
- Easy setup (~1 hour)
- Free tier includes unlimited users + 1GB storage
- Great documentation
- Google maintains it

**Cons:**
- Costs explode at scale: $0 (free) → $825/mo at 50k users → $1,825+/mo at 100k users
- Google owns the data (less privacy control)
- Not self-hostable (vendor lock-in)
- No SQL queries (NoSQL-only)
- Misaligned with open source philosophy

**Why we didn't choose it:**
Cost at scale is prohibitive (18x more expensive than Supabase at 100k users). For an open source fitness app, Google dependency isn't ideal.

### 3. Custom backend (Node.js + PostgreSQL)

**Pros:**
- Full control
- SQLSelf-hostable
- Open source-friendly

**Cons:**
- 4-6 weeks to build secure auth system from scratch
- DevOps burden (maintain server, security patches, backups)
- More to go wrong (our bugs, not Supabase's)
- Not realistic for indie team

**Why we didn't choose it:**
Supabase gives us the same SQL + open source benefits with zero DevOps burden. Build features, not infrastructure.

## Consequences

### Positive:

- **Multi-platform ready**: iOS today, Android/Web tomorrow with same backend
- **Cost predictable**: $0-25/mo regardless of scale (up to 100k users)
- **Open source aligned**: Supabase is MIT-licensed, self-hostable (future option)
- **Privacy control**: Can self-host Supabase if privacy concerns become critical
- **SQL power**: Full PostgreSQL for complex workout queries, analytics, social features
- **Guest mode first**: Users try app before any account creation (lower friction)
- **No vendor lock-in**: Supabase credentials are standard PostgreSQL + JWT, easy to migrate if needed

### Negative:

- **Requires backend**: Supabase project + database setup (2-3 hours)
- **Offline queue manual**: Unlike CloudKit, we build our own offline change queue
- **Internet required**: Auth flow needs internet (unlike CloudKit offline verification)
- **Team responsibility**: We own data security (Supabase is hosting, we control app)
- **SDK dependency**: `supabase-swift` package dependency in `Package.swift`
- **Setup cost now**: 2-3 hours vs CloudKit's 30 minutes

### Follow-up work:

1. Set up Supabase project + PostgreSQL schema
2. Implement auth service + guest/authenticated persistence abstraction
3. Implement iOS Sign In UI + guest→auth migration
4. Add offline queue (for workouts saved without network)
5. Document Supabase setup steps in `CONTRIBUTING.md` for contributors
6. Add environment config (API URL + key) to `Info.plist` + gitignore

## References

- Discussion: Multi-platform auth/persistence evaluation (this conversation)
- Verified pricing/market data: StatCounter (Nov 2025), Supabase docs, Firebase docs
- Related: `docs/adrs/0001-*` when implemented
- Workspace: `Sources/BetterFit/Services/` (auth + persistence modules)
