Places the supplied BetterFit logo artwork — the only correct way to show the brand mark.

```jsx
<Logo variant="wordmark" height={120} assetBase="../../assets" />
```

Variants: `wordmark` (mark + BETTER FIT on yellow — the only file containing the mark), `stacked` / `stacked-dark` (wordmark only, white / black field; their mark area is blank in the supplied artwork), `lettermark`, `combo`, `appicon` (square app marks).

On a dark screen use `wordmark` or `lettermark`; `stacked` is a white slab and will read as an empty panel. Give the mark clear space of at least its own cap height and never place elements inside it, recolour it, or set the name in live type as a substitute.
