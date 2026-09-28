import React from 'react';

/** Labelled numeric field for logging a set. Big tabular value, unit suffix. */
export function SetLogField({ label, unit, value, onChange, style, ...rest }) {
  return (
    <label style={{
      flex: 1, minWidth: 0, display: 'block', background: 'var(--surface-raised)', border: '1px solid var(--border)',
      borderRadius: 'var(--radius-md)', padding: '10px 14px', ...style
    }} {...rest}>
      <span style={{
        display: 'block', fontSize: 'var(--text-caption)', fontWeight: 'var(--weight-semibold)',
        textTransform: 'uppercase', letterSpacing: 'var(--tracking-label)', color: 'var(--text-secondary)'
      }}>{label}</span>
      <span style={{ display: 'flex', alignItems: 'baseline', gap: 6 }}>
        <input
          value={value}
          onChange={(e) => onChange && onChange(e.target.value)}
          inputMode="decimal"
          size={1}
          style={{
            flex: 1, width: '100%', minWidth: 0, background: 'transparent', border: 'none', outline: 'none', padding: 0,
            color: 'var(--text-primary)', fontFamily: 'var(--font-mono)', fontSize: 'var(--text-stat-lg)',
            fontWeight: 'var(--weight-bold)', fontVariantNumeric: 'tabular-nums'
          }}
        />
        {unit && <span style={{ fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)' }}>{unit}</span>}
      </span>
    </label>
  );
}
