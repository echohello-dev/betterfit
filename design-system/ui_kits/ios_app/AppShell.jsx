const { Icon, Logo } = window.BetterFitDesignSystem_6a70ea;

/* ---- Tweak context ----
   Three cross-cutting choices the whole kit reads: how chrome sits over the page,
   how tightly the ledger is packed, and how much yellow the app spends. */
const BFT_DEFAULT = { chrome: 'glass', density: 'standard', accent: 'balanced', artwork: 'icon' };
const BFTweakCtx = React.createContext(BFT_DEFAULT);
const useBFT = () => React.useContext(BFTweakCtx);

const DENSITY = {
  roomy:    { rowPy: 18, gutter: 38, sectPt: 34, metaGap: 5, title: 17 },
  standard: { rowPy: 14, gutter: 32, sectPt: 26, metaGap: 3, title: 17 },
  compact:  { rowPy: 9,  gutter: 26, sectPt: 18, metaGap: 1, title: 15 }
};

const TABS = [
  { id: 'workout', label: 'Workout', icon: 'barbell' },
  { id: 'body', label: 'Body', icon: 'person-simple-run' },
  { id: 'targets', label: 'Targets', icon: 'crosshair' },
  { id: 'log', label: 'Log', icon: 'calendar-blank' }
];

function StatusBar() {
  return (
    <div style={{ height: 48, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 24px', color: 'var(--text-primary)', fontSize: 14, fontWeight: 600, flex: '0 0 48px' }}>
      <span className="bf-num">9:41</span>
      <span style={{ display: 'inline-flex', gap: 5, alignItems: 'center' }}>
        <Icon name="cell-signal-full" size={14} /><Icon name="wifi-high" size={14} /><Icon name="battery-full" size={16} />
      </span>
    </div>
  );
}

/** Floating glass nav, or an opaque bar welded to the layout — see the `chrome` tweak. */
function TabBar({ active, onChange }) {
  const { chrome } = useBFT();
  const solid = chrome === 'solid';
  const compact = chrome === 'compact';
  const shell = solid
    ? { position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 40 }
    : { position: 'absolute', left: compact ? 60 : 12, right: compact ? 60 : 12, bottom: compact ? 16 : 12, zIndex: 40 };
  const inner = solid
    ? { background: 'var(--bg-elevated)', borderTop: '1px solid var(--border)', borderRadius: 0, padding: '6px 8px 22px', boxShadow: 'none' }
    : {
      background: 'var(--glass-fill)', WebkitBackdropFilter: 'var(--glass-blur)', backdropFilter: 'var(--glass-blur)',
      border: '1px solid var(--glass-border)', borderRadius: 32, padding: 6, boxShadow: 'var(--glass-shadow), inset 0 1px 0 rgba(255,255,255,.16)'
    };
  return (
    <div style={shell}>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4,1fr)', gap: 4, ...inner }}>
        {TABS.map((t) => {
          const on = t.id === active;
          return (
            <button key={t.id} type="button" onClick={() => onChange(t.id)} aria-label={t.label}
              style={{
                background: on && !solid ? 'var(--glass-highlight)' : 'transparent', border: 'none', cursor: 'pointer',
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3, padding: compact ? '0' : '9px 0 7px',
                borderRadius: 'var(--radius-pill)', minHeight: 52, color: on ? 'var(--accent-text)' : 'var(--text-tertiary)'
              }}>
              <Icon name={t.icon} size={21} />
              {!compact && <span style={{ fontSize: 10, fontWeight: 700, letterSpacing: '0.01em' }}>{t.label}</span>}
            </button>
          );
        })}
      </div>
    </div>
  );
}

function NavBar({ title, leading, trailing }) {
  return (
    <div style={{ flex: '0 0 auto', display: 'flex', alignItems: 'center', gap: 12, padding: '4px 20px 12px' }}>
      <div style={{ flex: '0 0 auto', minWidth: 44 }}>{leading}</div>
      <div style={{ flex: 1, textAlign: 'center', fontSize: 'var(--text-headline)', fontWeight: 'var(--weight-semibold)' }}>{title}</div>
      <div style={{ flex: '0 0 auto', minWidth: 44, display: 'flex', justifyContent: 'flex-end' }}>{trailing}</div>
    </div>
  );
}

function Phone({ children, scheme = 'dark', tweaks = BFT_DEFAULT }) {
  const d = DENSITY[tweaks.density] || DENSITY.standard;
  return (
    <BFTweakCtx.Provider value={tweaks}>
      <div data-scheme={scheme} style={{
        width: 390, height: 844, background: 'var(--bg-page)', color: 'var(--text-primary)',
        borderRadius: 44, overflow: 'hidden', display: 'flex', flexDirection: 'column',
        boxShadow: '0 30px 80px rgba(0,0,0,.55), 0 0 0 10px #1b1b1f', position: 'relative', fontFamily: 'var(--font-ui)',
        '--l-row-py': d.rowPy + 'px', '--l-gutter': d.gutter + 'px', '--l-sect-pt': d.sectPt + 'px',
        '--l-meta-gap': d.metaGap + 'px', '--l-title': d.title + 'px'
      }}>
        {children}
      </div>
    </BFTweakCtx.Provider>
  );
}

/** Non-Ledger screens scroll through here. Bottom padding clears the floating nav. */
function Scroll({ children, pad = true }) {
  return (
    <div style={{ flex: 1, overflowY: 'auto', overflowX: 'hidden', padding: pad ? '0 20px 100px' : '0 0 100px', scrollbarWidth: 'none', msOverflowStyle: 'none' }}>{children}</div>
  );
}

/** Keeps one broken screen from blanking the whole kit. */
class ScreenBoundary extends React.Component {
  constructor(p) { super(p); this.state = { error: null }; }
  static getDerivedStateFromError(error) { return { error }; }
  componentDidUpdate(prev) { if (prev.screenKey !== this.props.screenKey && this.state.error) this.setState({ error: null }); }
  render() {
    if (!this.state.error) return this.props.children;
    return (
      <div style={{ flex: 1, display: 'grid', placeItems: 'center', padding: 24, textAlign: 'center' }}>
        <div>
          <div style={{ fontSize: 'var(--text-headline)', fontWeight: 'var(--weight-semibold)' }}>This screen didn't load</div>
          <div style={{ fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)', marginTop: 6, maxWidth: 260, textWrap: 'pretty' }}>
            Usually a stale <code>_ds_bundle.js</code>. Pick another screen below, or reload once the bundle recompiles.
          </div>
          <div style={{ fontFamily: 'var(--font-mono)', fontSize: 11, color: 'var(--text-tertiary)', marginTop: 10 }}>
            {String(this.state.error && this.state.error.message).slice(0, 120)}
          </div>
        </div>
      </div>
    );
  }
}

/** Destructure DS components through this so a missing export degrades instead of throwing. */
function dsPick(names) {
  const NS = window.BetterFitDesignSystem_6a70ea || {};
  const out = {};
  for (const n of names) {
    out[n] = NS[n] || function Missing() {
      return <span style={{ fontSize: 11, fontFamily: 'var(--font-mono)', color: 'var(--text-tertiary)' }}>[{n}]</span>;
    };
  }
  return out;
}

/* ---- The Ledger: reimagined screen layout primitives ----
   Rules, not cards. A 46px mono gutter runs down every list. One squared
   full-bleed yellow slab per screen carries the number that matters and the
   single primary action, so nothing floats over the content. */

/** Uppercase micro label. */
function Eyebrow({ children, style }) {
  return <div style={{ fontSize: 11, fontWeight: 'var(--weight-bold)', textTransform: 'uppercase', letterSpacing: '0.14em', ...style }}>{children}</div>;
}

/** The screen's yellow moment: full bleed, squared, black ink. Goes neutral when the
    `accent` tweak is restrained — the yellow then lives on the docked action instead. */
function Slab({ children, style }) {
  const { accent } = useBFT();
  const quiet = accent === 'restrained';
  return <div style={{
    background: quiet ? 'transparent' : 'var(--bf-yellow)',
    color: quiet ? 'var(--text-primary)' : 'var(--bf-black)',
    borderBottom: quiet ? '1px solid var(--separator)' : 'none',
    padding: '18px 20px 20px', ...style
  }}>{children}</div>;
}

/** Primary action, inverted so it reads on the yellow field. */
function SlabAction({ icon, children, onClick, tone = 'ink' }) {
  const { accent } = useBFT();
  const onYellow = accent !== 'restrained';
  const ink = tone === 'ink';
  const fill = onYellow ? (ink ? 'var(--bf-black)' : 'transparent') : 'var(--accent)';
  const label = onYellow ? (ink ? 'var(--bf-yellow)' : 'var(--bf-black)') : 'var(--text-on-accent)';
  return (
    <button type="button" onClick={onClick} style={{
      width: '100%', height: 'var(--control-lg)', marginTop: 16, cursor: 'pointer',
      border: onYellow && !ink ? '1.5px solid rgba(0,0,0,.28)' : 'none',
      background: fill, color: label, borderRadius: 'var(--radius-button)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9,
      fontFamily: 'var(--font-ui)', fontSize: 'var(--text-headline)', fontWeight: 'var(--weight-semibold)'
    }}>{icon && <Icon name={icon} size={16} />}{children}</button>
  );
}

/** Mono spec strip — the two or three facts that qualify the slab's headline. */
function SpecStrip({ items, style }) {
  return (
    <div className="bf-num" style={{ display: 'flex', gap: 18, marginTop: 12, ...style }}>
      {items.map((it) => (
        <div key={it.label}>
          <div style={{ fontSize: 22, fontWeight: 'var(--weight-bold)', lineHeight: 1 }}>{it.value}</div>
          <div style={{ fontSize: 10, fontWeight: 'var(--weight-semibold)', textTransform: 'uppercase', letterSpacing: '0.1em', opacity: 0.58, marginTop: 5, fontFamily: 'var(--font-ui)' }}>{it.label}</div>
        </div>
      ))}
    </div>
  );
}

/** Section marker: label, then a hairline that runs to the trailing value. */
function SectionRule({ label, trailing, style }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: 'var(--l-sect-pt, 26px) 0 10px', ...style }}>
      <Eyebrow style={{ color: 'var(--text-secondary)', flex: '0 0 auto' }}>{label}</Eyebrow>
      <span style={{ flex: 1, height: 1, background: 'var(--separator)' }} />
      {trailing && <span className="bf-num" style={{ fontSize: 12, color: 'var(--text-tertiary)', flex: '0 0 auto' }}>{trailing}</span>}
    </div>
  );
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
    mo.observe(el, { attributes: true, attributeFilter: ['data-filled'] });
    return () => mo.disconnect();
  }, [el]);
  return [filled, setEl];
}

