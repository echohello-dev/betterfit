import React from 'react';
import { Icon } from './Icon.jsx';

/**
 * Placeholder for exercise / editorial photography. BetterFit ships no image
 * assets, so every photo position renders as a labelled slot until real
 * artwork is supplied. Pass `src` once you have it.
 */
export function PhotoSlot({ src, alt = '', width = 168, height = 240, radius = 'var(--radius-md)', label, style, ...rest }) {
  if (src) {
    return <img src={src} alt={alt} style={{ width, height, objectFit: 'cover', borderRadius: radius, display: 'block', ...style }} {...rest} />;
  }
  return (
    <div
      role="img" aria-label={alt || 'Photography placeholder'}
      style={{
        width, height, borderRadius: radius, background: 'var(--surface-raised)',
        border: '1px dashed var(--border-strong)', display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center', gap: 6, padding: 8, textAlign: 'center', ...style
      }}
      {...rest}
    >
      <Icon name="image" size={18} color="var(--text-tertiary)" />
      {label && <span style={{ fontSize: 'var(--text-caption)', color: 'var(--text-tertiary)', lineHeight: 1.2 }}>{label}</span>}
    </div>
  );
}
