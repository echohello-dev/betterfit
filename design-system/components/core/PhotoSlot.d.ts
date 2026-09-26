export interface PhotoSlotProps {
  /** Real image URL. Omit to render the placeholder. */
  src?: string;
  alt?: string;
  width?: number | string;
  height?: number | string;
  /** CSS length. Defaults to var(--radius-md). */
  radius?: string;
  /** Short note describing what belongs here, shown in the placeholder. */
  label?: string;
  style?: React.CSSProperties;
}

export declare function PhotoSlot(props: PhotoSlotProps): JSX.Element;
