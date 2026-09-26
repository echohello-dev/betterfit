import React from 'react';

/** Flat progress ring — solid track, accent fill, round caps. */
export function ProgressRing({ progress = 0, size = 86, lineWidth = 10, tint = 'var(--accent)', children, style, ...rest }) {
  const p = Math.max(0, Math.min(1, progress));
  const r = (size - lineWidth) / 2;
  const c = 2 * Math.PI * r;
  return (
    <div style={{ position: 'relative', width: size, height: size, ...style }}
      role="progressbar" aria-valuenow={Math.round(p * 100)} aria-valuemin={0} aria-valuemax={100} {...rest}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="var(--surface-raised)" strokeWidth={lineWidth} />
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={tint} strokeWidth={lineWidth}
          strokeLinecap="round" strokeDasharray={c} strokeDashoffset={c * (1 - p)}
          style={{ transition: 'stroke-dashoffset var(--dur-slow) var(--ease-snappy)' }} />
      </svg>
      <div style={{ position: 'absolute', inset: 0, display: 'grid', placeItems: 'center' }}>{children}</div>
    </div>
  );
}
