import React from 'react';

export const RECOVERY_COLORS = {
  recovered: 'var(--recovery-recovered)',
  fresh: 'var(--recovery-fresh)',
  fatigued: 'var(--recovery-fatigued)',
  sore: 'var(--recovery-sore)'
};

/** Small coloured dot for a region's recovery status. */
export function RecoveryDot({ status = 'recovered', size = 10, style, ...rest }) {
  return <span aria-label={`Recovery: ${status}`} style={{ width: size, height: size, borderRadius: 'var(--radius-pill)', background: RECOVERY_COLORS[status], display: 'inline-block', ...style }} {...rest} />;
}
