The session card — what the app recommends training next.

```jsx
<WorkoutCard tone="identity" focus="Up next" badge="Today" name="Push A"
  exercises={6} duration="48 min" volume="18.4k lb" muscles={['Chest', 'Shoulders', 'Triceps']} />
```

Use `tone="identity"` for at most one card per screen — the yellow field is the brand moment, everything else stays on dark surface.
