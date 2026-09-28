export interface SectionHeaderProps {
  /** Short label, rendered uppercase with generous tracking. */
  title: string;
  /** Trailing node — a ghost Button, count, or IconButton. */
  action?: React.ReactNode;
  style?: React.CSSProperties;
}

export declare function SectionHeader(props: SectionHeaderProps): JSX.Element;
