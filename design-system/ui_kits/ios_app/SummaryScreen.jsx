const { Icon } = dsPick(['Icon']);

const RESULTS = [
  { i: 1, name: 'Lat pulldown', best: '50 kg × 8', sets: '3 of 3', vol: '1.2k' },
  { i: 2, name: 'Cable row', best: '64 kg × 8', sets: '4 of 4', vol: '2.0k', pr: true },
  { i: 3, name: 'Barbell curl', best: '30 kg × 8', sets: '4 of 4', vol: '960' },
  { i: 4, name: 'Hammer curls', best: '15 kg × 12', sets: '3 of 3', vol: '540' },
  { i: 5, name: 'Face pull', best: '18 kg × 15', sets: '3 of 3', vol: '810' },
  { i: 6, name: 'Reverse fly', best: '10 kg × 12', sets: '2 of 3', vol: '240', short: true },
  { i: 7, name: 'Cable wood chop', best: '20 kg × 15', sets: '3 of 3', vol: '900' }
];
const pad2 = (n) => String(n).padStart(2, '0');

function SummaryScreen({ onBack, onAddExercise }) {
  return (
    <>
      <StatusBar />
      <div style={{ flex: '0 0 auto', display: 'flex', alignItems: 'center', gap: 12, padding: '0 16px 12px' }}>
        <button type="button" onClick={onBack} aria-label="Back" style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-secondary)', width: 44, height: 44, display: 'grid', placeItems: 'center' }}>
          <Icon name="caret-left" size={20} weight="bold" />
        </button>
        <span style={{ flex: 1 }} />
        <button type="button" aria-label="Share summary" style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-secondary)', width: 44, height: 44, display: 'grid', placeItems: 'center' }}>
          <Icon name="export" size={20} weight="bold" />
        </button>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', overflowX: 'hidden', scrollbarWidth: 'none', msOverflowStyle: 'none' }}>
        <Slab>
          <Eyebrow style={{ opacity: 0.6 }}>Tue 26 Jul · Session complete</Eyebrow>
          <h1 className="bf-display" style={{ margin: '10px 0 0', fontSize: 44, lineHeight: 0.94 }}>Pull Day</h1>
          <SpecStrip items={[
            { value: "44'", label: 'Duration' },
            { value: '6.7k', label: 'Volume kg' },
            { value: '22', label: 'Sets' }
          ]} />
          <div style={{ marginTop: 18, paddingTop: 16, borderTop: '1.5px solid rgba(0,0,0,.2)', fontSize: 'var(--text-subheadline)', fontWeight: 'var(--weight-semibold)', maxWidth: 300, textWrap: 'pretty' }}>
            Strongest pull session this month. Cable row went up 4 kg.
          </div>
        </Slab>

        <div style={{ padding: '0 20px 190px' }}>
          <SectionRule label="New records" trailing="1" />
          <LedgerRow gutter={<Icon name="medal" size={15} weight="bold" />} gutterAccent title="Cable row" meta="Previous best 60 kg × 8" trailing="64 kg" trailingMeta="× 8" />

          <SectionRule label="What you lifted" trailing={`${RESULTS.length} exercises`} />
          {RESULTS.map((r) => (
            <LedgerRow key={r.i} gutter={pad2(r.i)} gutterAccent={r.pr}
              title={r.name}
              meta={`Best ${r.best} · ${r.sets} sets${r.short ? ' · cut short' : ''}`}
              trailing={r.vol} trailingMeta="kg" />
          ))}
          <AddRow onClick={onAddExercise} label="Add something you did off plan" />

          <SectionRule label="Effect on recovery" />
          {[{ m: 'Lats', from: 96, to: 41 }, { m: 'Biceps', from: 81, to: 46 }, { m: 'Rear delts', from: 78, to: 52 }].map((x) => (
            <div key={x.m} style={{ padding: '13px 0', borderTop: '1px solid var(--separator)' }}>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 12 }}>
                <span style={{ flex: 1, fontSize: 'var(--text-body)', fontWeight: 'var(--weight-semibold)' }}>{x.m}</span>
                <span className="bf-num" style={{ fontSize: 'var(--text-footnote)', color: 'var(--text-tertiary)' }}>{x.from}%</span>
                <Icon name="arrow-right" size={12} weight="bold" color="var(--text-tertiary)" />
                <span className="bf-num" style={{ fontSize: 'var(--text-subheadline)', fontWeight: 'var(--weight-semibold)' }}>{x.to}%</span>
              </div>
              <Bar pct={x.to} color="var(--recovery-fatigued)" style={{ marginTop: 10 }} />
            </div>
          ))}

          <SectionRule label="Next" />
          <LedgerRow gutter={<Icon name="calendar-blank" size={15} weight="bold" />} title="Legs A" meta="Thursday · 8 exercises" chevron onClick={() => {}} />
        </div>
      </div>

      <GlassDock lift={16}>
        <button type="button" onClick={onBack} style={{
          flex: 1, height: 'var(--control-lg)', cursor: 'pointer', borderRadius: 16,
          background: 'var(--glass-highlight)', border: '1px solid var(--glass-border)', color: 'var(--text-primary)',
          fontFamily: 'var(--font-ui)', fontSize: 'var(--text-headline)', fontWeight: 'var(--weight-semibold)'
        }}>Done</button>
        <DockButton icon="export" label="Share summary" />
      </GlassDock>
    </>
  );
}

Object.assign(window, { SummaryScreen });
