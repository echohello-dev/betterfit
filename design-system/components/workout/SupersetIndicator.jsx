import React from 'react';
import { Icon } from '../core/Icon.jsx';

/** Bracket label grouping exercises performed back to back. */
export function SupersetIndicator({ rounds = 3, label = 'Superset', style, ...rest }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, ...style }} {...rest}>
      <span style={{ width: 2, height: 16, background: 'var(--accent)', borderRadius: 1 }} />
      <Icon name="arrows-clockwise" size={12} color="var(--accent-text)" />
      <span style={{
        fontSize: 'var(--text-caption)', fontWeight: 'var(--weight-semibold)', textTransform: 'uppercase',
        letterSpacing: 'var(--tracking-label)', color: 'var(--text-secondary)'
      }}>{label} · <span className="bf-num">{rounds}</span> rounds</span>
      <span style={{ flex: 1, height: 1, background: 'var(--separator)' }} />
    </div>
  );
}
