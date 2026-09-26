export interface StatTileProps {
  /** Phosphor icon slug. */
  icon?: string;
  value: string | number;
  label: string;
  /** Icon colour. Use a semantic token when the stat has status meaning. */
  tint?: string;
  style?: React.CSSProperties;
}

export declare function StatTile(props: StatTileProps): JSX.Element;
