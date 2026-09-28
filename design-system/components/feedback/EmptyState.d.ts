export interface EmptyStateProps {
  icon?: string;
  /** Plain statement of what is missing. */
  title: string;
  /** One sentence on what will appear here. */
  message?: string;
  /** Usually a small Button that creates the missing thing. */
  action?: React.ReactNode;
  style?: React.CSSProperties;
}

export declare function EmptyState(props: EmptyStateProps): JSX.Element;
