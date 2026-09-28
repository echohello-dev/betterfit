Renders one Phosphor icon; use it anywhere the iOS app uses an SF Symbol.

```jsx
<Icon name="barbell" size={18} />
<Icon name="fire-simple" size={16} color="var(--accent)" />
```

Requires the Phosphor webfont in the page head:
`<link rel="stylesheet" href="https://unpkg.com/@phosphor-icons/web@2.1.1/src/fill/style.css">`
(add `/bold/style.css` too if you use `weight="bold"`).

Default weight is `fill`. Keep one weight per screen — BetterFit never mixes stroke and fill icons.

Stroke-only glyphs (`plus`, `check`, `x`, carets, arrows, `magnifying-glass`, `list-checks`, `sliders-horizontal`, `chart-line*`) have no fill cut in Phosphor; the component falls back to `bold` for those so they never render as tofu. Load the bold stylesheet alongside fill.