/** Rounded artwork tile that replaces the mono gutter when rows carry art. */
function ArtTile({ icon, size = 38 }) {
  return (
    <span style={{
      flex: `0 0 ${size}px`, width: size, height: size, borderRadius: 11,
      background: 'var(--surface-raised)', border: '1px solid var(--border)',
      display: 'grid', placeItems: 'center', color: 'var(--accent-text)',
      position: 'relative', zIndex: 2
    }}><Icon name={icon || 'barbell'} size={19} /></span>
  );
}

/** One ruled ledger row. `gutter` is the mono index/date column; `art` opts the row
    into the `artwork` tweak — {icon, slot, label} for an icon tile or a photo bed. */
function LedgerRow({ gutter, gutterAccent, title, titleIcon, meta, trailing, trailingMeta, accent, dim, chevron, onClick, art, children }) {
  const { artwork } = useBFT();
  const [filled, slotRef] = useSlotFilled();
  const mode = art ? artwork : 'plain';
  const photo = mode === 'photo';
  const bed = photo && filled;
  const Tag = onClick ? 'button' : 'div';
  const slot = photo ? <image-slot ref={slotRef} id={art.slot} shape="rect" fit="cover" placeholder=" "></image-slot> : null;
  const row = (
    <Tag type={onClick ? 'button' : undefined} onClick={onClick} style={{
      display: 'flex', alignItems: photo || mode === 'icon' ? 'center' : 'flex-start', gap: 14, width: '100%', textAlign: 'left',
      padding: 'var(--l-row-py, 14px) 0', minHeight: photo ? 78 : undefined,
      borderTop: '1px solid var(--separator)', background: 'none', border: 'none',
      borderTopWidth: 1, borderTopStyle: 'solid', borderTopColor: 'var(--separator)',
      color: 'inherit', font: 'inherit', cursor: onClick ? 'pointer' : 'default',
      position: 'relative', opacity: dim ? 0.45 : 1, fontFamily: 'var(--font-ui)'
    }}>
      {accent && <span style={{ position: 'absolute', left: -20, top: 0, bottom: 0, width: 3, background: 'var(--accent)', zIndex: 3 }} />}
      {photo && (
        filled ? (
          <>
            <span aria-hidden="true" style={{ position: 'absolute', top: 1, bottom: 0, left: 0, right: -20, overflow: 'hidden', zIndex: 0 }}>{slot}</span>
            <span aria-hidden="true" style={{
              position: 'absolute', top: 1, bottom: 0, left: -20, right: -20, zIndex: 1, pointerEvents: 'none',
              background: 'linear-gradient(90deg, var(--bg-page) 0%, color-mix(in oklab, var(--bg-page) 88%, transparent) 46%, color-mix(in oklab, var(--bg-page) 58%, transparent) 100%)'
            }} />
          </>
        ) : (
          <span style={{ position: 'absolute', top: 1, bottom: 0, right: -20, width: 152, overflow: 'hidden', zIndex: 0 }}>{slot}</span>
        )
      )}
      {mode === 'icon' || photo
        ? <ArtTile icon={art.icon} />
        : <span className="bf-num" style={{ flex: '0 0 var(--l-gutter, 32px)', fontSize: 15, fontWeight: 'var(--weight-bold)', color: gutterAccent ? 'var(--accent-text)' : 'var(--text-tertiary)', paddingTop: 2 }}>{gutter}</span>}
      <span style={{ flex: 1, minWidth: 0, position: 'relative', zIndex: 2, marginRight: photo && !filled ? 148 : 0 }}>
        <span style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 'var(--l-title, var(--text-body))', fontWeight: 'var(--weight-semibold)', textWrap: 'pretty' }}>
          {titleIcon && <Icon name={titleIcon} size={16} weight="bold" color="var(--accent-text)" />}{title}
        </span>
        {(meta || (photo && !filled && (trailing || trailingMeta))) && (
          <span style={{ display: 'block', fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)', marginTop: 'var(--l-meta-gap, 3px)' }}>
            {photo && !filled && (trailing || trailingMeta)
              ? [trailing, trailingMeta, meta].filter(Boolean).join(' · ')
              : meta}
          </span>
        )}
        {children}
      </span>
      {(trailing || trailingMeta) && !(photo && !filled) && (
        <span style={{
          flex: '0 0 auto', textAlign: 'right', paddingTop: 1, position: 'relative', zIndex: 2,
          ...(bed ? {
            padding: '4px 8px', marginRight: -4, borderRadius: 8,
            background: 'color-mix(in oklab, var(--bg-page) 78%, transparent)',
            WebkitBackdropFilter: 'blur(10px)', backdropFilter: 'blur(10px)'
          } : null)
        }}>
          <span className="bf-num" style={{ display: 'block', fontSize: 'var(--text-subheadline)', fontWeight: 'var(--weight-semibold)' }}>{trailing}</span>
          {trailingMeta && <span className="bf-num" style={{ display: 'block', fontSize: 'var(--text-caption)', color: 'var(--text-tertiary)', marginTop: 3 }}>{trailingMeta}</span>}
        </span>
      )}
      {chevron && <Icon name="caret-right" size={14} weight="bold" color="var(--text-tertiary)" style={{ marginTop: 4, position: 'relative', zIndex: 2 }} />}
    </Tag>
  );
  return photo ? <div style={{ position: 'relative', overflow: 'hidden' }}>{row}</div> : row;
}

