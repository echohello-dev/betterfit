Fills an empty list or screen with an explanation and a way forward.

```jsx
<EmptyState icon="list-checks" title="No exercises planned"
  message="Add a lift, or generate a session from your recovery and equipment."
  action={<Button size="sm" fullWidth={false}>Add exercise</Button>} />
```

Never leave an empty state without a next step, and never shame the user for the gap.
