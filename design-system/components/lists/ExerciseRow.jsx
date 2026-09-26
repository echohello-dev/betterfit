import React from 'react';
import { Icon } from '../core/Icon.jsx';

/** Timeline row for a planned exercise: index marker, name, prescription, state. */
export function ExerciseRow({ index, name, prescription, muscles, state = 'planned', isLast = false, onClick, style, ...rest }) {
  const done = state === 'done';
  const active = state === 'active';
  const markerBg = done ? 'var(--surface-raised)' : active ? 'var(--accent)' : 'var(--surface-raised)';
  const markerFg = active ? 'var(--text-on-accent)' : 'var(--text-secondary)';
  return (
    <div onClick={onClick} style={{ display: 'flex', gap: 12, cursor: onClick ? 'pointer' : 'default', ...style }} {...rest}>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', flex: '0 0 28px' }}>
        <span style={{
          width: 28, height: 28, borderRadius: 'var(--radius-pill)', background: markerBg, color: markerFg,
          display: 'grid', placeItems: 'center', fontSize: 'var(--text-caption)', fontWeight: 'var(--weight-bold)',
          border: active ? '1px solid transparent' : '1px solid var(--border)'
        }} className="bf-num">
          {done ? <Icon name="check" size={13} weight="bold" color="var(--accent-text)" /> : index}
        </span>
        {!isLast && <span style={{ flex: 1, width: 1, background: 'var(--separator)', marginTop: 4, minHeight: 24 }} />}
      </div>
      <div style={{ flex: 1, minWidth: 0, paddingBottom: isLast ? 0 : 16 }}>
        <div style={{
          fontSize: 'var(--text-subheadline)', fontWeight: 'var(--weight-semibold)',
          color: done ? 'var(--text-secondary)' : 'var(--text-primary)',
          textDecoration: done ? 'line-through' : 'none'
        }}>{name}</div>
        {prescription && <div className="bf-num" style={{ fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)', marginTop: 2 }}>{prescription}</div>}
        {muscles && <div style={{ fontSize: 'var(--text-caption)', color: 'var(--text-tertiary)', marginTop: 4 }}>{muscles}</div>}
      </div>
      {active && <span style={{ alignSelf: 'flex-start', fontSize: 'var(--text-caption)', fontWeight: 'var(--weight-semibold)', color: 'var(--accent-text)', textTransform: 'uppercase', letterSpacing: 'var(--tracking-label)' }}>Now</span>}
    </div>
  );
}
