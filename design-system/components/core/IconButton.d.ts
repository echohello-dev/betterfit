export interface IconButtonProps {
  /** Phosphor icon slug. */
  icon: string;
  /** Required accessible label — the glyph alone is not a name. */
  label: string;
  /** Diameter in px. 40 default; use 44 for primary touch targets. */
  size?: number;
  variant?: 'surface' | 'accent' | 'quiet';
  onClick?: () => void;
  style?: React.CSSProperties;
}

export declare function IconButton(props: IconButtonProps): JSX.Element;
