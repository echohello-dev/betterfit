const { Icon } = dsPick(['Icon']);

const D = window.BFData;
const WORD = { recovered: 'Recovered', fresh: 'Ready', fatigued: 'Fatigued', sore: 'Sore' };
const TONE = { recovered: 'var(--recovery-recovered)', fresh: 'var(--recovery-fresh)', fatigued: 'var(--recovery-fatigued)', sore: 'var(--recovery-sore)' };
const LAST = { Chest: '1 day ago', Back: '4 days ago', Shoulders: '2 days ago', Arms: '3 days ago', Core: '5 days ago', Legs: '3 days ago' };
const REGION_ICON = {
  Chest: 'arrows-in-line-horizontal', Back: 'arrow-fat-line-down', Shoulders: 'arrows-out-line-horizontal',
  Arms: 'barbell', Core: 'circle-half-tilt', Legs: 'person-simple-run'
};

/** Recovery reads as a ruled bar chart: one row per group, bars on a shared left axis. */
function RecoveryRow({ r }) {
  return (
    <div style={{ padding: '13px 0', borderTop: '1px solid var(--separator)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <span style={{ flex: '0 0 var(--l-gutter, 32px)', display: 'flex', color: TONE[r.status] }}>
          <Icon name={REGION_ICON[r.region] || 'barbell'} size={19} />
        </span>
        <span style={{ flex: 1, fontSize: 'var(--l-title, var(--text-body))', fontWeight: 'var(--weight-semibold)' }}>{r.region}</span>
        <span style={{ fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)' }}>{WORD[r.status]}</span>
        <span className="bf-num" style={{ flex: '0 0 42px', textAlign: 'right', fontSize: 'var(--text-subheadline)', fontWeight: 'var(--weight-semibold)' }}>{r.percent}%</span>
      </div>
      <Bar pct={r.percent} color={TONE[r.status]} style={{ marginTop: 10, marginLeft: 'calc(var(--l-gutter, 32px) + 12px)' }} />
    </div>
  );
}

function BodyScreen() {
  const regions = [...D.recovery.regions].sort((a, b) => b.percent - a.percent);
  const ready = regions.filter((r) => r.percent >= 75);
  const sore = regions.filter((r) => r.percent < 50);
  const list = (xs) => xs.length < 2 ? xs.join('') : `${xs.slice(0, -1).join(', ')} and ${xs[xs.length - 1]}`;
  return (
    <>
      <StatusBar />
      <LedgerHead title="Body" right={
        <button type="button" aria-label="Recovery help" style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-secondary)', width: 44, height: 44, display: 'grid', placeItems: 'center' }}>
          <Icon name="question" size={20} weight="bold" />
        </button>
      } />

      <div style={{ flex: 1, overflowY: 'auto', overflowX: 'hidden', scrollbarWidth: 'none', msOverflowStyle: 'none', padding: '0 20px 110px' }}>
        <Readout label="Overall recovery" value={D.recovery.overall} unit="%"
          note={`${list(ready.map((r) => r.region))} are ready to train.${sore.length ? ` ${sore[0].region} needs another day.` : ''}`} />

        <div style={{ display: 'flex', gap: 8, marginTop: 20 }}>
          {regions.map((r) => (
            <span key={r.region} style={{ flex: 1, height: 6, background: TONE[r.status], borderRadius: 1 }} title={r.region} />
          ))}
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 8, fontSize: 10, color: 'var(--text-tertiary)', textTransform: 'uppercase', letterSpacing: '0.1em', fontWeight: 'var(--weight-semibold)' }}>
          <span>Most recovered</span><span>Least</span>
        </div>

        <SectionRule label="By muscle group" trailing={`${regions.length} tracked`} />
        {regions.map((r) => <RecoveryRow key={r.region} r={r} />)}

        <SectionRule label="Last trained" />
        {regions.map((r) => (
          <LedgerRow key={r.region} gutter={<Icon name={REGION_ICON[r.region] || 'barbell'} size={17} />} title={r.region} trailing={LAST[r.region] || '—'} />
        ))}

        <SectionRule label="How this is measured" />
        <p style={{ margin: 0, fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)', lineHeight: 1.5, textWrap: 'pretty' }}>
          Recovery combines the volume you lifted per muscle group, how long ago you trained it, and the sets you reported as hard. It is an estimate, not a diagnosis — train by how you feel.
        </p>
      </div>
    </>
  );
}

Object.assign(window, { BodyScreen });
