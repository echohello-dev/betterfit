import React from 'react';

const RAMP = ['var(--heat-0)', 'var(--heat-1)', 'var(--heat-2)', 'var(--heat-3)', 'var(--heat-4)'];

/** Week-column activity heatmap. `values` is one intensity (0–4) per day, oldest first. */
export function ContributionHeatmap({ values = [], weeks = 26, cell = 10, gap = 3, style, ...rest }) {
  const total = weeks * 7;
  const days = values.length >= total ? values.slice(-total) : [...Array(total - values.length).fill(0), ...values];
  const cols = [];
  for (let w = 0; w < weeks; w++) cols.push(days.slice(w * 7, w * 7 + 7));
  return (
    <div style={{ display: 'flex', gap, ...style }} {...rest}>
      {cols.map((col, i) => (
        <div key={i} style={{ display: 'grid', gap, gridTemplateRows: `repeat(7, ${cell}px)` }}>
          {col.map((v, j) => (
            <div key={j} title={`${v} workouts`} style={{
              width: cell, height: cell, borderRadius: 2,
              background: RAMP[Math.max(0, Math.min(4, v))]
            }} />
          ))}
        </div>
      ))}
    </div>
  );
}
