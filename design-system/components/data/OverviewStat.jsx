import React from 'react';
import { Icon } from '../core/Icon.jsx';

/** Inline icon + value + caption. Sits in a row under a headline, no container. */
export function OverviewStat({ icon, value, label, tint = 'var(--accent-text)', style, ...rest }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 2, ...style }} {...rest}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        {icon && <Icon name={icon} size={13} color={tint} />}
        <span className="bf-num" style={{ fontSize: 'var(--text-stat-sm)', fontWeight: 'var(--weight-semibold)' }}>{value}</span>
      </div>
      <span style={{ fontSize: 'var(--text-caption)', color: 'var(--text-secondary)' }}>{label}</span>
    </div>
  );
}
