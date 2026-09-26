import React from 'react';
import { Icon } from '../core/Icon.jsx';

/** Circular tinted icon + title + subtitle + optional trailing content. */
export function ListRow({ icon, title, subtitle, iconTint = 'var(--accent-text)', trailing, onClick, style, ...rest }) {
  return (
    <div
      onClick={onClick}
      role={onClick ? 'button' : undefined}
      style={{
        display: 'flex', alignItems: 'center', gap: 12, padding: '8px 0',
        minHeight: 'var(--tap-min)', cursor: onClick ? 'pointer' : 'default', ...style
      }}
      {...rest}
    >
      {icon && (
        <span style={{
          width: 44, height: 44, flex: '0 0 44px', borderRadius: 'var(--radius-pill)',
          background: 'color-mix(in srgb, ' + iconTint + ' 15%, transparent)',
          display: 'grid', placeItems: 'center'
        }}>
          <Icon name={icon} size={18} color={iconTint} />
        </span>
      )}
      <div style={{ minWidth: 0, flex: 1 }}>
        <div style={{ fontSize: 'var(--text-subheadline)', fontWeight: 'var(--weight-semibold)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{title}</div>
        {subtitle && <div style={{ fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)', marginTop: 2 }}>{subtitle}</div>}
      </div>
      {trailing}
    </div>
  );
}
