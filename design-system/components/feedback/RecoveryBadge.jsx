import React from 'react';
import { RECOVERY_COLORS } from './RecoveryDot.jsx';

const LABEL = { recovered: 'Recovered', fresh: 'Fresh', fatigued: 'Fatigued', sore: 'Sore' };

/** Tinted capsule stating a recovery status in words. */
export function RecoveryBadge({ status = 'recovered', style, ...rest }) {
  const c = RECOVERY_COLORS[status];
  return (
    <span style={{
      color: 'var(--text-primary)', background: `color-mix(in srgb, ${c} 22%, transparent)`,
      border: `1px solid color-mix(in srgb, ${c} 45%, transparent)`,
      padding: '3px 10px', borderRadius: 'var(--radius-pill)', display: 'inline-flex', alignItems: 'center', gap: 6,
      fontSize: 'var(--text-caption)', fontWeight: 'var(--weight-semibold)', ...style
    }} {...rest}>
      <span style={{ width: 7, height: 7, borderRadius: 'var(--radius-pill)', background: c }} />
      {LABEL[status]}
    </span>
  );
}
