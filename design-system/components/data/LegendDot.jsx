import React from 'react';

/** Colour key for a split or chart series. */
export function LegendDot({ label, percent, color = 'var(--accent)', style, ...rest }) {
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontSize: 'var(--text-caption)', color: 'var(--text-secondary)', ...style }} {...rest}>
      <span style={{ width: 8, height: 8, borderRadius: 'var(--radius-pill)', background: color }} />
      <span>{label}</span>
      {percent != null && <span className="bf-num" style={{ color: 'var(--text-primary)', fontWeight: 'var(--weight-semibold)' }}>{percent}%</span>}
    </span>
  );
}
