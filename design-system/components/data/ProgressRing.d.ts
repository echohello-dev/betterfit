export interface ProgressRingProps {
  /** 0…1. Values outside the range are clamped. */
  progress?: number;
  /** Outer diameter in px. */
  size?: number;
  lineWidth?: number;
  /** Stroke colour — pass a recovery or semantic token when the ring encodes status. */
  tint?: string;
  /** Centred content, usually a tabular percentage. */
  children?: React.ReactNode;
  style?: React.CSSProperties;
}

export declare function ProgressRing(props: ProgressRingProps): JSX.Element;
