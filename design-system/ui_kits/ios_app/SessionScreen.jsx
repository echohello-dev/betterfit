const { Icon } = dsPick(['Icon']);
const NS_S = window.BetterFitDesignSystem_6a70ea || {};
const RestBar = NS_S.RestTimerBar || (() => null);

const EX = { index: 2, name: 'Cable row', region: 'Lats', load: 64, reps: 8, total: 4, last: { load: 60, reps: 8 }, pr: { load: 64, reps: 8 } };
const UP_NEXT = [
  { i: 3, name: 'Barbell curl', spec: '4×8 · 30 kg', icon: 'barbell' },
  { i: 4, name: 'Hammer curls', spec: '3×12 · 15 kg', icon: 'barbell' },
  { i: 5, name: 'Face pull', spec: '3×15 · 18 kg', icon: 'arrows-out-line-horizontal' },
  { i: 6, name: 'Reverse fly', spec: '3×12 · 10 kg', icon: 'arrows-out-line-horizontal' },
  { i: 7, name: 'Cable wood chop', spec: '3×15 · 20 kg', icon: 'circle-half-tilt' }
];
const slugify = (s) => s.toLowerCase().replace(/[^a-z0-9]+/g, '-');
const pad2 = (n) => String(n).padStart(2, '0');
const kg = (n) => (Number.isInteger(n) ? n : n.toFixed(1));

/** Big two-button stepper. The value is the largest thing in it, and both
    buttons clear 44px so they work with a thumb between sets. */
function Stepper({ label, value, unit, step, min = 0, onChange }) {
  const bump = (d) => onChange(Math.max(min, Math.round((value + d * step) * 10) / 10));
  return (
    <div style={{ flex: 1, minWidth: 0 }}>
      <div style={{ fontSize: 10, fontWeight: 'var(--weight-bold)', textTransform: 'uppercase', letterSpacing: '0.12em', color: 'var(--text-secondary)' }}>{label}</div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 8 }}>
        <button type="button" aria-label={`Decrease ${label}`} onClick={() => bump(-1)} style={{
          width: 46, height: 46, flex: '0 0 46px', borderRadius: 'var(--radius-md)', cursor: 'pointer',
          border: '1px solid var(--border-strong)', background: 'var(--surface-raised)', color: 'var(--text-primary)',
          display: 'grid', placeItems: 'center'
        }}><Icon name="minus" size={16} weight="bold" /></button>
        <div className="bf-num" style={{ flex: 1, textAlign: 'center', whiteSpace: 'nowrap' }}>
          <span style={{ fontSize: 34, fontWeight: 'var(--weight-bold)', letterSpacing: '-0.02em' }}>{kg(value)}</span>
          {unit && <span style={{ fontSize: 15, fontWeight: 'var(--weight-bold)', color: 'var(--text-secondary)', marginLeft: 3 }}>{unit}</span>}
        </div>
        <button type="button" aria-label={`Increase ${label}`} onClick={() => bump(1)} style={{
          width: 46, height: 46, flex: '0 0 46px', borderRadius: 'var(--radius-md)', cursor: 'pointer',
          border: '1px solid var(--border-strong)', background: 'var(--surface-raised)', color: 'var(--text-primary)',
          display: 'grid', placeItems: 'center'
        }}><Icon name="plus" size={16} weight="bold" /></button>
      </div>
    </div>
  );
}

