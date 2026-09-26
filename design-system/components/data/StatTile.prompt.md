One number in a card, for 2- or 3-up stat grids.

```jsx
<div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 12 }}>
  <StatTile icon="fire-simple" value="12" label="Day streak" />
  <StatTile icon="barbell" value="18.4k" label="Volume (lb)" />
  <StatTile icon="heartbeat" value="72%" label="Recovery" tint="var(--info)" />
</div>
```
