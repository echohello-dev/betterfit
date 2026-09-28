import React from 'react';
import { Icon } from '../core/Icon.jsx';
import { Card } from '../core/Card.jsx';

/** Icon + value + label tile. Used in grids for streaks, volume, recovery. */
export function StatTile({ icon, value, label, tint = 'var(--accent-text)', style, ...rest }) {
  return (
    <Card padding={12} style={{ display: 'flex', flexDirection: 'column', gap: 8, ...style }} {...rest}>
      {icon && <Icon name={icon} size={16} color={tint} />}
      <div className="bf-num" style={{ fontSize: 'var(--text-stat-md)', fontWeight: 'var(--weight-bold)' }}>{value}</div>
      <div style={{ fontSize: 'var(--text-caption)', color: 'var(--text-secondary)' }}>{label}</div>
    </Card>
  );
}
