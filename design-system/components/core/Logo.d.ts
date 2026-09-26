export type LogoVariant = 'wordmark' | 'stacked' | 'stacked-dark' | 'lettermark' | 'combo' | 'appicon';

export interface LogoProps {
  /**
   * wordmark = mark over BETTER FIT on electric yellow — the only variant that includes the mark.
   * stacked / stacked-dark = wordmark only, on white / black (their mark area renders blank in the
   * supplied artwork). lettermark / combo / appicon = square app marks on yellow.
   */
  variant?: LogoVariant;
  /** Rendered height in px. Width follows the artwork. */
  height?: number;
  /** Path prefix to /assets from the consuming page. Default "assets". */
  assetBase?: string;
  style?: React.CSSProperties;
}

export declare function Logo(props: LogoProps): JSX.Element;
