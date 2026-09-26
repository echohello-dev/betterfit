export interface DropdownChipProps {
  /** The current value, not the field name — "45m", not "Duration". */
  label: string;
  /** lg = 48px header chip; md = 34px inline chip. */
  size?: 'md' | 'lg';
  onClick?: () => void;
  style?: React.CSSProperties;
}

export declare function DropdownChip(props: DropdownChipProps): JSX.Element;
