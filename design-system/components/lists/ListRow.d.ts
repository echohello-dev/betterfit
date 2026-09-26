export interface ListRowProps {
  /** Phosphor icon slug shown in a 44px tinted circle. */
  icon?: string;
  title: string;
  subtitle?: string;
  /** Circle tint; 15% of it fills the disc. */
  iconTint?: string;
  /** Trailing node — a value, MetricPill, or IconButton. */
  trailing?: React.ReactNode;
  onClick?: () => void;
  style?: React.CSSProperties;
}

export declare function ListRow(props: ListRowProps): JSX.Element;
