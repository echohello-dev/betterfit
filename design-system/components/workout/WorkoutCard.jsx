import React from 'react';
import { Icon } from '../core/Icon.jsx';

/** A suggested or scheduled session: name, focus, prescription, muscle summary. */
export function WorkoutCard({
  name, focus, exercises, duration, volume, muscles = [], tone = 'surface',
  badge, onClick, style, ...rest
}) {
  const identity = tone === 'identity';
  return (
    <div
      onClick={onClick}
      style={{
        background: identity ? 'var(--bf-yellow)' : 'var(--surface)',
        color: identity ? 'var(--bf-black)' : 'var(--text-primary)',
        border: identity ? '1px solid transparent' : '1px solid var(--border)',
        borderRadius: 'var(--radius-card)', padding: 16, cursor: onClick ? 'pointer' : 'default',
        display: 'flex', flexDirection: 'column', gap: 12, ...style
      }}
      {...rest}
    >
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
        <span style={{
          fontSize: 'var(--text-caption)', fontWeight: 'var(--weight-semibold)', textTransform: 'uppercase',
          letterSpacing: 'var(--tracking-label)', opacity: identity ? 0.7 : 1,
          color: identity ? 'var(--bf-black)' : 'var(--text-secondary)'
        }}>{focus}</span>
        {badge && (
          <span style={{
            fontSize: 'var(--text-caption)', fontWeight: 'var(--weight-semibold)', padding: '4px 10px',
            borderRadius: 'var(--radius-pill)',
            background: identity ? 'rgba(0,0,0,.12)' : 'var(--surface-raised)',
            border: identity ? '1px solid transparent' : '1px solid var(--border)'
          }}>{badge}</span>
        )}
      </div>

      <div className="bf-display" style={{ fontSize: 'var(--text-title-1)' }}>{name}</div>

      <div className="bf-num" style={{ display: 'flex', gap: 16, fontSize: 'var(--text-footnote)', opacity: identity ? 0.8 : 1, color: identity ? 'var(--bf-black)' : 'var(--text-secondary)' }}>
        {exercises != null && <span style={{ display: 'inline-flex', gap: 5, alignItems: 'center' }}><Icon name="list-checks" size={13} />{exercises} exercises</span>}
        {duration && <span style={{ display: 'inline-flex', gap: 5, alignItems: 'center' }}><Icon name="clock" size={13} />{duration}</span>}
        {volume && <span style={{ display: 'inline-flex', gap: 5, alignItems: 'center' }}><Icon name="barbell" size={13} />{volume}</span>}
      </div>

      {muscles.length > 0 && (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
          {muscles.map((m) => (
            <span key={m} style={{
              fontSize: 'var(--text-caption)', padding: '4px 8px', borderRadius: 'var(--radius-sm)',
              background: identity ? 'rgba(0,0,0,.1)' : 'var(--surface-raised)',
              color: identity ? 'var(--bf-black)' : 'var(--text-secondary)'
            }}>{m}</span>
          ))}
        </div>
      )}
    </div>
  );
}
