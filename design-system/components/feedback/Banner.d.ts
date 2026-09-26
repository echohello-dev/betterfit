export interface BannerProps {
  tone?: 'info' | 'success' | 'warning' | 'danger';
  /** Overrides the tone's default Phosphor icon. */
  icon?: string;
  title: string;
  message?: string;
  /** Usually a small secondary Button. */
  action?: React.ReactNode;
  /** Renders a dismiss affordance when provided. */
  onDismiss?: () => void;
  style?: React.CSSProperties;
}

export declare function Banner(props: BannerProps): JSX.Element;
