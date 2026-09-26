export interface RestTimerBarProps {
  /** Seconds left. */
  remaining?: number;
  /** Seconds the rest started at — drives the progress line. */
  total?: number;
  onAdd?: () => void;
  onSkip?: () => void;
  style?: React.CSSProperties;
}

export declare function RestTimerBar(props: RestTimerBarProps): JSX.Element;
