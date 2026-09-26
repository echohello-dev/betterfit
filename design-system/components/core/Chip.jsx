import React from 'react';
import { Icon } from './Icon.jsx';

/** Filter / selection capsule. Selected = accent fill, unselected = raised surface + hairline. */
export function Chip({ label, icon, selected = false, onClick, style, ...rest }) {
  return (
    <button
      type="button" onClick={onClick} aria-pressed={selected}
      style={{
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6, minHeight: 'var(--tap-min)', padding: '0 16px',
        borderRadius: 'var(--radius-pill)', cursor: onClick ? 'pointer' : 'default',
        background: selected ? 'var(--accent)' : 'var(--surface-raised)',
        color: selected ? 'var(--text-on-accent)' : 'var(--text-primary)',
        border: selected ? '1px solid transparent' : '1px solid var(--border)',
        fontSize: 'var(--text-footnote)', fontWeight: 'var(--weight-semibold)', fontFamily: 'var(--font-ui)',
        transition: 'background var(--dur-fast) var(--ease-out)', ...style
      }}
      {...rest}
    >
      {icon && <Icon name={icon} size={14} />}
      {label}
    </button>
  );
}
