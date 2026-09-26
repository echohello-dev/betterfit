/* @ds-bundle: {"format":4,"namespace":"BetterFitDesignSystem_6a70ea","components":[{"name":"Button","sourcePath":"components/core/Button.jsx"},{"name":"Card","sourcePath":"components/core/Card.jsx"},{"name":"Chip","sourcePath":"components/core/Chip.jsx"},{"name":"Divider","sourcePath":"components/core/Divider.jsx"},{"name":"DropdownChip","sourcePath":"components/core/DropdownChip.jsx"},{"name":"Icon","sourcePath":"components/core/Icon.jsx"},{"name":"IconButton","sourcePath":"components/core/IconButton.jsx"},{"name":"Logo","sourcePath":"components/core/Logo.jsx"},{"name":"MetricPill","sourcePath":"components/core/MetricPill.jsx"},{"name":"PhotoSlot","sourcePath":"components/core/PhotoSlot.jsx"},{"name":"SectionHeader","sourcePath":"components/core/SectionHeader.jsx"},{"name":"ContributionHeatmap","sourcePath":"components/data/ContributionHeatmap.jsx"},{"name":"Gauge","sourcePath":"components/data/Gauge.jsx"},{"name":"LegendDot","sourcePath":"components/data/LegendDot.jsx"},{"name":"MuscleChip","sourcePath":"components/data/MuscleChip.jsx"},{"name":"OverviewStat","sourcePath":"components/data/OverviewStat.jsx"},{"name":"ProgressRing","sourcePath":"components/data/ProgressRing.jsx"},{"name":"StatTile","sourcePath":"components/data/StatTile.jsx"},{"name":"Banner","sourcePath":"components/feedback/Banner.jsx"},{"name":"EmptyState","sourcePath":"components/feedback/EmptyState.jsx"},{"name":"RecoveryBadge","sourcePath":"components/feedback/RecoveryBadge.jsx"},{"name":"RECOVERY_COLORS","sourcePath":"components/feedback/RecoveryDot.jsx"},{"name":"RecoveryDot","sourcePath":"components/feedback/RecoveryDot.jsx"},{"name":"RestTimerBar","sourcePath":"components/feedback/RestTimerBar.jsx"},{"name":"ChevronRow","sourcePath":"components/lists/ChevronRow.jsx"},{"name":"ExerciseRow","sourcePath":"components/lists/ExerciseRow.jsx"},{"name":"ListRow","sourcePath":"components/lists/ListRow.jsx"},{"name":"SettingsRow","sourcePath":"components/lists/SettingsRow.jsx"},{"name":"SetLogField","sourcePath":"components/workout/SetLogField.jsx"},{"name":"SupersetIndicator","sourcePath":"components/workout/SupersetIndicator.jsx"},{"name":"WeightUnitToggle","sourcePath":"components/workout/WeightUnitToggle.jsx"},{"name":"WorkoutCard","sourcePath":"components/workout/WorkoutCard.jsx"}],"sourceHashes":{"components/core/Button.jsx":"b3ff7acc06ae","components/core/Card.jsx":"99821a742ab2","components/core/Chip.jsx":"22233673b0e7","components/core/Divider.jsx":"c7d1116be1e4","components/core/DropdownChip.jsx":"f6c201733013","components/core/Icon.jsx":"d813a0ef591c","components/core/IconButton.jsx":"6636ca2d40b3","components/core/Logo.jsx":"64fb18c1ee7c","components/core/MetricPill.jsx":"f95d21160369","components/core/PhotoSlot.jsx":"90c56157fcc4","components/core/SectionHeader.jsx":"682d9badb625","components/data/ContributionHeatmap.jsx":"e0ba29fc1c97","components/data/Gauge.jsx":"db9b9b982037","components/data/LegendDot.jsx":"95236bd12e8a","components/data/MuscleChip.jsx":"ff24563545ff","components/data/OverviewStat.jsx":"884acd2df7a4","components/data/ProgressRing.jsx":"2cd572bbafbc","components/data/StatTile.jsx":"b4c056bce31b","components/feedback/Banner.jsx":"7368565bf0cd","components/feedback/EmptyState.jsx":"79410f181a52","components/feedback/RecoveryBadge.jsx":"b1074c0e51d8","components/feedback/RecoveryDot.jsx":"8a3df73177de","components/feedback/RestTimerBar.jsx":"3aeb4890f450","components/lists/ChevronRow.jsx":"d73714c0e67b","components/lists/ExerciseRow.jsx":"b570f05fdfbc","components/lists/ListRow.jsx":"49af92d7ade7","components/lists/SettingsRow.jsx":"6039aa5ae44c","components/workout/SetLogField.jsx":"e2dd672536ae","components/workout/SupersetIndicator.jsx":"001cc035146d","components/workout/WeightUnitToggle.jsx":"8c5229444ba6","components/workout/WorkoutCard.jsx":"1acf63f140b3","ui_kits/ios_app/AddExerciseSheet.jsx":"44d8b3bb32b7","ui_kits/ios_app/AppShell.jsx":"be15b642533f","ui_kits/ios_app/BodyScreen.jsx":"5bff67fe0708","ui_kits/ios_app/LogScreen.jsx":"54847cd64074","ui_kits/ios_app/MyPlanScreen.jsx":"70cee2652c4b","ui_kits/ios_app/ProfileScreen.jsx":"34f72961a90d","ui_kits/ios_app/SearchScreen.jsx":"09c892a2e5b3","ui_kits/ios_app/SessionScreen.jsx":"d8af610eda55","ui_kits/ios_app/SettingsScreen.jsx":"bf0de8bf39c3","ui_kits/ios_app/SignInScreen.jsx":"5ed950c1c533","ui_kits/ios_app/SummaryScreen.jsx":"5afb222c7820","ui_kits/ios_app/TargetsScreen.jsx":"ae2833a7cd86","ui_kits/ios_app/data.js":"6fa253140d9b","ui_kits/ios_app/image-slot.js":"fff26d081c8d","ui_kits/ios_app/tweaks-panel.jsx":"d259e3a86f73","ui_kits/watch_app/WatchScreens.jsx":"56a50166c9b2","ui_kits/watch_app/WatchShell.jsx":"e4722ab4aca4"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.BetterFitDesignSystem_6a70ea = window.BetterFitDesignSystem_6a70ea || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/core/Card.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Flat card: solid surface + hairline border + 16px continuous corners. No glass, no blur. */
function Card({
  children,
  padding = 16,
  radius = 'var(--radius-card)',
  tone = 'surface',
  style,
  ...rest
}) {
  const tones = {
    surface: {
      background: 'var(--surface)',
      border: '1px solid var(--border)',
      color: 'var(--text-primary)'
    },
    raised: {
      background: 'var(--surface-raised)',
      border: '1px solid var(--border)',
      color: 'var(--text-primary)'
    },
    identity: {
      background: 'var(--bf-yellow)',
      border: '1px solid transparent',
      color: 'var(--bf-black)'
    },
    outline: {
      background: 'transparent',
      border: '1px solid var(--border-strong)',
      color: 'var(--text-primary)'
    }
  };
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      ...tones[tone],
      padding,
      borderRadius: radius,
      boxShadow: 'var(--shadow-card)',
      ...style
    }
  }, rest), children);
}
Object.assign(__ds_scope, { Card });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Card.jsx", error: String((e && e.message) || e) }); }

// components/core/Divider.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** 1px separator. Use sparingly — spacing usually does the job. */
function Divider({
  inset = 0,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    role: "separator",
    style: {
      height: 1,
      background: 'var(--separator)',
      marginLeft: inset,
      marginRight: inset,
      ...style
    }
  }, rest));
}
Object.assign(__ds_scope, { Divider });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Divider.jsx", error: String((e && e.message) || e) }); }

// components/core/Icon.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * Phosphor glyphs that are pure strokes have no `fill` cut — asking for one
 * renders tofu. These silently fall back to `bold`, which is the correct
 * visual match anyway.
 */
const STROKE_ONLY = new Set(['plus', 'minus', 'x', 'check', 'equals', 'divide', 'arrow-up', 'arrow-down', 'arrow-left', 'arrow-right', 'arrow-up-right', 'arrow-up-left', 'arrow-down-right', 'arrow-down-left', 'arrows-clockwise', 'arrows-counter-clockwise', 'arrows-left-right', 'arrows-out', 'arrows-in', 'caret-up', 'caret-down', 'caret-left', 'caret-right', 'caret-double-up', 'caret-double-down', 'caret-double-left', 'caret-double-right', 'dots-three', 'dots-three-vertical', 'dots-six', 'magnifying-glass', 'magnifying-glass-plus', 'magnifying-glass-minus', 'list', 'list-checks', 'list-bullets', 'sliders-horizontal', 'sliders', 'chart-line', 'chart-line-up', 'chart-line-down', 'wifi-high', 'wifi-medium']);

/** Phosphor Icons stand-in for SF Symbols. See readme.md → ICONOGRAPHY. */
function Icon({
  name,
  size = 16,
  weight = 'fill',
  color = 'currentColor',
  style,
  ...rest
}) {
  const w = weight === 'fill' && STROKE_ONLY.has(name) ? 'bold' : weight;
  return /*#__PURE__*/React.createElement("i", _extends({
    className: `ph-${w} ph-${name}`,
    "aria-hidden": "true",
    style: {
      fontSize: size,
      lineHeight: 1,
      color,
      display: 'inline-flex',
      ...style
    }
  }, rest));
}
Object.assign(__ds_scope, { Icon });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Icon.jsx", error: String((e && e.message) || e) }); }

// components/core/Button.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const {
  useState
} = React;
const HEIGHT = {
  lg: 'var(--control-lg)',
  md: 'var(--control-md)',
  sm: 'var(--control-sm)'
};
const FONT = {
  lg: 'var(--text-headline)',
  md: 'var(--text-headline)',
  sm: 'var(--text-subheadline)'
};
const VARIANTS = {
  primary: {
    background: 'var(--accent)',
    color: 'var(--text-on-accent)',
    border: '1px solid transparent'
  },
  secondary: {
    background: 'var(--surface-raised)',
    color: 'var(--text-primary)',
    border: '1px solid var(--border)'
  },
  ghost: {
    background: 'transparent',
    color: 'var(--accent-text)',
    border: '1px solid transparent'
  },
  /* Destructive is inverted, not red — the system has no alarm hue. */
  destructive: {
    background: 'var(--text-primary)',
    color: 'var(--bg-page)',
    border: '1px solid transparent'
  }
};

/** Actions. One full-width primary per view; secondary/ghost for everything else. */
function Button({
  children,
  variant = 'primary',
  size = 'lg',
  fullWidth = variant === 'primary',
  icon,
  trailingIcon,
  disabled = false,
  onClick,
  style,
  ...rest
}) {
  const [pressed, setPressed] = useState(false);
  const v = VARIANTS[variant] || VARIANTS.primary;
  const isGhost = variant === 'ghost';
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    disabled: disabled,
    onClick: onClick,
    onPointerDown: () => setPressed(true),
    onPointerUp: () => setPressed(false),
    onPointerLeave: () => setPressed(false),
    style: {
      ...v,
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 8,
      height: isGhost ? 'auto' : HEIGHT[size],
      /* Ghost has no container, but it still needs a thumb-sized hit area. */
      minHeight: 'var(--tap-min)',
      padding: isGhost ? '0 2px' : `0 ${size === 'sm' ? 16 : 20}px`,
      width: fullWidth ? '100%' : 'auto',
      fontFamily: 'var(--font-ui)',
      fontSize: FONT[size],
      fontWeight: 'var(--weight-semibold)',
      borderRadius: isGhost ? 0 : 'var(--radius-button)',
      cursor: disabled ? 'not-allowed' : 'pointer',
      opacity: disabled ? 0.4 : pressed ? variant === 'secondary' ? 0.7 : isGhost ? 0.6 : 'var(--press-opacity)' : 1,
      transform: pressed && !isGhost ? 'scale(var(--press-scale))' : 'none',
      transition: 'opacity var(--dur-press) var(--ease-out), transform var(--dur-press) var(--ease-out)',
      ...style
    }
  }, rest), icon && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: size === 'sm' ? 14 : 17
  }), /*#__PURE__*/React.createElement("span", null, children), trailingIcon && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: trailingIcon,
    size: size === 'sm' ? 12 : 14,
    style: {
      opacity: 0.7
    }
  }));
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Button.jsx", error: String((e && e.message) || e) }); }

// components/core/Chip.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Filter / selection capsule. Selected = accent fill, unselected = raised surface + hairline. */
function Chip({
  label,
  icon,
  selected = false,
  onClick,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    onClick: onClick,
    "aria-pressed": selected,
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 6,
      minHeight: 'var(--tap-min)',
      padding: '0 16px',
      borderRadius: 'var(--radius-pill)',
      cursor: onClick ? 'pointer' : 'default',
      background: selected ? 'var(--accent)' : 'var(--surface-raised)',
      color: selected ? 'var(--text-on-accent)' : 'var(--text-primary)',
      border: selected ? '1px solid transparent' : '1px solid var(--border)',
      fontSize: 'var(--text-footnote)',
      fontWeight: 'var(--weight-semibold)',
      fontFamily: 'var(--font-ui)',
      transition: 'background var(--dur-fast) var(--ease-out)',
      ...style
    }
  }, rest), icon && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 14
  }), label);
}
Object.assign(__ds_scope, { Chip });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Chip.jsx", error: String((e && e.message) || e) }); }

// components/core/DropdownChip.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Capsule that opens a menu. Reads as a current value, not a filter. */
function DropdownChip({
  label,
  size = 'md',
  onClick,
  style,
  ...rest
}) {
  const big = size === 'lg';
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    onClick: onClick,
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: big ? 10 : 6,
      padding: big ? '12px 20px' : '8px 14px',
      minHeight: big ? 48 : 34,
      borderRadius: 'var(--radius-pill)',
      cursor: 'pointer',
      background: 'var(--surface-raised)',
      border: '1px solid var(--border)',
      color: 'var(--text-primary)',
      fontFamily: 'var(--font-ui)',
      fontSize: big ? 'var(--text-callout)' : 'var(--text-footnote)',
      fontWeight: 'var(--weight-semibold)',
      ...style
    }
  }, rest), label, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "caret-down",
    size: big ? 13 : 11,
    weight: "bold",
    style: {
      opacity: 0.8
    }
  }));
}
Object.assign(__ds_scope, { DropdownChip });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/DropdownChip.jsx", error: String((e && e.message) || e) }); }

// components/core/IconButton.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const {
  useState
} = React;
/** Circular icon control on a raised surface. Chrome buttons, toolbars, row affordances.
    `size` is the visible circle; the hit area never drops below `--tap-min`. */
function IconButton({
  icon,
  label,
  size = 44,
  variant = 'surface',
  onClick,
  style,
  ...rest
}) {
  const [pressed, setPressed] = useState(false);
  const fills = {
    surface: {
      background: 'var(--surface-raised)',
      color: 'var(--text-primary)',
      border: '1px solid var(--border)'
    },
    accent: {
      background: 'var(--accent)',
      color: 'var(--text-on-accent)',
      border: '1px solid transparent'
    },
    quiet: {
      background: 'transparent',
      color: 'var(--text-secondary)',
      border: '1px solid transparent'
    }
  };
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    "aria-label": label,
    onClick: onClick,
    onPointerDown: () => setPressed(true),
    onPointerUp: () => setPressed(false),
    onPointerLeave: () => setPressed(false),
    style: {
      ...fills[variant],
      width: size,
      height: size,
      minWidth: 'var(--tap-min)',
      minHeight: 'var(--tap-min)',
      borderRadius: 'var(--radius-pill)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      cursor: 'pointer',
      padding: 0,
      opacity: pressed ? 0.7 : 1,
      transition: 'opacity var(--dur-press) var(--ease-out)',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: Math.round(size * 0.4)
  }));
}
Object.assign(__ds_scope, { IconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/IconButton.jsx", error: String((e && e.message) || e) }); }

// components/core/Logo.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const FILES = {
  wordmark: 'logo.png',
  stacked: 'logo-stacked.png',
  'stacked-dark': 'logo-stacked-dark.png',
  lettermark: 'icon-lettermark.png',
  combo: 'icon-combo.png',
  appicon: 'app-icon-1024.png'
};

/** Renders supplied BetterFit artwork. Never redraw or retype the mark. */
function Logo({
  variant = 'wordmark',
  height = 40,
  assetBase = 'assets',
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("img", _extends({
    src: `${assetBase}/${FILES[variant] || FILES.wordmark}`,
    alt: "BetterFit",
    style: {
      height,
      width: 'auto',
      display: 'block',
      ...style
    }
  }, rest));
}
Object.assign(__ds_scope, { Logo });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Logo.jsx", error: String((e && e.message) || e) }); }

// components/core/MetricPill.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Small labelled metric capsule. Weekly counts, durations, ranges. */
function MetricPill({
  label,
  value,
  icon,
  tone = 'neutral',
  style,
  ...rest
}) {
  const tones = {
    neutral: {
      color: 'var(--text-secondary)',
      background: 'var(--surface-raised)',
      border: '1px solid var(--border)'
    },
    accent: {
      color: 'var(--accent-text)',
      background: 'var(--accent-surface)',
      border: '1px solid transparent'
    },
    success: {
      color: 'var(--text-primary)',
      background: 'var(--success-surface)',
      border: '1px solid transparent'
    }
  };
  return /*#__PURE__*/React.createElement("span", _extends({
    style: {
      ...tones[tone],
      display: 'inline-flex',
      alignItems: 'center',
      gap: 6,
      padding: '6px 10px',
      borderRadius: 'var(--radius-pill)',
      fontSize: 'var(--text-caption)',
      fontWeight: 'var(--weight-semibold)',
      ...style
    }
  }, rest), icon && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 12
  }), label && /*#__PURE__*/React.createElement("span", null, label), value != null && /*#__PURE__*/React.createElement("span", {
    className: "bf-num"
  }, value));
}
Object.assign(__ds_scope, { MetricPill });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/MetricPill.jsx", error: String((e && e.message) || e) }); }

// components/core/PhotoSlot.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * Placeholder for exercise / editorial photography. BetterFit ships no image
 * assets, so every photo position renders as a labelled slot until real
 * artwork is supplied. Pass `src` once you have it.
 */
function PhotoSlot({
  src,
  alt = '',
  width = 168,
  height = 240,
  radius = 'var(--radius-md)',
  label,
  style,
  ...rest
}) {
  if (src) {
    return /*#__PURE__*/React.createElement("img", _extends({
      src: src,
      alt: alt,
      style: {
        width,
        height,
        objectFit: 'cover',
        borderRadius: radius,
        display: 'block',
        ...style
      }
    }, rest));
  }
  return /*#__PURE__*/React.createElement("div", _extends({
    role: "img",
    "aria-label": alt || 'Photography placeholder',
    style: {
      width,
      height,
      borderRadius: radius,
      background: 'var(--surface-raised)',
      border: '1px dashed var(--border-strong)',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 6,
      padding: 8,
      textAlign: 'center',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "image",
    size: 18,
    color: "var(--text-tertiary)"
  }), label && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--text-caption)',
      color: 'var(--text-tertiary)',
      lineHeight: 1.2
    }
  }, label));
}
Object.assign(__ds_scope, { PhotoSlot });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/PhotoSlot.jsx", error: String((e && e.message) || e) }); }

// components/core/SectionHeader.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Uppercased tracked section marker with an optional trailing action. */
function SectionHeader({
  title,
  action,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: 'flex',
      alignItems: 'baseline',
      justifyContent: 'space-between',
      gap: 12,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--text-caption)',
      fontWeight: 'var(--weight-semibold)',
      textTransform: 'uppercase',
      letterSpacing: 'var(--tracking-label)',
      color: 'var(--text-secondary)'
    }
  }, title), action);
}
Object.assign(__ds_scope, { SectionHeader });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/SectionHeader.jsx", error: String((e && e.message) || e) }); }

// components/data/ContributionHeatmap.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const RAMP = ['var(--heat-0)', 'var(--heat-1)', 'var(--heat-2)', 'var(--heat-3)', 'var(--heat-4)'];

/** Week-column activity heatmap. `values` is one intensity (0–4) per day, oldest first. */
function ContributionHeatmap({
  values = [],
  weeks = 26,
  cell = 10,
  gap = 3,
  style,
  ...rest
}) {
  const total = weeks * 7;
  const days = values.length >= total ? values.slice(-total) : [...Array(total - values.length).fill(0), ...values];
  const cols = [];
  for (let w = 0; w < weeks; w++) cols.push(days.slice(w * 7, w * 7 + 7));
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: 'flex',
      gap,
      ...style
    }
  }, rest), cols.map((col, i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    style: {
      display: 'grid',
      gap,
      gridTemplateRows: `repeat(7, ${cell}px)`
    }
  }, col.map((v, j) => /*#__PURE__*/React.createElement("div", {
    key: j,
    title: `${v} workouts`,
    style: {
      width: cell,
      height: cell,
      borderRadius: 2,
      background: RAMP[Math.max(0, Math.min(4, v))]
    }
  })))));
}
Object.assign(__ds_scope, { ContributionHeatmap });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/ContributionHeatmap.jsx", error: String((e && e.message) || e) }); }

// components/data/Gauge.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Semi-circular gauge. Reads as a conclusion, not a chart. */
function Gauge({
  progress = 0,
  width = 160,
  thickness = 12,
  tint = 'var(--accent)',
  label,
  value,
  style,
  ...rest
}) {
  const p = Math.max(0, Math.min(1, progress));
  const r = (width - thickness) / 2;
  const len = Math.PI * r;
  const h = width / 2 + thickness / 2;
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      width,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("svg", {
    width: width,
    height: h,
    viewBox: `0 0 ${width} ${h}`
  }, /*#__PURE__*/React.createElement("path", {
    d: `M ${thickness / 2} ${h - thickness / 2} A ${r} ${r} 0 0 1 ${width - thickness / 2} ${h - thickness / 2}`,
    fill: "none",
    stroke: "var(--surface-raised)",
    strokeWidth: thickness,
    strokeLinecap: "round"
  }), /*#__PURE__*/React.createElement("path", {
    d: `M ${thickness / 2} ${h - thickness / 2} A ${r} ${r} 0 0 1 ${width - thickness / 2} ${h - thickness / 2}`,
    fill: "none",
    stroke: tint,
    strokeWidth: thickness,
    strokeLinecap: "round",
    strokeDasharray: len,
    strokeDashoffset: len * (1 - p),
    style: {
      transition: 'stroke-dashoffset var(--dur-slow) var(--ease-snappy)'
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center',
      marginTop: -8
    }
  }, value != null && /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      fontSize: 'var(--text-stat-lg)',
      fontWeight: 'var(--weight-bold)'
    }
  }, value), label && /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-caption)',
      color: 'var(--text-secondary)'
    }
  }, label)));
}
Object.assign(__ds_scope, { Gauge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/Gauge.jsx", error: String((e && e.message) || e) }); }

// components/data/LegendDot.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Colour key for a split or chart series. */
function LegendDot({
  label,
  percent,
  color = 'var(--accent)',
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("span", _extends({
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 6,
      fontSize: 'var(--text-caption)',
      color: 'var(--text-secondary)',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 8,
      height: 8,
      borderRadius: 'var(--radius-pill)',
      background: color
    }
  }), /*#__PURE__*/React.createElement("span", null, label), percent != null && /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      color: 'var(--text-primary)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, percent, "%"));
}
Object.assign(__ds_scope, { LegendDot });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/LegendDot.jsx", error: String((e && e.message) || e) }); }

// components/data/MuscleChip.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Muscle group + share of the session, with a proportional bar. */
function MuscleChip({
  muscle,
  percent = 0,
  tint = 'var(--accent)',
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      flex: 1,
      minWidth: 72,
      padding: 12,
      borderRadius: 'var(--radius-md)',
      background: 'var(--surface)',
      border: '1px solid var(--border)',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      fontSize: 'var(--text-stat-sm)',
      fontWeight: 'var(--weight-bold)'
    }
  }, percent, "%"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-caption)',
      color: 'var(--text-secondary)',
      marginTop: 2,
      marginBottom: 8
    }
  }, muscle), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 4,
      borderRadius: 2,
      background: 'var(--surface-raised)',
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: `${Math.max(0, Math.min(100, percent))}%`,
      height: '100%',
      background: tint,
      transition: 'width var(--dur-standard) var(--ease-out)'
    }
  })));
}
Object.assign(__ds_scope, { MuscleChip });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/MuscleChip.jsx", error: String((e && e.message) || e) }); }

// components/data/OverviewStat.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Inline icon + value + caption. Sits in a row under a headline, no container. */
function OverviewStat({
  icon,
  value,
  label,
  tint = 'var(--accent-text)',
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 2,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 6
    }
  }, icon && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 13,
    color: tint
  }), /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      fontSize: 'var(--text-stat-sm)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, value)), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--text-caption)',
      color: 'var(--text-secondary)'
    }
  }, label));
}
Object.assign(__ds_scope, { OverviewStat });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/OverviewStat.jsx", error: String((e && e.message) || e) }); }

// components/data/ProgressRing.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Flat progress ring — solid track, accent fill, round caps. */
function ProgressRing({
  progress = 0,
  size = 86,
  lineWidth = 10,
  tint = 'var(--accent)',
  children,
  style,
  ...rest
}) {
  const p = Math.max(0, Math.min(1, progress));
  const r = (size - lineWidth) / 2;
  const c = 2 * Math.PI * r;
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      position: 'relative',
      width: size,
      height: size,
      ...style
    },
    role: "progressbar",
    "aria-valuenow": Math.round(p * 100),
    "aria-valuemin": 0,
    "aria-valuemax": 100
  }, rest), /*#__PURE__*/React.createElement("svg", {
    width: size,
    height: size,
    style: {
      transform: 'rotate(-90deg)'
    }
  }, /*#__PURE__*/React.createElement("circle", {
    cx: size / 2,
    cy: size / 2,
    r: r,
    fill: "none",
    stroke: "var(--surface-raised)",
    strokeWidth: lineWidth
  }), /*#__PURE__*/React.createElement("circle", {
    cx: size / 2,
    cy: size / 2,
    r: r,
    fill: "none",
    stroke: tint,
    strokeWidth: lineWidth,
    strokeLinecap: "round",
    strokeDasharray: c,
    strokeDashoffset: c * (1 - p),
    style: {
      transition: 'stroke-dashoffset var(--dur-slow) var(--ease-snappy)'
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      display: 'grid',
      placeItems: 'center'
    }
  }, children));
}
Object.assign(__ds_scope, { ProgressRing });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/ProgressRing.jsx", error: String((e && e.message) || e) }); }

// components/data/StatTile.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Icon + value + label tile. Used in grids for streaks, volume, recovery. */
function StatTile({
  icon,
  value,
  label,
  tint = 'var(--accent-text)',
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement(__ds_scope.Card, _extends({
    padding: 12,
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8,
      ...style
    }
  }, rest), icon && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 16,
    color: tint
  }), /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      fontSize: 'var(--text-stat-md)',
      fontWeight: 'var(--weight-bold)'
    }
  }, value), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-caption)',
      color: 'var(--text-secondary)'
    }
  }, label));
}
Object.assign(__ds_scope, { StatTile });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/StatTile.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Banner.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const TONES = {
  info: {
    border: 'var(--info)',
    surface: 'var(--info-surface)',
    icon: 'info',
    ink: 'var(--accent-text)'
  },
  success: {
    border: 'var(--success)',
    surface: 'var(--success-surface)',
    icon: 'check-circle',
    ink: 'var(--accent-text)'
  },
  warning: {
    border: 'var(--warning)',
    surface: 'var(--warning-surface)',
    icon: 'warning',
    ink: 'var(--accent-text)'
  },
  danger: {
    border: 'var(--danger)',
    surface: 'var(--danger-surface)',
    icon: 'warning-octagon',
    ink: 'var(--text-primary)'
  }
};

/** Inline notice with an optional action. Connection prompts, sync errors, plan changes. */
function Banner({
  tone = 'info',
  icon,
  title,
  message,
  action,
  onDismiss,
  style,
  ...rest
}) {
  const t = TONES[tone];
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: 'flex',
      gap: 12,
      alignItems: 'flex-start',
      padding: 14,
      background: t.surface,
      border: `1px solid color-mix(in srgb, ${t.border} 40%, transparent)`,
      borderRadius: 'var(--radius-card)',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon || t.icon,
    size: 18,
    color: t.ink
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-subheadline)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, title), message && /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)',
      marginTop: 2
    }
  }, message), action && /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 10
    }
  }, action)), onDismiss && /*#__PURE__*/React.createElement("button", {
    type: "button",
    "aria-label": "Dismiss",
    onClick: onDismiss,
    style: {
      background: 'none',
      border: 'none',
      color: 'var(--text-tertiary)',
      cursor: 'pointer',
      padding: 0
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "x",
    size: 14,
    weight: "bold"
  })));
}
Object.assign(__ds_scope, { Banner });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Banner.jsx", error: String((e && e.message) || e) }); }

// components/feedback/EmptyState.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Explains what will appear here and offers the next step. */
function EmptyState({
  icon = 'list-checks',
  title,
  message,
  action,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: 12,
      padding: '32px 20px',
      textAlign: 'center',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 36,
    color: "var(--text-tertiary)"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-headline)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, title), message && /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-subheadline)',
      color: 'var(--text-secondary)',
      maxWidth: 320
    }
  }, message), action);
}
Object.assign(__ds_scope, { EmptyState });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/EmptyState.jsx", error: String((e && e.message) || e) }); }

// components/feedback/RecoveryDot.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const RECOVERY_COLORS = {
  recovered: 'var(--recovery-recovered)',
  fresh: 'var(--recovery-fresh)',
  fatigued: 'var(--recovery-fatigued)',
  sore: 'var(--recovery-sore)'
};

/** Small coloured dot for a region's recovery status. */
function RecoveryDot({
  status = 'recovered',
  size = 10,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("span", _extends({
    "aria-label": `Recovery: ${status}`,
    style: {
      width: size,
      height: size,
      borderRadius: 'var(--radius-pill)',
      background: RECOVERY_COLORS[status],
      display: 'inline-block',
      ...style
    }
  }, rest));
}
Object.assign(__ds_scope, { RECOVERY_COLORS, RecoveryDot });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/RecoveryDot.jsx", error: String((e && e.message) || e) }); }

// components/feedback/RecoveryBadge.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const LABEL = {
  recovered: 'Recovered',
  fresh: 'Fresh',
  fatigued: 'Fatigued',
  sore: 'Sore'
};

