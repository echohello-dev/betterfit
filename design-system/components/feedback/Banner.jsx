import React from 'react';
import { Icon } from '../core/Icon.jsx';

const TONES = {
  info: { border: 'var(--info)', surface: 'var(--info-surface)', icon: 'info', ink: 'var(--accent-text)' },
  success: { border: 'var(--success)', surface: 'var(--success-surface)', icon: 'check-circle', ink: 'var(--accent-text)' },
  warning: { border: 'var(--warning)', surface: 'var(--warning-surface)', icon: 'warning', ink: 'var(--accent-text)' },
  danger: { border: 'var(--danger)', surface: 'var(--danger-surface)', icon: 'warning-octagon', ink: 'var(--text-primary)' }
};

/** Inline notice with an optional action. Connection prompts, sync errors, plan changes. */
export function Banner({ tone = 'info', icon, title, message, action, onDismiss, style, ...rest }) {
  const t = TONES[tone];
  return (
    <div style={{
      display: 'flex', gap: 12, alignItems: 'flex-start', padding: 14,
      background: t.surface, border: `1px solid color-mix(in srgb, ${t.border} 40%, transparent)`,
      borderRadius: 'var(--radius-card)', ...style
    }} {...rest}>
      <Icon name={icon || t.icon} size={18} color={t.ink} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 'var(--text-subheadline)', fontWeight: 'var(--weight-semibold)' }}>{title}</div>
        {message && <div style={{ fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)', marginTop: 2 }}>{message}</div>}
        {action && <div style={{ marginTop: 10 }}>{action}</div>}
      </div>
      {onDismiss && (
        <button type="button" aria-label="Dismiss" onClick={onDismiss} style={{ background: 'none', border: 'none', color: 'var(--text-tertiary)', cursor: 'pointer', padding: 0 }}>
          <Icon name="x" size={14} weight="bold" />
        </button>
      )}
    </div>
  );
}
