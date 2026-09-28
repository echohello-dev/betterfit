Weight and reps entry during a live set. Two side by side, then a primary "Log set".

```jsx
<div style={{ display: 'flex', gap: 12 }}>
  <SetLogField label="Weight" unit="lbs" value={weight} onChange={setWeight} />
  <SetLogField label="Reps" unit="reps" value={reps} onChange={setReps} />
</div>
```

Prefill the previous session's numbers so a set can be logged in one tap.