/** Tinted capsule stating a recovery status in words. */
function RecoveryBadge({
  status = 'recovered',
  style,
  ...rest
}) {
  const c = __ds_scope.RECOVERY_COLORS[status];
  return /*#__PURE__*/React.createElement("span", _extends({
    style: {
      color: 'var(--text-primary)',
      background: `color-mix(in srgb, ${c} 22%, transparent)`,
      border: `1px solid color-mix(in srgb, ${c} 45%, transparent)`,
      padding: '3px 10px',
      borderRadius: 'var(--radius-pill)',
      display: 'inline-flex',
      alignItems: 'center',
      gap: 6,
      fontSize: 'var(--text-caption)',
      fontWeight: 'var(--weight-semibold)',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 7,
      height: 7,
      borderRadius: 'var(--radius-pill)',
      background: c
    }
  }), LABEL[status]);
}
Object.assign(__ds_scope, { RecoveryBadge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/RecoveryBadge.jsx", error: String((e && e.message) || e) }); }

// components/feedback/RestTimerBar.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Sticky rest countdown with add-time and skip. Digits are tabular so they don't jitter. */
function RestTimerBar({
  remaining = 90,
  total = 90,
  onAdd,
  onSkip,
  style,
  ...rest
}) {
  const mm = String(Math.floor(Math.max(0, remaining) / 60)).padStart(2, '0');
  const ss = String(Math.max(0, remaining) % 60).padStart(2, '0');
  const pct = total > 0 ? Math.max(0, Math.min(1, remaining / total)) : 0;
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      background: 'var(--bg-elevated)',
      borderBottom: '1px solid var(--border)',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '12px 20px'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "timer",
    size: 18,
    color: "var(--accent)"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-caption)',
      color: 'var(--text-secondary)',
      textTransform: 'uppercase',
      letterSpacing: 'var(--tracking-label)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, "Rest"), /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      fontFamily: 'var(--font-mono)',
      fontSize: 'var(--text-stat-md)',
      fontWeight: 'var(--weight-bold)'
    }
  }, mm, ":", ss)), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onAdd,
    style: {
      background: 'var(--surface-raised)',
      border: '1px solid var(--border)',
      color: 'var(--text-primary)',
      borderRadius: 'var(--radius-pill)',
      padding: '8px 14px',
      fontSize: 'var(--text-footnote)',
      fontWeight: 'var(--weight-semibold)',
      cursor: 'pointer'
    }
  }, "+15s"), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onSkip,
    style: {
      background: 'transparent',
      border: 'none',
      color: 'var(--accent-text)',
      fontSize: 'var(--text-footnote)',
      fontWeight: 'var(--weight-semibold)',
      cursor: 'pointer',
      padding: '8px 4px'
    }
  }, "Skip")), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 3,
      background: 'var(--surface-raised)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: `${pct * 100}%`,
      height: '100%',
      background: 'var(--accent)',
      transition: 'width 1s linear'
    }
  })));
}
Object.assign(__ds_scope, { RestTimerBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/RestTimerBar.jsx", error: String((e && e.message) || e) }); }

// components/lists/ExerciseRow.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Timeline row for a planned exercise: index marker, name, prescription, state. */
function ExerciseRow({
  index,
  name,
  prescription,
  muscles,
  state = 'planned',
  isLast = false,
  onClick,
  style,
  ...rest
}) {
  const done = state === 'done';
  const active = state === 'active';
  const markerBg = done ? 'var(--surface-raised)' : active ? 'var(--accent)' : 'var(--surface-raised)';
  const markerFg = active ? 'var(--text-on-accent)' : 'var(--text-secondary)';
  return /*#__PURE__*/React.createElement("div", _extends({
    onClick: onClick,
    style: {
      display: 'flex',
      gap: 12,
      cursor: onClick ? 'pointer' : 'default',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      flex: '0 0 28px'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 28,
      height: 28,
      borderRadius: 'var(--radius-pill)',
      background: markerBg,
      color: markerFg,
      display: 'grid',
      placeItems: 'center',
      fontSize: 'var(--text-caption)',
      fontWeight: 'var(--weight-bold)',
      border: active ? '1px solid transparent' : '1px solid var(--border)'
    },
    className: "bf-num"
  }, done ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "check",
    size: 13,
    weight: "bold",
    color: "var(--accent-text)"
  }) : index), !isLast && /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      width: 1,
      background: 'var(--separator)',
      marginTop: 4,
      minHeight: 24
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0,
      paddingBottom: isLast ? 0 : 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-subheadline)',
      fontWeight: 'var(--weight-semibold)',
      color: done ? 'var(--text-secondary)' : 'var(--text-primary)',
      textDecoration: done ? 'line-through' : 'none'
    }
  }, name), prescription && /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)',
      marginTop: 2
    }
  }, prescription), muscles && /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-caption)',
      color: 'var(--text-tertiary)',
      marginTop: 4
    }
  }, muscles)), active && /*#__PURE__*/React.createElement("span", {
    style: {
      alignSelf: 'flex-start',
      fontSize: 'var(--text-caption)',
      fontWeight: 'var(--weight-semibold)',
      color: 'var(--accent-text)',
      textTransform: 'uppercase',
      letterSpacing: 'var(--tracking-label)'
    }
  }, "Now"));
}
Object.assign(__ds_scope, { ExerciseRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/lists/ExerciseRow.jsx", error: String((e && e.message) || e) }); }

// components/lists/ListRow.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Circular tinted icon + title + subtitle + optional trailing content. */
function ListRow({
  icon,
  title,
  subtitle,
  iconTint = 'var(--accent-text)',
  trailing,
  onClick,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    onClick: onClick,
    role: onClick ? 'button' : undefined,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '8px 0',
      minHeight: 'var(--tap-min)',
      cursor: onClick ? 'pointer' : 'default',
      ...style
    }
  }, rest), icon && /*#__PURE__*/React.createElement("span", {
    style: {
      width: 44,
      height: 44,
      flex: '0 0 44px',
      borderRadius: 'var(--radius-pill)',
      background: 'color-mix(in srgb, ' + iconTint + ' 15%, transparent)',
      display: 'grid',
      placeItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 18,
    color: iconTint
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      minWidth: 0,
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-subheadline)',
      fontWeight: 'var(--weight-semibold)',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, title), subtitle && /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)',
      marginTop: 2
    }
  }, subtitle)), trailing);
}
Object.assign(__ds_scope, { ListRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/lists/ListRow.jsx", error: String((e && e.message) || e) }); }

// components/lists/ChevronRow.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Navigation row — a ListRow that always ends in a chevron. */
function ChevronRow({
  icon,
  title,
  subtitle,
  iconTint,
  value,
  onClick,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement(__ds_scope.ListRow, _extends({
    icon: icon,
    title: title,
    subtitle: subtitle,
    iconTint: iconTint,
    onClick: onClick,
    style: style,
    trailing: /*#__PURE__*/React.createElement("span", {
      style: {
        display: 'inline-flex',
        alignItems: 'center',
        gap: 8,
        color: 'var(--text-tertiary)'
      }
    }, value && /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: 'var(--text-footnote)',
        color: 'var(--text-secondary)'
      }
    }, value), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "caret-right",
      size: 13,
      weight: "bold"
    }))
  }, rest));
}
Object.assign(__ds_scope, { ChevronRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/lists/ChevronRow.jsx", error: String((e && e.message) || e) }); }

// components/lists/SettingsRow.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Settings row in four shapes: toggle, radio, static value, external link. */
function SettingsRow({
  kind = 'static',
  icon,
  title,
  subtitle,
  value,
  checked = false,
  onChange,
  onClick,
  style,
  ...rest
}) {
  const interactive = kind === 'toggle' || kind === 'radio' || kind === 'link';
  const handle = () => {
    if (kind === 'toggle' || kind === 'radio') onChange && onChange(!checked);else if (onClick) onClick();
  };
  return /*#__PURE__*/React.createElement("div", _extends({
    onClick: interactive ? handle : onClick,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '12px 0',
      minHeight: 'var(--tap-min)',
      cursor: interactive || onClick ? 'pointer' : 'default',
      ...style
    }
  }, rest), icon && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 17,
    color: "var(--text-secondary)",
    style: {
      flex: '0 0 20px'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-body)'
    }
  }, title), subtitle && /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)',
      marginTop: 2
    }
  }, subtitle)), kind === 'toggle' && /*#__PURE__*/React.createElement("span", {
    role: "switch",
    "aria-checked": checked,
    style: {
      width: 46,
      height: 28,
      flex: '0 0 46px',
      borderRadius: 'var(--radius-pill)',
      padding: 2,
      background: checked ? 'var(--accent)' : 'var(--surface-raised)',
      border: checked ? '1px solid transparent' : '1px solid var(--border)',
      display: 'flex',
      justifyContent: checked ? 'flex-end' : 'flex-start',
      transition: 'background var(--dur-fast) var(--ease-out)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 24,
      height: 24,
      borderRadius: 'var(--radius-pill)',
      background: checked ? 'var(--bf-black)' : 'var(--bg-elevated)',
      border: checked ? '1px solid transparent' : '1px solid var(--border)'
    }
  })), kind === 'radio' && checked && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "check",
    size: 16,
    weight: "bold",
    color: "var(--accent-text)"
  }), kind === 'static' && value && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--text-subheadline)',
      color: 'var(--text-secondary)'
    }
  }, value), kind === 'link' && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "arrow-up-right",
    size: 14,
    weight: "bold",
    color: "var(--text-tertiary)"
  }));
}
Object.assign(__ds_scope, { SettingsRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/lists/SettingsRow.jsx", error: String((e && e.message) || e) }); }

// components/workout/SetLogField.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Labelled numeric field for logging a set. Big tabular value, unit suffix. */
function SetLogField({
  label,
  unit,
  value,
  onChange,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("label", _extends({
    style: {
      flex: 1,
      minWidth: 0,
      display: 'block',
      background: 'var(--surface-raised)',
      border: '1px solid var(--border)',
      borderRadius: 'var(--radius-md)',
      padding: '10px 14px',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 'var(--text-caption)',
      fontWeight: 'var(--weight-semibold)',
      textTransform: 'uppercase',
      letterSpacing: 'var(--tracking-label)',
      color: 'var(--text-secondary)'
    }
  }, label), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("input", {
    value: value,
    onChange: e => onChange && onChange(e.target.value),
    inputMode: "decimal",
    size: 1,
    style: {
      flex: 1,
      width: '100%',
      minWidth: 0,
      background: 'transparent',
      border: 'none',
      outline: 'none',
      padding: 0,
      color: 'var(--text-primary)',
      fontFamily: 'var(--font-mono)',
      fontSize: 'var(--text-stat-lg)',
      fontWeight: 'var(--weight-bold)',
      fontVariantNumeric: 'tabular-nums'
    }
  }), unit && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)'
    }
  }, unit)));
}
Object.assign(__ds_scope, { SetLogField });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/workout/SetLogField.jsx", error: String((e && e.message) || e) }); }

// components/workout/SupersetIndicator.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Bracket label grouping exercises performed back to back. */
function SupersetIndicator({
  rounds = 3,
  label = 'Superset',
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 2,
      height: 16,
      background: 'var(--accent)',
      borderRadius: 1
    }
  }), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "arrows-clockwise",
    size: 12,
    color: "var(--accent-text)"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--text-caption)',
      fontWeight: 'var(--weight-semibold)',
      textTransform: 'uppercase',
      letterSpacing: 'var(--tracking-label)',
      color: 'var(--text-secondary)'
    }
  }, label, " \xB7 ", /*#__PURE__*/React.createElement("span", {
    className: "bf-num"
  }, rounds), " rounds"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      height: 1,
      background: 'var(--separator)'
    }
  }));
}
Object.assign(__ds_scope, { SupersetIndicator });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/workout/SupersetIndicator.jsx", error: String((e && e.message) || e) }); }

// components/workout/WeightUnitToggle.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** Two-option segmented control on a raised well. */
function WeightUnitToggle({
  value = 'lb',
  options = ['lb', 'kg'],
  onChange,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    role: "group",
    style: {
      display: 'inline-flex',
      gap: 2,
      padding: 2,
      borderRadius: 'var(--radius-pill)',
      background: 'var(--surface-raised)',
      border: '1px solid var(--border)',
      ...style
    }
  }, rest), options.map(o => {
    const on = o === value;
    return /*#__PURE__*/React.createElement("button", {
      key: o,
      type: "button",
      onClick: () => onChange && onChange(o),
      "aria-pressed": on,
      style: {
        minHeight: 'var(--tap-min)',
        padding: '0 18px',
        borderRadius: 'var(--radius-pill)',
        border: 'none',
        cursor: 'pointer',
        background: on ? 'var(--accent)' : 'transparent',
        color: on ? 'var(--text-on-accent)' : 'var(--text-secondary)',
        fontFamily: 'var(--font-ui)',
        fontSize: 'var(--text-footnote)',
        fontWeight: 'var(--weight-semibold)',
        transition: 'background var(--dur-fast) var(--ease-out)'
      }
    }, o);
  }));
}
Object.assign(__ds_scope, { WeightUnitToggle });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/workout/WeightUnitToggle.jsx", error: String((e && e.message) || e) }); }

// components/workout/WorkoutCard.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/** A suggested or scheduled session: name, focus, prescription, muscle summary. */
function WorkoutCard({
  name,
  focus,
  exercises,
  duration,
  volume,
  muscles = [],
  tone = 'surface',
  badge,
  onClick,
  style,
  ...rest
}) {
  const identity = tone === 'identity';
  return /*#__PURE__*/React.createElement("div", _extends({
    onClick: onClick,
    style: {
      background: identity ? 'var(--bf-yellow)' : 'var(--surface)',
      color: identity ? 'var(--bf-black)' : 'var(--text-primary)',
      border: identity ? '1px solid transparent' : '1px solid var(--border)',
      borderRadius: 'var(--radius-card)',
      padding: 16,
      cursor: onClick ? 'pointer' : 'default',
      display: 'flex',
      flexDirection: 'column',
      gap: 12,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--text-caption)',
      fontWeight: 'var(--weight-semibold)',
      textTransform: 'uppercase',
      letterSpacing: 'var(--tracking-label)',
      opacity: identity ? 0.7 : 1,
      color: identity ? 'var(--bf-black)' : 'var(--text-secondary)'
    }
  }, focus), badge && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--text-caption)',
      fontWeight: 'var(--weight-semibold)',
      padding: '4px 10px',
      borderRadius: 'var(--radius-pill)',
      background: identity ? 'rgba(0,0,0,.12)' : 'var(--surface-raised)',
      border: identity ? '1px solid transparent' : '1px solid var(--border)'
    }
  }, badge)), /*#__PURE__*/React.createElement("div", {
    className: "bf-display",
    style: {
      fontSize: 'var(--text-title-1)'
    }
  }, name), /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      display: 'flex',
      gap: 16,
      fontSize: 'var(--text-footnote)',
      opacity: identity ? 0.8 : 1,
      color: identity ? 'var(--bf-black)' : 'var(--text-secondary)'
    }
  }, exercises != null && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      gap: 5,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "list-checks",
    size: 13
  }), exercises, " exercises"), duration && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      gap: 5,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "clock",
    size: 13
  }), duration), volume && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      gap: 5,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "barbell",
    size: 13
  }), volume)), muscles.length > 0 && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexWrap: 'wrap',
      gap: 6
    }
  }, muscles.map(m => /*#__PURE__*/React.createElement("span", {
    key: m,
    style: {
      fontSize: 'var(--text-caption)',
      padding: '4px 8px',
      borderRadius: 'var(--radius-sm)',
      background: identity ? 'rgba(0,0,0,.1)' : 'var(--surface-raised)',
      color: identity ? 'var(--bf-black)' : 'var(--text-secondary)'
    }
  }, m))));
}
Object.assign(__ds_scope, { WorkoutCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/workout/WorkoutCard.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/AddExerciseSheet.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const {
  Icon,
  Card,
  Divider,
  Chip,
  PhotoSlot
} = dsPick(['Icon', 'Card', 'Divider', 'Chip', 'PhotoSlot']);
const CATEGORIES = [{
  icon: 'barbell',
  title: 'All exercises'
}, {
  icon: 'clock-counter-clockwise',
  title: 'Recently added'
}, {
  icon: 'user',
  title: 'Added by you'
}, {
  icon: 'person-simple-run',
  title: 'By muscle group'
}, {
  icon: 'dumbbell',
  title: 'By equipment'
}, {
  icon: 'scales',
  title: 'Weighted'
}, {
  icon: 'hand-fist',
  title: 'Bodyweight only'
}, {
  icon: 'heartbeat',
  title: 'Cardio'
}];
const BY_MUSCLE = [{
  title: 'Lats',
  subtitle: '32 exercises'
}, {
  title: 'Biceps',
  subtitle: '24 exercises'
}, {
  title: 'Chest',
  subtitle: '41 exercises'
}, {
  title: 'Shoulders',
  subtitle: '38 exercises'
}, {
  title: 'Quads',
  subtitle: '29 exercises'
}, {
  title: 'Core',
  subtitle: '35 exercises'
}];
const ALL = [{
  title: 'Lat Pulldown',
  subtitle: 'Lats · Cable'
}, {
  title: 'Cable Row',
  subtitle: 'Lats · Cable'
}, {
  title: 'Hammer Curls',
  subtitle: 'Biceps · Dumbbell'
}, {
  title: 'Barbell Curl',
  subtitle: 'Biceps · Barbell'
}, {
  title: 'Bench Press',
  subtitle: 'Chest · Barbell'
}, {
  title: 'Overhead Press',
  subtitle: 'Shoulders · Barbell'
}, {
  title: 'Cable Wood Chop',
  subtitle: 'Core · Cable'
}];
function PickerRow({
  icon,
  title,
  subtitle,
  selected,
  onToggle,
  showThumb,
  inPlan
}) {
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: inPlan ? undefined : onToggle,
    "aria-pressed": onToggle ? selected || inPlan : undefined,
    disabled: inPlan,
    style: {
      width: '100%',
      background: 'none',
      border: 'none',
      textAlign: 'left',
      cursor: inPlan ? 'default' : 'pointer',
      opacity: inPlan ? 0.55 : 1,
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '10px 0',
      minHeight: 'var(--tap-min)',
      color: 'var(--text-primary)',
      fontFamily: 'var(--font-ui)'
    }
  }, showThumb ? /*#__PURE__*/React.createElement(PhotoSlot, {
    width: 44,
    height: 44,
    radius: "10px",
    label: "",
    alt: `${title} demonstration`
  }) : /*#__PURE__*/React.createElement(Icon, {
    name: icon,
    size: 20,
    color: "var(--text-secondary)",
    style: {
      flex: '0 0 24px'
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 'var(--text-body)'
    }
  }, title), (inPlan || subtitle) && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)',
      marginTop: 2
    }
  }, inPlan ? 'Already in this workout' : subtitle)), onToggle ? /*#__PURE__*/React.createElement("span", {
    style: {
      width: 26,
      height: 26,
      flex: '0 0 26px',
      borderRadius: 'var(--radius-pill)',
      background: selected || inPlan ? 'var(--accent)' : 'transparent',
      border: selected || inPlan ? '1px solid transparent' : '1px solid var(--border-strong)',
      display: 'grid',
      placeItems: 'center'
    }
  }, (selected || inPlan) && /*#__PURE__*/React.createElement(Icon, {
    name: "check",
    size: 14,
    weight: "bold",
    color: "var(--bf-black)"
  })) : /*#__PURE__*/React.createElement(Icon, {
    name: "caret-right",
    size: 13,
    weight: "bold",
    color: "var(--text-tertiary)"
  }));
}

/** Full-height sheet for adding exercises to the current plan. */
function AddExerciseSheet({
  onClose,
  onAdd,
  inPlan = []
}) {
  const [scope, setScope] = React.useState('All');
  const [query, setQuery] = React.useState('');
  const [picked, setPicked] = React.useState([]);
  const [group, setGroup] = React.useState(false);
  const toggle = title => {
    if (inPlan.includes(title)) return;
    setPicked(p => p.includes(title) ? p.filter(t => t !== title) : [...p, title]);
  };
  const list = scope === 'Categories' ? CATEGORIES : scope === 'By muscle' ? BY_MUSCLE : ALL;
  const rows = list.filter(r => r.title.toLowerCase().includes(query.toLowerCase()));
  const selectable = scope === 'All';
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(NavBar, {
    title: "Add exercise",
    leading: /*#__PURE__*/React.createElement("button", {
      type: "button",
      "aria-label": "Filters",
      style: {
        width: 'var(--tap-min)',
        height: 'var(--tap-min)',
        borderRadius: 'var(--radius-pill)',
        cursor: 'pointer',
        background: 'transparent',
        border: '1px solid var(--border)',
        color: 'var(--accent-text)',
        display: 'grid',
        placeItems: 'center'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "sliders-horizontal",
      size: 15
    })),
    trailing: /*#__PURE__*/React.createElement("button", {
      type: "button",
      "aria-label": "Close",
      onClick: onClose,
      style: {
        width: 'var(--tap-min)',
        height: 'var(--tap-min)',
        borderRadius: 'var(--radius-pill)',
        cursor: 'pointer',
        background: 'transparent',
        border: '1px solid var(--border)',
        color: 'var(--text-primary)',
        display: 'grid',
        placeItems: 'center'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "x",
      size: 15,
      weight: "bold"
    }))
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: '0 0 auto',
      padding: '0 20px 12px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      background: 'var(--surface-raised)',
      border: '1px solid var(--border)',
      borderRadius: 'var(--radius-md)',
      padding: '0 12px',
      height: 44
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "magnifying-glass",
    size: 16,
    color: "var(--text-tertiary)"
  }), /*#__PURE__*/React.createElement("input", {
    value: query,
    onChange: e => setQuery(e.target.value),
    placeholder: "Search exercises",
    style: {
      flex: 1,
      minWidth: 0,
      alignSelf: 'stretch',
      background: 'transparent',
      border: 'none',
      outline: 'none',
      color: 'var(--text-primary)',
      fontSize: 'var(--text-body)',
      fontFamily: 'var(--font-ui)'
    }
  }), query && /*#__PURE__*/React.createElement("button", {
    type: "button",
    "aria-label": "Clear",
    onClick: () => setQuery(''),
    style: {
      background: 'none',
      border: 'none',
      cursor: 'pointer',
      color: 'var(--text-tertiary)',
      padding: 0
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "x-circle",
    size: 16
  })))), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: '0 0 auto',
      display: 'flex',
      gap: 8,
      padding: '0 20px 14px'
    }
  }, ['All', 'By muscle', 'Categories'].map(s => /*#__PURE__*/React.createElement(Chip, {
    key: s,
    label: s,
    selected: scope === s,
    onClick: () => setScope(s)
  }))), /*#__PURE__*/React.createElement(Scroll, null, /*#__PURE__*/React.createElement(Card, {
    padding: 12
  }, rows.map((r, i) => /*#__PURE__*/React.createElement("div", {
    key: r.title
  }, i > 0 && /*#__PURE__*/React.createElement(Divider, {
    inset: selectable ? 56 : 36
  }), /*#__PURE__*/React.createElement(PickerRow, _extends({}, r, {
    showThumb: selectable,
    inPlan: selectable && inPlan.includes(r.title),
    selected: picked.includes(r.title),
    onToggle: selectable ? () => toggle(r.title) : undefined
  }))))), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 140
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: 0,
      right: 0,
      bottom: 0,
      padding: '28px 20px 20px',
      background: 'linear-gradient(to top, var(--bg-page) 60%, transparent)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 10,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: () => setGroup(g => !g),
    "aria-pressed": group,
    style: {
      flex: '0 0 auto',
      height: 'var(--control-lg)',
      padding: '0 16px',
      cursor: 'pointer',
      borderRadius: 'var(--radius-button)',
      background: group ? 'var(--surface-raised)' : 'transparent',
      border: '1px solid var(--border-strong)',
      color: 'var(--text-primary)',
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--text-footnote)',
      fontWeight: 'var(--weight-semibold)',
      display: 'inline-flex',
      alignItems: 'center',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrows-clockwise",
    size: 14
  }), "Group as circuit"), /*#__PURE__*/React.createElement("button", {
    type: "button",
    disabled: picked.length === 0,
    onClick: () => onAdd(picked.filter(p => !inPlan.includes(p))),
    style: {
      flex: 1,
      height: 'var(--control-lg)',
      border: 'none',
      cursor: picked.length ? 'pointer' : 'not-allowed',
      opacity: picked.length ? 1 : 0.4,
      background: 'var(--accent)',
      color: 'var(--bf-black)',
      borderRadius: 'var(--radius-button)',
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--text-headline)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, picked.length ? `Add ${picked.length} exercise${picked.length > 1 ? 's' : ''}` : 'Add exercise'))));
}
Object.assign(window, {
  AddExerciseSheet
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/AddExerciseSheet.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/AppShell.jsx
try { (() => {
const {
  Icon,
  Logo
} = window.BetterFitDesignSystem_6a70ea;

/* ---- Tweak context ----
   Three cross-cutting choices the whole kit reads: how chrome sits over the page,
   how tightly the ledger is packed, and how much yellow the app spends. */
const BFT_DEFAULT = {
  chrome: 'glass',
  density: 'standard',
  accent: 'balanced',
  artwork: 'icon'
};
const BFTweakCtx = React.createContext(BFT_DEFAULT);
const useBFT = () => React.useContext(BFTweakCtx);
const DENSITY = {
  roomy: {
    rowPy: 18,
    gutter: 38,
    sectPt: 34,
    metaGap: 5,
    title: 17
  },
  standard: {
    rowPy: 14,
    gutter: 32,
    sectPt: 26,
    metaGap: 3,
    title: 17
  },
  compact: {
    rowPy: 9,
    gutter: 26,
    sectPt: 18,
    metaGap: 1,
    title: 15
  }
};
const TABS = [{
  id: 'workout',
  label: 'Workout',
  icon: 'barbell'
}, {
  id: 'body',
  label: 'Body',
  icon: 'person-simple-run'
}, {
  id: 'targets',
  label: 'Targets',
  icon: 'crosshair'
}, {
  id: 'log',
  label: 'Log',
  icon: 'calendar-blank'
}];
function StatusBar() {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      height: 48,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 24px',
      color: 'var(--text-primary)',
      fontSize: 14,
      fontWeight: 600,
      flex: '0 0 48px'
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "bf-num"
  }, "9:41"), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      gap: 5,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "cell-signal-full",
    size: 14
  }), /*#__PURE__*/React.createElement(Icon, {
    name: "wifi-high",
    size: 14
  }), /*#__PURE__*/React.createElement(Icon, {
    name: "battery-full",
    size: 16
  })));
}

/** Floating glass nav, or an opaque bar welded to the layout — see the `chrome` tweak. */
function TabBar({
  active,
  onChange
}) {
  const {
    chrome
  } = useBFT();
  const solid = chrome === 'solid';
  const compact = chrome === 'compact';
  const shell = solid ? {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 40
  } : {
    position: 'absolute',
    left: compact ? 60 : 12,
    right: compact ? 60 : 12,
    bottom: compact ? 16 : 12,
    zIndex: 40
  };
  const inner = solid ? {
    background: 'var(--bg-elevated)',
    borderTop: '1px solid var(--border)',
    borderRadius: 0,
    padding: '6px 8px 22px',
    boxShadow: 'none'
  } : {
    background: 'var(--glass-fill)',
    WebkitBackdropFilter: 'var(--glass-blur)',
    backdropFilter: 'var(--glass-blur)',
    border: '1px solid var(--glass-border)',
    borderRadius: 32,
    padding: 6,
    boxShadow: 'var(--glass-shadow), inset 0 1px 0 rgba(255,255,255,.16)'
  };
  return /*#__PURE__*/React.createElement("div", {
    style: shell
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: 'repeat(4,1fr)',
      gap: 4,
      ...inner
    }
  }, TABS.map(t => {
    const on = t.id === active;
    return /*#__PURE__*/React.createElement("button", {
      key: t.id,
      type: "button",
      onClick: () => onChange(t.id),
      "aria-label": t.label,
      style: {
        background: on && !solid ? 'var(--glass-highlight)' : 'transparent',
        border: 'none',
        cursor: 'pointer',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: 3,
        padding: compact ? '0' : '9px 0 7px',
        borderRadius: 'var(--radius-pill)',
        minHeight: 52,
        color: on ? 'var(--accent-text)' : 'var(--text-tertiary)'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: t.icon,
      size: 21
    }), !compact && /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: 10,
        fontWeight: 700,
        letterSpacing: '0.01em'
      }
    }, t.label));
  })));
}
function NavBar({
  title,
  leading,
  trailing
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: '0 0 auto',
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '4px 20px 12px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: '0 0 auto',
      minWidth: 44
    }
  }, leading), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      textAlign: 'center',
      fontSize: 'var(--text-headline)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, title), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: '0 0 auto',
      minWidth: 44,
      display: 'flex',
      justifyContent: 'flex-end'
    }
  }, trailing));
}
function Phone({
  children,
  scheme = 'dark',
  tweaks = BFT_DEFAULT
}) {
  const d = DENSITY[tweaks.density] || DENSITY.standard;
  return /*#__PURE__*/React.createElement(BFTweakCtx.Provider, {
    value: tweaks
  }, /*#__PURE__*/React.createElement("div", {
    "data-scheme": scheme,
    style: {
      width: 390,
      height: 844,
      background: 'var(--bg-page)',
      color: 'var(--text-primary)',
      borderRadius: 44,
      overflow: 'hidden',
      display: 'flex',
      flexDirection: 'column',
      boxShadow: '0 30px 80px rgba(0,0,0,.55), 0 0 0 10px #1b1b1f',
      position: 'relative',
      fontFamily: 'var(--font-ui)',
      '--l-row-py': d.rowPy + 'px',
      '--l-gutter': d.gutter + 'px',
      '--l-sect-pt': d.sectPt + 'px',
      '--l-meta-gap': d.metaGap + 'px',
      '--l-title': d.title + 'px'
    }
  }, children));
}

/** Non-Ledger screens scroll through here. Bottom padding clears the floating nav. */
function Scroll({
  children,
  pad = true
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      overflowX: 'hidden',
      padding: pad ? '0 20px 100px' : '0 0 100px',
      scrollbarWidth: 'none',
      msOverflowStyle: 'none'
    }
  }, children);
}

/** Keeps one broken screen from blanking the whole kit. */
class ScreenBoundary extends React.Component {
  constructor(p) {
    super(p);
    this.state = {
      error: null
    };
  }
  static getDerivedStateFromError(error) {
    return {
      error
    };
  }
  componentDidUpdate(prev) {
    if (prev.screenKey !== this.props.screenKey && this.state.error) this.setState({
      error: null
    });
  }
  render() {
    if (!this.state.error) return this.props.children;
    return /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1,
        display: 'grid',
        placeItems: 'center',
        padding: 24,
        textAlign: 'center'
      }
    }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--text-headline)',
        fontWeight: 'var(--weight-semibold)'
      }
    }, "This screen didn't load"), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--text-footnote)',
        color: 'var(--text-secondary)',
        marginTop: 6,
        maxWidth: 260,
        textWrap: 'pretty'
      }
    }, "Usually a stale ", /*#__PURE__*/React.createElement("code", null, "_ds_bundle.js"), ". Pick another screen below, or reload once the bundle recompiles."), /*#__PURE__*/React.createElement("div", {
      style: {
        fontFamily: 'var(--font-mono)',
        fontSize: 11,
        color: 'var(--text-tertiary)',
        marginTop: 10
      }
    }, String(this.state.error && this.state.error.message).slice(0, 120))));
  }
}

