export interface CardProps {
  children?: React.ReactNode;
  /** Internal padding in px. 16 is the standard. */
  padding?: number;
  /** CSS length. Defaults to var(--radius-card) = 16px. */
  radius?: string;
  /** identity = yellow field with black content, for brand moments only. */
  tone?: 'surface' | 'raised' | 'identity' | 'outline';
  style?: React.CSSProperties;
}

export declare function Card(props: CardProps): JSX.Element;
