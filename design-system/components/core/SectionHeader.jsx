import React from 'react';

/** Uppercased tracked section marker with an optional trailing action. */
export function SectionHeader({ title, action, style, ...rest }) {
  return (
    <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 12, ...style }} {...rest}>
      <span style={{
        fontSize: 'var(--text-caption)', fontWeight: 'var(--weight-semibold)', textTransform: 'uppercase',
        letterSpacing: 'var(--tracking-label)', color: 'var(--text-secondary)'
      }}>{title}</span>
      {action}
    </div>
  );
}
