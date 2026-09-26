export interface ContributionHeatmapProps {
  /** Intensity per day, 0–4, oldest first. Short arrays are padded with empty days. */
  values?: number[];
  /** Number of week columns to render. */
  weeks?: number;
  /** Cell edge in px. */
  cell?: number;
  gap?: number;
  style?: React.CSSProperties;
}

export declare function ContributionHeatmap(props: ContributionHeatmapProps): JSX.Element;
