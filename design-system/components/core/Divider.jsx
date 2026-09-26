import React from 'react';

/** 1px separator. Use sparingly — spacing usually does the job. */
export function Divider({ inset = 0, style, ...rest }) {
  return <div role="separator" style={{ height: 1, background: 'var(--separator)', marginLeft: inset, marginRight: inset, ...style }} {...rest} />;
}
