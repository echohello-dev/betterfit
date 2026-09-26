import type { RecoveryStatus } from './RecoveryDot';

export interface RecoveryBadgeProps {
  status?: RecoveryStatus;
  style?: React.CSSProperties;
}

export declare function RecoveryBadge(props: RecoveryBadgeProps): JSX.Element;
