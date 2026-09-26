import React from 'react';
import { Icon } from './Icon.jsx';

/** Capsule that opens a menu. Reads as a current value, not a filter. */
export function DropdownChip({ label, size = 'md', onClick, style, ...rest }) {
  const big = size === 'lg';
  return (
    <button
      type="button" onClick={onClick}
      style={{
        display: 'inline-flex', alignItems: 'center', gap: big ? 10 : 6,
        padding: big ? '12px 20px' : '8px 14px', minHeight: big ? 48 : 34,
        borderRadius: 'var(--radius-pill)', cursor: 'pointer',
        background: 'var(--surface-raised)', border: '1px solid var(--border)',
        color: 'var(--text-primary)', fontFamily: 'var(--font-ui)',
        fontSize: big ? 'var(--text-callout)' : 'var(--text-footnote)',
        fontWeight: 'var(--weight-semibold)', ...style
      }}
      {...rest}
    >
      {label}
      <Icon name="caret-down" size={big ? 13 : 11} weight="bold" style={{ opacity: 0.8 }} />
    </button>
  );
}
