const { Icon } = dsPick(['Icon']);

const PLAN = {
  name: 'Pull Day', duration: '45 min', gym: 'Anytime Fitness', muscles: 3,
  rows: [
    { name: 'Lat pulldown', sets: 3, reps: 8, load: '50 kg', focus: true, region: 'Lats' },
    { name: 'Cable row', sets: 4, reps: 8, load: '64 kg', region: 'Lats' },
    { name: 'Barbell curl', sets: 4, reps: 8, load: '30 kg', region: 'Biceps' },
    { name: 'Hammer curls', sets: 3, reps: 12, load: '15 kg', region: 'Biceps' },
    { name: 'Face pull', sets: 3, reps: 15, load: '18 kg', region: 'Rear delts' },
    { name: 'Reverse fly', sets: 3, reps: 12, load: '10 kg', region: 'Rear delts' },
    { name: 'Cable wood chop', sets: 3, reps: 15, load: '20 kg', region: 'Core' }
  ]
};

const SUGGESTED = [
  { name: 'Pull Day', meta: 'Recommended · 45 min · back and biceps', why: 'Back is 96% recovered' },
  { name: 'Legs A', meta: '52 min · quads and glutes', why: 'Due since Thursday' },
  { name: 'Push B', meta: '44 min · chest and shoulders', why: 'Chest still sore', dim: true }
];
const FREQUENT = [
  { name: 'Pull B', meta: 'Done 14 times · last Tuesday' },
  { name: 'Push A', meta: 'Done 12 times · last Monday' },
  { name: 'Legs A', meta: 'Done 9 times · last Thursday' },
  { name: 'Conditioning', meta: 'Done 6 times · last Saturday' }
];

const REGION_ICON = {
  Lats: 'arrow-fat-line-down', Biceps: 'barbell', 'Rear delts': 'arrows-out-line-horizontal',
  Core: 'circle-half-tilt', Quads: 'person-simple-run', Chest: 'arrows-in-line-horizontal', Added: 'plus-circle'
};
const slugify = (s) => s.toLowerCase().replace(/[^a-z0-9]+/g, '-');

const pad = (n) => String(n).padStart(2, '0');

/** Segmented source switch for where the next session comes from. */
function SourceSwitch({ value, onChange }) {
  return (
    <div style={{ display: 'flex', gap: 4, padding: 4, background: 'var(--surface-raised)', borderRadius: 'var(--radius-pill)', marginTop: 4 }}>
      {[['suggested', 'Suggested'], ['frequent', 'Frequent']].map(([id, label]) => (
        <button key={id} type="button" onClick={() => onChange(id)} style={{
          flex: 1, height: 'var(--tap-min)', cursor: 'pointer', border: 'none', borderRadius: 'var(--radius-pill)',
          background: value === id ? 'var(--bg-page)' : 'transparent',
          color: value === id ? 'var(--text-primary)' : 'var(--text-secondary)',
          fontFamily: 'var(--font-ui)', fontSize: 'var(--text-footnote)', fontWeight: 'var(--weight-semibold)'
        }}>{label}</button>
      ))}
    </div>
  );
}

/** One-tap start for a session you didn't have to go looking for. */
function QuickStart({ onClick }) {
  return (
    <button type="button" onClick={onClick} aria-label="Start this session" style={{
      width: 44, height: 44, flex: '0 0 44px', borderRadius: 'var(--radius-pill)', cursor: 'pointer',
      background: 'var(--surface-raised)', border: '1px solid var(--border)', color: 'var(--accent-text)',
      display: 'grid', placeItems: 'center'
    }}><Icon name="play" size={15} /></button>
  );
}

