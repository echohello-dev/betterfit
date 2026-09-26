export type IconWeight = 'thin' | 'light' | 'regular' | 'bold' | 'fill' | 'duotone';

export interface IconProps {
  /** Phosphor icon slug, e.g. "barbell", "fire-simple", "heartbeat". */
  name: string;
  /** Rendered px size. Match adjacent text size or step up one. */
  size?: number;
  /**
   * Defaults to "fill" — closest match to SF Symbols semibold. Stroke-only
   * glyphs (plus, check, carets, arrows, magnifying-glass, …) have no fill cut
   * and fall back to "bold" automatically.
   */
  weight?: IconWeight;
  color?: string;
  style?: React.CSSProperties;
}

export declare function Icon(props: IconProps): JSX.Element;