/** Inline set editor: steppers, one-tap suggestions, and bulk apply. */
function SetEditor({ set, index, count, onChange, onApplyRest, onApplyAll, onClose }) {
  const sugg = [
    { label: `Last ${EX.last.load} × ${EX.last.reps}`, icon: 'arrow-counter-clockwise', load: EX.last.load, reps: EX.last.reps },
    { label: '+2.5 kg', icon: 'trend-up', load: set.load + 2.5, reps: set.reps },
    { label: '+1 rep', icon: 'plus', load: set.load, reps: set.reps + 1 },
    { label: `PR ${EX.pr.load} × ${EX.pr.reps}`, icon: 'medal', load: EX.pr.load, reps: EX.pr.reps }
  ];
  const rest = count - index - 1;
  return (
    <div style={{ padding: '4px 0 18px', borderTop: '1px solid var(--separator)' }}>
      <div style={{ display: 'flex', gap: 16, paddingTop: 12 }}>
        <Stepper label="Weight" value={set.load} unit="kg" step={2.5} onChange={(v) => onChange({ load: v })} />
        <Stepper label="Reps" value={set.reps} step={1} min={1} onChange={(v) => onChange({ reps: v })} />
      </div>
      <div style={{ display: 'flex', gap: 8, overflowX: 'auto', scrollbarWidth: 'none', msOverflowStyle: 'none', marginTop: 16 }}>
        {sugg.map((s) => (
          <button key={s.label} type="button" onClick={() => onChange({ load: s.load, reps: s.reps })} style={{
            flex: '0 0 auto', display: 'inline-flex', alignItems: 'center', gap: 7, minHeight: 'var(--tap-min)', padding: '0 15px',
            borderRadius: 'var(--radius-pill)', cursor: 'pointer', background: 'var(--surface-raised)',
            border: '1px solid var(--border)', color: 'var(--text-primary)',
            fontFamily: 'var(--font-ui)', fontSize: 'var(--text-footnote)', fontWeight: 'var(--weight-semibold)'
          }}>
            <Icon name={s.icon} size={14} weight="bold" color="var(--accent-text)" />{s.label}
          </button>
        ))}
      </div>
      <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
        {rest > 0 && (
          <button type="button" onClick={onApplyRest} style={{
            flex: 1, minHeight: 'var(--tap-min)', cursor: 'pointer', borderRadius: 'var(--radius-button)',
            background: 'transparent', border: '1px solid var(--border-strong)', color: 'var(--text-primary)',
            fontFamily: 'var(--font-ui)', fontSize: 'var(--text-footnote)', fontWeight: 'var(--weight-semibold)'
          }}>Apply to next {rest}</button>
        )}
        <button type="button" onClick={onApplyAll} style={{
          flex: 1, minHeight: 'var(--tap-min)', cursor: 'pointer', borderRadius: 'var(--radius-button)',
          background: 'transparent', border: '1px solid var(--border-strong)', color: 'var(--text-primary)',
          fontFamily: 'var(--font-ui)', fontSize: 'var(--text-footnote)', fontWeight: 'var(--weight-semibold)'
        }}>Apply to all {count}</button>
        <button type="button" onClick={onClose} aria-label="Close editor" style={{
          width: 'var(--tap-min)', flex: '0 0 var(--tap-min)', minHeight: 'var(--tap-min)', cursor: 'pointer',
          borderRadius: 'var(--radius-button)', background: 'transparent', border: '1px solid var(--border-strong)',
          color: 'var(--text-secondary)', display: 'grid', placeItems: 'center'
        }}><Icon name="check" size={16} weight="bold" /></button>
      </div>
    </div>
  );
}

