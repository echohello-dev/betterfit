export interface WeightUnitToggleProps {
  /** Currently selected option. */
  value?: string;
  /** Two or three short options. Defaults to ["lb","kg"]. */
  options?: string[];
  onChange?: (next: string) => void;
  style?: React.CSSProperties;
}

export declare function WeightUnitToggle(props: WeightUnitToggleProps): JSX.Element;
