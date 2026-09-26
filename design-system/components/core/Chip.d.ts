export interface ChipProps {
  label: string;
  /** Phosphor icon slug rendered at 12px before the label. */
  icon?: string;
  selected?: boolean;
  onClick?: () => void;
  style?: React.CSSProperties;
}

export declare function Chip(props: ChipProps): JSX.Element;
