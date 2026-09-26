const { Icon } = window.BetterFitDesignSystem_6a70ea;

/** 45mm Apple Watch screen: 396×484 logical points, 44px corner radius. */
function Watch({ children }) {
  return (
    <div style={{ position: 'relative', padding: 14, background: 'linear-gradient(160deg,#3a3a3f,#111114)', borderRadius: 74, boxShadow: '0 24px 60px rgba(0,0,0,.6)' }}>
      <div style={{
        width: 198, height: 242, background: 'var(--bg-page)', color: 'var(--text-primary)',
        borderRadius: 44, overflow: 'hidden', display: 'flex', flexDirection: 'column', fontFamily: 'var(--font-ui)'
      }}>{children}</div>
    </div>
  );
}

function WatchBar({ title }) {
  return (
    <div style={{ flex: '0 0 auto', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '8px 14px 4px' }}>
      <span style={{ fontSize: 11, fontWeight: 600, color: 'var(--accent-text)' }}>{title}</span>
      <span className="bf-num" style={{ fontSize: 11, fontWeight: 600 }}>9:41</span>
    </div>
  );
}

function WatchScroll({ children }) {
  return <div style={{ flex: 1, overflowY: 'auto', padding: '4px 10px 12px', display: 'flex', flexDirection: 'column', gap: 8, scrollbarWidth: 'none', msOverflowStyle: 'none' }}>{children}</div>;
}

/** Full-width watch control — larger and simpler than its phone equivalent. */
function WatchButton({ children, icon, tone = 'accent', onClick }) {
  const tones = {
    accent: { background: 'var(--accent)', color: 'var(--text-on-accent)', border: '1px solid transparent' },
    surface: { background: 'var(--surface-raised)', color: 'var(--text-primary)', border: '1px solid var(--border)' },
    success: { background: 'var(--yellow-bright)', color: 'var(--bf-black)', border: '1px solid transparent' },
    danger: { background: 'transparent', color: 'var(--text-primary)', border: '1px solid var(--border-strong)' }
  };
  return (
    <button type="button" onClick={onClick} style={{
      ...tones[tone], width: '100%', minHeight: 44, borderRadius: 'var(--radius-md)', cursor: 'pointer',
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
      fontSize: 14, fontWeight: 600, fontFamily: 'var(--font-ui)'
    }}>
      {icon && <Icon name={icon} size={14} />}{children}
    </button>
  );
}

Object.assign(window, { Watch, WatchBar, WatchScroll, WatchButton });