/** One set as a ledger row: big mono value, tap to edit, swipe left to clear or delete. */
function SetRow({ set, i, count, open, onOpen, onChange, onApplyRest, onApplyAll, onClear, onDelete }) {
  const planned = !set.logged;
  return (
    <div>
      <SwipeRow accent={set.current}
        left={[{ icon: 'copy', label: 'Copy all', onClick: onApplyAll }]}
        right={[
          ...(set.logged ? [{ icon: 'arrow-counter-clockwise', label: 'Clear', onClick: onClear }] : []),
          { icon: 'trash', label: 'Delete', destructive: true, onClick: onDelete }
        ]}>
        <button type="button" onClick={onOpen} style={{
          display: 'flex', alignItems: 'center', gap: 14, width: '100%', textAlign: 'left', cursor: 'pointer',
          padding: 'var(--l-row-py, 14px) 0', borderTop: '1px solid var(--separator)', background: 'none',
          border: 'none', borderTopWidth: 1, borderTopStyle: 'solid', borderTopColor: 'var(--separator)',
          color: 'inherit', font: 'inherit', fontFamily: 'var(--font-ui)', opacity: planned && !set.current ? 0.5 : 1
        }}>
          <span className="bf-num" style={{ flex: '0 0 var(--l-gutter, 32px)', fontSize: 15, fontWeight: 'var(--weight-bold)', color: set.current ? 'var(--accent-text)' : 'var(--text-tertiary)' }}>
            {pad2(i + 1)}
          </span>
          <span style={{ flex: 1, minWidth: 0 }}>
            <span className="bf-num" style={{ display: 'flex', alignItems: 'baseline', gap: 5, whiteSpace: 'nowrap' }}>
              <span style={{ fontSize: 28, fontWeight: 'var(--weight-bold)', letterSpacing: '-0.02em' }}>{kg(set.load)}</span>
              <span style={{ fontSize: 13, fontWeight: 'var(--weight-bold)', color: 'var(--text-secondary)' }}>kg</span>
              <span style={{ fontSize: 15, fontWeight: 'var(--weight-bold)', color: 'var(--text-tertiary)', margin: '0 2px' }}>×</span>
              <span style={{ fontSize: 28, fontWeight: 'var(--weight-bold)' }}>{set.reps}</span>
            </span>
            <span style={{ display: 'block', fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)', marginTop: 'var(--l-meta-gap, 3px)' }}>
              {set.logged ? 'Logged' : set.current ? 'Up now · tap to edit' : 'Planned'}
            </span>
          </span>
          {set.logged
            ? <Icon name="check" size={18} weight="bold" color="var(--accent-text)" />
            : <Icon name={open ? 'caret-up' : 'pencil-simple'} size={16} weight="bold" color="var(--text-tertiary)" />}
        </button>
      </SwipeRow>
      {open && (
        <SetEditor set={set} index={i} count={count} onChange={onChange}
          onApplyRest={onApplyRest} onApplyAll={onApplyAll} onClose={onOpen} />
      )}
    </div>
  );
}

function SessionScreen({ onClose, onFinish, onAddExercise }) {
  const [sets, setSets] = React.useState(
    Array.from({ length: EX.total }, (_, i) => ({ load: EX.load, reps: EX.reps, logged: i < 2 }))
  );
  const [openSet, setOpenSet] = React.useState(null);
  const [resting, setResting] = React.useState(false);
  const [remaining, setRemaining] = React.useState(90);
  const [queue, setQueue] = React.useState(UP_NEXT);

  React.useEffect(() => {
    if (!resting) return;
    const id = setInterval(() => setRemaining((r) => (r <= 1 ? (setResting(false), 90) : r - 1)), 1000);
    return () => clearInterval(id);
  }, [resting]);

  const done = sets.filter((s) => s.logged).length;
  const currentIdx = sets.findIndex((s) => !s.logged);
  const complete = currentIdx === -1;
  const cur = complete ? sets[sets.length - 1] : sets[currentIdx];

  const patch = (i, next) => setSets((cur) => cur.map((s, j) => (j === i ? { ...s, ...next } : s)));
  const applyFrom = (i, all) => setSets((cur) => cur.map((s, j) => (
    (all ? true : j > i) && !s.logged ? { ...s, load: cur[i].load, reps: cur[i].reps } : s
  )));
  const logSet = () => {
    if (complete) return;
    patch(currentIdx, { logged: true });
    setRemaining(90); setResting(true); setOpenSet(null);
  };

  return (
    <>
      <StatusBar />
      <div style={{ flex: '0 0 auto', display: 'flex', alignItems: 'center', gap: 12, padding: '0 16px 10px' }}>
        <button type="button" onClick={onClose} aria-label="Close session" style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-secondary)', width: 44, height: 44, display: 'grid', placeItems: 'center' }}>
          <Icon name="x" size={20} weight="bold" />
        </button>
        <span className="bf-num" style={{ flex: 1, textAlign: 'center', fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)' }}>
          Pull Day · {pad2(EX.index)} of 07
        </span>
        <span className="bf-num" style={{ fontSize: 'var(--text-subheadline)', fontWeight: 'var(--weight-bold)', padding: '0 6px' }}>18:24</span>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', overflowX: 'hidden', scrollbarWidth: 'none', msOverflowStyle: 'none' }}>
        <div style={{ padding: '4px 20px 20px', borderBottom: '1px solid var(--separator)' }}>
          <Eyebrow style={{ color: 'var(--accent-text)' }}>Exercise {pad2(EX.index)} · {EX.region}</Eyebrow>
          <h1 className="bf-display" style={{ margin: '8px 0 0', fontSize: 34, lineHeight: 1 }}>{EX.name}</h1>
          <div style={{ marginTop: 18 }}>
            <div style={{ fontSize: 10, fontWeight: 'var(--weight-bold)', textTransform: 'uppercase', letterSpacing: '0.12em', color: 'var(--text-secondary)' }}>
              Set {complete ? EX.total : currentIdx + 1} of {sets.length}
            </div>
            <div style={{ display: 'flex', gap: 16, marginTop: 10 }}>
              <Stepper label="Weight" value={cur.load} unit="kg" step={2.5}
                onChange={(v) => patch(complete ? sets.length - 1 : currentIdx, { load: v })} />
              <Stepper label="Reps" value={cur.reps} step={1} min={1}
                onChange={(v) => patch(complete ? sets.length - 1 : currentIdx, { reps: v })} />
            </div>
          </div>
        </div>

        {resting && <RestBar remaining={remaining} total={90} onAdd={() => setRemaining((r) => r + 15)} onSkip={() => setResting(false)} />}

        <QuickActions style={{ padding: '14px 20px 4px' }} items={[
          { icon: 'arrows-clockwise', label: 'Swap exercise', onClick: () => {} },
          { icon: 'copy', label: 'Same for all sets', onClick: () => applyFrom(complete ? sets.length - 1 : currentIdx, true) },
          { icon: 'plus-circle', label: 'Add a set', onClick: () => setSets((c) => [...c, { load: cur.load, reps: cur.reps, logged: false }]) },
          { icon: 'note-pencil', label: 'Add note', onClick: () => {} },
          { icon: 'timer', label: 'Rest 90s', onClick: () => { setRemaining(90); setResting(true); } }
        ]} />

        <div style={{ padding: '0 20px 200px' }}>
          <SectionRule label="This exercise" trailing={`${done} of ${sets.length} logged`} />
          {sets.map((s, i) => (
            <SetRow key={i} set={{ ...s, current: i === currentIdx }} i={i} count={sets.length}
              open={openSet === i}
              onOpen={() => setOpenSet((o) => (o === i ? null : i))}
              onChange={(next) => patch(i, next)}
              onApplyRest={() => applyFrom(i, false)}
              onApplyAll={() => applyFrom(i, true)}
              onClear={() => patch(i, { logged: false })}
              onDelete={() => { setOpenSet(null); setSets((c) => c.filter((_, j) => j !== i)); }} />
          ))}
          <AddRow onClick={() => setSets((c) => [...c, { load: cur.load, reps: cur.reps, logged: false }])} label="Add a set" />

          <SectionRule label="Up next" trailing="Swipe a row" />
          {queue.map((e) => (
            <SwipeRow key={e.i}
              left={[{ icon: 'arrow-line-up', label: 'Do now', onClick: () => setQueue((q) => [e, ...q.filter((x) => x.i !== e.i)]) }]}
              right={[
                { icon: 'arrows-clockwise', label: 'Replace', onClick: () => {} },
                { icon: 'trash', label: 'Remove', destructive: true, onClick: () => setQueue((q) => q.filter((x) => x.i !== e.i)) }
              ]}>
              <LedgerRow gutter={pad2(e.i)} title={e.name} meta={`${pad2(e.i)} · ${e.spec}`} chevron onClick={() => {}}
                art={{ icon: e.icon, slot: `up-${slugify(e.name)}`, label: e.name }} />
            </SwipeRow>
          ))}
          <AddRow onClick={onAddExercise} />

          <button type="button" onClick={onFinish} style={{
            width: '100%', height: 'var(--control-md)', marginTop: 26, cursor: 'pointer',
            background: 'transparent', border: '1px solid var(--border-strong)', color: 'var(--text-secondary)',
            borderRadius: 'var(--radius-button)', fontFamily: 'var(--font-ui)', fontSize: 'var(--text-subheadline)', fontWeight: 'var(--weight-semibold)'
          }}>Finish workout</button>
        </div>
      </div>

      <GlassDock lift={16}>
        <PrimaryAction icon={complete ? 'arrow-right' : 'check'} onClick={complete ? undefined : logSet}>
          {complete ? 'Next exercise' : `Log ${kg(cur.load)} × ${cur.reps}`}
        </PrimaryAction>
        <DockButton icon="timer" label="Start rest timer" onClick={() => { setRemaining(90); setResting(true); }} />
        <DockButton icon="plus" label="Add exercise" onClick={onAddExercise} />
      </GlassDock>
    </>
  );
}

Object.assign(window, { SessionScreen });
