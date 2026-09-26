import React from 'react';
import { ListRow } from './ListRow.jsx';
import { Icon } from '../core/Icon.jsx';

/** Navigation row — a ListRow that always ends in a chevron. */
export function ChevronRow({ icon, title, subtitle, iconTint, value, onClick, style, ...rest }) {
  return (
    <ListRow
      icon={icon} title={title} subtitle={subtitle} iconTint={iconTint} onClick={onClick} style={style}
      trailing={
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 8, color: 'var(--text-tertiary)' }}>
          {value && <span style={{ fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)' }}>{value}</span>}
          <Icon name="caret-right" size={13} weight="bold" />
        </span>
      }
      {...rest}
    />
  );
}