function MyPlanScreen({ onStart, onAddExercise, added = [] }) {
  const base = PLAN.rows.map((r) => r.name);
  const initial = [...PLAN.rows, ...added.filter((n) => !base.includes(n)).map((name) => ({ name, sets: 3, reps: 10, load: '—', region: 'Added' }))];
  const [rows, setRows] = React.useState(initial);
  const [source, setSource] = React.useState('suggested');
  React.useEffect(() => {
    setRows((cur) => {
      const have = cur.map((r) => r.name);
      const extra = added.filter((n) => !have.includes(n)).map((name) => ({ name, sets: 3, reps: 10, load: '—', region: 'Added' }));
      return extra.length ? [...cur, ...extra] : cur;
    });
  }, [added.length]);

  const remove = (name) => setRows((cur) => cur.filter((r) => r.name !== name));
  const toTop = (name) => setRows((cur) => { const i = cur.findIndex((r) => r.name === name); if (i < 1) return cur; const c = [...cur]; const [it] = c.splice(i, 1); return [it, ...c]; });
  const mark = (name, key) => setRows((cur) => cur.map((r) => r.name === name ? { ...r, [key]: !r[key] } : r));

  const list = source === 'suggested' ? SUGGESTED : FREQUENT;

  return (
    <>
      <StatusBar />
      <LedgerHead title="Plan" right={
        <>
          <span className="bf-num" style={{ fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)' }}>Tue 26 Jul</span>
          <span style={{ width: 34, height: 34, borderRadius: 'var(--radius-pill)', background: 'var(--surface-raised)', border: '1px solid var(--border)', display: 'grid', placeItems: 'center', fontSize: 12, fontWeight: 'var(--weight-bold)' }}>JH</span>
        </>
      } />

      <div style={{ flex: 1, overflowY: 'auto', overflowX: 'hidden', scrollbarWidth: 'none', msOverflowStyle: 'none' }}>
        <HeaderBlock eyebrow="Today · Pull" title={PLAN.name} spec={[
          { value: rows.length, label: 'Exercises' },
          { value: PLAN.duration.replace(' min', "'"), label: 'Planned' },
          { value: PLAN.muscles, label: 'Muscles' }
        ]} />

        <QuickActions style={{ padding: '14px 20px 4px' }} items={[
          { icon: 'arrows-left-right', label: 'Swap session', onClick: () => {} },
          { icon: 'pencil-simple', label: 'Edit', onClick: () => {} },
          { icon: 'arrow-counter-clockwise', label: 'Repeat last', onClick: () => {} },
          { icon: 'clock', label: 'Trim to 30 min', onClick: () => {} },
          { icon: 'barbell', label: PLAN.gym, onClick: () => {} }
        ]} />

        <div style={{ padding: '0 20px 200px' }}>
          <SectionRule label="The work" trailing="Swipe a row" />
          {rows.map((r, i) => (
            <SwipeRow key={`${r.name}-${i}`} accent={r.focus}
              left={[
                { icon: 'arrow-line-up', label: 'To top', onClick: () => toTop(r.name) },
                { icon: 'link-simple', label: 'Superset', onClick: () => mark(r.name, 'superset') }
              ]}
              right={[
                { icon: 'arrows-clockwise', label: 'Replace', onClick: () => mark(r.name, 'replacing') },
                { icon: 'trash', label: 'Remove', destructive: true, onClick: () => remove(r.name) }
              ]}>
              <LedgerRow gutter={pad(i + 1)} gutterAccent={r.focus}
                art={{ icon: REGION_ICON[r.region] || 'barbell', slot: `plan-${slugify(r.name)}`, label: r.name }}
                title={r.name}
                meta={[`${pad(i + 1)}`, r.focus ? 'Focus exercise' : null, r.superset ? 'Superset' : null, r.replacing ? 'Choosing a replacement' : null, r.region].filter(Boolean).join(' · ')}
                trailing={`${r.sets}×${r.reps}`} trailingMeta={r.load} />
            </SwipeRow>
          ))}
          <AddRow onClick={onAddExercise} />

          <SectionRule label="Start something else" trailing={source === 'suggested' ? 'Based on recovery' : 'Most used'} />
          <SourceSwitch value={source} onChange={setSource} />
          <div style={{ marginTop: 8 }}>
            {list.map((s) => (
              <LedgerRow key={s.name} gutter={<Icon name="barbell" size={15} weight="bold" />}
                art={{ icon: 'barbell', slot: `session-${slugify(s.name)}`, label: s.name }}
                title={s.name} meta={s.meta} dim={s.dim}
                trailing={<QuickStart onClick={onStart} />} />
            ))}
          </div>
        </div>
      </div>

      <GlassDock lift={88}>
        <PrimaryAction icon="play" onClick={onStart}>Start workout</PrimaryAction>
        <DockButton icon="pencil-simple" label="Edit this session" />
        <DockButton icon="plus" label="Add exercise" onClick={onAddExercise} />
      </GlassDock>
    </>
  );
}

Object.assign(window, { MyPlanScreen, BF_PLAN_EXERCISES: PLAN.rows.map((r) => r.name) });
