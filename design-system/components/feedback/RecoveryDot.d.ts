export type RecoveryStatus = 'recovered' | 'fresh' | 'fatigued' | 'sore';

export interface RecoveryDotProps {
  /** recovered (blue) → fresh (green) → fatigued (amber) → sore (red). */
  status?: RecoveryStatus;
  size?: number;
  style?: React.CSSProperties;
}

export declare function RecoveryDot(props: RecoveryDotProps): JSX.Element;
export declare const RECOVERY_COLORS: Record<RecoveryStatus, string>;
