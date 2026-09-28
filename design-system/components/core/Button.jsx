import React, { useState } from 'react';
import { Icon } from './Icon.jsx';

const HEIGHT = { lg: 'var(--control-lg)', md: 'var(--control-md)', sm: 'var(--control-sm)' };
const FONT = { lg: 'var(--text-headline)', md: 'var(--text-headline)', sm: 'var(--text-subheadline)' };

const VARIANTS = {
  primary: { background: 'var(--accent)', color: 'var(--text-on-accent)', border: '1px solid transparent' },
  secondary: { background: 'var(--surface-raised)', color: 'var(--text-primary)', border: '1px solid var(--border)' },
  ghost: { background: 'transparent', color: 'var(--accent-text)', border: '1px solid transparent' },
  /* Destructive is inverted, not red — the system has no alarm hue. */
  destructive: { background: 'var(--text-primary)', color: 'var(--bg-page)', border: '1px solid transparent' }
};

/** Actions. One full-width primary per view; secondary/ghost for everything else. */
export function Button({
  children, variant = 'primary', size = 'lg', fullWidth = variant === 'primary',
  icon, trailingIcon, disabled = false, onClick, style, ...rest
}) {
  const [pressed, setPressed] = useState(false);
  const v = VARIANTS[variant] || VARIANTS.primary;
  const isGhost = variant === 'ghost';
  return (
    <button
      type="button"
      disabled={disabled}
      onClick={onClick}
      onPointerDown={() => setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      style={{
        ...v,
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        height: isGhost ? 'auto' : HEIGHT[size],
        /* Ghost has no container, but it still needs a thumb-sized hit area. */
        minHeight: 'var(--tap-min)',
        padding: isGhost ? '0 2px' : `0 ${size === 'sm' ? 16 : 20}px`,
        width: fullWidth ? '100%' : 'auto',
        fontFamily: 'var(--font-ui)', fontSize: FONT[size],
        fontWeight: 'var(--weight-semibold)',
        borderRadius: isGhost ? 0 : 'var(--radius-button)',
        cursor: disabled ? 'not-allowed' : 'pointer',
        opacity: disabled ? 0.4 : pressed ? (variant === 'secondary' ? 0.7 : isGhost ? 0.6 : 'var(--press-opacity)') : 1,
        transform: pressed && !isGhost ? 'scale(var(--press-scale))' : 'none',
        transition: 'opacity var(--dur-press) var(--ease-out), transform var(--dur-press) var(--ease-out)',
        ...style
      }}
      {...rest}
    >
      {icon && <Icon name={icon} size={size === 'sm' ? 14 : 17} />}
      <span>{children}</span>
      {trailingIcon && <Icon name={trailingIcon} size={size === 'sm' ? 12 : 14} style={{ opacity: 0.7 }} />}
    </button>
  );
}
