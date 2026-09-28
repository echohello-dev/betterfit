Shows which muscle groups a planned session hits and by how much.

```jsx
<div style={{ display: 'flex', gap: 12 }}>
  <MuscleChip muscle="Chest" percent={42} />
  <MuscleChip muscle="Triceps" percent={33} />
</div>
```

Cap at four chips — beyond that the split stops being a decision aid.
