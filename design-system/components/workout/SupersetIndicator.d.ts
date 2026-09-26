export interface SupersetIndicatorProps {
  /** Number of rounds through the grouped exercises. */
  rounds?: number;
  /** Group name; "Superset" by default, also used for "Circuit". */
  label?: string;
  style?: React.CSSProperties;
}

export declare function SupersetIndicator(props: SupersetIndicatorProps): JSX.Element;
