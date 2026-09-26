import React from 'react';
import { Icon } from '../core/Icon.jsx';

/** Settings row in four shapes: toggle, radio, static value, external link. */
export function SettingsRow({ kind = 'static', icon, title, subtitle, value, checked = false, onChange, onClick, style, ...rest }) {
  const interactive = kind === 'toggle' || kind === 'radio' || kind === 'link';
  const handle = () => {
    if (kind === 'toggle' || kind === 'radio') onChange && onChange(!checked);
    else if (onClick) onClick();
  };
  return (
    <div
      onClick={interactive ? handle : onClick}
      style={{
        display: 'flex', alignItems: 'center', gap: 12, padding: '12px 0', minHeight: 'var(--tap-min)',
        cursor: interactive || onClick ? 'pointer' : 'default', ...style
      }}
      {...rest}
    >
      {icon && <Icon name={icon} size={17} color="var(--text-secondary)" style={{ flex: '0 0 20px' }} />}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 'var(--text-body)' }}>{title}</div>
        {subtitle && <div style={{ fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)', marginTop: 2 }}>{subtitle}</div>}
      </div>
      {kind === 'toggle' && (
        <span role="switch" aria-checked={checked} style={{
          width: 46, height: 28, flex: '0 0 46px', borderRadius: 'var(--radius-pill)', padding: 2,
          background: checked ? 'var(--accent)' : 'var(--surface-raised)', border: checked ? '1px solid transparent' : '1px solid var(--border)',
          display: 'flex', justifyContent: checked ? 'flex-end' : 'flex-start',
          transition: 'background var(--dur-fast) var(--ease-out)'
        }}>
          <span style={{
            width: 24, height: 24, borderRadius: 'var(--radius-pill)',
            background: checked ? 'var(--bf-black)' : 'var(--bg-elevated)',
            border: checked ? '1px solid transparent' : '1px solid var(--border)'
          }} />
        </span>
      )}
      {kind === 'radio' && checked && <Icon name="check" size={16} weight="bold" color="var(--accent-text)" />}
      {kind === 'static' && value && <span style={{ fontSize: 'var(--text-subheadline)', color: 'var(--text-secondary)' }}>{value}</span>}
      {kind === 'link' && <Icon name="arrow-up-right" size={14} weight="bold" color="var(--text-tertiary)" />}
    </div>
  );
}