/** Destructure DS components through this so a missing export degrades instead of throwing. */
function dsPick(names) {
  const NS = window.BetterFitDesignSystem_6a70ea || {};
  const out = {};
  for (const n of names) {
    out[n] = NS[n] || function Missing() {
      return /*#__PURE__*/React.createElement("span", {
        style: {
          fontSize: 11,
          fontFamily: 'var(--font-mono)',
          color: 'var(--text-tertiary)'
        }
      }, "[", n, "]");
    };
  }
  return out;
}

/* ---- The Ledger: reimagined screen layout primitives ----
   Rules, not cards. A 46px mono gutter runs down every list. One squared
   full-bleed yellow slab per screen carries the number that matters and the
   single primary action, so nothing floats over the content. */

/** Uppercase micro label. */
function Eyebrow({
  children,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 11,
      fontWeight: 'var(--weight-bold)',
      textTransform: 'uppercase',
      letterSpacing: '0.14em',
      ...style
    }
  }, children);
}

/** The screen's yellow moment: full bleed, squared, black ink. Goes neutral when the
    `accent` tweak is restrained — the yellow then lives on the docked action instead. */
function Slab({
  children,
  style
}) {
  const {
    accent
  } = useBFT();
  const quiet = accent === 'restrained';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      background: quiet ? 'transparent' : 'var(--bf-yellow)',
      color: quiet ? 'var(--text-primary)' : 'var(--bf-black)',
      borderBottom: quiet ? '1px solid var(--separator)' : 'none',
      padding: '18px 20px 20px',
      ...style
    }
  }, children);
}

/** Primary action, inverted so it reads on the yellow field. */
function SlabAction({
  icon,
  children,
  onClick,
  tone = 'ink'
}) {
  const {
    accent
  } = useBFT();
  const onYellow = accent !== 'restrained';
  const ink = tone === 'ink';
  const fill = onYellow ? ink ? 'var(--bf-black)' : 'transparent' : 'var(--accent)';
  const label = onYellow ? ink ? 'var(--bf-yellow)' : 'var(--bf-black)' : 'var(--text-on-accent)';
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onClick,
    style: {
      width: '100%',
      height: 'var(--control-lg)',
      marginTop: 16,
      cursor: 'pointer',
      border: onYellow && !ink ? '1.5px solid rgba(0,0,0,.28)' : 'none',
      background: fill,
      color: label,
      borderRadius: 'var(--radius-button)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 9,
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--text-headline)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, icon && /*#__PURE__*/React.createElement(Icon, {
    name: icon,
    size: 16
  }), children);
}

/** Mono spec strip — the two or three facts that qualify the slab's headline. */
function SpecStrip({
  items,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      display: 'flex',
      gap: 18,
      marginTop: 12,
      ...style
    }
  }, items.map(it => /*#__PURE__*/React.createElement("div", {
    key: it.label
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 22,
      fontWeight: 'var(--weight-bold)',
      lineHeight: 1
    }
  }, it.value), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 10,
      fontWeight: 'var(--weight-semibold)',
      textTransform: 'uppercase',
      letterSpacing: '0.1em',
      opacity: 0.58,
      marginTop: 5,
      fontFamily: 'var(--font-ui)'
    }
  }, it.label))));
}

/** Section marker: label, then a hairline that runs to the trailing value. */
function SectionRule({
  label,
  trailing,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: 'var(--l-sect-pt, 26px) 0 10px',
      ...style
    }
  }, /*#__PURE__*/React.createElement(Eyebrow, {
    style: {
      color: 'var(--text-secondary)',
      flex: '0 0 auto'
    }
  }, label), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      height: 1,
      background: 'var(--separator)'
    }
  }), trailing && /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)',
      flex: '0 0 auto'
    }
  }, trailing));
}

/** Tracks an <image-slot>'s `data-filled` attribute so a row can lay itself out
    differently before and after the user drops a photo in. */
function useSlotFilled() {
  const [filled, setFilled] = React.useState(false);
  const [el, setEl] = React.useState(null);
  React.useEffect(() => {
    if (!el) return;
    const read = () => setFilled(el.hasAttribute('data-filled'));
    read();
    const mo = new MutationObserver(read);
    mo.observe(el, {
      attributes: true,
      attributeFilter: ['data-filled']
    });
    return () => mo.disconnect();
  }, [el]);
  return [filled, setEl];
}

/** Rounded artwork tile that replaces the mono gutter when rows carry art. */
function ArtTile({
  icon,
  size = 38
}) {
  return /*#__PURE__*/React.createElement("span", {
    style: {
      flex: `0 0 ${size}px`,
      width: size,
      height: size,
      borderRadius: 11,
      background: 'var(--surface-raised)',
      border: '1px solid var(--border)',
      display: 'grid',
      placeItems: 'center',
      color: 'var(--accent-text)',
      position: 'relative',
      zIndex: 2
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: icon || 'barbell',
    size: 19
  }));
}

/** One ruled ledger row. `gutter` is the mono index/date column; `art` opts the row
    into the `artwork` tweak — {icon, slot, label} for an icon tile or a photo bed. */
function LedgerRow({
  gutter,
  gutterAccent,
  title,
  titleIcon,
  meta,
  trailing,
  trailingMeta,
  accent,
  dim,
  chevron,
  onClick,
  art,
  children
}) {
  const {
    artwork
  } = useBFT();
  const [filled, slotRef] = useSlotFilled();
  const mode = art ? artwork : 'plain';
  const photo = mode === 'photo';
  const bed = photo && filled;
  const Tag = onClick ? 'button' : 'div';
  const slot = photo ? /*#__PURE__*/React.createElement("image-slot", {
    ref: slotRef,
    id: art.slot,
    shape: "rect",
    fit: "cover",
    placeholder: " "
  }) : null;
  const row = /*#__PURE__*/React.createElement(Tag, {
    type: onClick ? 'button' : undefined,
    onClick: onClick,
    style: {
      display: 'flex',
      alignItems: photo || mode === 'icon' ? 'center' : 'flex-start',
      gap: 14,
      width: '100%',
      textAlign: 'left',
      padding: 'var(--l-row-py, 14px) 0',
      minHeight: photo ? 78 : undefined,
      borderTop: '1px solid var(--separator)',
      background: 'none',
      border: 'none',
      borderTopWidth: 1,
      borderTopStyle: 'solid',
      borderTopColor: 'var(--separator)',
      color: 'inherit',
      font: 'inherit',
      cursor: onClick ? 'pointer' : 'default',
      position: 'relative',
      opacity: dim ? 0.45 : 1,
      fontFamily: 'var(--font-ui)'
    }
  }, accent && /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'absolute',
      left: -20,
      top: 0,
      bottom: 0,
      width: 3,
      background: 'var(--accent)',
      zIndex: 3
    }
  }), photo && (filled ? /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("span", {
    "aria-hidden": "true",
    style: {
      position: 'absolute',
      top: 1,
      bottom: 0,
      left: 0,
      right: -20,
      overflow: 'hidden',
      zIndex: 0
    }
  }, slot), /*#__PURE__*/React.createElement("span", {
    "aria-hidden": "true",
    style: {
      position: 'absolute',
      top: 1,
      bottom: 0,
      left: -20,
      right: -20,
      zIndex: 1,
      pointerEvents: 'none',
      background: 'linear-gradient(90deg, var(--bg-page) 0%, color-mix(in oklab, var(--bg-page) 88%, transparent) 46%, color-mix(in oklab, var(--bg-page) 58%, transparent) 100%)'
    }
  })) : /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'absolute',
      top: 1,
      bottom: 0,
      right: -20,
      width: 152,
      overflow: 'hidden',
      zIndex: 0
    }
  }, slot)), mode === 'icon' || photo ? /*#__PURE__*/React.createElement(ArtTile, {
    icon: art.icon
  }) : /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      flex: '0 0 var(--l-gutter, 32px)',
      fontSize: 15,
      fontWeight: 'var(--weight-bold)',
      color: gutterAccent ? 'var(--accent-text)' : 'var(--text-tertiary)',
      paddingTop: 2
    }
  }, gutter), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0,
      position: 'relative',
      zIndex: 2,
      marginRight: photo && !filled ? 148 : 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      fontSize: 'var(--l-title, var(--text-body))',
      fontWeight: 'var(--weight-semibold)',
      textWrap: 'pretty'
    }
  }, titleIcon && /*#__PURE__*/React.createElement(Icon, {
    name: titleIcon,
    size: 16,
    weight: "bold",
    color: "var(--accent-text)"
  }), title), (meta || photo && !filled && (trailing || trailingMeta)) && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)',
      marginTop: 'var(--l-meta-gap, 3px)'
    }
  }, photo && !filled && (trailing || trailingMeta) ? [trailing, trailingMeta, meta].filter(Boolean).join(' · ') : meta), children), (trailing || trailingMeta) && !(photo && !filled) && /*#__PURE__*/React.createElement("span", {
    style: {
      flex: '0 0 auto',
      textAlign: 'right',
      paddingTop: 1,
      position: 'relative',
      zIndex: 2,
      ...(bed ? {
        padding: '4px 8px',
        marginRight: -4,
        borderRadius: 8,
        background: 'color-mix(in oklab, var(--bg-page) 78%, transparent)',
        WebkitBackdropFilter: 'blur(10px)',
        backdropFilter: 'blur(10px)'
      } : null)
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      display: 'block',
      fontSize: 'var(--text-subheadline)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, trailing), trailingMeta && /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      display: 'block',
      fontSize: 'var(--text-caption)',
      color: 'var(--text-tertiary)',
      marginTop: 3
    }
  }, trailingMeta)), chevron && /*#__PURE__*/React.createElement(Icon, {
    name: "caret-right",
    size: 14,
    weight: "bold",
    color: "var(--text-tertiary)",
    style: {
      marginTop: 4,
      position: 'relative',
      zIndex: 2
    }
  }));
  return photo ? /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      overflow: 'hidden'
    }
  }, row) : row;
}

/** Conclusion first: the value, its label, then the sentence that interprets it. */
function Readout({
  value,
  unit,
  label,
  note,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '10px 0 4px',
      ...style
    }
  }, /*#__PURE__*/React.createElement(Eyebrow, {
    style: {
      color: 'var(--text-secondary)'
    }
  }, label), /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 6,
      marginTop: 10
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 64,
      fontWeight: 'var(--weight-bold)',
      lineHeight: 0.9,
      letterSpacing: '-0.03em'
    }
  }, value), unit && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 22,
      fontWeight: 'var(--weight-bold)',
      color: 'var(--text-secondary)'
    }
  }, unit)), note && /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-subheadline)',
      color: 'var(--text-secondary)',
      marginTop: 12,
      maxWidth: 300,
      textWrap: 'pretty'
    }
  }, note));
}

/** Flat 4px bar on the yellow ladder. Never a ring. */
function Bar({
  pct,
  color = 'var(--accent)',
  style
}) {
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      height: 4,
      background: 'var(--surface-raised)',
      borderRadius: 2,
      overflow: 'hidden',
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      height: '100%',
      width: `${Math.max(2, Math.min(100, pct))}%`,
      background: color
    }
  }));
}

/** Trailing row that opens the exercise picker. Plus sits in the gutter. */
function AddRow({
  onClick,
  label = 'Add exercise'
}) {
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onClick,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 14,
      width: '100%',
      padding: '16px 0',
      borderTop: '1px solid var(--separator)',
      background: 'none',
      border: 'none',
      borderTopWidth: 1,
      borderTopStyle: 'solid',
      borderTopColor: 'var(--separator)',
      cursor: 'pointer',
      color: 'var(--accent-text)',
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--text-body)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: '0 0 var(--l-gutter, 32px)',
      display: 'flex'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "plus",
    size: 16,
    weight: "bold"
  })), label);
}

/** Screen title line that sits above a slab or a readout. */
function LedgerHead({
  title,
  right
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: '0 0 auto',
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '0 20px 14px'
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "bf-display",
    style: {
      flex: 1,
      fontSize: 26
    }
  }, title), right);
}

/** Neutral page header for ACTION screens — unless the `accent` tweak is bold, in which
    case it takes the full yellow field and the docked action goes quiet. */
function HeaderBlock({
  eyebrow,
  title,
  spec,
  children,
  style
}) {
  const {
    accent
  } = useBFT();
  const yellow = accent === 'bold';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '4px 20px 20px',
      background: yellow ? 'var(--bf-yellow)' : 'transparent',
      color: yellow ? 'var(--bf-black)' : 'var(--text-primary)',
      borderBottom: yellow ? 'none' : '1px solid var(--separator)',
      ...style
    }
  }, eyebrow && /*#__PURE__*/React.createElement(Eyebrow, {
    style: {
      color: yellow ? 'inherit' : 'var(--accent-text)',
      opacity: yellow ? 0.62 : 1
    }
  }, eyebrow), title && /*#__PURE__*/React.createElement("h1", {
    className: "bf-display",
    style: {
      margin: '10px 0 0',
      fontSize: 44,
      lineHeight: 0.94
    }
  }, title), spec && /*#__PURE__*/React.createElement(SpecStrip, {
    items: spec,
    style: {
      marginTop: 14
    }
  }), children);
}

/** Floating glass dock — or an opaque tray when the `chrome` tweak is solid. */
function GlassDock({
  children,
  lift = 88,
  style
}) {
  const {
    chrome
  } = useBFT();
  const solid = chrome === 'solid';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: solid ? 0 : 12,
      right: solid ? 0 : 12,
      bottom: solid ? lift > 40 ? 74 : 0 : lift,
      zIndex: 35,
      background: solid ? 'var(--bg-elevated)' : 'var(--glass-fill-strong)',
      WebkitBackdropFilter: solid ? 'none' : 'var(--glass-blur)',
      backdropFilter: solid ? 'none' : 'var(--glass-blur)',
      border: solid ? 'none' : '1px solid var(--glass-border)',
      borderTop: solid ? '1px solid var(--border)' : undefined,
      borderRadius: solid ? 0 : 34,
      boxShadow: solid ? 'none' : 'var(--glass-shadow), inset 0 1px 0 rgba(255,255,255,.16)',
      padding: solid ? '12px 16px' : 10,
      display: 'flex',
      gap: 8,
      alignItems: 'center',
      ...style
    }
  }, children);
}

/** The docked primary action. Wears the yellow unless the `accent` tweak has spent it
    on a full-bleed header instead — exactly one yellow fill per screen, always. */
function PrimaryAction({
  icon,
  children,
  onClick,
  style
}) {
  const {
    accent
  } = useBFT();
  const quiet = accent === 'bold';
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onClick,
    style: {
      flex: 1,
      height: 'var(--control-lg)',
      cursor: 'pointer',
      border: quiet ? '1px solid var(--glass-border)' : 'none',
      background: quiet ? 'var(--glass-highlight)' : 'var(--accent)',
      color: quiet ? 'var(--text-primary)' : 'var(--text-on-accent)',
      borderRadius: 'var(--radius-pill)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 9,
      boxShadow: quiet ? 'inset 0 1px 0 rgba(255,255,255,.14)' : 'none',
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--text-headline)',
      fontWeight: 'var(--weight-semibold)',
      ...style
    }
  }, icon && /*#__PURE__*/React.createElement(Icon, {
    name: icon,
    size: 17
  }), children);
}

/** Square glass companion button beside the primary action. */
function DockButton({
  icon,
  label,
  onClick
}) {
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onClick,
    "aria-label": label,
    title: label,
    style: {
      width: 'var(--control-lg)',
      height: 'var(--control-lg)',
      flex: '0 0 var(--control-lg)',
      cursor: 'pointer',
      borderRadius: 'var(--radius-pill)',
      boxShadow: 'inset 0 1px 0 rgba(255,255,255,.14)',
      background: 'var(--glass-highlight)',
      border: '1px solid var(--glass-border)',
      color: 'var(--text-primary)',
      display: 'grid',
      placeItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: icon,
    size: 19,
    weight: "bold"
  }));
}

/** Horizontal quick-action strip. Small, glassy, always one tap from the list. */
function QuickActions({
  items,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      overflowX: 'auto',
      scrollbarWidth: 'none',
      msOverflowStyle: 'none',
      padding: '0 20px',
      ...style
    }
  }, items.map(it => /*#__PURE__*/React.createElement("button", {
    key: it.label,
    type: "button",
    onClick: it.onClick,
    style: {
      flex: '0 0 auto',
      display: 'inline-flex',
      alignItems: 'center',
      gap: 7,
      height: 'var(--tap-min)',
      padding: '0 16px',
      borderRadius: 'var(--radius-pill)',
      cursor: 'pointer',
      background: 'var(--glass-fill)',
      WebkitBackdropFilter: 'var(--glass-blur)',
      backdropFilter: 'var(--glass-blur)',
      border: '1px solid var(--glass-border)',
      color: 'var(--text-primary)',
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--text-footnote)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: it.icon,
    size: 15,
    weight: "bold",
    color: "var(--accent-text)"
  }), it.label)));
}

/** Swipe a ledger row either way to reveal actions. Drag, or tap the row's
    trailing handle. `left`/`right` are the edges the actions sit on. */
function SwipeRow({
  left = [],
  right = [],
  accent,
  children
}) {
  const W = 84;
  const [x, setX] = React.useState(0);
  const drag = React.useRef(null);
  const openL = left.length * W,
    openR = right.length * W;
  const down = e => {
    drag.current = {
      start: e.clientX,
      from: x
    };
    e.currentTarget.setPointerCapture(e.pointerId);
  };
  const move = e => {
    if (!drag.current) return;
    const next = drag.current.from + (e.clientX - drag.current.start);
    setX(Math.max(-openR, Math.min(openL, next)));
  };
  const up = () => {
    if (!drag.current) return;
    drag.current = null;
    setX(v => v <= -openR / 2 ? -openR : v >= openL / 2 ? openL : 0);
  };
  const Face = ({
    actions,
    side
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      top: 0,
      bottom: 0,
      [side]: 0,
      display: 'flex'
    }
  }, actions.map(a => /*#__PURE__*/React.createElement("button", {
    key: a.label,
    type: "button",
    onClick: () => {
      setX(0);
      a.onClick && a.onClick();
    },
    style: {
      width: W,
      cursor: 'pointer',
      border: 'none',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 5,
      background: a.destructive ? 'var(--text-primary)' : 'var(--glass-fill-strong)',
      WebkitBackdropFilter: 'var(--glass-blur)',
      backdropFilter: 'var(--glass-blur)',
      color: a.destructive ? 'var(--bg-page)' : 'var(--text-primary)',
      fontFamily: 'var(--font-ui)',
      fontSize: 11,
      fontWeight: 'var(--weight-bold)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: a.icon,
    size: 18,
    weight: "bold"
  }), a.label)));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      overflow: 'hidden',
      touchAction: 'pan-y',
      margin: '0 -20px'
    }
  }, !!openL && /*#__PURE__*/React.createElement(Face, {
    actions: left,
    side: "left"
  }), !!openR && /*#__PURE__*/React.createElement(Face, {
    actions: right,
    side: "right"
  }), /*#__PURE__*/React.createElement("div", {
    onPointerDown: down,
    onPointerMove: move,
    onPointerUp: up,
    onPointerCancel: up,
    style: {
      transform: `translateX(${x}px)`,
      transition: drag.current ? 'none' : 'transform var(--dur-fast) var(--ease-snappy)',
      background: 'var(--bg-page)',
      cursor: 'grab',
      position: 'relative',
      padding: '0 20px'
    }
  }, accent && /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'absolute',
      left: 0,
      top: 0,
      bottom: 0,
      width: 3,
      background: 'var(--accent)'
    }
  }), children));
}
Object.assign(window, {
  StatusBar,
  TabBar,
  NavBar,
  Phone,
  Scroll,
  ScreenBoundary,
  dsPick,
  BFTABS: TABS,
  Eyebrow,
  Slab,
  SlabAction,
  SpecStrip,
  SectionRule,
  LedgerRow,
  ArtTile,
  Readout,
  Bar,
  AddRow,
  LedgerHead,
  HeaderBlock,
  GlassDock,
  PrimaryAction,
  DockButton,
  QuickActions,
  SwipeRow,
  useBFT,
  BFT_DEFAULT
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/AppShell.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/BodyScreen.jsx
try { (() => {
const {
  Icon
} = dsPick(['Icon']);
const D = window.BFData;
const WORD = {
  recovered: 'Recovered',
  fresh: 'Ready',
  fatigued: 'Fatigued',
  sore: 'Sore'
};
const TONE = {
  recovered: 'var(--recovery-recovered)',
  fresh: 'var(--recovery-fresh)',
  fatigued: 'var(--recovery-fatigued)',
  sore: 'var(--recovery-sore)'
};
const LAST = {
  Chest: '1 day ago',
  Back: '4 days ago',
  Shoulders: '2 days ago',
  Arms: '3 days ago',
  Core: '5 days ago',
  Legs: '3 days ago'
};
const REGION_ICON = {
  Chest: 'arrows-in-line-horizontal',
  Back: 'arrow-fat-line-down',
  Shoulders: 'arrows-out-line-horizontal',
  Arms: 'barbell',
  Core: 'circle-half-tilt',
  Legs: 'person-simple-run'
};

/** Recovery reads as a ruled bar chart: one row per group, bars on a shared left axis. */
function RecoveryRow({
  r
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '13px 0',
      borderTop: '1px solid var(--separator)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: '0 0 var(--l-gutter, 32px)',
      display: 'flex',
      color: TONE[r.status]
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: REGION_ICON[r.region] || 'barbell',
    size: 19
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: 'var(--l-title, var(--text-body))',
      fontWeight: 'var(--weight-semibold)'
    }
  }, r.region), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)'
    }
  }, WORD[r.status]), /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      flex: '0 0 42px',
      textAlign: 'right',
      fontSize: 'var(--text-subheadline)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, r.percent, "%")), /*#__PURE__*/React.createElement(Bar, {
    pct: r.percent,
    color: TONE[r.status],
    style: {
      marginTop: 10,
      marginLeft: 'calc(var(--l-gutter, 32px) + 12px)'
    }
  }));
}
function BodyScreen() {
  const regions = [...D.recovery.regions].sort((a, b) => b.percent - a.percent);
  const ready = regions.filter(r => r.percent >= 75);
  const sore = regions.filter(r => r.percent < 50);
  const list = xs => xs.length < 2 ? xs.join('') : `${xs.slice(0, -1).join(', ')} and ${xs[xs.length - 1]}`;
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(LedgerHead, {
    title: "Body",
    right: /*#__PURE__*/React.createElement("button", {
      type: "button",
      "aria-label": "Recovery help",
      style: {
        background: 'none',
        border: 'none',
        cursor: 'pointer',
        color: 'var(--text-secondary)',
        width: 44,
        height: 44,
        display: 'grid',
        placeItems: 'center'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "question",
      size: 20,
      weight: "bold"
    }))
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      overflowX: 'hidden',
      scrollbarWidth: 'none',
      msOverflowStyle: 'none',
      padding: '0 20px 110px'
    }
  }, /*#__PURE__*/React.createElement(Readout, {
    label: "Overall recovery",
    value: D.recovery.overall,
    unit: "%",
    note: `${list(ready.map(r => r.region))} are ready to train.${sore.length ? ` ${sore[0].region} needs another day.` : ''}`
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      marginTop: 20
    }
  }, regions.map(r => /*#__PURE__*/React.createElement("span", {
    key: r.region,
    style: {
      flex: 1,
      height: 6,
      background: TONE[r.status],
      borderRadius: 1
    },
    title: r.region
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      marginTop: 8,
      fontSize: 10,
      color: 'var(--text-tertiary)',
      textTransform: 'uppercase',
      letterSpacing: '0.1em',
      fontWeight: 'var(--weight-semibold)'
    }
  }, /*#__PURE__*/React.createElement("span", null, "Most recovered"), /*#__PURE__*/React.createElement("span", null, "Least")), /*#__PURE__*/React.createElement(SectionRule, {
    label: "By muscle group",
    trailing: `${regions.length} tracked`
  }), regions.map(r => /*#__PURE__*/React.createElement(RecoveryRow, {
    key: r.region,
    r: r
  })), /*#__PURE__*/React.createElement(SectionRule, {
    label: "Last trained"
  }), regions.map(r => /*#__PURE__*/React.createElement(LedgerRow, {
    key: r.region,
    gutter: /*#__PURE__*/React.createElement(Icon, {
      name: REGION_ICON[r.region] || 'barbell',
      size: 17
    }),
    title: r.region,
    trailing: LAST[r.region] || '—'
  })), /*#__PURE__*/React.createElement(SectionRule, {
    label: "How this is measured"
  }), /*#__PURE__*/React.createElement("p", {
    style: {
      margin: 0,
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)',
      lineHeight: 1.5,
      textWrap: 'pretty'
    }
  }, "Recovery combines the volume you lifted per muscle group, how long ago you trained it, and the sets you reported as hard. It is an estimate, not a diagnosis \u2014 train by how you feel.")));
}
Object.assign(window, {
  BodyScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/BodyScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/LogScreen.jsx
try { (() => {
const {
  Icon,
  ContributionHeatmap
} = dsPick(['Icon', 'ContributionHeatmap']);
const D = window.BFData;
const GROUP_ICON = {
  Chest: 'arrows-in-line-horizontal',
  Back: 'arrow-fat-line-down',
  Shoulders: 'arrows-out-line-horizontal',
  Arms: 'barbell',
  Core: 'circle-half-tilt',
  Legs: 'person-simple-run',
  Cardio: 'heartbeat'
};
const JULY = [{
  date: 26,
  name: 'Pull B',
  meta: 'Planned · today',
  today: true,
  groups: [['Back', 2], ['Arms', 3], ['Shoulders', 2]]
}, {
  date: 25,
  name: 'Push A',
  meta: '48 min · 8 exercises',
  volume: '16.2k',
  groups: [['Chest', 3], ['Shoulders', 3], ['Arms', 2]]
}, {
  date: 24,
  name: 'Legs A',
  meta: '52 min · 9 exercises',
  volume: '18.4k',
  groups: [['Legs', 6], ['Core', 3]]
}, {
  date: 23,
  name: 'Rest',
  rest: true
}, {
  date: 22,
  name: 'Push A',
  meta: '46 min · 7 exercises',
  volume: '15.1k',
  groups: [['Chest', 4], ['Shoulders', 3]]
}, {
  date: 20,
  name: 'Pull A',
  meta: '41 min · 7 exercises',
  volume: '14.2k',
  groups: [['Back', 4], ['Arms', 3]]
}, {
  date: 19,
  name: 'Conditioning',
  meta: '28 min · intervals',
  groups: [['Cardio', 4], ['Core', 2]]
}, {
  date: 17,
  name: 'Legs B',
  meta: '55 min · 8 exercises',
  volume: '19.8k',
  groups: [['Legs', 5], ['Core', 3]]
}, {
  date: 16,
  name: 'Rest',
  rest: true
}, {
  date: 15,
  name: 'Push B',
  meta: '44 min · 7 exercises',
  volume: '13.9k',
  groups: [['Chest', 4], ['Arms', 3]]
}];

/** Stacked horizontal badges: one per muscle group trained, overlapping, with its count. */
function GroupBadges({
  groups
}) {
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      marginTop: 8
    }
  }, groups.map(([g, n], i) => /*#__PURE__*/React.createElement("span", {
    key: g,
    title: `${g} · ${n} exercises`,
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 4,
      height: 26,
      padding: '0 9px 0 7px',
      borderRadius: 'var(--radius-pill)',
      background: 'var(--surface-raised)',
      border: '1px solid var(--bg-page)',
      color: 'var(--text-secondary)',
      marginLeft: i ? -8 : 0,
      zIndex: groups.length - i,
      position: 'relative'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: GROUP_ICON[g] || 'barbell',
    size: 13,
    weight: "bold",
    color: "var(--accent-text)"
  }), /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      fontSize: 11,
      fontWeight: 'var(--weight-bold)'
    }
  }, n))));
}

/** One day in the ledger. `streakUp`/`streakDown` draw the hot-streak line through
    the gutter, joining consecutive training days into a single unbroken run. */
