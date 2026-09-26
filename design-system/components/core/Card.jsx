import React from 'react';

/** Flat card: solid surface + hairline border + 16px continuous corners. No glass, no blur. */
export function Card({ children, padding = 16, radius = 'var(--radius-card)', tone = 'surface', style, ...rest }) {
  const tones = {
    surface: { background: 'var(--surface)', border: '1px solid var(--border)', color: 'var(--text-primary)' },
    raised: { background: 'var(--surface-raised)', border: '1px solid var(--border)', color: 'var(--text-primary)' },
    identity: { background: 'var(--bf-yellow)', border: '1px solid transparent', color: 'var(--bf-black)' },
    outline: { background: 'transparent', border: '1px solid var(--border-strong)', color: 'var(--text-primary)' }
  };
  return (
    <div style={{ ...tones[tone], padding, borderRadius: radius, boxShadow: 'var(--shadow-card)', ...style }} {...rest}>
      {children}
    </div>
  );
}
