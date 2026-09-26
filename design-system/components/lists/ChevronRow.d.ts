export interface ChevronRowProps {
  icon?: string;
  title: string;
  subtitle?: string;
  iconTint?: string;
  /** Current value shown before the chevron, e.g. "Pounds". */
  value?: string;
  onClick?: () => void;
  style?: React.CSSProperties;
}

export declare function ChevronRow(props: ChevronRowProps): JSX.Element;