function DayRow({
  s,
  streakUp,
  streakDown,
  onClick
}) {
  const hot = streakUp || streakDown;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative'
    }
  }, hot && /*#__PURE__*/React.createElement("span", {
    "aria-hidden": "true",
    style: {
      position: 'absolute',
      left: 15,
      top: streakUp ? 0 : '50%',
      bottom: streakDown ? 0 : '50%',
      width: 2,
      background: 'var(--accent)',
      zIndex: 0
    }
  }), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onClick,
    disabled: !onClick,
    style: {
      display: 'flex',
      alignItems: 'flex-start',
      gap: 14,
      width: '100%',
      textAlign: 'left',
      padding: 'var(--l-row-py, 14px) 0',
      borderTop: '1px solid var(--separator)',
      background: 'none',
      border: 'none',
      borderTopWidth: 1,
      borderTopStyle: 'solid',
      borderTopColor: 'var(--separator)',
      color: 'inherit',
      font: 'inherit',
      fontFamily: 'var(--font-ui)',
      cursor: onClick ? 'pointer' : 'default',
      opacity: s.rest ? 0.45 : 1,
      position: 'relative'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: '0 0 var(--l-gutter, 32px)',
      display: 'flex',
      justifyContent: 'flex-start',
      position: 'relative',
      zIndex: 1
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      width: 32,
      height: 32,
      marginLeft: -1,
      borderRadius: 'var(--radius-pill)',
      display: 'grid',
      placeItems: 'center',
      fontSize: 14,
      fontWeight: 'var(--weight-bold)',
      background: hot ? 'var(--accent)' : 'transparent',
      color: hot ? 'var(--text-on-accent)' : s.today ? 'var(--accent-text)' : 'var(--text-tertiary)'
    }
  }, s.date)), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: 'var(--l-title, var(--text-body))',
      fontWeight: 'var(--weight-semibold)'
    }
  }, s.name), s.volume && /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      fontSize: 'var(--text-subheadline)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, s.volume, /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--text-tertiary)',
      fontSize: 'var(--text-caption)'
    }
  }, "\xA0kg"))), s.meta && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)',
      marginTop: 'var(--l-meta-gap, 3px)'
    }
  }, s.meta), s.groups && /*#__PURE__*/React.createElement(GroupBadges, {
    groups: s.groups
  }))));
}
function LogScreen({
  onOpenSummary,
  onAddExercise
}) {
  const trained = i => JULY[i] && !JULY[i].rest;
  const joined = (a, b) => trained(a) && trained(b) && JULY[a].date - JULY[b].date === 1;
  const runs = JULY.filter(s => !s.rest).length;
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(LedgerHead, {
    title: "Log",
    right: /*#__PURE__*/React.createElement("button", {
      type: "button",
      "aria-label": "Jump to date",
      style: {
        background: 'none',
        border: 'none',
        cursor: 'pointer',
        color: 'var(--text-secondary)',
        width: 44,
        height: 44,
        display: 'grid',
        placeItems: 'center'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "calendar-blank",
      size: 20,
      weight: "bold"
    }))
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      overflowX: 'hidden',
      scrollbarWidth: 'none',
      msOverflowStyle: 'none',
      padding: '0 20px 110px'
    }
  }, /*#__PURE__*/React.createElement(Readout, {
    label: "Current streak",
    value: D.streak.current,
    unit: "days",
    note: `Three days back to back this week. Your best run is ${D.streak.best} days — keep Thursday and you match it.`
  }), /*#__PURE__*/React.createElement(SectionRule, {
    label: "Consistency",
    trailing: "26 weeks"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '4px 0 2px'
    }
  }, /*#__PURE__*/React.createElement(ContributionHeatmap, {
    values: D.heatmap,
    cell: 9,
    gap: 3
  })), /*#__PURE__*/React.createElement(SectionRule, {
    label: "July",
    trailing: `${runs} sessions · 97.6k kg`
  }), JULY.map((s, i) => /*#__PURE__*/React.createElement(DayRow, {
    key: s.date,
    s: s,
    streakUp: joined(i - 1, i),
    streakDown: joined(i, i + 1),
    onClick: !s.rest && !s.today ? onOpenSummary : undefined
  })), /*#__PURE__*/React.createElement(AddRow, {
    onClick: onAddExercise,
    label: "Log a past workout"
  }), /*#__PURE__*/React.createElement(SectionRule, {
    label: "All time"
  }), /*#__PURE__*/React.createElement(LedgerRow, {
    gutter: /*#__PURE__*/React.createElement(Icon, {
      name: "barbell",
      size: 15,
      weight: "bold"
    }),
    title: "Sessions",
    trailing: "184"
  }), /*#__PURE__*/React.createElement(LedgerRow, {
    gutter: /*#__PURE__*/React.createElement(Icon, {
      name: "scales",
      size: 15,
      weight: "bold"
    }),
    title: "Volume lifted",
    trailing: "2.41M",
    trailingMeta: "kg"
  }), /*#__PURE__*/React.createElement(LedgerRow, {
    gutter: /*#__PURE__*/React.createElement(Icon, {
      name: "clock",
      size: 15,
      weight: "bold"
    }),
    title: "Time training",
    trailing: "142",
    trailingMeta: "hours"
  })));
}
Object.assign(window, {
  LogScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/LogScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/MyPlanScreen.jsx
try { (() => {
const {
  Icon
} = dsPick(['Icon']);
const PLAN = {
  name: 'Pull Day',
  duration: '45 min',
  gym: 'Anytime Fitness',
  muscles: 3,
  rows: [{
    name: 'Lat pulldown',
    sets: 3,
    reps: 8,
    load: '50 kg',
    focus: true,
    region: 'Lats'
  }, {
    name: 'Cable row',
    sets: 4,
    reps: 8,
    load: '64 kg',
    region: 'Lats'
  }, {
    name: 'Barbell curl',
    sets: 4,
    reps: 8,
    load: '30 kg',
    region: 'Biceps'
  }, {
    name: 'Hammer curls',
    sets: 3,
    reps: 12,
    load: '15 kg',
    region: 'Biceps'
  }, {
    name: 'Face pull',
    sets: 3,
    reps: 15,
    load: '18 kg',
    region: 'Rear delts'
  }, {
    name: 'Reverse fly',
    sets: 3,
    reps: 12,
    load: '10 kg',
    region: 'Rear delts'
  }, {
    name: 'Cable wood chop',
    sets: 3,
    reps: 15,
    load: '20 kg',
    region: 'Core'
  }]
};
const SUGGESTED = [{
  name: 'Pull Day',
  meta: 'Recommended · 45 min · back and biceps',
  why: 'Back is 96% recovered'
}, {
  name: 'Legs A',
  meta: '52 min · quads and glutes',
  why: 'Due since Thursday'
}, {
  name: 'Push B',
  meta: '44 min · chest and shoulders',
  why: 'Chest still sore',
  dim: true
}];
const FREQUENT = [{
  name: 'Pull B',
  meta: 'Done 14 times · last Tuesday'
}, {
  name: 'Push A',
  meta: 'Done 12 times · last Monday'
}, {
  name: 'Legs A',
  meta: 'Done 9 times · last Thursday'
}, {
  name: 'Conditioning',
  meta: 'Done 6 times · last Saturday'
}];
const REGION_ICON = {
  Lats: 'arrow-fat-line-down',
  Biceps: 'barbell',
  'Rear delts': 'arrows-out-line-horizontal',
  Core: 'circle-half-tilt',
  Quads: 'person-simple-run',
  Chest: 'arrows-in-line-horizontal',
  Added: 'plus-circle'
};
const slugify = s => s.toLowerCase().replace(/[^a-z0-9]+/g, '-');
const pad = n => String(n).padStart(2, '0');

/** Segmented source switch for where the next session comes from. */
function SourceSwitch({
  value,
  onChange
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 4,
      padding: 4,
      background: 'var(--surface-raised)',
      borderRadius: 'var(--radius-pill)',
      marginTop: 4
    }
  }, [['suggested', 'Suggested'], ['frequent', 'Frequent']].map(([id, label]) => /*#__PURE__*/React.createElement("button", {
    key: id,
    type: "button",
    onClick: () => onChange(id),
    style: {
      flex: 1,
      height: 'var(--tap-min)',
      cursor: 'pointer',
      border: 'none',
      borderRadius: 'var(--radius-pill)',
      background: value === id ? 'var(--bg-page)' : 'transparent',
      color: value === id ? 'var(--text-primary)' : 'var(--text-secondary)',
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--text-footnote)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, label)));
}

/** One-tap start for a session you didn't have to go looking for. */
function QuickStart({
  onClick
}) {
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onClick,
    "aria-label": "Start this session",
    style: {
      width: 44,
      height: 44,
      flex: '0 0 44px',
      borderRadius: 'var(--radius-pill)',
      cursor: 'pointer',
      background: 'var(--surface-raised)',
      border: '1px solid var(--border)',
      color: 'var(--accent-text)',
      display: 'grid',
      placeItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "play",
    size: 15
  }));
}
function MyPlanScreen({
  onStart,
  onAddExercise,
  added = []
}) {
  const base = PLAN.rows.map(r => r.name);
  const initial = [...PLAN.rows, ...added.filter(n => !base.includes(n)).map(name => ({
    name,
    sets: 3,
    reps: 10,
    load: '—',
    region: 'Added'
  }))];
  const [rows, setRows] = React.useState(initial);
  const [source, setSource] = React.useState('suggested');
  React.useEffect(() => {
    setRows(cur => {
      const have = cur.map(r => r.name);
      const extra = added.filter(n => !have.includes(n)).map(name => ({
        name,
        sets: 3,
        reps: 10,
        load: '—',
        region: 'Added'
      }));
      return extra.length ? [...cur, ...extra] : cur;
    });
  }, [added.length]);
  const remove = name => setRows(cur => cur.filter(r => r.name !== name));
  const toTop = name => setRows(cur => {
    const i = cur.findIndex(r => r.name === name);
    if (i < 1) return cur;
    const c = [...cur];
    const [it] = c.splice(i, 1);
    return [it, ...c];
  });
  const mark = (name, key) => setRows(cur => cur.map(r => r.name === name ? {
    ...r,
    [key]: !r[key]
  } : r));
  const list = source === 'suggested' ? SUGGESTED : FREQUENT;
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(LedgerHead, {
    title: "Plan",
    right: /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("span", {
      className: "bf-num",
      style: {
        fontSize: 'var(--text-footnote)',
        color: 'var(--text-secondary)'
      }
    }, "Tue 26 Jul"), /*#__PURE__*/React.createElement("span", {
      style: {
        width: 34,
        height: 34,
        borderRadius: 'var(--radius-pill)',
        background: 'var(--surface-raised)',
        border: '1px solid var(--border)',
        display: 'grid',
        placeItems: 'center',
        fontSize: 12,
        fontWeight: 'var(--weight-bold)'
      }
    }, "JH"))
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      overflowX: 'hidden',
      scrollbarWidth: 'none',
      msOverflowStyle: 'none'
    }
  }, /*#__PURE__*/React.createElement(HeaderBlock, {
    eyebrow: "Today \xB7 Pull",
    title: PLAN.name,
    spec: [{
      value: rows.length,
      label: 'Exercises'
    }, {
      value: PLAN.duration.replace(' min', "'"),
      label: 'Planned'
    }, {
      value: PLAN.muscles,
      label: 'Muscles'
    }]
  }), /*#__PURE__*/React.createElement(QuickActions, {
    style: {
      padding: '14px 20px 4px'
    },
    items: [{
      icon: 'arrows-left-right',
      label: 'Swap session',
      onClick: () => {}
    }, {
      icon: 'pencil-simple',
      label: 'Edit',
      onClick: () => {}
    }, {
      icon: 'arrow-counter-clockwise',
      label: 'Repeat last',
      onClick: () => {}
    }, {
      icon: 'clock',
      label: 'Trim to 30 min',
      onClick: () => {}
    }, {
      icon: 'barbell',
      label: PLAN.gym,
      onClick: () => {}
    }]
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '0 20px 200px'
    }
  }, /*#__PURE__*/React.createElement(SectionRule, {
    label: "The work",
    trailing: "Swipe a row"
  }), rows.map((r, i) => /*#__PURE__*/React.createElement(SwipeRow, {
    key: `${r.name}-${i}`,
    accent: r.focus,
    left: [{
      icon: 'arrow-line-up',
      label: 'To top',
      onClick: () => toTop(r.name)
    }, {
      icon: 'link-simple',
      label: 'Superset',
      onClick: () => mark(r.name, 'superset')
    }],
    right: [{
      icon: 'arrows-clockwise',
      label: 'Replace',
      onClick: () => mark(r.name, 'replacing')
    }, {
      icon: 'trash',
      label: 'Remove',
      destructive: true,
      onClick: () => remove(r.name)
    }]
  }, /*#__PURE__*/React.createElement(LedgerRow, {
    gutter: pad(i + 1),
    gutterAccent: r.focus,
    art: {
      icon: REGION_ICON[r.region] || 'barbell',
      slot: `plan-${slugify(r.name)}`,
      label: r.name
    },
    title: r.name,
    meta: [`${pad(i + 1)}`, r.focus ? 'Focus exercise' : null, r.superset ? 'Superset' : null, r.replacing ? 'Choosing a replacement' : null, r.region].filter(Boolean).join(' · '),
    trailing: `${r.sets}×${r.reps}`,
    trailingMeta: r.load
  }))), /*#__PURE__*/React.createElement(AddRow, {
    onClick: onAddExercise
  }), /*#__PURE__*/React.createElement(SectionRule, {
    label: "Start something else",
    trailing: source === 'suggested' ? 'Based on recovery' : 'Most used'
  }), /*#__PURE__*/React.createElement(SourceSwitch, {
    value: source,
    onChange: setSource
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 8
    }
  }, list.map(s => /*#__PURE__*/React.createElement(LedgerRow, {
    key: s.name,
    gutter: /*#__PURE__*/React.createElement(Icon, {
      name: "barbell",
      size: 15,
      weight: "bold"
    }),
    art: {
      icon: 'barbell',
      slot: `session-${slugify(s.name)}`,
      label: s.name
    },
    title: s.name,
    meta: s.meta,
    dim: s.dim,
    trailing: /*#__PURE__*/React.createElement(QuickStart, {
      onClick: onStart
    })
  }))))), /*#__PURE__*/React.createElement(GlassDock, {
    lift: 88
  }, /*#__PURE__*/React.createElement(PrimaryAction, {
    icon: "play",
    onClick: onStart
  }, "Start workout"), /*#__PURE__*/React.createElement(DockButton, {
    icon: "pencil-simple",
    label: "Edit this session"
  }), /*#__PURE__*/React.createElement(DockButton, {
    icon: "plus",
    label: "Add exercise",
    onClick: onAddExercise
  })));
}
Object.assign(window, {
  MyPlanScreen,
  BF_PLAN_EXERCISES: PLAN.rows.map(r => r.name)
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/MyPlanScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/ProfileScreen.jsx
try { (() => {
const {
  Card,
  SectionHeader,
  Divider,
  Icon,
  StatTile,
  ContributionHeatmap,
  MetricPill,
  ListRow,
  Button,
  IconButton,
  Logo
} = window.BetterFitDesignSystem_6a70ea;
function ProfileScreen({
  onSettings
}) {
  const d = window.BFData;
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(NavBar, {
    title: "Me",
    trailing: /*#__PURE__*/React.createElement(IconButton, {
      icon: "gear-six",
      label: "Settings",
      size: 44,
      variant: "quiet",
      onClick: onSettings
    })
  }), /*#__PURE__*/React.createElement(Scroll, null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 20
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 14
    }
  }, /*#__PURE__*/React.createElement(Logo, {
    variant: "combo",
    height: 58,
    assetBase: "../../assets",
    style: {
      borderRadius: 16
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "bf-display",
    style: {
      fontSize: 'var(--text-title-2)'
    }
  }, d.user.name), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)'
    }
  }, d.user.since)), /*#__PURE__*/React.createElement(MetricPill, {
    label: d.user.plan,
    tone: "accent",
    icon: "star"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: 'repeat(3,1fr)',
      gap: 10
    }
  }, /*#__PURE__*/React.createElement(StatTile, {
    icon: "fire-simple",
    value: d.streak.current,
    label: "Day streak"
  }), /*#__PURE__*/React.createElement(StatTile, {
    icon: "barbell",
    value: "41k",
    label: "Volume (lb)"
  }), /*#__PURE__*/React.createElement(StatTile, {
    icon: "heartbeat",
    value: d.recovery.overall + '%',
    label: "Recovery"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(SectionHeader, {
    title: "Weekly targets",
    action: /*#__PURE__*/React.createElement(Button, {
      variant: "ghost",
      size: "sm",
      fullWidth: false
    }, "Edit")
  }), /*#__PURE__*/React.createElement(Card, null, d.targets.map((t, i) => /*#__PURE__*/React.createElement("div", {
    key: t.label,
    style: {
      marginTop: i ? 14 : 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--text-subheadline)'
    }
  }, t.label), /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      fontSize: 'var(--text-subheadline)',
      fontWeight: 600,
      whiteSpace: 'nowrap'
    }
  }, t.value, /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--text-tertiary)',
      fontWeight: 400
    }
  }, "\xA0/\xA0", t.target, t.unit))), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 6,
      borderRadius: 3,
      background: 'var(--surface-raised)',
      marginTop: 8,
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: Math.min(100, t.value / t.target * 100) + '%',
      height: '100%',
      background: 'var(--accent)'
    }
  })))))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(SectionHeader, {
    title: "Personal records",
    action: /*#__PURE__*/React.createElement(Button, {
      variant: "ghost",
      size: "sm",
      fullWidth: false
    }, "View all")
  }), /*#__PURE__*/React.createElement(Card, {
    padding: 12
  }, d.prs.map((p, i) => /*#__PURE__*/React.createElement("div", {
    key: p.name
  }, i > 0 && /*#__PURE__*/React.createElement(Divider, {
    inset: 56
  }), /*#__PURE__*/React.createElement(ListRow, {
    icon: "trophy",
    title: p.name,
    subtitle: p.when,
    iconTint: "var(--accent-text)",
    trailing: /*#__PURE__*/React.createElement("span", {
      className: "bf-num",
      style: {
        fontSize: 'var(--text-subheadline)',
        fontWeight: 600
      }
    }, p.value)
  }))))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(SectionHeader, {
    title: "Achievements",
    action: /*#__PURE__*/React.createElement("span", {
      className: "bf-num",
      style: {
        fontSize: 'var(--text-caption)',
        color: 'var(--text-tertiary)'
      }
    }, "2/4")
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 10
    }
  }, d.achievements.map(a => /*#__PURE__*/React.createElement(Card, {
    key: a.title,
    padding: 14,
    style: {
      opacity: a.done ? 1 : 0.45
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: a.icon,
    size: 20,
    color: a.done ? 'var(--accent-text)' : 'var(--text-tertiary)'
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-footnote)',
      fontWeight: 600,
      marginTop: 8
    }
  }, a.title), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-caption)',
      color: 'var(--text-secondary)',
      marginTop: 2
    }
  }, a.done ? 'Earned' : 'Locked'))))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(SectionHeader, {
    title: "Your year"
  }), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(ContributionHeatmap, {
    values: d.heatmap,
    weeks: 22,
    cell: 9,
    gap: 3
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)',
      marginTop: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      color: 'var(--text-primary)',
      fontWeight: 600
    }
  }, "112"), " workouts logged. Twelve weeks unbroken."))))));
}
Object.assign(window, {
  ProfileScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/ProfileScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/SearchScreen.jsx
try { (() => {
const {
  Card,
  Divider,
  Chip,
  Icon,
  ListRow,
  EmptyState,
  Button
} = window.BetterFitDesignSystem_6a70ea;
function SearchScreen() {
  const d = window.BFData;
  const [q, setQ] = React.useState('');
  const results = d.searchResults.filter(r => r.title.toLowerCase().includes(q.toLowerCase()));
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(NavBar, {
    title: "Search"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: '0 0 auto',
      padding: '0 20px 12px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      background: 'var(--surface-raised)',
      border: '1px solid var(--border)',
      borderRadius: 'var(--radius-md)',
      padding: '0 12px',
      height: 44
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "magnifying-glass",
    size: 16,
    color: "var(--text-tertiary)"
  }), /*#__PURE__*/React.createElement("input", {
    value: q,
    onChange: e => setQ(e.target.value),
    placeholder: "Exercises, plans, settings",
    style: {
      flex: 1,
      alignSelf: 'stretch',
      background: 'transparent',
      border: 'none',
      outline: 'none',
      color: 'var(--text-primary)',
      fontSize: 'var(--text-body)',
      fontFamily: 'var(--font-ui)'
    }
  }), q && /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: () => setQ(''),
    "aria-label": "Clear",
    style: {
      background: 'none',
      border: 'none',
      cursor: 'pointer',
      color: 'var(--text-tertiary)',
      width: 'var(--tap-min)',
      height: 'var(--tap-min)',
      display: 'grid',
      placeItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "x-circle",
    size: 16
  })))), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: '0 0 auto',
      display: 'flex',
      gap: 8,
      padding: '0 20px 16px',
      overflowX: 'auto',
      scrollbarWidth: 'none',
      msOverflowStyle: 'none'
    }
  }, /*#__PURE__*/React.createElement(Chip, {
    label: "All",
    selected: true
  }), /*#__PURE__*/React.createElement(Chip, {
    label: "Exercises",
    icon: "barbell"
  }), /*#__PURE__*/React.createElement(Chip, {
    label: "Muscles"
  }), /*#__PURE__*/React.createElement(Chip, {
    label: "Settings",
    icon: "gear-six"
  })), /*#__PURE__*/React.createElement(Scroll, null, results.length === 0 ? /*#__PURE__*/React.createElement(EmptyState, {
    icon: "magnifying-glass",
    title: `Nothing matches "${q}"`,
    message: "Try a muscle group, a piece of equipment, or a setting name.",
    action: /*#__PURE__*/React.createElement(Button, {
      size: "sm",
      fullWidth: false,
      variant: "secondary",
      onClick: () => setQ('')
    }, "Clear search")
  }) : /*#__PURE__*/React.createElement(Card, {
    padding: 12
  }, results.map((r, i) => /*#__PURE__*/React.createElement("div", {
    key: r.title
  }, i > 0 && /*#__PURE__*/React.createElement(Divider, {
    inset: 56
  }), /*#__PURE__*/React.createElement(ListRow, {
    icon: r.icon,
    title: r.title,
    subtitle: r.subtitle,
    onClick: () => {},
    trailing: /*#__PURE__*/React.createElement(Icon, {
      name: "caret-right",
      size: 13,
      weight: "bold",
      color: "var(--text-tertiary)"
    })
  }))))));
}
Object.assign(window, {
  SearchScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/SearchScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/SessionScreen.jsx
try { (() => {
const {
  Icon
} = dsPick(['Icon']);
const NS_S = window.BetterFitDesignSystem_6a70ea || {};
const RestBar = NS_S.RestTimerBar || (() => null);
const EX = {
  index: 2,
  name: 'Cable row',
  region: 'Lats',
  load: 64,
  reps: 8,
  total: 4,
  last: {
    load: 60,
    reps: 8
  },
  pr: {
    load: 64,
    reps: 8
  }
};
const UP_NEXT = [{
  i: 3,
  name: 'Barbell curl',
  spec: '4×8 · 30 kg',
  icon: 'barbell'
}, {
  i: 4,
  name: 'Hammer curls',
  spec: '3×12 · 15 kg',
  icon: 'barbell'
}, {
  i: 5,
  name: 'Face pull',
  spec: '3×15 · 18 kg',
  icon: 'arrows-out-line-horizontal'
}, {
  i: 6,
  name: 'Reverse fly',
  spec: '3×12 · 10 kg',
  icon: 'arrows-out-line-horizontal'
}, {
  i: 7,
  name: 'Cable wood chop',
  spec: '3×15 · 20 kg',
  icon: 'circle-half-tilt'
}];
const slugify = s => s.toLowerCase().replace(/[^a-z0-9]+/g, '-');
const pad2 = n => String(n).padStart(2, '0');
const kg = n => Number.isInteger(n) ? n : n.toFixed(1);

/** Big two-button stepper. The value is the largest thing in it, and both
    buttons clear 44px so they work with a thumb between sets. */
function Stepper({
  label,
  value,
  unit,
  step,
  min = 0,
  onChange
}) {
  const bump = d => onChange(Math.max(min, Math.round((value + d * step) * 10) / 10));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 10,
      fontWeight: 'var(--weight-bold)',
      textTransform: 'uppercase',
      letterSpacing: '0.12em',
      color: 'var(--text-secondary)'
    }
  }, label), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      marginTop: 8
    }
  }, /*#__PURE__*/React.createElement("button", {
    type: "button",
    "aria-label": `Decrease ${label}`,
    onClick: () => bump(-1),
    style: {
      width: 46,
      height: 46,
      flex: '0 0 46px',
      borderRadius: 'var(--radius-md)',
      cursor: 'pointer',
      border: '1px solid var(--border-strong)',
      background: 'var(--surface-raised)',
      color: 'var(--text-primary)',
      display: 'grid',
      placeItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "minus",
    size: 16,
    weight: "bold"
  })), /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      flex: 1,
      textAlign: 'center',
      whiteSpace: 'nowrap'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 34,
      fontWeight: 'var(--weight-bold)',
      letterSpacing: '-0.02em'
    }
  }, kg(value)), unit && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 15,
      fontWeight: 'var(--weight-bold)',
      color: 'var(--text-secondary)',
      marginLeft: 3
    }
  }, unit)), /*#__PURE__*/React.createElement("button", {
    type: "button",
    "aria-label": `Increase ${label}`,
    onClick: () => bump(1),
    style: {
      width: 46,
      height: 46,
      flex: '0 0 46px',
      borderRadius: 'var(--radius-md)',
      cursor: 'pointer',
      border: '1px solid var(--border-strong)',
      background: 'var(--surface-raised)',
      color: 'var(--text-primary)',
      display: 'grid',
      placeItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "plus",
    size: 16,
    weight: "bold"
  }))));
}

/** Inline set editor: steppers, one-tap suggestions, and bulk apply. */
function SetEditor({
  set,
  index,
  count,
  onChange,
  onApplyRest,
  onApplyAll,
  onClose
}) {
  const sugg = [{
    label: `Last ${EX.last.load} × ${EX.last.reps}`,
    icon: 'arrow-counter-clockwise',
    load: EX.last.load,
    reps: EX.last.reps
  }, {
    label: '+2.5 kg',
    icon: 'trend-up',
    load: set.load + 2.5,
    reps: set.reps
  }, {
    label: '+1 rep',
    icon: 'plus',
    load: set.load,
    reps: set.reps + 1
  }, {
    label: `PR ${EX.pr.load} × ${EX.pr.reps}`,
    icon: 'medal',
    load: EX.pr.load,
    reps: EX.pr.reps
  }];
  const rest = count - index - 1;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '4px 0 18px',
      borderTop: '1px solid var(--separator)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 16,
      paddingTop: 12
    }
  }, /*#__PURE__*/React.createElement(Stepper, {
    label: "Weight",
    value: set.load,
    unit: "kg",
    step: 2.5,
    onChange: v => onChange({
      load: v
    })
  }), /*#__PURE__*/React.createElement(Stepper, {
    label: "Reps",
    value: set.reps,
    step: 1,
    min: 1,
    onChange: v => onChange({
      reps: v
    })
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      overflowX: 'auto',
      scrollbarWidth: 'none',
      msOverflowStyle: 'none',
      marginTop: 16
    }
  }, sugg.map(s => /*#__PURE__*/React.createElement("button", {
    key: s.label,
    type: "button",
    onClick: () => onChange({
      load: s.load,
      reps: s.reps
    }),
    style: {
      flex: '0 0 auto',
      display: 'inline-flex',
      alignItems: 'center',
      gap: 7,
      minHeight: 'var(--tap-min)',
      padding: '0 15px',
      borderRadius: 'var(--radius-pill)',
      cursor: 'pointer',
      background: 'var(--surface-raised)',
      border: '1px solid var(--border)',
      color: 'var(--text-primary)',
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--text-footnote)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: s.icon,
    size: 14,
    weight: "bold",
    color: "var(--accent-text)"
  }), s.label))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      marginTop: 12
    }
  }, rest > 0 && /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onApplyRest,
    style: {
      flex: 1,
      minHeight: 'var(--tap-min)',
      cursor: 'pointer',
      borderRadius: 'var(--radius-button)',
      background: 'transparent',
      border: '1px solid var(--border-strong)',
      color: 'var(--text-primary)',
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--text-footnote)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, "Apply to next ", rest), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onApplyAll,
    style: {
      flex: 1,
      minHeight: 'var(--tap-min)',
      cursor: 'pointer',
      borderRadius: 'var(--radius-button)',
      background: 'transparent',
      border: '1px solid var(--border-strong)',
      color: 'var(--text-primary)',
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--text-footnote)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, "Apply to all ", count), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onClose,
    "aria-label": "Close editor",
    style: {
      width: 'var(--tap-min)',
      flex: '0 0 var(--tap-min)',
      minHeight: 'var(--tap-min)',
      cursor: 'pointer',
      borderRadius: 'var(--radius-button)',
      background: 'transparent',
      border: '1px solid var(--border-strong)',
      color: 'var(--text-secondary)',
      display: 'grid',
      placeItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "check",
    size: 16,
    weight: "bold"
  }))));
}