/** Conclusion first: the value, its label, then the sentence that interprets it. */
function Readout({ value, unit, label, note, style }) {
  return (
    <div style={{ padding: '10px 0 4px', ...style }}>
      <Eyebrow style={{ color: 'var(--text-secondary)' }}>{label}</Eyebrow>
      <div className="bf-num" style={{ display: 'flex', alignItems: 'baseline', gap: 6, marginTop: 10 }}>
        <span style={{ fontSize: 64, fontWeight: 'var(--weight-bold)', lineHeight: 0.9, letterSpacing: '-0.03em' }}>{value}</span>
        {unit && <span style={{ fontSize: 22, fontWeight: 'var(--weight-bold)', color: 'var(--text-secondary)' }}>{unit}</span>}
      </div>
      {note && <div style={{ fontSize: 'var(--text-subheadline)', color: 'var(--text-secondary)', marginTop: 12, maxWidth: 300, textWrap: 'pretty' }}>{note}</div>}
    </div>
  );
}

/** Flat 4px bar on the yellow ladder. Never a ring. */
function Bar({ pct, color = 'var(--accent)', style }) {
  return (
    <span style={{ display: 'block', height: 4, background: 'var(--surface-raised)', borderRadius: 2, overflow: 'hidden', ...style }}>
      <span style={{ display: 'block', height: '100%', width: `${Math.max(2, Math.min(100, pct))}%`, background: color }} />
    </span>
  );
}

