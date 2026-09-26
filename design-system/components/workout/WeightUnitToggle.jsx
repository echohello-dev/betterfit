import React from 'react';

/** Two-option segmented control on a raised well. */
export function WeightUnitToggle({ value = 'lb', options = ['lb', 'kg'], onChange, style, ...rest }) {
  return (
    <div role="group" style={{
      display: 'inline-flex', gap: 2, padding: 2, borderRadius: 'var(--radius-pill)',
      background: 'var(--surface-raised)', border: '1px solid var(--border)', ...style
    }} {...rest}>
      {options.map((o) => {
        const on = o === value;
        return (
          <button key={o} type="button" onClick={() => onChange && onChange(o)} aria-pressed={on}
            style={{
              minHeight: 'var(--tap-min)', padding: '0 18px', borderRadius: 'var(--radius-pill)', border: 'none', cursor: 'pointer',
              background: on ? 'var(--accent)' : 'transparent', color: on ? 'var(--text-on-accent)' : 'var(--text-secondary)',
              fontFamily: 'var(--font-ui)', fontSize: 'var(--text-footnote)', fontWeight: 'var(--weight-semibold)',
              transition: 'background var(--dur-fast) var(--ease-out)'
            }}>{o}</button>
        );
      })}
    </div>
  );
}