/** One set as a ledger row: big mono value, tap to edit, swipe left to clear or delete. */
function SetRow({
  set,
  i,
  count,
  open,
  onOpen,
  onChange,
  onApplyRest,
  onApplyAll,
  onClear,
  onDelete
}) {
  const planned = !set.logged;
  return /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement(SwipeRow, {
    accent: set.current,
    left: [{
      icon: 'copy',
      label: 'Copy all',
      onClick: onApplyAll
    }],
    right: [...(set.logged ? [{
      icon: 'arrow-counter-clockwise',
      label: 'Clear',
      onClick: onClear
    }] : []), {
      icon: 'trash',
      label: 'Delete',
      destructive: true,
      onClick: onDelete
    }]
  }, /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onOpen,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 14,
      width: '100%',
      textAlign: 'left',
      cursor: 'pointer',
      padding: 'var(--l-row-py, 14px) 0',
      borderTop: '1px solid var(--separator)',
      background: 'none',
      border: 'none',
      borderTopWidth: 1,
      borderTopStyle: 'solid',
      borderTopColor: 'var(--separator)',
      color: 'inherit',
      font: 'inherit',
      fontFamily: 'var(--font-ui)',
      opacity: planned && !set.current ? 0.5 : 1
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      flex: '0 0 var(--l-gutter, 32px)',
      fontSize: 15,
      fontWeight: 'var(--weight-bold)',
      color: set.current ? 'var(--accent-text)' : 'var(--text-tertiary)'
    }
  }, pad2(i + 1)), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 5,
      whiteSpace: 'nowrap'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 28,
      fontWeight: 'var(--weight-bold)',
      letterSpacing: '-0.02em'
    }
  }, kg(set.load)), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      fontWeight: 'var(--weight-bold)',
      color: 'var(--text-secondary)'
    }
  }, "kg"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 15,
      fontWeight: 'var(--weight-bold)',
      color: 'var(--text-tertiary)',
      margin: '0 2px'
    }
  }, "\xD7"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 28,
      fontWeight: 'var(--weight-bold)'
    }
  }, set.reps)), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)',
      marginTop: 'var(--l-meta-gap, 3px)'
    }
  }, set.logged ? 'Logged' : set.current ? 'Up now · tap to edit' : 'Planned')), set.logged ? /*#__PURE__*/React.createElement(Icon, {
    name: "check",
    size: 18,
    weight: "bold",
    color: "var(--accent-text)"
  }) : /*#__PURE__*/React.createElement(Icon, {
    name: open ? 'caret-up' : 'pencil-simple',
    size: 16,
    weight: "bold",
    color: "var(--text-tertiary)"
  }))), open && /*#__PURE__*/React.createElement(SetEditor, {
    set: set,
    index: i,
    count: count,
    onChange: onChange,
    onApplyRest: onApplyRest,
    onApplyAll: onApplyAll,
    onClose: onOpen
  }));
}
function SessionScreen({
  onClose,
  onFinish,
  onAddExercise
}) {
  const [sets, setSets] = React.useState(Array.from({
    length: EX.total
  }, (_, i) => ({
    load: EX.load,
    reps: EX.reps,
    logged: i < 2
  })));
  const [openSet, setOpenSet] = React.useState(null);
  const [resting, setResting] = React.useState(false);
  const [remaining, setRemaining] = React.useState(90);
  const [queue, setQueue] = React.useState(UP_NEXT);
  React.useEffect(() => {
    if (!resting) return;
    const id = setInterval(() => setRemaining(r => r <= 1 ? (setResting(false), 90) : r - 1), 1000);
    return () => clearInterval(id);
  }, [resting]);
  const done = sets.filter(s => s.logged).length;
  const currentIdx = sets.findIndex(s => !s.logged);
  const complete = currentIdx === -1;
  const cur = complete ? sets[sets.length - 1] : sets[currentIdx];
  const patch = (i, next) => setSets(cur => cur.map((s, j) => j === i ? {
    ...s,
    ...next
  } : s));
  const applyFrom = (i, all) => setSets(cur => cur.map((s, j) => (all ? true : j > i) && !s.logged ? {
    ...s,
    load: cur[i].load,
    reps: cur[i].reps
  } : s));
  const logSet = () => {
    if (complete) return;
    patch(currentIdx, {
      logged: true
    });
    setRemaining(90);
    setResting(true);
    setOpenSet(null);
  };
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: '0 0 auto',
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '0 16px 10px'
    }
  }, /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onClose,
    "aria-label": "Close session",
    style: {
      background: 'none',
      border: 'none',
      cursor: 'pointer',
      color: 'var(--text-secondary)',
      width: 44,
      height: 44,
      display: 'grid',
      placeItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "x",
    size: 20,
    weight: "bold"
  })), /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      flex: 1,
      textAlign: 'center',
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)'
    }
  }, "Pull Day \xB7 ", pad2(EX.index), " of 07"), /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      fontSize: 'var(--text-subheadline)',
      fontWeight: 'var(--weight-bold)',
      padding: '0 6px'
    }
  }, "18:24")), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      overflowX: 'hidden',
      scrollbarWidth: 'none',
      msOverflowStyle: 'none'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '4px 20px 20px',
      borderBottom: '1px solid var(--separator)'
    }
  }, /*#__PURE__*/React.createElement(Eyebrow, {
    style: {
      color: 'var(--accent-text)'
    }
  }, "Exercise ", pad2(EX.index), " \xB7 ", EX.region), /*#__PURE__*/React.createElement("h1", {
    className: "bf-display",
    style: {
      margin: '8px 0 0',
      fontSize: 34,
      lineHeight: 1
    }
  }, EX.name), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 18
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 10,
      fontWeight: 'var(--weight-bold)',
      textTransform: 'uppercase',
      letterSpacing: '0.12em',
      color: 'var(--text-secondary)'
    }
  }, "Set ", complete ? EX.total : currentIdx + 1, " of ", sets.length), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 16,
      marginTop: 10
    }
  }, /*#__PURE__*/React.createElement(Stepper, {
    label: "Weight",
    value: cur.load,
    unit: "kg",
    step: 2.5,
    onChange: v => patch(complete ? sets.length - 1 : currentIdx, {
      load: v
    })
  }), /*#__PURE__*/React.createElement(Stepper, {
    label: "Reps",
    value: cur.reps,
    step: 1,
    min: 1,
    onChange: v => patch(complete ? sets.length - 1 : currentIdx, {
      reps: v
    })
  })))), resting && /*#__PURE__*/React.createElement(RestBar, {
    remaining: remaining,
    total: 90,
    onAdd: () => setRemaining(r => r + 15),
    onSkip: () => setResting(false)
  }), /*#__PURE__*/React.createElement(QuickActions, {
    style: {
      padding: '14px 20px 4px'
    },
    items: [{
      icon: 'arrows-clockwise',
      label: 'Swap exercise',
      onClick: () => {}
    }, {
      icon: 'copy',
      label: 'Same for all sets',
      onClick: () => applyFrom(complete ? sets.length - 1 : currentIdx, true)
    }, {
      icon: 'plus-circle',
      label: 'Add a set',
      onClick: () => setSets(c => [...c, {
        load: cur.load,
        reps: cur.reps,
        logged: false
      }])
    }, {
      icon: 'note-pencil',
      label: 'Add note',
      onClick: () => {}
    }, {
      icon: 'timer',
      label: 'Rest 90s',
      onClick: () => {
        setRemaining(90);
        setResting(true);
      }
    }]
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '0 20px 200px'
    }
  }, /*#__PURE__*/React.createElement(SectionRule, {
    label: "This exercise",
    trailing: `${done} of ${sets.length} logged`
  }), sets.map((s, i) => /*#__PURE__*/React.createElement(SetRow, {
    key: i,
    set: {
      ...s,
      current: i === currentIdx
    },
    i: i,
    count: sets.length,
    open: openSet === i,
    onOpen: () => setOpenSet(o => o === i ? null : i),
    onChange: next => patch(i, next),
    onApplyRest: () => applyFrom(i, false),
    onApplyAll: () => applyFrom(i, true),
    onClear: () => patch(i, {
      logged: false
    }),
    onDelete: () => {
      setOpenSet(null);
      setSets(c => c.filter((_, j) => j !== i));
    }
  })), /*#__PURE__*/React.createElement(AddRow, {
    onClick: () => setSets(c => [...c, {
      load: cur.load,
      reps: cur.reps,
      logged: false
    }]),
    label: "Add a set"
  }), /*#__PURE__*/React.createElement(SectionRule, {
    label: "Up next",
    trailing: "Swipe a row"
  }), queue.map(e => /*#__PURE__*/React.createElement(SwipeRow, {
    key: e.i,
    left: [{
      icon: 'arrow-line-up',
      label: 'Do now',
      onClick: () => setQueue(q => [e, ...q.filter(x => x.i !== e.i)])
    }],
    right: [{
      icon: 'arrows-clockwise',
      label: 'Replace',
      onClick: () => {}
    }, {
      icon: 'trash',
      label: 'Remove',
      destructive: true,
      onClick: () => setQueue(q => q.filter(x => x.i !== e.i))
    }]
  }, /*#__PURE__*/React.createElement(LedgerRow, {
    gutter: pad2(e.i),
    title: e.name,
    meta: `${pad2(e.i)} · ${e.spec}`,
    chevron: true,
    onClick: () => {},
    art: {
      icon: e.icon,
      slot: `up-${slugify(e.name)}`,
      label: e.name
    }
  }))), /*#__PURE__*/React.createElement(AddRow, {
    onClick: onAddExercise
  }), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onFinish,
    style: {
      width: '100%',
      height: 'var(--control-md)',
      marginTop: 26,
      cursor: 'pointer',
      background: 'transparent',
      border: '1px solid var(--border-strong)',
      color: 'var(--text-secondary)',
      borderRadius: 'var(--radius-button)',
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--text-subheadline)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, "Finish workout"))), /*#__PURE__*/React.createElement(GlassDock, {
    lift: 16
  }, /*#__PURE__*/React.createElement(PrimaryAction, {
    icon: complete ? 'arrow-right' : 'check',
    onClick: complete ? undefined : logSet
  }, complete ? 'Next exercise' : `Log ${kg(cur.load)} × ${cur.reps}`), /*#__PURE__*/React.createElement(DockButton, {
    icon: "timer",
    label: "Start rest timer",
    onClick: () => {
      setRemaining(90);
      setResting(true);
    }
  }), /*#__PURE__*/React.createElement(DockButton, {
    icon: "plus",
    label: "Add exercise",
    onClick: onAddExercise
  })));
}
Object.assign(window, {
  SessionScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/SessionScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/SettingsScreen.jsx
try { (() => {
const {
  Card,
  SectionHeader,
  Divider,
  SettingsRow,
  Button,
  WeightUnitToggle,
  Icon
} = window.BetterFitDesignSystem_6a70ea;
function SettingsScreen({
  onBack,
  scheme,
  onScheme
}) {
  const [reminders, setReminders] = React.useState(true);
  const [health, setHealth] = React.useState(true);
  const [autoTrack, setAutoTrack] = React.useState(false);
  const [unit, setUnit] = React.useState('lb');
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(NavBar, {
    title: "Settings",
    leading: /*#__PURE__*/React.createElement(Button, {
      variant: "ghost",
      size: "sm",
      fullWidth: false,
      icon: "caret-left",
      onClick: onBack
    }, "Back")
  }), /*#__PURE__*/React.createElement(Scroll, null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 20
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 10
    }
  }, /*#__PURE__*/React.createElement(SectionHeader, {
    title: "Appearance"
  }), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--text-body)'
    }
  }, "Theme"), /*#__PURE__*/React.createElement(WeightUnitToggle, {
    value: scheme === 'dark' ? 'Dark' : 'Light',
    options: ['Light', 'Dark'],
    onChange: v => onScheme(v === 'Dark' ? 'dark' : 'light')
  })), /*#__PURE__*/React.createElement(Divider, {
    style: {
      margin: '12px 0'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-secondary)',
      textWrap: 'pretty'
    }
  }, "BetterFit has one accent. Light and dark mirror the same two colours \u2014 there is nothing else to pick."))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 10
    }
  }, /*#__PURE__*/React.createElement(SectionHeader, {
    title: "Training"
  }), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(SettingsRow, {
    kind: "static",
    icon: "scales",
    title: "Weight units",
    value: unit === 'lb' ? 'Pounds' : 'Kilograms'
  }), /*#__PURE__*/React.createElement(Divider, null), /*#__PURE__*/React.createElement(SettingsRow, {
    kind: "toggle",
    icon: "pulse",
    title: "Auto-track sets",
    subtitle: "Detect sets from Apple Watch motion",
    checked: autoTrack,
    onChange: setAutoTrack
  }), /*#__PURE__*/React.createElement(Divider, null), /*#__PURE__*/React.createElement(SettingsRow, {
    kind: "toggle",
    icon: "heartbeat",
    title: "Apple Health",
    subtitle: "Read workouts and resting heart rate",
    checked: health,
    onChange: setHealth
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 10
    }
  }, /*#__PURE__*/React.createElement(SectionHeader, {
    title: "Notifications"
  }), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(SettingsRow, {
    kind: "toggle",
    icon: "bell",
    title: "Workout reminders",
    subtitle: "Weekdays, 6:30 pm",
    checked: reminders,
    onChange: setReminders
  }), /*#__PURE__*/React.createElement(Divider, null), /*#__PURE__*/React.createElement(SettingsRow, {
    kind: "static",
    icon: "timer",
    title: "Default rest",
    value: "90s"
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 10
    }
  }, /*#__PURE__*/React.createElement(SectionHeader, {
    title: "About"
  }), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(SettingsRow, {
    kind: "static",
    title: "Version",
    value: "1.8.2"
  }), /*#__PURE__*/React.createElement(Divider, null), /*#__PURE__*/React.createElement(SettingsRow, {
    kind: "link",
    title: "Privacy policy"
  }), /*#__PURE__*/React.createElement(Divider, null), /*#__PURE__*/React.createElement(SettingsRow, {
    kind: "link",
    title: "Licences"
  }))), /*#__PURE__*/React.createElement(Button, {
    variant: "destructive"
  }, "Sign out"))));
}
Object.assign(window, {
  SettingsScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/SettingsScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/SignInScreen.jsx
try { (() => {
const {
  Button,
  Logo
} = window.BetterFitDesignSystem_6a70ea;
function SignInScreen({
  onSignIn,
  onGuest
}) {
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'grid',
      placeItems: 'center',
      padding: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement(Logo, {
    variant: "wordmark",
    height: 200,
    assetBase: "../../assets",
    style: {
      margin: '0 auto',
      borderRadius: 28
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 24,
      fontSize: 'var(--text-title-3)',
      color: 'var(--text-secondary)'
    }
  }, "Your strength training coach"))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '0 24px 12px',
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(Button, {
    icon: "apple-logo",
    onClick: onSignIn
  }, "Continue with Apple"), /*#__PURE__*/React.createElement(Button, {
    variant: "secondary",
    icon: "google-logo",
    onClick: onSignIn
  }, "Sign in with Google"), /*#__PURE__*/React.createElement(Button, {
    variant: "secondary",
    icon: "envelope",
    onClick: onSignIn
  }, "Sign in with email"), /*#__PURE__*/React.createElement(Button, {
    variant: "ghost",
    onClick: onGuest
  }, "Continue as guest")), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '4px 40px 28px',
      textAlign: 'center',
      fontSize: 'var(--text-caption)',
      color: 'var(--text-secondary)',
      textWrap: 'pretty'
    }
  }, "We value your privacy. Guest mode stores data on this device only.")));
}
Object.assign(window, {
  SignInScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/SignInScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/SummaryScreen.jsx
try { (() => {
const {
  Icon
} = dsPick(['Icon']);
const RESULTS = [{
  i: 1,
  name: 'Lat pulldown',
  best: '50 kg × 8',
  sets: '3 of 3',
  vol: '1.2k'
}, {
  i: 2,
  name: 'Cable row',
  best: '64 kg × 8',
  sets: '4 of 4',
  vol: '2.0k',
  pr: true
}, {
  i: 3,
  name: 'Barbell curl',
  best: '30 kg × 8',
  sets: '4 of 4',
  vol: '960'
}, {
  i: 4,
  name: 'Hammer curls',
  best: '15 kg × 12',
  sets: '3 of 3',
  vol: '540'
}, {
  i: 5,
  name: 'Face pull',
  best: '18 kg × 15',
  sets: '3 of 3',
  vol: '810'
}, {
  i: 6,
  name: 'Reverse fly',
  best: '10 kg × 12',
  sets: '2 of 3',
  vol: '240',
  short: true
}, {
  i: 7,
  name: 'Cable wood chop',
  best: '20 kg × 15',
  sets: '3 of 3',
  vol: '900'
}];
const pad2 = n => String(n).padStart(2, '0');
function SummaryScreen({
  onBack,
  onAddExercise
}) {
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: '0 0 auto',
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '0 16px 12px'
    }
  }, /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onBack,
    "aria-label": "Back",
    style: {
      background: 'none',
      border: 'none',
      cursor: 'pointer',
      color: 'var(--text-secondary)',
      width: 44,
      height: 44,
      display: 'grid',
      placeItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "caret-left",
    size: 20,
    weight: "bold"
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1
    }
  }), /*#__PURE__*/React.createElement("button", {
    type: "button",
    "aria-label": "Share summary",
    style: {
      background: 'none',
      border: 'none',
      cursor: 'pointer',
      color: 'var(--text-secondary)',
      width: 44,
      height: 44,
      display: 'grid',
      placeItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "export",
    size: 20,
    weight: "bold"
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      overflowX: 'hidden',
      scrollbarWidth: 'none',
      msOverflowStyle: 'none'
    }
  }, /*#__PURE__*/React.createElement(Slab, null, /*#__PURE__*/React.createElement(Eyebrow, {
    style: {
      opacity: 0.6
    }
  }, "Tue 26 Jul \xB7 Session complete"), /*#__PURE__*/React.createElement("h1", {
    className: "bf-display",
    style: {
      margin: '10px 0 0',
      fontSize: 44,
      lineHeight: 0.94
    }
  }, "Pull Day"), /*#__PURE__*/React.createElement(SpecStrip, {
    items: [{
      value: "44'",
      label: 'Duration'
    }, {
      value: '6.7k',
      label: 'Volume kg'
    }, {
      value: '22',
      label: 'Sets'
    }]
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 18,
      paddingTop: 16,
      borderTop: '1.5px solid rgba(0,0,0,.2)',
      fontSize: 'var(--text-subheadline)',
      fontWeight: 'var(--weight-semibold)',
      maxWidth: 300,
      textWrap: 'pretty'
    }
  }, "Strongest pull session this month. Cable row went up 4 kg.")), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '0 20px 190px'
    }
  }, /*#__PURE__*/React.createElement(SectionRule, {
    label: "New records",
    trailing: "1"
  }), /*#__PURE__*/React.createElement(LedgerRow, {
    gutter: /*#__PURE__*/React.createElement(Icon, {
      name: "medal",
      size: 15,
      weight: "bold"
    }),
    gutterAccent: true,
    title: "Cable row",
    meta: "Previous best 60 kg \xD7 8",
    trailing: "64 kg",
    trailingMeta: "\xD7 8"
  }), /*#__PURE__*/React.createElement(SectionRule, {
    label: "What you lifted",
    trailing: `${RESULTS.length} exercises`
  }), RESULTS.map(r => /*#__PURE__*/React.createElement(LedgerRow, {
    key: r.i,
    gutter: pad2(r.i),
    gutterAccent: r.pr,
    title: r.name,
    meta: `Best ${r.best} · ${r.sets} sets${r.short ? ' · cut short' : ''}`,
    trailing: r.vol,
    trailingMeta: "kg"
  })), /*#__PURE__*/React.createElement(AddRow, {
    onClick: onAddExercise,
    label: "Add something you did off plan"
  }), /*#__PURE__*/React.createElement(SectionRule, {
    label: "Effect on recovery"
  }), [{
    m: 'Lats',
    from: 96,
    to: 41
  }, {
    m: 'Biceps',
    from: 81,
    to: 46
  }, {
    m: 'Rear delts',
    from: 78,
    to: 52
  }].map(x => /*#__PURE__*/React.createElement("div", {
    key: x.m,
    style: {
      padding: '13px 0',
      borderTop: '1px solid var(--separator)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: 'var(--text-body)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, x.m), /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-tertiary)'
    }
  }, x.from, "%"), /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-right",
    size: 12,
    weight: "bold",
    color: "var(--text-tertiary)"
  }), /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      fontSize: 'var(--text-subheadline)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, x.to, "%")), /*#__PURE__*/React.createElement(Bar, {
    pct: x.to,
    color: "var(--recovery-fatigued)",
    style: {
      marginTop: 10
    }
  }))), /*#__PURE__*/React.createElement(SectionRule, {
    label: "Next"
  }), /*#__PURE__*/React.createElement(LedgerRow, {
    gutter: /*#__PURE__*/React.createElement(Icon, {
      name: "calendar-blank",
      size: 15,
      weight: "bold"
    }),
    title: "Legs A",
    meta: "Thursday \xB7 8 exercises",
    chevron: true,
    onClick: () => {}
  }))), /*#__PURE__*/React.createElement(GlassDock, {
    lift: 16
  }, /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onBack,
    style: {
      flex: 1,
      height: 'var(--control-lg)',
      cursor: 'pointer',
      borderRadius: 16,
      background: 'var(--glass-highlight)',
      border: '1px solid var(--glass-border)',
      color: 'var(--text-primary)',
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--text-headline)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, "Done"), /*#__PURE__*/React.createElement(DockButton, {
    icon: "export",
    label: "Share summary"
  })));
}
Object.assign(window, {
  SummaryScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/SummaryScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/TargetsScreen.jsx
try { (() => {
const {
  Icon
} = dsPick(['Icon']);
const D = window.BFData;
const SESSION_ICON = name => /pull/i.test(name) ? 'arrow-fat-line-down' : /push/i.test(name) ? 'arrows-in-line-horizontal' : /leg/i.test(name) ? 'person-simple-run' : /cond|cardio|interval/i.test(name) ? 'heartbeat' : /rest/i.test(name) ? 'moon' : 'barbell';
function TargetRow({
  t
}) {
  const pct = Math.round(t.value / t.target * 100);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '14px 0',
      borderTop: '1px solid var(--separator)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: 'var(--text-body)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, t.label), /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      fontSize: 'var(--text-subheadline)',
      fontWeight: 'var(--weight-semibold)'
    }
  }, t.value, t.unit), /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      fontSize: 'var(--text-footnote)',
      color: 'var(--text-tertiary)'
    }
  }, "/ ", t.target, t.unit)), /*#__PURE__*/React.createElement(Bar, {
    pct: pct,
    style: {
      marginTop: 10
    }
  }), /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      fontSize: 'var(--text-caption)',
      color: 'var(--text-secondary)',
      marginTop: 7
    }
  }, pct, "% of the week"));
}
function TargetsScreen() {
  const w = D.targets[0];
  const left = w.target - w.value;
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(LedgerHead, {
    title: "Targets",
    right: /*#__PURE__*/React.createElement("button", {
      type: "button",
      "aria-label": "Edit targets",
      style: {
        background: 'none',
        border: 'none',
        cursor: 'pointer',
        color: 'var(--accent-text)',
        minWidth: 44,
        height: 44,
        fontFamily: 'var(--font-ui)',
        fontSize: 'var(--text-subheadline)',
        fontWeight: 'var(--weight-semibold)'
      }
    }, "Edit")
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      overflowX: 'hidden',
      scrollbarWidth: 'none',
      msOverflowStyle: 'none'
    }
  }, /*#__PURE__*/React.createElement(Slab, null, /*#__PURE__*/React.createElement(Eyebrow, {
    style: {
      opacity: 0.6
    }
  }, "This week"), /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 8,
      marginTop: 10,
      whiteSpace: 'nowrap'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 68,
      fontWeight: 'var(--weight-bold)',
      lineHeight: 0.86,
      letterSpacing: '-0.03em'
    }
  }, w.value), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 26,
      fontWeight: 'var(--weight-bold)',
      opacity: 0.5
    }
  }, "/\xA0", w.target)), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--text-body)',
      fontWeight: 'var(--weight-semibold)',
      marginTop: 14,
      maxWidth: 280,
      textWrap: 'pretty'
    }
  }, "Workouts done. ", left === 1 ? 'One more reaches your goal.' : `${left} more reach your goal.`), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 5,
      marginTop: 18
    }
  }, Array.from({
    length: w.target
  }).map((_, i) => /*#__PURE__*/React.createElement("span", {
    key: i,
    style: {
      flex: 1,
      height: 8,
      background: i < w.value ? 'var(--bf-black)' : 'rgba(0,0,0,.22)'
    }
  })))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '0 20px 110px'
    }
  }, /*#__PURE__*/React.createElement(SectionRule, {
    label: "Weekly targets",
    trailing: `${D.targets.length} set`
  }), D.targets.map(t => /*#__PURE__*/React.createElement(TargetRow, {
    key: t.label,
    t: t
  })), /*#__PURE__*/React.createElement(SectionRule, {
    label: "The week",
    trailing: "Mon\u2013Sun"
  }), D.week.map(d => /*#__PURE__*/React.createElement(LedgerRow, {
    key: d.day,
    gutter: d.day.slice(0, 2).toUpperCase(),
    gutterAccent: d.today,
    title: d.name,
    titleIcon: SESSION_ICON(d.name),
    meta: d.today ? 'Today' : d.done ? 'Completed' : d.name === 'Rest' ? 'Scheduled rest' : 'Scheduled',
    dim: d.name === 'Rest',
    trailing: d.done ? /*#__PURE__*/React.createElement(Icon, {
      name: "check",
      size: 16,
      weight: "bold",
      color: "var(--accent-text)"
    }) : null
  })), /*#__PURE__*/React.createElement(SectionRule, {
    label: "Streak"
  }), /*#__PURE__*/React.createElement(LedgerRow, {
    gutter: /*#__PURE__*/React.createElement(Icon, {
      name: "flame",
      size: 15,
      weight: "bold"
    }),
    title: "Current streak",
    meta: `Best is ${D.streak.best} days`,
    trailing: `${D.streak.current} days`
  }), /*#__PURE__*/React.createElement(SectionRule, {
    label: "Records this month",
    trailing: `${D.prs.length}`
  }), D.prs.map(p => /*#__PURE__*/React.createElement(LedgerRow, {
    key: p.name,
    gutter: /*#__PURE__*/React.createElement(Icon, {
      name: "medal",
      size: 15,
      weight: "bold"
    }),
    title: p.name,
    meta: p.when,
    trailing: p.value
  })))));
}
Object.assign(window, {
  TargetsScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/TargetsScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/data.js
try { (() => {
window.BFData = {
  user: {
    name: 'Johnny',
    since: 'Member since Jan 2024',
    plan: 'Pro'
  },
  today: {
    name: 'Pull B',
    focus: 'Today · Tue 26 Jul',
    exercises: 5,
    duration: '42 min',
    volume: '14.2k lb',
    muscles: ['Lats', 'Biceps', 'Rear delts']
  },
  muscleSplit: [{
    muscle: 'Lats',
    percent: 38
  }, {
    muscle: 'Biceps',
    percent: 27
  }, {
    muscle: 'Rear delts',
    percent: 21
  }, {
    muscle: 'Core',
    percent: 14
  }],
  plan: [{
    index: 1,
    name: 'Trap bar deadlift',
    prescription: '4 × 5 · 245 lb',
    muscles: 'Back, Glutes',
    state: 'planned'
  }, {
    index: 2,
    name: 'Barbell row',
    prescription: '4 × 8 · 135 lb',
    muscles: 'Lats, Rear delts',
    state: 'planned'
  }, {
    index: 3,
    name: 'Lat pulldown',
    prescription: '3 × 10 · 120 lb',
    muscles: 'Lats',
    state: 'planned'
  }, {
    index: 4,
    name: 'EZ curl',
    prescription: '3 × 12 · 65 lb',
    muscles: 'Biceps',
    state: 'planned'
  }, {
    index: 5,
    name: 'Face pull',
    prescription: '3 × 15 · 40 lb',
    muscles: 'Rear delts',
    state: 'planned'
  }],
  recovery: {
    overall: 72,
    regions: [{
      region: 'Chest',
      status: 'sore',
      percent: 34
    }, {
      region: 'Back',
      status: 'recovered',
      percent: 96
    }, {
      region: 'Shoulders',
      status: 'fatigued',
      percent: 58
    }, {
      region: 'Arms',
      status: 'fresh',
      percent: 81
    }, {
      region: 'Core',
      status: 'recovered',
      percent: 92
    }, {
      region: 'Legs',
      status: 'fresh',
      percent: 77
    }]
  },
  streak: {
    current: 12,
    best: 21
  },
  heatmap: Array.from({
    length: 182
  }, (_, i) => i % 7 === 2 || i % 7 === 6 ? 0 : Math.round(Math.abs(Math.sin(i * 0.63)) * 4)),
  prs: [{
    name: 'Trap bar deadlift',
    value: '345 lb',
    when: '2 weeks ago'
  }, {
    name: 'Bench press',
    value: '205 lb',
    when: 'Last month'
  }, {
    name: 'Back squat',
    value: '285 lb',
    when: 'Last month'
  }],
  targets: [{
    label: 'Workouts',
    value: 3,
    target: 5,
    unit: ''
  }, {
    label: 'Volume',
    value: 41,
    target: 60,
    unit: 'k lb'
  }, {
    label: 'Active minutes',
    value: 186,
    target: 250,
    unit: ''
  }],
  achievements: [{
    icon: 'medal',
    title: 'Ten in a row',
    done: true
  }, {
    icon: 'barbell',
    title: 'Bodyweight bench',
    done: true
  }, {
    icon: 'sun-horizon',
    title: 'Five 6am sessions',
    done: false
  }, {
    icon: 'mountains',
    title: '100k lb month',
    done: false
  }],
  searchResults: [{
    icon: 'barbell',
    title: 'Bench press',
    subtitle: 'Chest · Barbell'
  }, {
    icon: 'barbell',
    title: 'Incline bench press',
    subtitle: 'Chest · Barbell'
  }, {
    icon: 'person-simple-run',
    title: 'Treadmill intervals',
    subtitle: 'Cardio · Machine'
  }, {
    icon: 'barbell',
    title: 'Bent-over row',
    subtitle: 'Back · Barbell'
  }, {
    icon: 'gear-six',
    title: 'Weight units',
    subtitle: 'Setting · Preferences'
  }],
  week: [{
    day: 'Mon',
    name: 'Push A',
    done: true
  }, {
    day: 'Tue',
    name: 'Pull B',
    done: false,
    today: true
  }, {
    day: 'Wed',
    name: 'Rest',
    done: false
  }, {
    day: 'Thu',
    name: 'Legs A',
    done: false
  }, {
    day: 'Fri',
    name: 'Push B',
    done: false
  }, {
    day: 'Sat',
    name: 'Conditioning',
    done: false
  }, {
    day: 'Sun',
    name: 'Rest',
    done: false
  }]
};
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/data.js", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/image-slot.js
try { (() => {
// @ds-adherence-ignore -- omelette starter scaffold (raw elements/hex/px by design)
// Copied omelette starter. Re-running copy_starter_component with this kind overwrites this file with the latest version (page content is unaffected).
/* BEGIN USAGE */
/**
 * <image-slot> — user-fillable image placeholder.
 *
 * Drop this into a deck, mockup, or page wherever a design needs an image.
 * You control the slot's shape; it sizes to its container by default. When the search_stock_photos tool
 * is available, prefill the slot by default — write the photo's URL into
 * src (with credit/credit-href); the user can still fill or replace it
 * by dragging an image file onto it (or clicking to browse). The dropped
 * image persists across reloads via a .image-slots.state.json sidecar —
 * same read-via-fetch / write-via-window.omelette pattern as
 * design_canvas.jsx, so the filled slot shows on share links, downloaded
 * zips, and PPTX export. Outside the omelette runtime the slot is read-only.
 *
 * The sidecar is a SIBLING of the HTML file that uses this component: the
 * read is a document-relative fetch, and the host resolves the bridge's
 * sidecar writes into the previewed file's directory to match (same
 * contract as design_canvas.jsx). Pages in the same directory share one
 * sidecar; keep slot ids distinct across them.
 *
 * Attributes:
 *   id           Persistence key. REQUIRED for the drop to survive reload —
 *                every slot on the page needs a distinct id.
 *   shape        'rect' | 'rounded' | 'circle' | 'pill'   (default 'rounded')
 *                'circle' applies 50% border-radius; on a non-square slot
 *                that's an ellipse — set equal width and height for a true
 *                circle.
 *   radius       Corner radius in px for 'rounded'.       (default 12)
 *   mask         Any CSS clip-path value. Overrides `shape` — use this for
 *                hexagons, blobs, arbitrary polygons.
 *   fit          Initial framing baseline: cover | contain.   (default 'cover')
 *                cover starts the image filling the frame (overflow cropped);
 *                contain starts it fully visible (letterboxed). Either way the
 *                user can always pan/scale from there — double-click, or the
 *                Edit control, enters reframe mode (drag to move, scroll or
 *                corner-handles to scale; Escape / click-out commits). The
 *                crop persists alongside the image in the sidecar.
 *   placeholder  Empty-state caption.                      (default 'Drop an image')
 *   src          Optional initial/fallback image URL. Prefill it with a real
 *                photo via search_stock_photos when that tool is available
 *                (set credit/credit-href from the result). A user drop
 *                overrides it; clearing the drop reveals src again.
 *   credit       Attribution text shown as a small overlay at the
 *                bottom-left of the filled slot. REQUIRED whenever src
 *                points at any Unsplash host (images.unsplash.com,
 *                plus.unsplash.com, …): an Unsplash src with no credit
 *                renders an error tile INSTEAD of the photo (Unsplash
 *                terms forbid showing their photos unattributed). Use the
 *                exact form 'Photo by {photographer name} on Unsplash' —
 *                the overlay then links the name to credit-href and
 *                'Unsplash' to the Unsplash homepage, and links back to
 *                unsplash.com automatically get the required utm referral
 *                params appended at render time. The credit belongs to
 *                the src image, so it only shows while src is what's
 *                displayed — a user-dropped image hides it.
 *   credit-href  Link for the photographer's name in the credit overlay
 *                (their Unsplash profile URL from the stock-photo search
 *                results). http(s) URLs only — anything else renders the
 *                name as plain text.
 *
 * Sizing: the slot fills its container by default (width/height 100%).
 * Put it in a sized wrapper — absolutely positioned, a grid cell, a fixed
 * frame — and it takes exactly that box. When the parent's height is
 * indefinite (ordinary flow), it falls back to full width at a 3:2 aspect
 * ratio instead of collapsing. In a shrink-to-fit parent (a float,
 * width:max-content, an unsized absolute wrapper), percentages have
 * nothing to resolve against — size the slot or its wrapper explicitly
 * there. For a fixed-size slot, set
 * width/height on the element itself (inline style), which overrides the
 * default. When
 * layering content above a slot (full-bleed layouts), make the overlay
 * click-through — pointer-events: none on scrims/text plates, re-enabled
 * on interactive children — so the slot's hover controls stay reachable.
 * Keep the slot's bottom-left corner visually clear as well: the credit
 * overlay renders there, and a dark fade or text plate covering it hides
 * the attribution Unsplash's terms require — end the fade above that
 * corner, or keep it nearly transparent where the credit sits.
 *
 * Usage:
 *   <div style="position:relative;width:100%;height:100%">      <!-- full-bleed: -->
 *     <image-slot id="bg" shape="rect"></image-slot>            <!-- fills the wrapper -->
 *   </div>
 *   <image-slot id="hero"   style="width:800px;height:450px" shape="rounded" radius="20"
 *               placeholder="Drop a hero image"></image-slot>
 *   <image-slot id="avatar" style="width:120px;height:120px" shape="circle"></image-slot>
 *   <image-slot id="kite"   style="width:300px;height:300px"
 *               mask="polygon(50% 0, 100% 50%, 50% 100%, 0 50%)"></image-slot>
 */
/* END USAGE */

(() => {
  const STATE_FILE = '.image-slots.state.json';

  // Unsplash terms require visible attribution wherever their photos
  // display, and every link back to unsplash.com must carry utm referral
  // params. Two render-time rules enforce that here:
  //  - an Unsplash-src slot with NO credit attribute renders an error
  //    tile INSTEAD of the photo (an uncredited Unsplash photo on screen
  //    is itself the terms violation, so it never renders bare);
  //  - rendered credit links pointing at unsplash.com get the referral
  //    params appended when absent (credit-href values live in page
  //    content that can't be edited after the fact).
  // Keep the utm_source value in sync with UTM_SOURCE in
  // platform/web-agent/unsplash.ts — this file is a project-local
  // artifact and cannot import it (equality is pinned by tests).
  const UNSPLASH_HOMEPAGE_HREF = 'https://unsplash.com/?utm_source=claude_design&utm_medium=referral';
  // Host rule mirrors the hotlink validator that admits Unsplash srcs into
  // pages in the first place (cdn$ in unsplash.ts: apex or any subdomain)
  // — Unsplash+ results serve from plus.unsplash.com, not just images.*,
  // and an admitted-but-uncredited photo must error whatever unsplash
  // host it rides on.
  // Trailing-dot FQDNs (images.unsplash.com.) are the same host to the
  // browser but would miss the regex — strip one dot so the check fails
  // CLOSED (unrecognized-but-real Unsplash srcs must error, not render).
  const isUnsplashHost = u => {
    try {
      return /(^|\.)unsplash\.com$/.test(new URL(u, document.baseURI).hostname.replace(/\.$/, ''));
    } catch {
      return false;
    }
  };
  // Render-time referral normalization for links back to Unsplash:
  // appends utm_source/utm_medium when absent, preserves every existing
  // query param, never overwrites an existing utm_source, and passes
  // non-Unsplash URLs through untouched. Input is an ABSOLUTE validated
  // http(s) URL (the credit render funnel resolves + validates first).
  const withReferral = href => {
    try {
      const u = new URL(href);
      if (!/(^|\.)unsplash\.com$/.test(u.hostname.replace(/\.$/, ''))) {
        return href;
      }
      if (!u.searchParams.has('utm_source')) {
        u.searchParams.set('utm_source', 'claude_design');
      }
      if (!u.searchParams.has('utm_medium')) {
        u.searchParams.set('utm_medium', 'referral');
      }
      return u.toString();
    } catch (e) {
      return href;
    }
  };
  // 2× a ~600px slot in a 1920-wide deck — retina-sharp without making the
  // sidecar enormous. A 1200px WebP at q=0.85 is ~150-300KB.
  const MAX_DIM = 1200;
  // Raster formats only. SVG is excluded (can carry script; createImageBitmap
  // on SVG blobs is inconsistent). GIF is excluded because the canvas
  // re-encode keeps only the first frame, so an animated GIF would silently
  // go still — better to reject than surprise.
  const ACCEPT = ['image/png', 'image/jpeg', 'image/webp', 'image/avif'];

  // ── Shared sidecar store ────────────────────────────────────────────────
  // One fetch + immediate write-on-change for every <image-slot> on the
  // page. Reads via fetch() so viewing works anywhere the HTML and sidecar
  // are served together; writes go through window.omelette.writeFile, which
  // the host allowlists to *.state.json basenames only.
  const subs = new Set();
  let slots = {};
  // ids explicitly cleared before the sidecar fetch resolved — otherwise
  // the merge below can't tell "never set" from "just deleted" and would
  // resurrect the sidecar's stale value.
  const tombstones = new Set();
  let loaded = false;
  let loadP = null;
  function load() {
    if (loadP) return loadP;
    loadP = fetch(STATE_FILE).then(r => r.ok ? r.json() : null).then(j => {
      // Merge: sidecar loses to any in-memory change that raced ahead of
      // the fetch (drop or clear) so neither is clobbered by hydration.
      if (j && typeof j === 'object') {
        const merged = Object.assign({}, j, slots);
        // A framing-only write that raced ahead of hydration must not
        // drop a user image that's only on disk — inherit u from the
        // sidecar for any in-memory entry that lacks one.
        for (const k in slots) {
          if (merged[k] && !merged[k].u && j[k]) {
            merged[k].u = typeof j[k] === 'string' ? j[k] : j[k].u;
          }
        }
        for (const id of tombstones) delete merged[id];
        slots = merged;
      }
      tombstones.clear();
    }).catch(() => {}).then(() => {
      loaded = true;
      subs.forEach(fn => fn());
    });
    return loadP;
  }

  // Serialize writes so two near-simultaneous drops on different slots
  // can't reorder at the backend and leave the sidecar with only the
  // first. A save requested mid-flight just marks dirty and re-fires on
  // completion with the then-current slots.
  let saving = false;
  let saveDirty = false;
  // Unload-time flush: save()'s serialization defers a mid-RTT re-fire to a
  // .then that never runs in an unloading document, silently dropping a
  // pagehide commit. Post the current slots immediately instead — content
  // is a superset snapshot of any in-flight save's, the write is a
  // whole-file last-writer-wins replace, and postMessage FIFO delivers it
  // to the host after the in-flight one, so a backend-side reorder at
  // worst reproduces the dropped-commit outcome this flush improves on.
  // Guarded on the initial sidecar read: pre-hydration slots can miss
  // other slots' persisted entries, and flushing it would clobber them —
  // that narrow case stays best-effort (the in-memory merge in load()
  // cannot happen in an unloading document anyway).
  function flushNow() {
    if (!loaded) return;
    const w = window.omelette && window.omelette.writeFile;
    if (!w) return;
    try {
      Promise.resolve(w(STATE_FILE, JSON.stringify(slots))).catch(() => {});
    } catch (e) {}
  }
  function save() {
    if (saving) {
      saveDirty = true;
      return;
    }
    const w = window.omelette && window.omelette.writeFile;
    if (!w) return;
    saving = true;
    Promise.resolve(w(STATE_FILE, JSON.stringify(slots))).catch(() => {}).then(() => {
      saving = false;
      if (saveDirty) {
        saveDirty = false;
        save();
      }
    });
  }
  const S_MAX = 5;
  const clampS = s => Math.max(1, Math.min(S_MAX, s));

  // Normalize a stored slot value. Pre-reframe sidecars stored a bare
  // data-URL string; newer ones store {u, s, x, y}. Either shape is valid.
  function getSlot(id) {
    const v = slots[id];
    if (!v) return null;
    return typeof v === 'string' ? {
      u: v,
      s: 1,
      x: 0,
      y: 0
    } : v;
  }
  function setSlot(id, val) {
    if (!id) return;
    if (val) {
      slots[id] = val;
      tombstones.delete(id);
    } else {
      delete slots[id];
      if (!loaded) tombstones.add(id);
    }
    subs.forEach(fn => fn());
    // A drop is rare + high-value — write immediately so nav-away can't lose
    // it. Gate on the initial read so we don't overwrite a sidecar we haven't
    // merged yet; the merge in load() keeps this change once the read lands.
    if (loaded) save();else load().then(save);
  }

  // ── Image downscale ─────────────────────────────────────────────────────
  // Encode through a canvas so the sidecar carries resized bytes, not the
  // raw upload. Longest side is capped at 2× the slot's rendered width
  // (retina) and at MAX_DIM. WebP keeps alpha and is ~10× smaller than PNG
  // for photos, so there's no need for per-image format picking.
  async function toDataUrl(file, targetW) {
    const bitmap = await createImageBitmap(file);
    try {
      const cap = Math.min(MAX_DIM, Math.max(1, Math.round(targetW * 2)) || MAX_DIM);
      const scale = Math.min(1, cap / Math.max(bitmap.width, bitmap.height));
      const w = Math.max(1, Math.round(bitmap.width * scale));
      const h = Math.max(1, Math.round(bitmap.height * scale));
      const canvas = document.createElement('canvas');
      canvas.width = w;
      canvas.height = h;
      canvas.getContext('2d').drawImage(bitmap, 0, 0, w, h);
      return canvas.toDataURL('image/webp', 0.85);
    } finally {
      bitmap.close && bitmap.close();
    }
  }

  // ── Custom element ──────────────────────────────────────────────────────
  const stylesheet =
  // Fill the container by default: slots are usually placed inside a
  // sized wrapper (a hero frame, a grid cell, an inset:0 layer) and are
  // expected to take that box — a fixed intrinsic size would render as
  // a small tile in the corner of a full-bleed wrapper instead.
  // aspect-ratio is the companion fallback that keeps a bare slot
  // visible when the parent's height is indefinite: height:100%
  // resolves to auto there, and the ratio then derives height from
  // width instead of letting the slot collapse to zero height.
  // Explicit width/height on the element override all of this.
  // color:inherit (not a fixed near-black): the placeholder chrome —
  // empty-state icon/caption (currentColor) and the dashed ring — must
  // read on dark decks too, and the slide's own text color is the one
  // color guaranteed to contrast with the slide background. The soft
  // look comes from opacity on those parts, not from a baked-in alpha.
  ':host{display:block;position:relative;' + '  font:13px/1.3 system-ui,-apple-system,sans-serif;' + '  width:100%;height:100%;aspect-ratio:3/2}' + '.empty .cap,.empty .sub{opacity:.75}' + '.frame{position:absolute;inset:0;overflow:hidden;background:rgba(127,127,127,.08)}' +
  // .frame img (clipped) and .spill (unclipped ghost + handles) share the
  // same left/top/width/height in frame-%, computed by _applyView(), so the
  // inside-mask crop and the outside-mask spill stay pixel-aligned.
  '.frame img{position:absolute;max-width:none;transform:translate(-50%,-50%);' + '  -webkit-user-drag:none;user-select:none;touch-action:none}' +
  // Reframe mode (double-click): the full image spills past the mask. The
  // spill layer is sized to the IMAGE bounds so its corners are where the
  // resize handles belong. The ghost <img> inside is translucent; the real
  // clipped <img> underneath shows the opaque in-mask crop.
  // popover=manual promotes the spill to the top layer on reframe, so it is
  // not clipped by any overflow:hidden / clip-path / scroll-container
  // ancestor (a plain z-index can't escape overflow clipping). UA popover
  // defaults (inset:0;margin:auto) are reset; _applyView sets viewport px.
  '.spill{position:fixed;margin:0;inset:auto;border:0;padding:0;background:transparent;' + '  overflow:visible;transform:translate(-50%,-50%);z-index:1;cursor:grab;touch-action:none}' + ':host([data-panning]) .spill{cursor:grabbing}' + '.spill .ghost{position:absolute;inset:0;width:100%;height:100%;opacity:.35;' + '  pointer-events:none;-webkit-user-drag:none;user-select:none;' + '  box-shadow:0 0 0 1px rgba(0,0,0,.2),0 12px 32px rgba(0,0,0,.2)}' + '.spill .handle{position:absolute;width:12px;height:12px;border-radius:50%;' + '  background:#fff;box-shadow:0 0 0 1.5px #c96442,0 1px 3px rgba(0,0,0,.3);' + '  transform:translate(-50%,-50%)}' + '.spill .handle[data-c=nw]{left:0;top:0;cursor:nwse-resize}' + '.spill .handle[data-c=ne]{left:100%;top:0;cursor:nesw-resize}' + '.spill .handle[data-c=sw]{left:0;top:100%;cursor:nesw-resize}' + '.spill .handle[data-c=se]{left:100%;top:100%;cursor:nwse-resize}' + ':host([data-reframe]){z-index:10}' + ':host([data-reframe]) .frame{box-shadow:0 0 0 2px #c96442}' + '.empty{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;' + '  justify-content:center;gap:6px;text-align:center;padding:12px;box-sizing:border-box;' + '  cursor:pointer;user-select:none}' + '.empty svg{opacity:.45}' + '.empty .cap{max-width:90%;font-weight:500;letter-spacing:.01em}' + '.empty .sub{font-size:11px}' + '.empty .sub u{text-underline-offset:2px}' + '.empty:hover .sub{opacity:1}' + ':host([data-over]) .frame{outline:2px solid #c96442;outline-offset:-2px;' + '  background:rgba(201,100,66,.10)}' + '.ring{position:absolute;inset:0;pointer-events:none;border:1.5px dashed currentColor;' + '  opacity:.35;transition:border-color .12s,opacity .12s}' + ':host([data-over]) .ring{border-color:#c96442;opacity:1}' + ':host([data-filled]) .ring{display:none}' +
  // Controls overlay INSIDE the frame, pinned to the top-right corner, so
  // a full-bleed slot in an overflow:hidden container still shows them
  // (the old below-mask placement got clipped). Credit sits bottom-left,
  // so top-right avoids collision. The blurred pill background keeps them
  // legible over the image.
  // The UA [popover] base rule styles the element in EVERY state (only
  // display:none is gated on :not(:popover-open), and the display:flex
  // below overrides that) — so the UA resets live HERE, like .spill's,
  // or the ordinary hover-state strip renders as a bordered Canvas box
  // centered by margin:auto. inset:auto precedes top/right (shorthand).
  '.ctl{position:absolute;inset:auto;top:8px;right:8px;margin:0;border:0;padding:0;' + '  background:transparent;overflow:visible;' + '  display:flex;gap:6px;opacity:0;pointer-events:none;transition:opacity .12s;z-index:2;' + '  white-space:nowrap}' +
  // While reframing, the spill owns the top layer and would swallow every
  // click on the in-frame controls. Promoting .ctl into the top layer
  // ABOVE the spill (shown after it — later popovers stack higher) keeps
  // Edit-as-toggle and Replace clickable mid-reframe. _applyView pins it
  // to the frame's top-right in viewport px (translateX(-100%)
  // right-aligns against the computed left edge); inset:auto clears the
  // base rule's top/right so the inline left/top position it alone.
  '.ctl:popover-open{position:fixed;inset:auto;transform:translateX(-100%)}' + ':host([data-filled][data-editable]:hover) .ctl,:host([data-reframe]) .ctl' + '  {opacity:1;pointer-events:auto}' + '.ctl button{appearance:none;border:0;border-radius:6px;padding:5px 10px;cursor:pointer;' + '  background:rgba(0,0,0,.65);color:#fff;font:11px/1 system-ui,-apple-system,sans-serif;' + '  backdrop-filter:blur(6px)}' + '.ctl button:hover{background:rgba(0,0,0,.8)}' + '.err{position:absolute;left:8px;bottom:8px;right:8px;color:#b3261e;font-size:11px;' + '  background:rgba(255,255,255,.85);padding:4px 6px;border-radius:5px;pointer-events:none}' +
  // Replacement in flight: after a src swap the browser keeps painting
  // the PREVIOUS image until the new one decodes, so a Replace would
  // flash the old photo and then pop. Hide the stale frame (visibility,
  // not display — _applyView geometry still applies) and spin until the
  // new image reports in (load/error clears data-swapping).
  ':host([data-swapping]) .frame img{visibility:hidden}' + '.loading{position:absolute;inset:0;display:none;align-items:center;' + '  justify-content:center;pointer-events:none}' + ':host([data-swapping]) .loading{display:flex}' + '.loading::after{content:"";width:22px;height:22px;border-radius:50%;' + '  border:2px solid rgba(127,127,127,.25);border-top-color:currentColor;' + '  animation:om-slot-spin .7s linear infinite}' + '@keyframes om-slot-spin{to{transform:rotate(360deg)}}' +
  // Reduced motion: the static two-tone ring still reads as "working".
  '@media (prefers-reduced-motion:reduce){.loading::after{animation:none}}' + '.credit{position:absolute;left:6px;bottom:6px;max-width:calc(100% - 12px);display:none;' + '  padding:3px 7px;border-radius:5px;background:rgba(0,0,0,.55);color:#fff;' + '  font:10px/1.2 system-ui,-apple-system,sans-serif;text-decoration:none;' + '  white-space:nowrap;overflow:hidden;text-overflow:ellipsis;backdrop-filter:blur(6px)}' +
  // The credit is a SPAN holding one or two <a>s (Unsplash's prescribed
  // form links the photographer AND Unsplash) — anchors style inline so
  // the overlay reads as one line of text.
  '.credit a{color:inherit;text-decoration:none}' + '.credit a:hover,.credit a:focus-visible{text-decoration:underline}' + ':host([data-filled][data-credit]) .credit{display:block}' +
  // Exports must ship JUST the image — no hover controls, no credit chip
  // (the host marks <html data-om-exporting> for the capture window; the
  // page-level hide script can't reach shadow DOM, this rule can).
  ':host-context([data-om-exporting]) .ctl,' + ':host-context([data-om-exporting]) .credit{display:none !important}' +
  // Print must ship just the image too: the hover-gated controls can be
  // mid-hover when print() fires, and the credit chip is screen chrome —
  // the same rule the capture window gets, keyed on print media instead
  // of the host's data-om-exporting mark (the print path sets no mark).
  '@media print{.ctl,.credit{display:none !important}}' +
  // No export-window mask rules here on purpose: the export capture
  // releases the replacement mask by REMOVING data-swapping (the
  // shadow-root pass in pages/export/shared.ts HIDE_EXPORT_CHROME_SCRIPT)
  // — attribute removal works in every engine (:host-context is
  // Chromium-only), is scoped by construction to slots actually
  // mid-swap, and hides the spinner through the same gate. A masked img
  // would otherwise be silently dropped from PPTX decks (the capture
  // walk skips visibility:hidden imgs).
  // Attribution error tile: REPLACES the photo when an Unsplash src has
  // no credit attribute — rendering the photo uncredited is the terms
  // violation, so the photo must not appear at all.
  // Calm and neutral on purpose (review feedback): the tile informs the
  // user; the fix instructions are machine-facing (usage docblock, tool
  // description, and the turn-end scan's bounce copy name the attributes
  // for the agent).
  '.attr-error{position:absolute;inset:0;display:none;flex-direction:column;align-items:center;' + '  justify-content:center;gap:6px;text-align:center;padding:12px;box-sizing:border-box;' + '  background:#f2f1ef;color:#6e6c66;user-select:none;' + '  font:13px/1.45 system-ui,-apple-system,sans-serif}' + '.attr-error svg{opacity:.55}' + '.attr-error .cap{max-width:92%;font-weight:500;letter-spacing:.01em}' + ':host([data-attribution-error]) .attr-error{display:flex}' + ':host([data-attribution-error]) .ring{display:none}';
  const icon = '<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" ' + 'stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">' + '<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/>' + '<path d="m21 15-5-5L5 21"/></svg>';
  const warnIcon = '<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" ' + 'stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">' + '<path d="m21.73 18-8-14a2 2 0 0 0-3.46 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3"/>' + '<path d="M12 9v4"/><path d="M12 17h.01"/></svg>';
  class ImageSlot extends HTMLElement {
    static get observedAttributes() {
      return ['shape', 'radius', 'mask', 'fit', 'placeholder', 'src', 'id', 'credit', 'credit-href'];
    }

    /** Duplicate-slide hook (called by deck-stage, see its
     *  _remintDuplicateIds): copy this id's stored image, if any, under a
     *  freshly minted key and return that key — so a duplicated slide's
     *  slot keeps its dropped photo instead of reverting to the
     *  placeholder. 'isFree' is the caller's uniqueness check (document
     *  ids); candidates must ALSO be unused in the sidecar, which can
     *  hold keys from other pages sharing the project root. (An EMPTY
     *  slot on another page leaves no sidecar entry, so its id is not
     *  detectable here — a minted key can collide with it and that slot
     *  would show this photo. Same blast radius as two pages reusing an
     *  id by hand, which the shared sidecar already permits.) Returns null
     *  when no id could be minted (caller strips the id, today's
     *  behavior). */
    static cloneSlot(fromId, isFree) {
      if (typeof fromId !== 'string' || !fromId) return null;
      // Pre-hydration the store can't veto candidates or source the copy
      // — degrade to the strip (today's behavior) rather than mint
      // against keys we can't see yet. Any rendered (= droppable) slot
      // means load() has already settled.
      if (!loaded) return null;
      const stem = fromId.replace(/-\d+$/, '') || fromId;
      for (let n = 2; n < 100; n++) {
        const toId = stem + '-' + n;
        if (toId === fromId) continue;
        if (slots[toId] !== undefined) {
          // Reuse a key holding this exact value (bytes AND crop) if no
          // live element here owns it — a duplicate op the host refused
          // after minting leaves such a key behind, and reusing keeps
          // refused retries from accumulating one orphaned copy per
          // attempt. Full equality (not just bytes) so a byte-identical
          // key another PAGE owns with its own crop is stepped past, not
          // adopted or rewritten. (Entries without .u never match.)
          const prev = getSlot(toId);
          const cur = getSlot(fromId);
          if (!(prev && cur && prev.u && prev.u === cur.u && prev.s === cur.s && prev.x === cur.x && prev.y === cur.y && (typeof isFree !== 'function' || isFree(toId)))) continue;
          return toId;
        }
        if (typeof isFree === 'function' && !isFree(toId)) continue;
        const v = getSlot(fromId);
        if (v) setSlot(toId, Object.assign({}, v));
        return toId;
      }
      return null;
    }
    constructor() {
      super();
      // clonable: rail thumbnails deep-clone slides and carry this shadow
      // along; reuse an already-cloned root so upgrade-after-clone works.
      // (Deliberately NOT serializable — a getHTML consumer would embed
      // multi-MB sidecar data-URLs into serialized page HTML.)
      const root = this.shadowRoot || this.attachShadow({
        mode: 'open',
        clonable: true
      });
      // .spill and .ctl sit OUTSIDE .frame so overflow:hidden + border-radius
      // on the frame (circle, pill, rounded) can't clip them.
      root.innerHTML = '<style>' + stylesheet + '</style>' + '<div class="frame" part="frame">' + '  <img part="image" alt="" draggable="false" style="display:none">' + '  <div class="empty" part="empty">' + icon + '    <div class="cap"></div>' + '    <div class="sub">or <u>browse files</u></div></div>' + '  <div class="attr-error" part="attribution-error">' + warnIcon + '    <div class="cap">This photo needs attribution</div></div>' + '  <div class="loading" part="loading"></div>' + '  <div class="ring" part="ring"></div>' + '</div>' +
      // Outside .frame, like .spill/.ctl — the frame's overflow:hidden +
      // border-radius/clip-path would cut the credit off on circle/pill/mask.
      // A SPAN, not an <a>: the prescribed Unsplash credit holds two links
      // (photographer + Unsplash), built per-render in _render().
      '<span class="credit" part="credit"></span>' + '<div class="spill" popover="manual" data-dc-edit-transparent>' + '  <img class="ghost" alt="" draggable="false">' + '  <div class="handle" data-c="nw"></div><div class="handle" data-c="ne"></div>' + '  <div class="handle" data-c="sw"></div><div class="handle" data-c="se"></div>' + '</div>' +
      // data-dc-edit-transparent: the DC editor's edit-mode picker lets
      // clicks through for chrome marked with it (EDIT_TRANSPARENT_SEL)
      // — without it, Replace/Edit clicks in Edit mode are swallowed by
      // element selection and the controls look dead.
      '<div class="ctl" popover="manual" data-dc-edit-transparent><button data-act="replace" title="Replace image">Replace</button>' + '  <button data-act="edit" title="Reframe image">Edit</button></div>' + '<input type="file" accept="' + ACCEPT.join(',') + '" hidden>';
      this._frame = root.querySelector('.frame');
      this._ring = root.querySelector('.ring');
      this._img = root.querySelector('.frame img');
      this._empty = root.querySelector('.empty');
      this._cap = root.querySelector('.cap');
      this._sub = root.querySelector('.sub');
      this._spill = root.querySelector('.spill');
      this._ctl = root.querySelector('.ctl');
      this._credit = root.querySelector('.credit');
      this._attrError = root.querySelector('.attr-error');
      // Credit clicks open the link, not browse/reframe.
      this._credit.addEventListener('click', e => e.stopPropagation());
      this._credit.addEventListener('dblclick', e => e.stopPropagation());
      this._ghost = root.querySelector('.ghost');
      this._err = null;
      this._input = root.querySelector('input');
      this._depth = 0;
      this._gen = 0;
      // Encode-in-flight marker (the owning _ingest generation): while set,
      // the same-src "nothing in flight" clear in _render must not fire —
      // the stored value still points at the OLD image until the encode
      // lands, so that clear would unmask the stale image mid-replace.
      this._swapGen = 0;
      // Render-owned swap in flight: set when _render assigns a new src,
      // cleared only by the img's own load/error (or the empty branch).
      // img.complete CANNOT stand in for this — setting src only QUEUES
      // the current-request swap (a microtask), so synchronously after an
      // assignment, complete still reports the OLD settled request. The
      // pick path does exactly that: the host sets src, credit, and
      // credit-href back-to-back in one task, and renders #2/#3 would
      // read the stale complete === true and drop the mask one render
      // after it was set.
      this._loadPending = false;
      // See _render's empty branch: a transient attribution-error wipe of a
      // showing image must make the follow-up render a replacement (spinner),
      // not a first fill (blank frame).
      this._hidShowing = false;
      this._view = {
        s: 1,
        x: 0,
        y: 0
      };
      this._subFn = () => this._render();
      // Shadow-DOM listeners live with the shadow DOM — bound once here so
      // disconnect/reconnect (e.g. React remount) doesn't stack handlers.
      this._empty.addEventListener('click', () => this._input.click());
      root.addEventListener('click', e => {
        const act = e.target && e.target.getAttribute && e.target.getAttribute('data-act');
        if (!act) return;
        // The hidden controls are opacity-0 but still tabbable — without
        // this gate a keyboard user could drive them on a read-only share
        // link (mirrors the dblclick handler's editable gate).
        if (!this.hasAttribute('data-editable')) return;
        if (act === 'replace') {
          this._exitReframe(true);
          // Host-owned picker (Unsplash modal; it also offers local import).
          this.dispatchEvent(new CustomEvent('image-slot:pick', {
            bubbles: true,
            composed: true,
            detail: {
              id: this.id || null
            }
          }));
        }
        if (act === 'edit') {
          if (!this._reframes()) return;
          if (this.hasAttribute('data-reframe')) this._exitReframe(true);else this._enterReframe();
        }
      });
      this._input.addEventListener('change', () => {
        const f = this._input.files && this._input.files[0];
        if (f) this._ingest(f);
        this._input.value = '';
      });
      // naturalWidth/Height aren't known until load — re-apply so the cover
      // baseline is computed from real dimensions, not the 100%×100% fallback.
      // load/error also release the replacement-in-flight mask (via the
      // single discipline in _releaseMask): the swap is only revealed once
      // the new image can actually paint (on error the frame shows its
      // background, same as a fresh slot with a broken src).
      this._img.addEventListener('load', () => {
        this._loadPending = false;
        this._releaseMask(true);
        this._applyView();
      });
      this._img.addEventListener('error', () => {
        this._loadPending = false;
        this._releaseMask(true);
      });
      // Gated only on editable — any filled slot can be repositioned/scaled,
      // regardless of fit. Share links (no writeFile) stay static.
      this.addEventListener('dblclick', e => {
        if (!this.hasAttribute('data-editable') || !this._reframes()) return;
        e.preventDefault();
        if (this.hasAttribute('data-reframe')) this._exitReframe(true);else this._enterReframe();
      });
      // Pan + resize both originate on the spill layer. A handle pointerdown
      // drives an aspect-locked resize anchored at the opposite corner; any
      // other pointerdown on the spill pans. Offsets are frame-% so a
      // reframed slot survives responsive resize / PPTX export.
      this._spill.addEventListener('pointerdown', e => {
        if (e.button !== 0 || !this.hasAttribute('data-reframe')) return;
        e.preventDefault();
        e.stopPropagation();
        this._spill.setPointerCapture(e.pointerId);
        const rect = this.getBoundingClientRect();
        const fw = rect.width || 1,
          fh = rect.height || 1;
        const corner = e.target.getAttribute && e.target.getAttribute('data-c');
        let move;
        if (corner) {
          // Resize about the OPPOSITE corner. Viewport-px throughout (rect
          // fw/fh, not clientWidth) so the math survives a transform:scale()
          // ancestor — deck_stage renders slides scaled-to-fit.
          const iw = this._img.naturalWidth || 1,
            ih = this._img.naturalHeight || 1;
          const contain = (this.getAttribute('fit') || 'cover').toLowerCase() === 'contain';
          const base = contain ? Math.min(fw / iw, fh / ih) : Math.max(fw / iw, fh / ih);
          const sx = corner.includes('e') ? 1 : -1;
          const sy = corner.includes('s') ? 1 : -1;
          const s0 = this._view.s;
          const w0 = iw * base * s0,
            h0 = ih * base * s0;
          const cx0 = (50 + this._view.x) / 100 * fw;
          const cy0 = (50 + this._view.y) / 100 * fh;
          const ox = cx0 - sx * w0 / 2,
            oy = cy0 - sy * h0 / 2;
          const diag0 = Math.hypot(w0, h0);
          const ux = sx * w0 / diag0,
            uy = sy * h0 / diag0;
          move = ev => {
            const proj = (ev.clientX - rect.left - ox) * ux + (ev.clientY - rect.top - oy) * uy;
            const s = clampS(s0 * proj / diag0);
            const d = diag0 * s / s0;
            this._view.s = s;
            this._view.x = (ox + ux * d / 2) / fw * 100 - 50;
            this._view.y = (oy + uy * d / 2) / fh * 100 - 50;
            this._clampView();
            this._applyView();
          };
        } else {
          this.setAttribute('data-panning', '');
          const start = {
            px: e.clientX,
            py: e.clientY,
            x: this._view.x,
            y: this._view.y
          };
          move = ev => {
            this._view.x = start.x + (ev.clientX - start.px) / fw * 100;
            this._view.y = start.y + (ev.clientY - start.py) / fh * 100;
            this._clampView();
            this._applyView();
          };
        }
        const up = () => {
          try {
            this._spill.releasePointerCapture(e.pointerId);
          } catch {}
          this._spill.removeEventListener('pointermove', move);
          this._spill.removeEventListener('pointerup', up);
          this._spill.removeEventListener('pointercancel', up);
          this.removeAttribute('data-panning');
          this._dragUp = null;
        };
        // Stashed so _exitReframe (Escape / outside-click mid-drag) can
        // tear the capture + listeners down synchronously.
        this._dragUp = up;
        this._spill.addEventListener('pointermove', move);
        this._spill.addEventListener('pointerup', up);
        this._spill.addEventListener('pointercancel', up);
      });
      // Wheel zoom stays available inside reframe mode as a trackpad nicety —
      // zooms toward the cursor (offset' = cursor·(1-k) + offset·k).
      this.addEventListener('wheel', e => {
        if (!this.hasAttribute('data-reframe')) return;
        e.preventDefault();
        const r = this.getBoundingClientRect();
        const cx = (e.clientX - r.left) / r.width * 100 - 50;
        const cy = (e.clientY - r.top) / r.height * 100 - 50;
        const prev = this._view.s;
        const next = clampS(prev * Math.pow(1.0015, -e.deltaY));
        if (next === prev) return;
        const k = next / prev;
        this._view.s = next;
        this._view.x = cx * (1 - k) + this._view.x * k;
        this._view.y = cy * (1 - k) + this._view.y * k;
        this._clampView();
        this._applyView();
      }, {
        passive: false
      });
    }
    connectedCallback() {
      // Warn once per page — an id-less slot works for the session but
      // cannot persist, and two id-less slots would share nothing.
      if (!this.id && !ImageSlot._warned) {
        ImageSlot._warned = true;
        console.warn('<image-slot> without an id will not persist its dropped image.');
      }
      this.addEventListener('dragenter', this);
      this.addEventListener('dragover', this);
      this.addEventListener('dragleave', this);
      this.addEventListener('drop', this);
      subs.add(this._subFn);
      // The host may inject window.omelette.writeFile AFTER the first render;
      // re-render on hover so the editable-gated controls reliably appear.
      this.addEventListener('pointerenter', this._subFn);
      // width%/height% in _applyView encode the frame aspect at call time —
      // a host resize (responsive grid, pane divider) would stretch the
      // image until the next _render. Re-render on size change: _render()
      // re-seeds _view from stored before clamp/apply, so a shrink→grow
      // cycle round-trips instead of ratcheting x/y toward the narrower
      // frame's clamp range.
      this._ro = new ResizeObserver(() => this._render());
      this._ro.observe(this);
      load();
      this._render();
    }
    disconnectedCallback() {
      subs.delete(this._subFn);
      this.removeEventListener('pointerenter', this._subFn);
      this.removeEventListener('dragenter', this);
      this.removeEventListener('dragover', this);
      this.removeEventListener('dragleave', this);
      this.removeEventListener('drop', this);
      if (this._ro) {
        this._ro.disconnect();
        this._ro = null;
      }
      // commit=false: a disconnect is not a user intent — committing here
      // would persist whatever half-finished drag a React remount or DOM
      // splice happened to interrupt. Deliberate exits commit on their own
      // paths (Escape/click-out/toggle), and unloads commit via pagehide.
      this._exitReframe(false);
    }
    _enterReframe() {
      if (this.hasAttribute('data-reframe')) return;
      this.setAttribute('data-reframe', '');
      this._signalReframe(true);
      // Best-effort commit when the document unloads mid-reframe (a host
      // navigation racing the enter signal, a manual reload, tab close):
      // the sidecar write rides the host bridge, which outlives this
      // document, so the crop survives even though the mode dies with the
      // DOM. Held on the instance so _exitReframe detaches exactly what
      // was attached.
      this._pagehide = () => {
        this._exitReframe(true);
        flushNow();
      };
      window.addEventListener('pagehide', this._pagehide);
      // Promote spill to the top layer, then keep it pinned over the frame:
      // scroll/resize cover the common cases, and a per-frame rect check
      // catches layout shifts that fire neither (an image above finishing
      // load, streamed DOM pushing the slot down, an ancestor transform
      // change) so the overlay can't detach from the frame.
      try {
        this._spill.showPopover();
      } catch {}
      // After the spill, so the controls stack above it in the top layer.
      try {
        this._ctl.showPopover();
      } catch {}
      this._reposition = () => {
        if (this.hasAttribute('data-reframe')) this._applyView();
      };
      window.addEventListener('scroll', this._reposition, true);
      window.addEventListener('resize', this._reposition);
      this._lastRect = '';
      this._watch = () => {
        if (!this.hasAttribute('data-reframe')) return;
        const r = this.getBoundingClientRect();
        const key = r.left + ',' + r.top + ',' + r.width + ',' + r.height;
        if (key !== this._lastRect) {
          this._lastRect = key;
          this._applyView();
        }
        this._watchId = requestAnimationFrame(this._watch);
      };
      this._watchId = requestAnimationFrame(this._watch);
      this._applyView();
      // Close on click outside (the spill handler stopPropagation()s so
      // in-image drags don't reach this) and on Escape. Listeners are held
      // on the instance so _exitReframe / disconnectedCallback can detach
      // exactly what was attached.
      this._outside = e => {
        if (e.composedPath && e.composedPath().includes(this)) return;
        this._exitReframe(true);
      };
      this._esc = e => {
        if (e.key === 'Escape') this._exitReframe(true);
      };
      document.addEventListener('pointerdown', this._outside, true);
      document.addEventListener('keydown', this._esc, true);
    }
    _exitReframe(commit) {
      if (!this.hasAttribute('data-reframe')) return;
      if (this._dragUp) this._dragUp();
      this.removeAttribute('data-reframe');
      this.removeAttribute('data-panning');
      if (this._outside) document.removeEventListener('pointerdown', this._outside, true);
      if (this._esc) document.removeEventListener('keydown', this._esc, true);
      this._outside = this._esc = null;
      if (this._reposition) {
        window.removeEventListener('scroll', this._reposition, true);
        window.removeEventListener('resize', this._reposition);
        this._reposition = null;
      }
      if (this._watchId) {
        cancelAnimationFrame(this._watchId);
        this._watchId = 0;
      }
      if (this._pagehide) {
        window.removeEventListener('pagehide', this._pagehide);
        this._pagehide = null;
      }
      try {
        this._spill.hidePopover();
      } catch {}
      try {
        this._ctl.hidePopover();
      } catch {}
      this._ctl.style.left = '';
      this._ctl.style.top = '';
      if (commit) this._commitView();
      this._signalReframe(false);
    }

    // Reframe state lives only in this DOM until commit, invisible to the
    // host's dirty signals — announce enter/exit so the host can hold
    // auto-reloads for exactly the gesture (the guest bundle forwards
    // image-slot:reframe to the host as imageSlotReframe). Dispatched on
    // the element (composed, so it escapes shadow roots) while connected;
    // a disconnected exit (disconnectedCallback) falls back to document so
    // the host still hears it.
    _signalReframe(active) {
      const target = this.isConnected ? this : document;
      target.dispatchEvent(new CustomEvent('image-slot:reframe', {
        bubbles: true,
        composed: true,
        detail: {
          active: active,
          id: this.id || null
        }
      }));
    }

    // Public: host's "Import from computer" calls this to run local browse.
    openFilePicker() {
      this._exitReframe(true);
      this._input.click();
    }

    // A src write is a newer intent for this slot's content — the host
    // pick path (setImageSlotImage) or an agent edit — so it must win
    // over any encode still in flight from an earlier drop: left live,
    // that encode lands later, passes _ingest's gen guard, and its
    // setSlot silently overwrites the pick (the stored value shadows
    // src in _render). Bumping _gen kills the encode before its own
    // _swapGen clear runs, so clear the dead claim here too — otherwise
    // _releaseMask (gated on !_swapGen) never fires and the pick's
    // spinner is stranded. src ONLY: the pick sets credit/credit-href
    // in the same task, and clearing _swapGen on those would let the
    // same-src branch unmask the old image mid-encode.
    attributeChangedCallback(name, oldVal, newVal) {
      if (name === 'src' && oldVal !== newVal) {
        this._gen++;
        this._swapGen = 0;
      }
      if (this.shadowRoot) this._render();
    }

    // handleEvent — one listener object for all four drag events keeps the
    // add/remove symmetric and the depth counter correct.
    handleEvent(e) {
      if (e.type === 'dragenter' || e.type === 'dragover') {
        // Without preventDefault the browser never fires 'drop'.
        e.preventDefault();
        e.stopPropagation();
        if (e.dataTransfer) e.dataTransfer.dropEffect = 'copy';
        if (e.type === 'dragenter') this._depth++;
        this.setAttribute('data-over', '');
      } else if (e.type === 'dragleave') {
        // dragenter/leave fire for every descendant crossing — count depth
        // so hovering the icon inside the empty state doesn't flicker.
        if (--this._depth <= 0) {
          this._depth = 0;
          this.removeAttribute('data-over');
        }
      } else if (e.type === 'drop') {
        e.preventDefault();
        e.stopPropagation();
        this._depth = 0;
        this.removeAttribute('data-over');
        const f = e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files[0];
        if (f) this._ingest(f);
      }
    }
    async _ingest(file) {
      this._setError(null);
      if (!file || ACCEPT.indexOf(file.type) < 0) {
        this._setError('Drop a PNG, JPEG, WebP, or AVIF image.');
        return;
      }
      // toDataUrl can take hundreds of ms on a large photo. A Clear or a
      // newer drop during that window would be clobbered when this await
      // resumes — bump + capture a generation so stale encodes bail.
      const gen = ++this._gen;
      // Replacing a shown image: surface the swap through the encode too,
      // not just the decode — otherwise the old photo sits there with no
      // feedback while the canvas re-encode runs. An empty slot keeps its
      // placeholder (no spinner) until the encode lands, as before.
      // _swapGen guards the mask against re-renders DURING the encode
      // (pointerenter, ResizeObserver, another slot's store write): the
      // stored value still resolves to the old image there, so _render's
      // same-src clear would otherwise unmask it mid-replace.
      if (this.hasAttribute('data-filled')) {
        this.setAttribute('data-swapping', '');
        this._swapGen = gen;
      }
      try {
        const w = this.clientWidth || this.offsetWidth || MAX_DIM;
        const url = await toDataUrl(file, w);
        if (gen !== this._gen) return;
        // Only exit reframe once the new image is in hand — a rejected type
        // or decode failure leaves the in-progress crop untouched.
        this._exitReframe(false);
        // Clear BEFORE setSlot: its synchronous re-render must see no
        // pending encode, so a byte-identical re-upload (same data URL, no
        // load event coming) still clears the mask via the complete branch.
        this._swapGen = 0;
        const val = {
          u: url,
          s: 1,
          x: 0,
          y: 0
        };
        setSlot(this.id || '', val);
        // Keep a session-local copy for id-less slots so the drop still
        // shows, even though it cannot persist.
        if (!this.id) {
          this._local = val;
          this._render();
        }
      } catch (err) {
        if (gen !== this._gen) return;
        this._swapGen = 0;
        // Reveal the kept old image — unless another replacement (a
        // remote pick's src swap) is still in flight, in which case the
        // mask stays until THAT image settles (its load/error releases).
        this._releaseMask();
        this._setError('Could not read that image.');
        console.warn('<image-slot> ingest failed:', err);
      }
    }
    _setError(msg) {
      if (this._err) {
        this._err.remove();
        this._err = null;
      }
      if (!msg) return;
      const d = document.createElement('div');
      d.className = 'err';
      d.textContent = msg;
      this.shadowRoot.appendChild(d);
      this._err = d;
      setTimeout(() => {
        if (this._err === d) {
          d.remove();
          this._err = null;
        }
      }, 3000);
    }

    // Reframing (pan/resize) is available on any filled slot — the user can
    // always reposition/scale. `fit` only sets the initial baseline (see
    // _geom): contain starts fully-visible, cover starts frame-filling.
    _reframes() {
      return this.hasAttribute('data-filled');
    }

    // The single release discipline for the replacement-in-flight mask
    // (data-swapping). The mask comes off only when BOTH hold:
    //  - no encode is pending (_swapGen) — mid-encode the stored value
    //    still resolves to the old image, so any reveal paints it;
    //  - the frame img has settled on its current src — an unsettled src
    //    means some replacement is still in flight (e.g. a remote pick),
    //    whoever started it, and revealing would paint the previous
    //    frame. The load/error listeners pass settled=true (the event IS
    //    the settlement signal, per spec complete is true by then);
    //    other callers rely on the complete flag (covers loaded AND
    //    failed).
    // Every release path funnels through here EXCEPT _render's empty
    // branch (the img is being cleared — nothing will ever settle).
    _releaseMask(settled) {
      if (!this._swapGen && !this._loadPending && (settled || this._img.complete)) {
        this.removeAttribute('data-swapping');
      }
    }

    // Baseline geometry, shared by clamp/apply/resize. `base` is the scale at
    // view-scale s=1: cover = fill the frame (overflow on the looser axis),
    // contain = fit fully inside (letterboxed). Zooming a contain image past
    // s where it overflows naturally becomes a crop. Null until the img has
    // loaded (naturalWidth is 0 before that) or when the slot has no layout
    // box — ResizeObserver fires with a 0×0 rect under display:none, and
    // clamping against a degenerate 1×1 frame would silently pull the stored
    // pan toward zero.
    _geom() {
      const iw = this._img.naturalWidth,
        ih = this._img.naturalHeight;
      const fw = this.clientWidth,
        fh = this.clientHeight;
      if (!iw || !ih || !fw || !fh) return null;
      const contain = (this.getAttribute('fit') || 'cover').toLowerCase() === 'contain';
      const base = contain ? Math.min(fw / iw, fh / ih) : Math.max(fw / iw, fh / ih);
      return {
        iw,
        ih,
        fw,
        fh,
        base
      };
    }
    _clampView() {
      // Pan range on each axis is half the overflow past the frame edge.
      const g = this._geom();
      if (!g) return;
      const mx = Math.max(0, (g.iw * g.base * this._view.s / g.fw - 1) * 50);
      const my = Math.max(0, (g.ih * g.base * this._view.s / g.fh - 1) * 50);
      this._view.x = Math.max(-mx, Math.min(mx, this._view.x));
      this._view.y = Math.max(-my, Math.min(my, this._view.y));
    }
    _applyView() {
      const g = this._geom();
      // Top-layer controls: pin to the frame's top-right in viewport px
      // (the same 8px inset as the in-frame layout; unscaled — top-layer UI
      // reads as chrome, not page content). BEFORE the geometry branch:
      // placement needs only the frame rect, and a not-yet-loaded or broken
      // src must not leave the promoted strip floating unpositioned. Gated
      // on the popover actually being open: without the Popover API,
      // showPopover() threw (swallowed in _enterReframe), .ctl stays in
      // its in-frame absolute layout, and viewport-px coordinates would
      // shove it off-frame — and matches(':popover-open') itself throws
      // there (unknown pseudo-class), hence the try/catch.
      if (this.hasAttribute('data-reframe')) {
        let onTop = false;
        try {
          onTop = this._ctl.matches(':popover-open');
        } catch {}
        if (onTop) {
          const r = this.getBoundingClientRect();
          this._ctl.style.left = r.right - 8 + 'px';
          this._ctl.style.top = r.top + 8 + 'px';
        }
      }
      if (!g) {
        // Dimensions not known yet (before img load) — centered fit so there
        // is no flash of an unpositioned image before the geometry lands.
        const contain = (this.getAttribute('fit') || 'cover').toLowerCase() === 'contain';
        this._img.style.width = '100%';
        this._img.style.height = '100%';
        this._img.style.left = '50%';
        this._img.style.top = '50%';
        this._img.style.objectFit = contain ? 'contain' : 'cover';
        return;
      }
      // Baseline (cover-fill or contain-fit) × view scale. Width/height and
      // left/top are all frame-% — depends only on the frame aspect ratio, so
      // a responsive resize keeps the same crop. The spill layer mirrors the
      // same box so its corners = image corners.
      const k = g.base * this._view.s;
      const w = g.iw * k / g.fw * 100 + '%';
      const h = g.ih * k / g.fh * 100 + '%';
      const l = 50 + this._view.x + '%';
      const t = 50 + this._view.y + '%';
      this._img.style.width = w;
      this._img.style.height = h;
      this._img.style.left = l;
      this._img.style.top = t;
      this._img.style.objectFit = '';
      if (this.hasAttribute('data-reframe')) {
        // Top-layer spill: position in viewport px over the frame. The top
        // layer escapes ancestor transforms entirely, so EVERY term must be
        // in viewport units: getBoundingClientRect gives the frame's scaled
        // origin AND size, and the rect/layout ratio rescales the ghost —
        // sizing from layout px alone renders it 1/scale too large under a
        // scaled deck slide. Inner ghost + handles stay box-relative.
        const r = this.getBoundingClientRect();
        const sx = g.fw ? r.width / g.fw : 1;
        const sy = g.fh ? r.height / g.fh : 1;
        this._spill.style.width = g.iw * k * sx + 'px';
        this._spill.style.height = g.ih * k * sy + 'px';
        this._spill.style.left = r.left + (50 + this._view.x) / 100 * r.width + 'px';
        this._spill.style.top = r.top + (50 + this._view.y) / 100 * r.height + 'px';
      }
    }
    _commitView() {
      const v = {
        s: this._view.s,
        x: this._view.x,
        y: this._view.y
      };
      if (this._userUrl) v.u = this._userUrl;
      // Framing-only (no u) persists too so an author-src slot remembers its
      // crop; clearing the sidecar still falls through to src=.
      if (this.id) setSlot(this.id, v);else {
        this._local = v;
      }
    }
    _render() {
      // Shape / mask. Presets use border-radius so the dashed ring can
      // follow the rounded outline; clip-path is only applied for an
      // explicit `mask` (the ring is hidden there since a rectangle
      // dashed border chopped by an arbitrary polygon looks broken).
      const mask = this.getAttribute('mask');
      const shape = (this.getAttribute('shape') || 'rounded').toLowerCase();
      let radius = '';
      if (shape === 'circle') radius = '50%';else if (shape === 'pill') radius = '9999px';else if (shape === 'rounded') {
        const n = parseFloat(this.getAttribute('radius'));
        radius = (Number.isFinite(n) ? n : 12) + 'px';
      }
      this._frame.style.borderRadius = mask ? '' : radius;
      this._frame.style.clipPath = mask || '';
      this._ring.style.borderRadius = mask ? '' : radius;
      this._ring.style.display = mask ? 'none' : '';

      // Controls and reframe entry gate on this so share links stay read-only.
      const editable = !!(window.omelette && window.omelette.writeFile);
      this.toggleAttribute('data-editable', editable);
      this._sub.style.display = editable ? '' : 'none';

      // Content. The sidecar is also writable by the agent's write_file
      // tool, so its value isn't guaranteed canvas-originated — only accept
      // data:image/ URLs from it. The `src` attribute is author-controlled
      // (Claude wrote it into the HTML) so it passes through unchanged.
      let stored = this.id ? getSlot(this.id) : this._local;
      if (stored && stored.u && !/^data:image\//i.test(stored.u)) stored = null;
      const srcAttr = this.getAttribute('src') || '';
      this._userUrl = stored && stored.u || null;
      const url = this._userUrl || srcAttr;
      // Don't clobber an in-flight reframe with a store-triggered re-render.
      if (!this.hasAttribute('data-reframe')) {
        this._view = {
          s: stored && Number.isFinite(stored.s) ? clampS(stored.s) : 1,
          x: stored && Number.isFinite(stored.x) ? stored.x : 0,
          y: stored && Number.isFinite(stored.y) ? stored.y : 0
        };
      }
      this._cap.textContent = this.getAttribute('placeholder') || 'Drop an image';
      // Toggle via style.display — the [hidden] attribute alone loses to
      // the display:flex / display:block rules in the stylesheet above.
      // An Unsplash src with no credit attribute must NOT render — showing
      // the photo uncredited is the Unsplash-terms violation itself. The
      // error tile replaces the photo until the credit is written. A
      // user-dropped image is the user's own content and always renders.
      // Trimmed: credit is agent/user-editable content, and a whitespace-
      // only value must count as missing — otherwise it would suppress the
      // error tile AND render an empty credit box (no text, no links),
      // exactly the unattributed state this gate exists to prevent.
      const credit = (this.getAttribute('credit') || '').trim();
      const attrError = !!(!credit && !this._userUrl && srcAttr && isUnsplashHost(srcAttr));
      this.toggleAttribute('data-attribution-error', attrError);
      if (url && !attrError) {
        const prev = this._img.getAttribute('src');
        if (prev !== url) {
          // Replacing an already-shown image: mark the swap BEFORE setting
          // src so the stale frame is never revealed (see the data-swapping
          // stylesheet rules). First fill (prev empty) keeps the existing
          // placeholder-until-load behavior — no spinner. _hidShowing
          // covers the pick path's transient attribution-error wipe: prev
          // is gone, but an image WAS showing, so this is a replacement.
          if (prev || this._hidShowing) this.setAttribute('data-swapping', '');
          // Mark the swap BEFORE assigning src: complete keeps reporting
          // the old settled request until the browser's
          // update-the-image-data microtask runs, so same-task re-renders
          // (the pick path's credit/credit-href setAttributes) need this
          // flag, not complete, to know a load is in flight.
          this._loadPending = true;
          this._img.src = url;
          this._ghost.src = url;
        } else {
          // Same-src re-render — release if settled, so an ingest-set
          // spinner can't stick after a byte-identical re-upload (same
          // data URL, no further load event ever fires).
          this._releaseMask();
        }
        this._hidShowing = false;
        this._img.style.display = 'block';
        this._empty.style.display = 'none';
        this.setAttribute('data-filled', '');
        this._clampView();
        this._applyView();
      } else {
        this.removeAttribute('data-swapping');
        // The src is being removed — no load/error will ever fire for it.
        this._loadPending = false;
        // A transient attribution-error wipe of a showing image happens on
        // the pick path: the host sets src one setAttribute before credit,
        // so render N hides the old image (attrError) and render N+1
        // restores a URL. Remember the wipe so that restore renders as a
        // replacement (spinner), not a first fill (blank frame).
        this._hidShowing = attrError && !!this._img.getAttribute('src');
        this._img.style.display = 'none';
        this._img.removeAttribute('src');
        this._ghost.removeAttribute('src');
        // The error tile owns the blocked-photo state; .empty stays for
        // the genuinely-empty slot.
        this._empty.style.display = attrError ? 'none' : 'flex';
        this.removeAttribute('data-filled');
      }

      // Credit belongs to the author src, so a user drop hides it.
      // textContent + the http(s)-only funnel keep external strings inert.
      const showCredit = !!(url && credit && !this._userUrl && !attrError);
      this._credit.textContent = '';
      if (showCredit) {
        // Validate once (resolved against the document, http(s) only),
        // then append the terms-required utm referral params to links
        // that point back at unsplash.com.
        let href = '';
        const rawHref = this.getAttribute('credit-href') || '';
        if (rawHref) {
          try {
            const u = new URL(rawHref, document.baseURI);
            if (u.protocol === 'http:' || u.protocol === 'https:') {
              href = withReferral(u.href);
            }
          } catch {}
        }
        const mkLink = (text, linkHref) => {
          const a = document.createElement('a');
          a.setAttribute('target', '_blank');
          a.setAttribute('rel', 'noopener noreferrer');
          a.setAttribute('href', linkHref);
          a.textContent = text;
          return a;
        };
        // Unsplash's prescribed credit is TWO links — the photographer's
        // name to their profile (credit-href) and 'Unsplash' to the
        // homepage. Render that split whenever the text has the canonical
        // shape; other text keeps the legacy single-link rendering.
        const m = /^Photo by (.+) on Unsplash$/.exec(credit);
        if (m) {
          this._credit.appendChild(document.createTextNode('Photo by '));
          this._credit.appendChild(href ? mkLink(m[1], href) : document.createTextNode(m[1]));
          this._credit.appendChild(document.createTextNode(' on '));
          this._credit.appendChild(mkLink('Unsplash', UNSPLASH_HOMEPAGE_HREF));
        } else if (href) {
          this._credit.appendChild(mkLink(credit, href));
        } else {
          this._credit.textContent = credit;
        }
      }
      this.toggleAttribute('data-credit', showCredit);
    }
  }
  if (!customElements.get('image-slot')) {
    customElements.define('image-slot', ImageSlot);
  }
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/image-slot.js", error: String((e && e.message) || e) }); }

// ui_kits/ios_app/tweaks-panel.jsx
try { (() => {
// @ds-adherence-ignore -- omelette starter scaffold (raw elements/hex/px by design)
// Copied omelette starter. Re-running copy_starter_component with this kind overwrites this file with the latest version (page content is unaffected).

/* BEGIN USAGE */
// tweaks-panel.jsx
// Reusable Tweaks shell + form-control helpers.
// Exports (to window): useTweaks, TweaksPanel, TweakSection, TweakRow, TweakSlider,
//   TweakToggle, TweakRadio, TweakSelect, TweakText, TweakNumber, TweakColor, TweakButton.
//
// Owns the host protocol (listens for __activate_edit_mode / __deactivate_edit_mode,
// posts __edit_mode_available / __edit_mode_set_keys / __edit_mode_dismissed) so
// individual prototypes don't re-roll it. Ships a consistent set of controls so you
// don't hand-draw <input type="range">, segmented radios, steppers, etc.
//
// Usage (in an HTML file that loads React + Babel):
//
//   const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
//     "primaryColor": "#D97757",
//     "palette": ["#D97757", "#29261b", "#f6f4ef"],
//     "fontSize": 16,
//     "density": "regular",
//     "dark": false
//   }/*EDITMODE-END*/;
//
//   function App() {
//     const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
//     return (
//       <div style={{ fontSize: t.fontSize, color: t.primaryColor }}>
//         Hello
//         <TweaksPanel>
//           <TweakSection label="Typography" />
//           <TweakSlider label="Font size" value={t.fontSize} min={10} max={32} unit="px"
//                        onChange={(v) => setTweak('fontSize', v)} />
//           <TweakRadio  label="Density" value={t.density}
//                        options={['compact', 'regular', 'comfy']}
//                        onChange={(v) => setTweak('density', v)} />
//           <TweakSection label="Theme" />
//           <TweakColor  label="Primary" value={t.primaryColor}
//                        options={['#D97757', '#2A6FDB', '#1F8A5B', '#7A5AE0']}
//                        onChange={(v) => setTweak('primaryColor', v)} />
//           <TweakColor  label="Palette" value={t.palette}
//                        options={[['#D97757', '#29261b', '#f6f4ef'],
//                                  ['#475569', '#0f172a', '#f1f5f9']]}
//                        onChange={(v) => setTweak('palette', v)} />
//           <TweakToggle label="Dark mode" value={t.dark}
//                        onChange={(v) => setTweak('dark', v)} />
//         </TweaksPanel>
//       </div>
//     );
//   }
//
// TweakRadio is the segmented control for 2–3 short options (auto-falls-back to
// TweakSelect past ~16/~10 chars per label); reach for TweakSelect directly when
// options are many or long. For color tweaks always curate 3-4 options rather than
// a free picker; an option can also be a whole 2–5 color palette (the stored value
// is the array). The Tweak* controls are a floor, not a ceiling — build custom
// controls inside the panel if a tweak calls for UI they don't cover.
/* END USAGE */
// ─────────────────────────────────────────────────────────────────────────────

const __TWEAKS_STYLE = `
  .twk-panel{position:fixed;right:16px;bottom:16px;z-index:2147483646;width:280px;
    max-height:calc(100vh - 32px);display:flex;flex-direction:column;
    transform:scale(var(--dc-inv-zoom,1));transform-origin:bottom right;
    background:rgba(250,249,247,.78);color:#29261b;
    -webkit-backdrop-filter:blur(24px) saturate(160%);backdrop-filter:blur(24px) saturate(160%);
    border:.5px solid rgba(255,255,255,.6);border-radius:14px;
    box-shadow:0 1px 0 rgba(255,255,255,.5) inset,0 12px 40px rgba(0,0,0,.18);
    font:11.5px/1.4 ui-sans-serif,system-ui,-apple-system,sans-serif;overflow:hidden}
  .twk-hd{display:flex;align-items:center;justify-content:space-between;
    padding:10px 8px 10px 14px;cursor:move;user-select:none}
  .twk-hd b{font-size:12px;font-weight:600;letter-spacing:.01em}
  .twk-x{appearance:none;border:0;background:transparent;color:rgba(41,38,27,.55);
    width:22px;height:22px;border-radius:6px;cursor:default;font-size:13px;line-height:1}
  .twk-x:hover{background:rgba(0,0,0,.06);color:#29261b}
  .twk-body{padding:2px 14px 14px;display:flex;flex-direction:column;gap:10px;
    overflow-y:auto;overflow-x:hidden;min-height:0;
    scrollbar-width:thin;scrollbar-color:rgba(0,0,0,.15) transparent}
  .twk-body::-webkit-scrollbar{width:8px}
  .twk-body::-webkit-scrollbar-track{background:transparent;margin:2px}
  .twk-body::-webkit-scrollbar-thumb{background:rgba(0,0,0,.15);border-radius:4px;
    border:2px solid transparent;background-clip:content-box}
  .twk-body::-webkit-scrollbar-thumb:hover{background:rgba(0,0,0,.25);
    border:2px solid transparent;background-clip:content-box}
  .twk-row{display:flex;flex-direction:column;gap:5px}
  .twk-row-h{flex-direction:row;align-items:center;justify-content:space-between;gap:10px}
  .twk-lbl{display:flex;justify-content:space-between;align-items:baseline;
    color:rgba(41,38,27,.72)}
  .twk-lbl>span:first-child{font-weight:500}
  .twk-val{color:rgba(41,38,27,.5);font-variant-numeric:tabular-nums}

  .twk-sect{font-size:10px;font-weight:600;letter-spacing:.06em;text-transform:uppercase;
    color:rgba(41,38,27,.45);padding:10px 0 0}
  .twk-sect:first-child{padding-top:0}

  .twk-field{appearance:none;box-sizing:border-box;width:100%;min-width:0;height:26px;padding:0 8px;
    border:.5px solid rgba(0,0,0,.1);border-radius:7px;
    background:rgba(255,255,255,.6);color:inherit;font:inherit;outline:none}
  .twk-field:focus{border-color:rgba(0,0,0,.25);background:rgba(255,255,255,.85)}
  select.twk-field{padding-right:22px;
    background-image:url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='10' height='6' viewBox='0 0 10 6'><path fill='rgba(0,0,0,.5)' d='M0 0h10L5 6z'/></svg>");
    background-repeat:no-repeat;background-position:right 8px center}

  .twk-slider{appearance:none;-webkit-appearance:none;width:100%;height:4px;margin:6px 0;
    border-radius:999px;background:rgba(0,0,0,.12);outline:none}
  .twk-slider::-webkit-slider-thumb{-webkit-appearance:none;appearance:none;
    width:14px;height:14px;border-radius:50%;background:#fff;
    border:.5px solid rgba(0,0,0,.12);box-shadow:0 1px 3px rgba(0,0,0,.2);cursor:default}
  .twk-slider::-moz-range-thumb{width:14px;height:14px;border-radius:50%;
    background:#fff;border:.5px solid rgba(0,0,0,.12);box-shadow:0 1px 3px rgba(0,0,0,.2);cursor:default}

  .twk-seg{position:relative;display:flex;padding:2px;border-radius:8px;
    background:rgba(0,0,0,.06);user-select:none}
  .twk-seg-thumb{position:absolute;top:2px;bottom:2px;border-radius:6px;
    background:rgba(255,255,255,.9);box-shadow:0 1px 2px rgba(0,0,0,.12);
    transition:left .15s cubic-bezier(.3,.7,.4,1),width .15s}
  .twk-seg.dragging .twk-seg-thumb{transition:none}
  .twk-seg button{appearance:none;position:relative;z-index:1;flex:1;border:0;
    background:transparent;color:inherit;font:inherit;font-weight:500;min-height:22px;
    border-radius:6px;cursor:default;padding:4px 6px;line-height:1.2;
    overflow-wrap:anywhere}

  .twk-toggle{position:relative;width:32px;height:18px;border:0;border-radius:999px;
    background:rgba(0,0,0,.15);transition:background .15s;cursor:default;padding:0}
  .twk-toggle[data-on="1"]{background:#34c759}
  .twk-toggle i{position:absolute;top:2px;left:2px;width:14px;height:14px;border-radius:50%;
    background:#fff;box-shadow:0 1px 2px rgba(0,0,0,.25);transition:transform .15s}
  .twk-toggle[data-on="1"] i{transform:translateX(14px)}

  .twk-num{display:flex;align-items:center;box-sizing:border-box;min-width:0;height:26px;padding:0 0 0 8px;
    border:.5px solid rgba(0,0,0,.1);border-radius:7px;background:rgba(255,255,255,.6)}
  .twk-num-lbl{font-weight:500;color:rgba(41,38,27,.6);cursor:ew-resize;
    user-select:none;padding-right:8px}
  .twk-num input{flex:1;min-width:0;height:100%;border:0;background:transparent;
    font:inherit;font-variant-numeric:tabular-nums;text-align:right;padding:0 8px 0 0;
    outline:none;color:inherit;-moz-appearance:textfield}
  .twk-num input::-webkit-inner-spin-button,.twk-num input::-webkit-outer-spin-button{
    -webkit-appearance:none;margin:0}
  .twk-num-unit{padding-right:8px;color:rgba(41,38,27,.45)}

  .twk-btn{appearance:none;height:26px;padding:0 12px;border:0;border-radius:7px;
    background:rgba(0,0,0,.78);color:#fff;font:inherit;font-weight:500;cursor:default}
  .twk-btn:hover{background:rgba(0,0,0,.88)}
  .twk-btn.secondary{background:rgba(0,0,0,.06);color:inherit}
  .twk-btn.secondary:hover{background:rgba(0,0,0,.1)}

  .twk-swatch{appearance:none;-webkit-appearance:none;width:56px;height:22px;
    border:.5px solid rgba(0,0,0,.1);border-radius:6px;padding:0;cursor:default;
    background:transparent;flex-shrink:0}
  .twk-swatch::-webkit-color-swatch-wrapper{padding:0}
  .twk-swatch::-webkit-color-swatch{border:0;border-radius:5.5px}
  .twk-swatch::-moz-color-swatch{border:0;border-radius:5.5px}

  .twk-chips{display:flex;gap:6px}
  .twk-chip{position:relative;appearance:none;flex:1;min-width:0;height:46px;
    padding:0;border:0;border-radius:6px;overflow:hidden;cursor:default;
    box-shadow:0 0 0 .5px rgba(0,0,0,.12),0 1px 2px rgba(0,0,0,.06);
    transition:transform .12s cubic-bezier(.3,.7,.4,1),box-shadow .12s}
  .twk-chip:hover{transform:translateY(-1px);
    box-shadow:0 0 0 .5px rgba(0,0,0,.18),0 4px 10px rgba(0,0,0,.12)}
  .twk-chip[data-on="1"]{box-shadow:0 0 0 1.5px rgba(0,0,0,.85),
    0 2px 6px rgba(0,0,0,.15)}
  .twk-chip>span{position:absolute;top:0;bottom:0;right:0;width:34%;
    display:flex;flex-direction:column;box-shadow:-1px 0 0 rgba(0,0,0,.1)}
  .twk-chip>span>i{flex:1;box-shadow:0 -1px 0 rgba(0,0,0,.1)}
  .twk-chip>span>i:first-child{box-shadow:none}
  .twk-chip svg{position:absolute;top:6px;left:6px;width:13px;height:13px;
    filter:drop-shadow(0 1px 1px rgba(0,0,0,.3))}
`;

// ── useTweaks ───────────────────────────────────────────────────────────────
// Single source of truth for tweak values. setTweak persists via the host
// (__edit_mode_set_keys → host rewrites the EDITMODE block on disk).
function useTweaks(defaults) {
  const [values, setValues] = React.useState(defaults);
  // Accepts either setTweak('key', value) or setTweak({ key: value, ... }) so a
  // useState-style call doesn't write a "[object Object]" key into the persisted
  // JSON block.
  const setTweak = React.useCallback((keyOrEdits, val) => {
    const edits = typeof keyOrEdits === 'object' && keyOrEdits !== null ? keyOrEdits : {
      [keyOrEdits]: val
    };
    setValues(prev => ({
      ...prev,
      ...edits
    }));
    window.parent.postMessage({
      type: '__edit_mode_set_keys',
      edits
    }, '*');
    // Same-window signal so in-page listeners (deck-stage rail thumbnails)
    // can react — the parent message only reaches the host, not peers.
    window.dispatchEvent(new CustomEvent('tweakchange', {
      detail: edits
    }));
  }, []);
  return [values, setTweak];
}

// ── TweaksPanel ─────────────────────────────────────────────────────────────
// Floating shell. Registers the protocol listener BEFORE announcing
// availability — if the announce ran first, the host's activate could land
// before our handler exists and the toolbar toggle would silently no-op.
// The close button posts __edit_mode_dismissed so the host's toolbar toggle
// flips off in lockstep; the host echoes __deactivate_edit_mode back which
// is what actually hides the panel.
function TweaksPanel({
  title = 'Tweaks',
  children
}) {
  const [open, setOpen] = React.useState(false);
  const dragRef = React.useRef(null);
  const offsetRef = React.useRef({
    x: 16,
    y: 16
  });
  const PAD = 16;
  const clampToViewport = React.useCallback(() => {
    const panel = dragRef.current;
    if (!panel) return;
    const w = panel.offsetWidth,
      h = panel.offsetHeight;
    const maxRight = Math.max(PAD, window.innerWidth - w - PAD);
    const maxBottom = Math.max(PAD, window.innerHeight - h - PAD);
    offsetRef.current = {
      x: Math.min(maxRight, Math.max(PAD, offsetRef.current.x)),
      y: Math.min(maxBottom, Math.max(PAD, offsetRef.current.y))
    };
    panel.style.right = offsetRef.current.x + 'px';
    panel.style.bottom = offsetRef.current.y + 'px';
  }, []);
  React.useEffect(() => {
    if (!open) return;
    clampToViewport();
    if (typeof ResizeObserver === 'undefined') {
      window.addEventListener('resize', clampToViewport);
      return () => window.removeEventListener('resize', clampToViewport);
    }
    const ro = new ResizeObserver(clampToViewport);
    ro.observe(document.documentElement);
    return () => ro.disconnect();
  }, [open, clampToViewport]);
  React.useEffect(() => {
    const onMsg = e => {
      const t = e?.data?.type;
      if (t === '__activate_edit_mode') setOpen(true);else if (t === '__deactivate_edit_mode') setOpen(false);
    };
    window.addEventListener('message', onMsg);
    window.parent.postMessage({
      type: '__edit_mode_available'
    }, '*');
    return () => window.removeEventListener('message', onMsg);
  }, []);
  const dismiss = () => {
    setOpen(false);
    window.parent.postMessage({
      type: '__edit_mode_dismissed'
    }, '*');
  };
  const onDragStart = e => {
    const panel = dragRef.current;
    if (!panel) return;
    const r = panel.getBoundingClientRect();
    const sx = e.clientX,
      sy = e.clientY;
    const startRight = window.innerWidth - r.right;
    const startBottom = window.innerHeight - r.bottom;
    const move = ev => {
      offsetRef.current = {
        x: startRight - (ev.clientX - sx),
        y: startBottom - (ev.clientY - sy)
      };
      clampToViewport();
    };
    const up = () => {
      window.removeEventListener('mousemove', move);
      window.removeEventListener('mouseup', up);
    };
    window.addEventListener('mousemove', move);
    window.addEventListener('mouseup', up);
  };

  // data-om-starter: inert presence marker — Claude Design's starter-usage
  // probe reads it. The closed panel renders nothing, so the marker rides
  // the <html> element as an attribute instead of a rendered node — zero
  // elements added, so page CSS (even structural selectors like
  // :nth-child) can never observe it. It records that the page WIRES a
  // tweaks panel, whether or not the panel is open. Keep this effect.
  React.useEffect(() => {
    document.documentElement.setAttribute('data-om-starter', 'tweaks-panel');
    return () => document.documentElement.removeAttribute('data-om-starter');
  }, []);
  if (!open) return null;
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("style", null, __TWEAKS_STYLE), /*#__PURE__*/React.createElement("div", {
    ref: dragRef,
    className: "twk-panel",
    "data-omelette-chrome": "",
    style: {
      right: offsetRef.current.x,
      bottom: offsetRef.current.y
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "twk-hd",
    onMouseDown: onDragStart
  }, /*#__PURE__*/React.createElement("b", null, title), /*#__PURE__*/React.createElement("button", {
    className: "twk-x",
    "aria-label": "Close tweaks",
    onMouseDown: e => e.stopPropagation(),
    onClick: dismiss
  }, "\u2715")), /*#__PURE__*/React.createElement("div", {
    className: "twk-body"
  }, children)));
}

// ── Layout helpers ──────────────────────────────────────────────────────────

function TweakSection({
  label,
  children
}) {
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    className: "twk-sect"
  }, label), children);
}
function TweakRow({
  label,
  value,
  children,
  inline = false
}) {
  return /*#__PURE__*/React.createElement("div", {
    className: inline ? 'twk-row twk-row-h' : 'twk-row'
  }, /*#__PURE__*/React.createElement("div", {
    className: "twk-lbl"
  }, /*#__PURE__*/React.createElement("span", null, label), value != null && /*#__PURE__*/React.createElement("span", {
    className: "twk-val"
  }, value)), children);
}

// ── Controls ────────────────────────────────────────────────────────────────

function TweakSlider({
  label,
  value,
  min = 0,
  max = 100,
  step = 1,
  unit = '',
  onChange
}) {
  return /*#__PURE__*/React.createElement(TweakRow, {
    label: label,
    value: `${value}${unit}`
  }, /*#__PURE__*/React.createElement("input", {
    type: "range",
    className: "twk-slider",
    min: min,
    max: max,
    step: step,
    value: value,
    onChange: e => onChange(Number(e.target.value))
  }));
}
function TweakToggle({
  label,
  value,
  onChange
}) {
  return /*#__PURE__*/React.createElement("div", {
    className: "twk-row twk-row-h"
  }, /*#__PURE__*/React.createElement("div", {
    className: "twk-lbl"
  }, /*#__PURE__*/React.createElement("span", null, label)), /*#__PURE__*/React.createElement("button", {
    type: "button",
    className: "twk-toggle",
    "data-on": value ? '1' : '0',
    role: "switch",
    "aria-checked": !!value,
    onClick: () => onChange(!value)
  }, /*#__PURE__*/React.createElement("i", null)));
}
function TweakRadio({
  label,
  value,
  options,
  onChange
}) {
  const trackRef = React.useRef(null);
  const [dragging, setDragging] = React.useState(false);
  // The active value is read by pointer-move handlers attached for the lifetime
  // of a drag — ref it so a stale closure doesn't fire onChange for every move.
  const valueRef = React.useRef(value);
  valueRef.current = value;

  // Segments wrap mid-word once per-segment width runs out. The track is
  // ~248px (280 panel − 28 body pad − 4 seg pad), each button loses 12px
  // to its own padding, and 11.5px system-ui averages ~6.3px/char — so 2
  // options fit ~16 chars each, 3 fit ~10. Past that (or >3 options), fall
  // back to a dropdown rather than wrap.
  const labelLen = o => String(typeof o === 'object' ? o.label : o).length;
  const maxLen = options.reduce((m, o) => Math.max(m, labelLen(o)), 0);
  const fitsAsSegments = maxLen <= ({
    2: 16,
    3: 10
  }[options.length] ?? 0);
  if (!fitsAsSegments) {
    // <select> emits strings — map back to the original option value so the
    // fallback stays type-preserving (numbers, booleans) like the segment path.
    const resolve = s => {
      const m = options.find(o => String(typeof o === 'object' ? o.value : o) === s);
      return m === undefined ? s : typeof m === 'object' ? m.value : m;
    };
    return /*#__PURE__*/React.createElement(TweakSelect, {
      label: label,
      value: value,
      options: options,
      onChange: s => onChange(resolve(s))
    });
  }
  const opts = options.map(o => typeof o === 'object' ? o : {
    value: o,
    label: o
  });
  const idx = Math.max(0, opts.findIndex(o => o.value === value));
  const n = opts.length;
  const segAt = clientX => {
    const r = trackRef.current.getBoundingClientRect();
    const inner = r.width - 4;
    const i = Math.floor((clientX - r.left - 2) / inner * n);
    return opts[Math.max(0, Math.min(n - 1, i))].value;
  };
  const onPointerDown = e => {
    setDragging(true);
    const v0 = segAt(e.clientX);
    if (v0 !== valueRef.current) onChange(v0);
    const move = ev => {
      if (!trackRef.current) return;
      const v = segAt(ev.clientX);
      if (v !== valueRef.current) onChange(v);
    };
    const up = () => {
      setDragging(false);
      window.removeEventListener('pointermove', move);
      window.removeEventListener('pointerup', up);
    };
    window.addEventListener('pointermove', move);
    window.addEventListener('pointerup', up);
  };
  return /*#__PURE__*/React.createElement(TweakRow, {
    label: label
  }, /*#__PURE__*/React.createElement("div", {
    ref: trackRef,
    role: "radiogroup",
    onPointerDown: onPointerDown,
    className: dragging ? 'twk-seg dragging' : 'twk-seg'
  }, /*#__PURE__*/React.createElement("div", {
    className: "twk-seg-thumb",
    style: {
      left: `calc(2px + ${idx} * (100% - 4px) / ${n})`,
      width: `calc((100% - 4px) / ${n})`
    }
  }), opts.map(o => /*#__PURE__*/React.createElement("button", {
    key: o.value,
    type: "button",
    role: "radio",
    "aria-checked": o.value === value
  }, o.label))));
}
function TweakSelect({
  label,
  value,
  options,
  onChange
}) {
  return /*#__PURE__*/React.createElement(TweakRow, {
    label: label
  }, /*#__PURE__*/React.createElement("select", {
    className: "twk-field",
    value: value,
    onChange: e => onChange(e.target.value)
  }, options.map(o => {
    const v = typeof o === 'object' ? o.value : o;
    const l = typeof o === 'object' ? o.label : o;
    return /*#__PURE__*/React.createElement("option", {
      key: v,
      value: v
    }, l);
  })));
}
function TweakText({
  label,
  value,
  placeholder,
  onChange
}) {
  return /*#__PURE__*/React.createElement(TweakRow, {
    label: label
  }, /*#__PURE__*/React.createElement("input", {
    className: "twk-field",
    type: "text",
    value: value,
    placeholder: placeholder,
    onChange: e => onChange(e.target.value)
  }));
}
function TweakNumber({
  label,
  value,
  min,
  max,
  step = 1,
  unit = '',
  onChange
}) {
  const clamp = n => {
    if (min != null && n < min) return min;
    if (max != null && n > max) return max;
    return n;
  };
  const startRef = React.useRef({
    x: 0,
    val: 0
  });
  const onScrubStart = e => {
    e.preventDefault();
    startRef.current = {
      x: e.clientX,
      val: value
    };
    const decimals = (String(step).split('.')[1] || '').length;
    const move = ev => {
      const dx = ev.clientX - startRef.current.x;
      const raw = startRef.current.val + dx * step;
      const snapped = Math.round(raw / step) * step;
      onChange(clamp(Number(snapped.toFixed(decimals))));
    };
    const up = () => {
      window.removeEventListener('pointermove', move);
      window.removeEventListener('pointerup', up);
    };
    window.addEventListener('pointermove', move);
    window.addEventListener('pointerup', up);
  };
  return /*#__PURE__*/React.createElement("div", {
    className: "twk-num"
  }, /*#__PURE__*/React.createElement("span", {
    className: "twk-num-lbl",
    onPointerDown: onScrubStart
  }, label), /*#__PURE__*/React.createElement("input", {
    type: "number",
    value: value,
    min: min,
    max: max,
    step: step,
    onChange: e => onChange(clamp(Number(e.target.value)))
  }), unit && /*#__PURE__*/React.createElement("span", {
    className: "twk-num-unit"
  }, unit));
}

// Relative-luminance contrast pick — checkmarks drawn over a swatch need to
// read on both #111 and #fafafa without per-option configuration. Hex input
// only (#rgb / #rrggbb); named or rgb()/hsl() colors fall through to "light".
function __twkIsLight(hex) {
  const h = String(hex).replace('#', '');
  const x = h.length === 3 ? h.replace(/./g, c => c + c) : h.padEnd(6, '0');
  const n = parseInt(x.slice(0, 6), 16);
  if (Number.isNaN(n)) return true;
  const r = n >> 16 & 255,
    g = n >> 8 & 255,
    b = n & 255;
  return r * 299 + g * 587 + b * 114 > 148000;
}
const __TwkCheck = ({
  light
}) => /*#__PURE__*/React.createElement("svg", {
  viewBox: "0 0 14 14",
  "aria-hidden": "true"
}, /*#__PURE__*/React.createElement("path", {
  d: "M3 7.2 5.8 10 11 4.2",
  fill: "none",
  strokeWidth: "2.2",
  strokeLinecap: "round",
  strokeLinejoin: "round",
  stroke: light ? 'rgba(0,0,0,.78)' : '#fff'
}));

// TweakColor — curated color/palette picker. Each option is either a single
// hex string or an array of 1-5 hex strings; the card adapts — a lone color
// renders solid, a palette renders colors[0] as the hero (left ~2/3) with the
// rest stacked in a sharp column on the right. onChange emits the
// option in the shape it was passed (string stays string, array stays array).
// Without options it falls back to the native color input for back-compat.
function TweakColor({
  label,
  value,
  options,
  onChange
}) {
  if (!options || !options.length) {
    return /*#__PURE__*/React.createElement("div", {
      className: "twk-row twk-row-h"
    }, /*#__PURE__*/React.createElement("div", {
      className: "twk-lbl"
    }, /*#__PURE__*/React.createElement("span", null, label)), /*#__PURE__*/React.createElement("input", {
      type: "color",
      className: "twk-swatch",
      value: value,
      onChange: e => onChange(e.target.value)
    }));
  }
  // Native <input type=color> emits lowercase hex per the HTML spec, so
  // compare case-insensitively. String() guards JSON.stringify(undefined),
  // which returns the primitive undefined (no .toLowerCase).
  const key = o => String(JSON.stringify(o)).toLowerCase();
  const cur = key(value);
  return /*#__PURE__*/React.createElement(TweakRow, {
    label: label
  }, /*#__PURE__*/React.createElement("div", {
    className: "twk-chips",
    role: "radiogroup"
  }, options.map((o, i) => {
    const colors = Array.isArray(o) ? o : [o];
    const [hero, ...rest] = colors;
    const sup = rest.slice(0, 4);
    const on = key(o) === cur;
    return /*#__PURE__*/React.createElement("button", {
      key: i,
      type: "button",
      className: "twk-chip",
      role: "radio",
      "aria-checked": on,
      "data-on": on ? '1' : '0',
      "aria-label": colors.join(', '),
      title: colors.join(' · '),
      style: {
        background: hero
      },
      onClick: () => onChange(o)
    }, sup.length > 0 && /*#__PURE__*/React.createElement("span", null, sup.map((c, j) => /*#__PURE__*/React.createElement("i", {
      key: j,
      style: {
        background: c
      }
    }))), on && /*#__PURE__*/React.createElement(__TwkCheck, {
      light: __twkIsLight(hero)
    }));
  })));
}
function TweakButton({
  label,
  onClick,
  secondary = false
}) {
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    className: secondary ? 'twk-btn secondary' : 'twk-btn',
    onClick: onClick
  }, label);
}
Object.assign(window, {
  useTweaks,
  TweaksPanel,
  TweakSection,
  TweakRow,
  TweakSlider,
  TweakToggle,
  TweakRadio,
  TweakSelect,
  TweakText,
  TweakNumber,
  TweakColor,
  TweakButton
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ios_app/tweaks-panel.jsx", error: String((e && e.message) || e) }); }

// ui_kits/watch_app/WatchScreens.jsx
try { (() => {
const {
  Icon,
  ProgressRing,
  RecoveryDot
} = window.BetterFitDesignSystem_6a70ea;
const SESSION_ICON = name => /pull/i.test(name) ? 'arrow-fat-line-down' : /push/i.test(name) ? 'arrows-in-line-horizontal' : /leg/i.test(name) ? 'person-simple-run' : /cond|cardio|interval/i.test(name) ? 'heartbeat' : 'barbell';
function WatchList({
  onStart
}) {
  const d = window.BFData;
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(WatchBar, {
    title: "BetterFit"
  }), /*#__PURE__*/React.createElement(WatchScroll, null, /*#__PURE__*/React.createElement("div", {
    style: {
      background: 'var(--bf-yellow)',
      color: 'var(--bf-black)',
      borderRadius: 'var(--radius-md)',
      padding: '10px 12px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 5
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: SESSION_ICON(d.today.name),
    size: 11,
    weight: "bold"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 9,
      fontWeight: 700,
      textTransform: 'uppercase',
      letterSpacing: '.1em',
      opacity: .62
    }
  }, "Today")), /*#__PURE__*/React.createElement("div", {
    className: "bf-display",
    style: {
      fontSize: 22,
      marginTop: 2
    }
  }, d.today.name), /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      fontSize: 10,
      fontWeight: 600,
      marginTop: 4
    }
  }, d.today.exercises, " exercises \xB7 ", d.today.duration), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onStart,
    style: {
      marginTop: 10,
      width: '100%',
      minHeight: 44,
      border: 'none',
      cursor: 'pointer',
      background: 'var(--bf-black)',
      color: 'var(--bf-yellow)',
      borderRadius: 'var(--radius-md)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 6,
      fontFamily: 'var(--font-ui)',
      fontSize: 14,
      fontWeight: 600
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "play",
    size: 13
  }), "Start")), ['Push A', 'Legs A', 'Conditioning'].map(n => /*#__PURE__*/React.createElement("div", {
    key: n,
    style: {
      background: 'var(--surface)',
      border: '1px solid var(--border)',
      borderRadius: 'var(--radius-md)',
      padding: '10px 12px',
      display: 'flex',
      alignItems: 'center',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: SESSION_ICON(n),
    size: 14,
    color: "var(--accent-text)"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      fontWeight: 600,
      flex: 1
    }
  }, n), /*#__PURE__*/React.createElement(Icon, {
    name: "caret-right",
    size: 11,
    weight: "bold",
    color: "var(--text-tertiary)"
  })))));
}
function WatchActive({
  onFinish
}) {
  const d = window.BFData;
  const [set, setSet] = React.useState(1);
  const [paused, setPaused] = React.useState(false);
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(WatchBar, {
    title: d.today.name
  }), /*#__PURE__*/React.createElement(WatchScroll, null, /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 5,
      color: paused ? 'var(--text-secondary)' : 'var(--accent-text)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: paused ? 'pause' : 'timer',
    size: 11,
    weight: "bold"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 9,
      fontWeight: 700,
      textTransform: 'uppercase',
      letterSpacing: '.1em'
    }
  }, paused ? 'Paused' : 'Elapsed')), /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      fontFamily: 'var(--font-mono)',
      fontSize: 30,
      fontWeight: 700,
      marginTop: 2,
      color: paused ? 'var(--text-secondary)' : 'var(--text-primary)'
    }
  }, "18:42")), /*#__PURE__*/React.createElement("div", {
    style: {
      background: 'var(--surface)',
      border: '1px solid var(--border)',
      borderRadius: 'var(--radius-md)',
      padding: 12,
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 5
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-fat-line-down",
    size: 12,
    weight: "bold",
    color: "var(--accent-text)"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      fontWeight: 600
    }
  }, d.plan[0].name)), /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      fontSize: 26,
      fontWeight: 700,
      marginTop: 4
    }
  }, "245 ", /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      color: 'var(--text-secondary)'
    }
  }, "lb")), /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      fontSize: 11,
      color: 'var(--text-secondary)'
    }
  }, "Set ", set, " of 4 \xB7 5 reps")), /*#__PURE__*/React.createElement(WatchButton, {
    icon: "check",
    onClick: () => setSet(s => Math.min(4, s + 1))
  }, "Log set"), /*#__PURE__*/React.createElement(WatchButton, {
    icon: paused ? 'play' : 'pause',
    tone: "surface",
    onClick: () => setPaused(p => !p)
  }, paused ? 'Resume' : 'Pause'), /*#__PURE__*/React.createElement(WatchButton, {
    tone: "danger",
    onClick: onFinish
  }, "End workout")));
}
function WatchSummary({
  onDone
}) {
  const d = window.BFData;
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(WatchBar, {
    title: "Complete"
  }), /*#__PURE__*/React.createElement(WatchScroll, null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      placeItems: 'center',
      paddingTop: 4
    }
  }, /*#__PURE__*/React.createElement(ProgressRing, {
    progress: 1,
    size: 78,
    lineWidth: 9,
    tint: "var(--accent)"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "check",
    size: 26,
    weight: "bold",
    color: "var(--text-primary)"
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "bf-display",
    style: {
      fontSize: 18
    }
  }, "Good work"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 5,
      fontSize: 10,
      color: 'var(--text-secondary)',
      marginTop: 2
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: SESSION_ICON(d.today.name),
    size: 11,
    weight: "bold",
    color: "var(--accent-text)"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      whiteSpace: 'nowrap'
    }
  }, d.today.name, " \xB7 42 min"))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 6
    }
  }, [['14.2k', 'lb lifted', 'scales'], ['18', 'sets', 'stack-simple'], ['13', 'day streak', 'flame'], ['412', 'kcal', 'fire-simple']].map(([v, l, ic]) => /*#__PURE__*/React.createElement("div", {
    key: l,
    style: {
      background: 'var(--surface)',
      border: '1px solid var(--border)',
      borderRadius: 'var(--radius-sm)',
      padding: '8px 10px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 4
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: ic,
    size: 11,
    weight: "bold",
    color: "var(--accent-text)"
  }), /*#__PURE__*/React.createElement("div", {
    className: "bf-num",
    style: {
      fontSize: 15,
      fontWeight: 700
    }
  }, v)), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 9,
      color: 'var(--text-secondary)',
      marginTop: 1
    }
  }, l)))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 6,
      fontSize: 10,
      color: 'var(--text-secondary)'
    }
  }, /*#__PURE__*/React.createElement(RecoveryDot, {
    status: "fatigued",
    size: 8
  }), /*#__PURE__*/React.createElement("span", null, "Back is now fatigued")), /*#__PURE__*/React.createElement(WatchButton, {
    tone: "surface",
    onClick: onDone
  }, "Done")));
}
Object.assign(window, {
  WatchList,
  WatchActive,
  WatchSummary
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/watch_app/WatchScreens.jsx", error: String((e && e.message) || e) }); }

// ui_kits/watch_app/WatchShell.jsx
try { (() => {
const {
  Icon
} = window.BetterFitDesignSystem_6a70ea;

/** 45mm Apple Watch screen: 396×484 logical points, 44px corner radius. */
function Watch({
  children
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      padding: 14,
      background: 'linear-gradient(160deg,#3a3a3f,#111114)',
      borderRadius: 74,
      boxShadow: '0 24px 60px rgba(0,0,0,.6)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 198,
      height: 242,
      background: 'var(--bg-page)',
      color: 'var(--text-primary)',
      borderRadius: 44,
      overflow: 'hidden',
      display: 'flex',
      flexDirection: 'column',
      fontFamily: 'var(--font-ui)'
    }
  }, children));
}
function WatchBar({
  title
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: '0 0 auto',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '8px 14px 4px'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 11,
      fontWeight: 600,
      color: 'var(--accent-text)'
    }
  }, title), /*#__PURE__*/React.createElement("span", {
    className: "bf-num",
    style: {
      fontSize: 11,
      fontWeight: 600
    }
  }, "9:41"));
}
function WatchScroll({
  children
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: '4px 10px 12px',
      display: 'flex',
      flexDirection: 'column',
      gap: 8,
      scrollbarWidth: 'none',
      msOverflowStyle: 'none'
    }
  }, children);
}

