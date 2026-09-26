export interface WorkoutCardProps {
  /** Session name, e.g. "Push A". */
  name: string;
  /** Uppercase eyebrow — "Up next", "Suggested", "Last workout". */
  focus?: string;
  exercises?: number;
  /** Human duration, e.g. "48 min". */
  duration?: string;
  /** Planned volume, e.g. "18.4k lb". */
  volume?: string;
  /** Muscle group tags, max four. */
  muscles?: string[];
  /** identity = yellow field with black type, for the single hero session. */
  tone?: 'surface' | 'identity';
  /** Small trailing capsule, e.g. "Today". */
  badge?: string;
  onClick?: () => void;
  style?: React.CSSProperties;
}

export declare function WorkoutCard(props: WorkoutCardProps): JSX.Element;
