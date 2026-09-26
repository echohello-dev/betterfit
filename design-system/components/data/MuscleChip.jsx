import React from 'react';

/** Muscle group + share of the session, with a proportional bar. */
export function MuscleChip({ muscle, percent = 0, tint = 'var(--accent)', style, ...rest }) {
  return (
    <div style={{
      flex: 1, minWidth: 72, padding: 12, borderRadius: 'var(--radius-md)',
      background: 'var(--surface)', border: '1px solid var(--border)', ...style
    }} {...rest}>
      <div className="bf-num" style={{ fontSize: 'var(--text-stat-sm)', fontWeight: 'var(--weight-bold)' }}>{percent}%</div>
      <div style={{ fontSize: 'var(--text-caption)', color: 'var(--text-secondary)', marginTop: 2, marginBottom: 8 }}>{muscle}</div>
      <div style={{ height: 4, borderRadius: 2, background: 'var(--surface-raised)', overflow: 'hidden' }}>
        <div style={{ width: `${Math.max(0, Math.min(100, percent))}%`, height: '100%', background: tint, transition: 'width var(--dur-standard) var(--ease-out)' }} />
      </div>
    </div>
  );
}
