export interface ButtonProps {
  children?: React.ReactNode;
  /** primary = yellow fill with black label; destructive = inverted (no red exists in this system). */
  variant?: 'primary' | 'secondary' | 'ghost' | 'destructive';
  /** lg = 54px CTA, md = 44px, sm = 34px. */
  size?: 'lg' | 'md' | 'sm';
  /** Defaults true for primary. */
  fullWidth?: boolean;
  /** Phosphor icon slug rendered before the label. */
  icon?: string;
  /** Phosphor icon slug rendered after the label, at 70% opacity. */
  trailingIcon?: string;
  disabled?: boolean;
  onClick?: () => void;
  style?: React.CSSProperties;
}

export declare function Button(props: ButtonProps): JSX.Element;
