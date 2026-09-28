import React, { useState } from 'react';
import { Icon } from './Icon.jsx';

/** Circular icon control on a raised surface. Chrome buttons, toolbars, row affordances.
    `size` is the visible circle; the hit area never drops below `--tap-min`. */
export function IconButton({ icon, label, size = 44, variant = 'surface', onClick, style, ...rest }) {
  const [pressed, setPressed] = useState(false);
  const fills = {
    surface: { background: 'var(--surface-raised)', color: 'var(--text-primary)', border: '1px solid var(--border)' },
    accent: { background: 'var(--accent)', color: 'var(--text-on-accent)', border: '1px solid transparent' },
    quiet: { background: 'transparent', color: 'var(--text-secondary)', border: '1px solid transparent' }
  };
  return (
    <button
      type="button" aria-label={label} onClick={onClick}
      onPointerDown={() => setPressed(true)} onPointerUp={() => setPressed(false)} onPointerLeave={() => setPressed(false)}
      style={{
        ...fills[variant], width: size, height: size, minWidth: 'var(--tap-min)', minHeight: 'var(--tap-min)', borderRadius: 'var(--radius-pill)',
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', padding: 0,
        opacity: pressed ? 0.7 : 1, transition: 'opacity var(--dur-press) var(--ease-out)', ...style
      }}
      {...rest}
    >
      <Icon name={icon} size={Math.round(size * 0.4)} />
    </button>
  );
}
