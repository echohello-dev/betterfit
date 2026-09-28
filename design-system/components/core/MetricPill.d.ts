export interface MetricPillProps {
  /** Word part, e.g. "Weekly". */
  label?: string;
  /** Numeric part, rendered with tabular figures. */
  value?: string | number;
  icon?: string;
  tone?: 'neutral' | 'accent' | 'success';
  style?: React.CSSProperties;
}

export declare function MetricPill(props: MetricPillProps): JSX.Element;
