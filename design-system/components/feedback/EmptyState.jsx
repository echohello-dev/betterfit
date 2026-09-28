import React from 'react';
import { Icon } from '../core/Icon.jsx';

/** Explains what will appear here and offers the next step. */
export function EmptyState({ icon = 'list-checks', title, message, action, style, ...rest }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12, padding: '32px 20px', textAlign: 'center', ...style }} {...rest}>
      <Icon name={icon} size={36} color="var(--text-tertiary)" />
      <div style={{ fontSize: 'var(--text-headline)', fontWeight: 'var(--weight-semibold)' }}>{title}</div>
      {message && <div style={{ fontSize: 'var(--text-subheadline)', color: 'var(--text-secondary)', maxWidth: 320 }}>{message}</div>}
      {action}
    </div>
  );
}
