export interface SettingsRowProps {
  /** toggle = switch, radio = single-select check, static = read-only value, link = opens externally. */
  kind?: 'toggle' | 'radio' | 'static' | 'link';
  icon?: string;
  title: string;
  subtitle?: string;
  /** Read-only value for kind="static". */
  value?: string;
  /** Switch / radio state. */
  checked?: boolean;
  onChange?: (next: boolean) => void;
  onClick?: () => void;
  style?: React.CSSProperties;
}

export declare function SettingsRow(props: SettingsRowProps): JSX.Element;
