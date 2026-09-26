The action primitive — one full-width yellow `primary` per screen, everything else secondary or ghost.

```jsx
<Button icon="play" trailingIcon="caret-right">Start workout</Button>
<Button variant="secondary" fullWidth={false}>Swap exercise</Button>
<Button variant="ghost" fullWidth={false}>View details</Button>
```

Variants: `primary` (electric yellow fill, black label), `secondary` (raised surface + hairline), `ghost` (accent text, no container), `destructive` (inverted — white fill with black label on dark, black fill with light label on light; the system has no red). Sizes `lg`/`md`/`sm` map to 54/44/34px; never go below a 44px tap target for touch.

Because the primary action *is* the brand yellow, a screen gets exactly one. A second yellow fill next to it destroys the hierarchy.
