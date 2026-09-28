import React from 'react';

/** Semi-circular gauge. Reads as a conclusion, not a chart. */
export function Gauge({ progress = 0, width = 160, thickness = 12, tint = 'var(--accent)', label, value, style, ...rest }) {
  const p = Math.max(0, Math.min(1, progress));
  const r = (width - thickness) / 2;
  const len = Math.PI * r;
  const h = width / 2 + thickness / 2;
  return (
    <div style={{ width, ...style }} {...rest}>
      <svg width={width} height={h} viewBox={`0 0 ${width} ${h}`}>
        <path d={`M ${thickness / 2} ${h - thickness / 2} A ${r} ${r} 0 0 1 ${width - thickness / 2} ${h - thickness / 2}`}
          fill="none" stroke="var(--surface-raised)" strokeWidth={thickness} strokeLinecap="round" />
        <path d={`M ${thickness / 2} ${h - thickness / 2} A ${r} ${r} 0 0 1 ${width - thickness / 2} ${h - thickness / 2}`}
          fill="none" stroke={tint} strokeWidth={thickness} strokeLinecap="round"
          strokeDasharray={len} strokeDashoffset={len * (1 - p)}
          style={{ transition: 'stroke-dashoffset var(--dur-slow) var(--ease-snappy)' }} />
      </svg>
      <div style={{ textAlign: 'center', marginTop: -8 }}>
        {value != null && <div className="bf-num" style={{ fontSize: 'var(--text-stat-lg)', fontWeight: 'var(--weight-bold)' }}>{value}</div>}
        {label && <div style={{ fontSize: 'var(--text-caption)', color: 'var(--text-secondary)' }}>{label}</div>}
      </div>
    </div>
  );
}