/** Trailing row that opens the exercise picker. Plus sits in the gutter. */
function AddRow({ onClick, label = 'Add exercise' }) {
  return (
    <button type="button" onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 14, width: '100%', padding: '16px 0',
      borderTop: '1px solid var(--separator)', background: 'none', border: 'none', borderTopWidth: 1, borderTopStyle: 'solid', borderTopColor: 'var(--separator)',
      cursor: 'pointer', color: 'var(--accent-text)', fontFamily: 'var(--font-ui)', fontSize: 'var(--text-body)', fontWeight: 'var(--weight-semibold)'
    }}>
      <span style={{ flex: '0 0 var(--l-gutter, 32px)', display: 'flex' }}><Icon name="plus" size={16} weight="bold" /></span>{label}
    </button>
  );
}

/** Screen title line that sits above a slab or a readout. */
function LedgerHead({ title, right }) {
  return (
    <div style={{ flex: '0 0 auto', display: 'flex', alignItems: 'center', gap: 12, padding: '0 20px 14px' }}>
      <span className="bf-display" style={{ flex: 1, fontSize: 26 }}>{title}</span>
      {right}
    </div>
  );
}

/** Neutral page header for ACTION screens — unless the `accent` tweak is bold, in which
    case it takes the full yellow field and the docked action goes quiet. */
