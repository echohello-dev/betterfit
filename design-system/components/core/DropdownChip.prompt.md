A capsule showing a current selection that opens a menu when tapped — duration, gym, date range.

```jsx
<DropdownChip label="45m" size="lg" onClick={openDuration} />
<DropdownChip label="Anytime Fitness" size="lg" onClick={openGym} />
```

Always label it with the chosen value. Use `Chip` instead when the control toggles rather than opens.
