-- BetterFit Persistence Schema
-- Stores workout data, templates, plans, and user profiles for authenticated users

-- =============================================================================
-- WORKOUTS
-- =============================================================================
-- Stores completed and in-progress workout sessions
-- The exercises column stores the full workout structure as JSONB (WorkoutExercise[])

create table if not exists public.workouts (
    id uuid primary key,
    user_id uuid not null references auth.users(id) on delete cascade,
    name text not null,
    exercises jsonb not null default '[]',
    date timestamptz not null default now(),
    duration double precision, -- TimeInterval in seconds
    is_completed boolean not null default false,
    template_id uuid, -- Reference to workout_templates.id (not enforced for flexibility)
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Indexes for common queries
create index if not exists workouts_user_id_idx on public.workouts(user_id);
create index if not exists workouts_date_idx on public.workouts(date desc);
create index if not exists workouts_user_date_idx on public.workouts(user_id, date desc);

-- =============================================================================
-- WORKOUT TEMPLATES
-- =============================================================================
-- Reusable workout templates that can be used to create workouts

create table if not exists public.workout_templates (
    id uuid primary key,
    user_id uuid not null references auth.users(id) on delete cascade,
    name text not null,
    description text,
    exercises jsonb not null default '[]', -- TemplateExercise[]
    tags text[] not null default '{}',
    created_date timestamptz not null default now(),
    last_used_date timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists workout_templates_user_id_idx on public.workout_templates(user_id);

-- =============================================================================
-- TRAINING PLANS
-- =============================================================================
-- Structured multi-week training programs

create table if not exists public.training_plans (
    id uuid primary key,
    user_id uuid not null references auth.users(id) on delete cascade,
    name text not null,
    description text,
    weeks jsonb not null default '[]', -- TrainingWeek[]
    current_week integer not null default 0,
    goal text not null, -- TrainingGoal enum value
    created_date timestamptz not null default now(),
    ai_adapted boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists training_plans_user_id_idx on public.training_plans(user_id);

-- =============================================================================
-- USER PROFILES
-- =============================================================================
-- User profile data for social features

create table if not exists public.user_profiles (
    id uuid primary key,
    user_id uuid not null unique references auth.users(id) on delete cascade,
    username text not null,
    current_streak integer not null default 0,
    longest_streak integer not null default 0,
    total_workouts integer not null default 0,
    active_challenges uuid[] not null default '{}',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists user_profiles_user_id_idx on public.user_profiles(user_id);
create unique index if not exists user_profiles_username_idx on public.user_profiles(username);

-- =============================================================================
-- BODY MAP RECOVERY
-- =============================================================================
-- Tracks muscle recovery status per body region

create table if not exists public.body_map_recovery (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null unique references auth.users(id) on delete cascade,
    regions jsonb not null default '{}', -- { "chest": "fatigued", "back": "recovered", ... }
    last_updated timestamptz not null default now(),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists body_map_recovery_user_id_idx on public.body_map_recovery(user_id);

-- =============================================================================
-- STREAK DATA
-- =============================================================================
-- Dedicated streak tracking (separate from user_profiles for simpler updates)

create table if not exists public.streak_data (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null unique references auth.users(id) on delete cascade,
    current_streak integer not null default 0,
    longest_streak integer not null default 0,
    last_workout_date timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists streak_data_user_id_idx on public.streak_data(user_id);

-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================
-- Users can only access their own data

alter table public.workouts enable row level security;
alter table public.workout_templates enable row level security;
alter table public.training_plans enable row level security;
alter table public.user_profiles enable row level security;
alter table public.body_map_recovery enable row level security;
alter table public.streak_data enable row level security;

-- Workouts policies
create policy "Users can view own workouts"
    on public.workouts for select
    using (auth.uid() = user_id);

create policy "Users can insert own workouts"
    on public.workouts for insert
    with check (auth.uid() = user_id);

create policy "Users can update own workouts"
    on public.workouts for update
    using (auth.uid() = user_id);

create policy "Users can delete own workouts"
    on public.workouts for delete
    using (auth.uid() = user_id);

-- Workout templates policies
create policy "Users can view own templates"
    on public.workout_templates for select
    using (auth.uid() = user_id);

create policy "Users can insert own templates"
    on public.workout_templates for insert
    with check (auth.uid() = user_id);

create policy "Users can update own templates"
    on public.workout_templates for update
    using (auth.uid() = user_id);

create policy "Users can delete own templates"
    on public.workout_templates for delete
    using (auth.uid() = user_id);

-- Training plans policies
create policy "Users can view own plans"
    on public.training_plans for select
    using (auth.uid() = user_id);

create policy "Users can insert own plans"
    on public.training_plans for insert
    with check (auth.uid() = user_id);

create policy "Users can update own plans"
    on public.training_plans for update
    using (auth.uid() = user_id);

create policy "Users can delete own plans"
    on public.training_plans for delete
    using (auth.uid() = user_id);

-- User profiles policies
create policy "Users can view own profile"
    on public.user_profiles for select
    using (auth.uid() = user_id);

create policy "Users can insert own profile"
    on public.user_profiles for insert
    with check (auth.uid() = user_id);

create policy "Users can update own profile"
    on public.user_profiles for update
    using (auth.uid() = user_id);

create policy "Users can delete own profile"
    on public.user_profiles for delete
    using (auth.uid() = user_id);

-- Body map recovery policies
create policy "Users can view own recovery"
    on public.body_map_recovery for select
    using (auth.uid() = user_id);

create policy "Users can insert own recovery"
    on public.body_map_recovery for insert
    with check (auth.uid() = user_id);

create policy "Users can update own recovery"
    on public.body_map_recovery for update
    using (auth.uid() = user_id);

create policy "Users can delete own recovery"
    on public.body_map_recovery for delete
    using (auth.uid() = user_id);

-- Streak data policies
create policy "Users can view own streak"
    on public.streak_data for select
    using (auth.uid() = user_id);

create policy "Users can insert own streak"
    on public.streak_data for insert
    with check (auth.uid() = user_id);

create policy "Users can update own streak"
    on public.streak_data for update
    using (auth.uid() = user_id);

create policy "Users can delete own streak"
    on public.streak_data for delete
    using (auth.uid() = user_id);

-- =============================================================================
-- UPDATED_AT TRIGGER
-- =============================================================================
-- Automatically updates the updated_at column on row changes

create or replace function public.handle_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

create trigger workouts_updated_at
    before update on public.workouts
    for each row execute function public.handle_updated_at();

create trigger workout_templates_updated_at
    before update on public.workout_templates
    for each row execute function public.handle_updated_at();

create trigger training_plans_updated_at
    before update on public.training_plans
    for each row execute function public.handle_updated_at();

create trigger user_profiles_updated_at
    before update on public.user_profiles
    for each row execute function public.handle_updated_at();

create trigger body_map_recovery_updated_at
    before update on public.body_map_recovery
    for each row execute function public.handle_updated_at();

create trigger streak_data_updated_at
    before update on public.streak_data
    for each row execute function public.handle_updated_at();
