import React from 'react';
import { Icon } from './Icon.jsx';

/** Small labelled metric capsule. Weekly counts, durations, ranges. */
export function MetricPill({ label, value, icon, tone = 'neutral', style, ...rest }) {
  const tones = {
    neutral: { color: 'var(--text-secondary)', background: 'var(--surface-raised)', border: '1px solid var(--border)' },
    accent: { color: 'var(--accent-text)', background: 'var(--accent-surface)', border: '1px solid transparent' },
    success: { color: 'var(--text-primary)', background: 'var(--success-surface)', border: '1px solid transparent' }
  };
  return (
    <span style={{
      ...tones[tone], display: 'inline-flex', alignItems: 'center', gap: 6, padding: '6px 10px',
      borderRadius: 'var(--radius-pill)', fontSize: 'var(--text-caption)', fontWeight: 'var(--weight-semibold)', ...style
    }} {...rest}>
      {icon && <Icon name={icon} size={12} />}
      {label && <span>{label}</span>}
      {value != null && <span className="bf-num">{value}</span>}
    </span>
  );
}