function HeaderBlock({ eyebrow, title, spec, children, style }) {
  const { accent } = useBFT();
  const yellow = accent === 'bold';
  return (
    <div style={{
      padding: '4px 20px 20px',
      background: yellow ? 'var(--bf-yellow)' : 'transparent',
      color: yellow ? 'var(--bf-black)' : 'var(--text-primary)',
      borderBottom: yellow ? 'none' : '1px solid var(--separator)', ...style
    }}>
      {eyebrow && <Eyebrow style={{ color: yellow ? 'inherit' : 'var(--accent-text)', opacity: yellow ? 0.62 : 1 }}>{eyebrow}</Eyebrow>}
      {title && <h1 className="bf-display" style={{ margin: '10px 0 0', fontSize: 44, lineHeight: 0.94 }}>{title}</h1>}
      {spec && <SpecStrip items={spec} style={{ marginTop: 14 }} />}
      {children}
    </div>
  );
}

/** Floating glass dock — or an opaque tray when the `chrome` tweak is solid. */
function GlassDock({ children, lift = 88, style }) {
  const { chrome } = useBFT();
  const solid = chrome === 'solid';
  return (
    <div style={{
      position: 'absolute', left: solid ? 0 : 12, right: solid ? 0 : 12,
      bottom: solid ? (lift > 40 ? 74 : 0) : lift, zIndex: 35,
      background: solid ? 'var(--bg-elevated)' : 'var(--glass-fill-strong)',
      WebkitBackdropFilter: solid ? 'none' : 'var(--glass-blur)', backdropFilter: solid ? 'none' : 'var(--glass-blur)',
      border: solid ? 'none' : '1px solid var(--glass-border)', borderTop: solid ? '1px solid var(--border)' : undefined,
      borderRadius: solid ? 0 : 34, boxShadow: solid ? 'none' : 'var(--glass-shadow), inset 0 1px 0 rgba(255,255,255,.16)',
      padding: solid ? '12px 16px' : 10, display: 'flex', gap: 8, alignItems: 'center', ...style
    }}>{children}</div>
  );
}

/** The docked primary action. Wears the yellow unless the `accent` tweak has spent it
    on a full-bleed header instead — exactly one yellow fill per screen, always. */
function PrimaryAction({ icon, children, onClick, style }) {
  const { accent } = useBFT();
  const quiet = accent === 'bold';
  return (
    <button type="button" onClick={onClick} style={{
      flex: 1, height: 'var(--control-lg)', cursor: 'pointer',
      border: quiet ? '1px solid var(--glass-border)' : 'none',
      background: quiet ? 'var(--glass-highlight)' : 'var(--accent)',
      color: quiet ? 'var(--text-primary)' : 'var(--text-on-accent)',
      borderRadius: 'var(--radius-pill)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9,
      boxShadow: quiet ? 'inset 0 1px 0 rgba(255,255,255,.14)' : 'none',
      fontFamily: 'var(--font-ui)', fontSize: 'var(--text-headline)', fontWeight: 'var(--weight-semibold)', ...style
    }}>{icon && <Icon name={icon} size={17} />}{children}</button>
  );
}

