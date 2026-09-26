export interface LegendDotProps {
  label: string;
  /** Whole number percentage; omit for a plain key. */
  percent?: number;
  color?: string;
  style?: React.CSSProperties;
}

export declare function LegendDot(props: LegendDotProps): JSX.Element;
