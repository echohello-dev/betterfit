export interface ExerciseRowProps {
  /** 1-based position in the session. */
  index: number;
  name: string;
  /** Sets × reps × load, e.g. "4 × 8 · 135 lb". Rendered with tabular figures. */
  prescription?: string;
  /** Comma-joined muscle groups. */
  muscles?: string;
  state?: 'planned' | 'active' | 'done';
  /** Suppresses the connector line on the final row. */
  isLast?: boolean;
  onClick?: () => void;
  style?: React.CSSProperties;
}

export declare function ExerciseRow(props: ExerciseRowProps): JSX.Element;