/** Full-width watch control — larger and simpler than its phone equivalent. */
function WatchButton({
  children,
  icon,
  tone = 'accent',
  onClick
}) {
  const tones = {
    accent: {
      background: 'var(--accent)',
      color: 'var(--text-on-accent)',
      border: '1px solid transparent'
    },
    surface: {
      background: 'var(--surface-raised)',
      color: 'var(--text-primary)',
      border: '1px solid var(--border)'
    },
    success: {
      background: 'var(--yellow-bright)',
      color: 'var(--bf-black)',
      border: '1px solid transparent'
    },
    danger: {
      background: 'transparent',
      color: 'var(--text-primary)',
      border: '1px solid var(--border-strong)'
    }
  };
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onClick,
    style: {
      ...tones[tone],
      width: '100%',
      minHeight: 44,
      borderRadius: 'var(--radius-md)',
      cursor: 'pointer',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 6,
      fontSize: 14,
      fontWeight: 600,
      fontFamily: 'var(--font-ui)'
    }
  }, icon && /*#__PURE__*/React.createElement(Icon, {
    name: icon,
    size: 14
  }), children);
}
Object.assign(window, {
  Watch,
  WatchBar,
  WatchScroll,
  WatchButton
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/watch_app/WatchShell.jsx", error: String((e && e.message) || e) }); }

__ds_ns.Button = __ds_scope.Button;

__ds_ns.Card = __ds_scope.Card;

__ds_ns.Chip = __ds_scope.Chip;

__ds_ns.Divider = __ds_scope.Divider;

__ds_ns.DropdownChip = __ds_scope.DropdownChip;

__ds_ns.Icon = __ds_scope.Icon;

__ds_ns.IconButton = __ds_scope.IconButton;

__ds_ns.Logo = __ds_scope.Logo;

__ds_ns.MetricPill = __ds_scope.MetricPill;

__ds_ns.PhotoSlot = __ds_scope.PhotoSlot;

__ds_ns.SectionHeader = __ds_scope.SectionHeader;

__ds_ns.ContributionHeatmap = __ds_scope.ContributionHeatmap;

__ds_ns.Gauge = __ds_scope.Gauge;

__ds_ns.LegendDot = __ds_scope.LegendDot;

__ds_ns.MuscleChip = __ds_scope.MuscleChip;

__ds_ns.OverviewStat = __ds_scope.OverviewStat;

__ds_ns.ProgressRing = __ds_scope.ProgressRing;

__ds_ns.StatTile = __ds_scope.StatTile;

__ds_ns.Banner = __ds_scope.Banner;

__ds_ns.EmptyState = __ds_scope.EmptyState;

__ds_ns.RecoveryBadge = __ds_scope.RecoveryBadge;

__ds_ns.RECOVERY_COLORS = __ds_scope.RECOVERY_COLORS;

__ds_ns.RecoveryDot = __ds_scope.RecoveryDot;

__ds_ns.RestTimerBar = __ds_scope.RestTimerBar;

__ds_ns.ChevronRow = __ds_scope.ChevronRow;

__ds_ns.ExerciseRow = __ds_scope.ExerciseRow;

__ds_ns.ListRow = __ds_scope.ListRow;

__ds_ns.SettingsRow = __ds_scope.SettingsRow;

__ds_ns.SetLogField = __ds_scope.SetLogField;

__ds_ns.SupersetIndicator = __ds_scope.SupersetIndicator;

__ds_ns.WeightUnitToggle = __ds_scope.WeightUnitToggle;

__ds_ns.WorkoutCard = __ds_scope.WorkoutCard;

})();