/** Square glass companion button beside the primary action. */
function DockButton({ icon, label, onClick }) {
  return (
    <button type="button" onClick={onClick} aria-label={label} title={label} style={{
      width: 'var(--control-lg)', height: 'var(--control-lg)', flex: '0 0 var(--control-lg)', cursor: 'pointer',
      borderRadius: 'var(--radius-pill)', boxShadow: 'inset 0 1px 0 rgba(255,255,255,.14)',
      background: 'var(--glass-highlight)', border: '1px solid var(--glass-border)', color: 'var(--text-primary)',
      display: 'grid', placeItems: 'center'
    }}><Icon name={icon} size={19} weight="bold" /></button>
  );
}

/** Horizontal quick-action strip. Small, glassy, always one tap from the list. */
function QuickActions({ items, style }) {
  return (
    <div style={{ display: 'flex', gap: 8, overflowX: 'auto', scrollbarWidth: 'none', msOverflowStyle: 'none', padding: '0 20px', ...style }}>
      {items.map((it) => (
        <button key={it.label} type="button" onClick={it.onClick} style={{
          flex: '0 0 auto', display: 'inline-flex', alignItems: 'center', gap: 7, height: 'var(--tap-min)', padding: '0 16px',
          borderRadius: 'var(--radius-pill)', cursor: 'pointer',
          background: 'var(--glass-fill)', WebkitBackdropFilter: 'var(--glass-blur)', backdropFilter: 'var(--glass-blur)',
          border: '1px solid var(--glass-border)', color: 'var(--text-primary)',
          fontFamily: 'var(--font-ui)', fontSize: 'var(--text-footnote)', fontWeight: 'var(--weight-semibold)'
        }}>
          <Icon name={it.icon} size={15} weight="bold" color="var(--accent-text)" />{it.label}
        </button>
      ))}
    </div>
  );
}

/** Swipe a ledger row either way to reveal actions. Drag, or tap the row's
    trailing handle. `left`/`right` are the edges the actions sit on. */
function SwipeRow({ left = [], right = [], accent, children }) {
  const W = 84;
  const [x, setX] = React.useState(0);
  const drag = React.useRef(null);
  const openL = left.length * W, openR = right.length * W;

  const down = (e) => { drag.current = { start: e.clientX, from: x }; e.currentTarget.setPointerCapture(e.pointerId); };
  const move = (e) => {
    if (!drag.current) return;
    const next = drag.current.from + (e.clientX - drag.current.start);
    setX(Math.max(-openR, Math.min(openL, next)));
  };
  const up = () => {
    if (!drag.current) return;
    drag.current = null;
    setX((v) => (v <= -openR / 2 ? -openR : v >= openL / 2 ? openL : 0));
  };

  const Face = ({ actions, side }) => (
    <div style={{ position: 'absolute', top: 0, bottom: 0, [side]: 0, display: 'flex' }}>
      {actions.map((a) => (
        <button key={a.label} type="button" onClick={() => { setX(0); a.onClick && a.onClick(); }} style={{
          width: W, cursor: 'pointer', border: 'none', display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center', gap: 5,
          background: a.destructive ? 'var(--text-primary)' : 'var(--glass-fill-strong)',
          WebkitBackdropFilter: 'var(--glass-blur)', backdropFilter: 'var(--glass-blur)',
          color: a.destructive ? 'var(--bg-page)' : 'var(--text-primary)',
          fontFamily: 'var(--font-ui)', fontSize: 11, fontWeight: 'var(--weight-bold)'
        }}>
          <Icon name={a.icon} size={18} weight="bold" />{a.label}
        </button>
      ))}
    </div>
  );

  return (
    <div style={{ position: 'relative', overflow: 'hidden', touchAction: 'pan-y', margin: '0 -20px' }}>
      {!!openL && <Face actions={left} side="left" />}
      {!!openR && <Face actions={right} side="right" />}
      <div onPointerDown={down} onPointerMove={move} onPointerUp={up} onPointerCancel={up}
        style={{
          transform: `translateX(${x}px)`, transition: drag.current ? 'none' : 'transform var(--dur-fast) var(--ease-snappy)',
          background: 'var(--bg-page)', cursor: 'grab', position: 'relative', padding: '0 20px'
        }}>{accent && <span style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: 3, background: 'var(--accent)' }} />}{children}</div>
    </div>
  );
}

Object.assign(window, {
  StatusBar, TabBar, NavBar, Phone, Scroll, ScreenBoundary, dsPick, BFTABS: TABS,
  Eyebrow, Slab, SlabAction, SpecStrip, SectionRule, LedgerRow, ArtTile, Readout, Bar, AddRow, LedgerHead,
  HeaderBlock, GlassDock, PrimaryAction, DockButton, QuickActions, SwipeRow, useBFT, BFT_DEFAULT
});
