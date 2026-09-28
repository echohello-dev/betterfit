export interface MuscleChipProps {
  /** Display name, e.g. "Chest", "Lats". */
  muscle: string;
  /** Share of the session, 0…100. */
  percent?: number;
  tint?: string;
  style?: React.CSSProperties;
}

export declare function MuscleChip(props: MuscleChipProps): JSX.Element;
