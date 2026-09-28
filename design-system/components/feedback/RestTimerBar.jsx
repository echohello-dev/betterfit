import React from 'react';
import { Icon } from '../core/Icon.jsx';

/** Sticky rest countdown with add-time and skip. Digits are tabular so they don't jitter. */
export function RestTimerBar({ remaining = 90, total = 90, onAdd, onSkip, style, ...rest }) {
  const mm = String(Math.floor(Math.max(0, remaining) / 60)).padStart(2, '0');
  const ss = String(Math.max(0, remaining) % 60).padStart(2, '0');
  const pct = total > 0 ? Math.max(0, Math.min(1, remaining / total)) : 0;
  return (
    <div style={{ background: 'var(--bg-elevated)', borderBottom: '1px solid var(--border)', ...style }} {...rest}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 20px' }}>
        <Icon name="timer" size={18} color="var(--accent)" />
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 'var(--text-caption)', color: 'var(--text-secondary)', textTransform: 'uppercase', letterSpacing: 'var(--tracking-label)', fontWeight: 'var(--weight-semibold)' }}>Rest</div>
          <div className="bf-num" style={{ fontFamily: 'var(--font-mono)', fontSize: 'var(--text-stat-md)', fontWeight: 'var(--weight-bold)' }}>{mm}:{ss}</div>
        </div>
        <button type="button" onClick={onAdd} style={{ background: 'var(--surface-raised)', border: '1px solid var(--border)', color: 'var(--text-primary)', borderRadius: 'var(--radius-pill)', padding: '8px 14px', fontSize: 'var(--text-footnote)', fontWeight: 'var(--weight-semibold)', cursor: 'pointer' }}>+15s</button>
        <button type="button" onClick={onSkip} style={{ background: 'transparent', border: 'none', color: 'var(--accent-text)', fontSize: 'var(--text-footnote)', fontWeight: 'var(--weight-semibold)', cursor: 'pointer', padding: '8px 4px' }}>Skip</button>
      </div>
      <div style={{ height: 3, background: 'var(--surface-raised)' }}>
        <div style={{ width: `${pct * 100}%`, height: '100%', background: 'var(--accent)', transition: 'width 1s linear' }} />
      </div>
    </div>
  );
}
