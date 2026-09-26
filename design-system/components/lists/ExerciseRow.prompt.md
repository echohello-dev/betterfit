A single exercise in the session timeline, with its completion state.

```jsx
<ExerciseRow index={1} name="Back squat" prescription="5 × 5 · 225 lb" state="done" />
<ExerciseRow index={2} name="Romanian deadlift" prescription="3 × 8 · 165 lb" state="active" />
<ExerciseRow index={3} name="Leg press" prescription="3 × 12" isLast />
```

Exactly one row should be `active`. Completion is shown by a check *and* strikethrough, never by colour alone.
