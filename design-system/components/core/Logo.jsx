import React from 'react';

const FILES = {
  wordmark: 'logo.png',
  stacked: 'logo-stacked.png',
  'stacked-dark': 'logo-stacked-dark.png',
  lettermark: 'icon-lettermark.png',
  combo: 'icon-combo.png',
  appicon: 'app-icon-1024.png'
};

/** Renders supplied BetterFit artwork. Never redraw or retype the mark. */
export function Logo({ variant = 'wordmark', height = 40, assetBase = 'assets', style, ...rest }) {
  return (
    <img
      src={`${assetBase}/${FILES[variant] || FILES.wordmark}`}
      alt="BetterFit"
      style={{ height, width: 'auto', display: 'block', ...style }}
      {...rest}
    />
  );
}
