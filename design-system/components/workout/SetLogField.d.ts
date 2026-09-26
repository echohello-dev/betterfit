export interface SetLogFieldProps {
  /** Uppercase field name, e.g. "Weight". */
  label: string;
  /** Unit suffix, e.g. "lbs", "reps". */
  unit?: string;
  value: string | number;
  onChange?: (next: string) => void;
  style?: React.CSSProperties;
}

export declare function SetLogField(props: SetLogFieldProps): JSX.Element;
