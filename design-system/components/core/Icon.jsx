import React from 'react';

/**
 * Phosphor glyphs that are pure strokes have no `fill` cut — asking for one
 * renders tofu. These silently fall back to `bold`, which is the correct
 * visual match anyway.
 */
const STROKE_ONLY = new Set([
  'plus', 'minus', 'x', 'check', 'equals', 'divide',
  'arrow-up', 'arrow-down', 'arrow-left', 'arrow-right',
  'arrow-up-right', 'arrow-up-left', 'arrow-down-right', 'arrow-down-left',
  'arrows-clockwise', 'arrows-counter-clockwise', 'arrows-left-right', 'arrows-out', 'arrows-in',
  'caret-up', 'caret-down', 'caret-left', 'caret-right',
  'caret-double-up', 'caret-double-down', 'caret-double-left', 'caret-double-right',
  'dots-three', 'dots-three-vertical', 'dots-six',
  'magnifying-glass', 'magnifying-glass-plus', 'magnifying-glass-minus',
  'list', 'list-checks', 'list-bullets', 'sliders-horizontal', 'sliders',
  'chart-line', 'chart-line-up', 'chart-line-down', 'wifi-high', 'wifi-medium'
]);

/** Phosphor Icons stand-in for SF Symbols. See readme.md → ICONOGRAPHY. */
export function Icon({ name, size = 16, weight = 'fill', color = 'currentColor', style, ...rest }) {
  const w = weight === 'fill' && STROKE_ONLY.has(name) ? 'bold' : weight;
  return (
    <i
      className={`ph-${w} ph-${name}`}
      aria-hidden="true"
      style={{ fontSize: size, lineHeight: 1, color, display: 'inline-flex', ...style }}
      {...rest}
    />
  );
}
