export interface GaugeProps {
  /** 0…1. */
  progress?: number;
  /** Overall width in px; height is roughly half. */
  width?: number;
  thickness?: number;
  tint?: string;
  /** Big tabular readout under the arc. */
  value?: string | number;
  /** Short caption under the value. */
  label?: string;
  style?: React.CSSProperties;
}

export declare function Gauge(props: GaugeProps): JSX.Element;
