const { Icon, Card, Divider, Chip, PhotoSlot } = dsPick(['Icon', 'Card', 'Divider', 'Chip', 'PhotoSlot']);

const CATEGORIES = [
  { icon: 'barbell', title: 'All exercises' },
  { icon: 'clock-counter-clockwise', title: 'Recently added' },
  { icon: 'user', title: 'Added by you' },
  { icon: 'person-simple-run', title: 'By muscle group' },
  { icon: 'dumbbell', title: 'By equipment' },
  { icon: 'scales', title: 'Weighted' },
  { icon: 'hand-fist', title: 'Bodyweight only' },
  { icon: 'heartbeat', title: 'Cardio' }
];

const BY_MUSCLE = [
  { title: 'Lats', subtitle: '32 exercises' },
  { title: 'Biceps', subtitle: '24 exercises' },
  { title: 'Chest', subtitle: '41 exercises' },
  { title: 'Shoulders', subtitle: '38 exercises' },
  { title: 'Quads', subtitle: '29 exercises' },
  { title: 'Core', subtitle: '35 exercises' }
];

const ALL = [
  { title: 'Lat Pulldown', subtitle: 'Lats · Cable' },
  { title: 'Cable Row', subtitle: 'Lats · Cable' },
  { title: 'Hammer Curls', subtitle: 'Biceps · Dumbbell' },
  { title: 'Barbell Curl', subtitle: 'Biceps · Barbell' },
  { title: 'Bench Press', subtitle: 'Chest · Barbell' },
  { title: 'Overhead Press', subtitle: 'Shoulders · Barbell' },
  { title: 'Cable Wood Chop', subtitle: 'Core · Cable' }
];

function PickerRow({ icon, title, subtitle, selected, onToggle, showThumb, inPlan }) {
  return (
    <button
      type="button" onClick={inPlan ? undefined : onToggle}
      aria-pressed={onToggle ? selected || inPlan : undefined} disabled={inPlan}
      style={{
        width: '100%', background: 'none', border: 'none', textAlign: 'left',
        cursor: inPlan ? 'default' : 'pointer', opacity: inPlan ? 0.55 : 1,
        display: 'flex', alignItems: 'center', gap: 12, padding: '10px 0', minHeight: 'var(--tap-min)',
        color: 'var(--text-primary)', fontFamily: 'var(--font-ui)'
      }}
    >
      {showThumb
        ? <PhotoSlot width={44} height={44} radius="10px" label="" alt={`${title} demonstration`} />
        : <Icon name={icon} size={20} color="var(--text-secondary)" style={{ flex: '0 0 24px' }} />}
      <span style={{ flex: 1, minWidth: 0 }}>
        <span style={{ display: 'block', fontSize: 'var(--text-body)' }}>{title}</span>
        {(inPlan || subtitle) && (
          <span style={{ display: 'block', fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)', marginTop: 2 }}>
            {inPlan ? 'Already in this workout' : subtitle}
          </span>
        )}
      </span>
      {onToggle
        ? <span style={{
            width: 26, height: 26, flex: '0 0 26px', borderRadius: 'var(--radius-pill)',
            background: selected || inPlan ? 'var(--accent)' : 'transparent',
            border: selected || inPlan ? '1px solid transparent' : '1px solid var(--border-strong)',
            display: 'grid', placeItems: 'center'
          }}>
            {(selected || inPlan) && <Icon name="check" size={14} weight="bold" color="var(--bf-black)" />}
          </span>
        : <Icon name="caret-right" size={13} weight="bold" color="var(--text-tertiary)" />}
    </button>
  );
}

/** Full-height sheet for adding exercises to the current plan. */
function AddExerciseSheet({ onClose, onAdd, inPlan = [] }) {
  const [scope, setScope] = React.useState('All');
  const [query, setQuery] = React.useState('');
  const [picked, setPicked] = React.useState([]);
  const [group, setGroup] = React.useState(false);

  const toggle = (title) => {
    if (inPlan.includes(title)) return;
    setPicked((p) => p.includes(title) ? p.filter((t) => t !== title) : [...p, title]);
  };

  const list = scope === 'Categories' ? CATEGORIES : scope === 'By muscle' ? BY_MUSCLE : ALL;
  const rows = list.filter((r) => r.title.toLowerCase().includes(query.toLowerCase()));
  const selectable = scope === 'All';

  return (
    <>
      <StatusBar />
      <NavBar
        title="Add exercise"
        leading={
          <button type="button" aria-label="Filters" style={{
            width: 'var(--tap-min)', height: 'var(--tap-min)', borderRadius: 'var(--radius-pill)', cursor: 'pointer',
            background: 'transparent', border: '1px solid var(--border)', color: 'var(--accent-text)',
            display: 'grid', placeItems: 'center'
          }}><Icon name="sliders-horizontal" size={15} /></button>
        }
        trailing={
          <button type="button" aria-label="Close" onClick={onClose} style={{
            width: 'var(--tap-min)', height: 'var(--tap-min)', borderRadius: 'var(--radius-pill)', cursor: 'pointer',
            background: 'transparent', border: '1px solid var(--border)', color: 'var(--text-primary)',
            display: 'grid', placeItems: 'center'
          }}><Icon name="x" size={15} weight="bold" /></button>
        }
      />

      <div style={{ flex: '0 0 auto', padding: '0 20px 12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, background: 'var(--surface-raised)', border: '1px solid var(--border)', borderRadius: 'var(--radius-md)', padding: '0 12px', height: 44 }}>
          <Icon name="magnifying-glass" size={16} color="var(--text-tertiary)" />
          <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Search exercises"
            style={{ flex: 1, minWidth: 0, alignSelf: 'stretch', background: 'transparent', border: 'none', outline: 'none', color: 'var(--text-primary)', fontSize: 'var(--text-body)', fontFamily: 'var(--font-ui)' }} />
          {query && (
            <button type="button" aria-label="Clear" onClick={() => setQuery('')} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-tertiary)', padding: 0 }}>
              <Icon name="x-circle" size={16} />
            </button>
          )}
        </div>
      </div>

      <div style={{ flex: '0 0 auto', display: 'flex', gap: 8, padding: '0 20px 14px' }}>
        {['All', 'By muscle', 'Categories'].map((s) => (
          <Chip key={s} label={s} selected={scope === s} onClick={() => setScope(s)} />
        ))}
      </div>

      <Scroll>
        <Card padding={12}>
          {rows.map((r, i) => (
            <div key={r.title}>
              {i > 0 && <Divider inset={selectable ? 56 : 36} />}
              <PickerRow
                {...r}
                showThumb={selectable}
                inPlan={selectable && inPlan.includes(r.title)}
                selected={picked.includes(r.title)}
                onToggle={selectable ? () => toggle(r.title) : undefined}
              />
            </div>
          ))}
        </Card>
        <div style={{ height: 140 }} />
      </Scroll>

      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0, padding: '28px 20px 20px',
        background: 'linear-gradient(to top, var(--bg-page) 60%, transparent)'
      }}>
        <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
          <button type="button" onClick={() => setGroup((g) => !g)} aria-pressed={group}
            style={{
              flex: '0 0 auto', height: 'var(--control-lg)', padding: '0 16px', cursor: 'pointer',
              borderRadius: 'var(--radius-button)',
              background: group ? 'var(--surface-raised)' : 'transparent',
              border: '1px solid var(--border-strong)', color: 'var(--text-primary)',
              fontFamily: 'var(--font-ui)', fontSize: 'var(--text-footnote)', fontWeight: 'var(--weight-semibold)',
              display: 'inline-flex', alignItems: 'center', gap: 6
            }}>
            <Icon name="arrows-clockwise" size={14} />Group as circuit
          </button>
          <button type="button" disabled={picked.length === 0} onClick={() => onAdd(picked.filter((p) => !inPlan.includes(p)))}
            style={{
              flex: 1, height: 'var(--control-lg)', border: 'none',
              cursor: picked.length ? 'pointer' : 'not-allowed', opacity: picked.length ? 1 : 0.4,
              background: 'var(--accent)', color: 'var(--bf-black)', borderRadius: 'var(--radius-button)',
              fontFamily: 'var(--font-ui)', fontSize: 'var(--text-headline)', fontWeight: 'var(--weight-semibold)'
            }}>
            {picked.length ? `Add ${picked.length} exercise${picked.length > 1 ? 's' : ''}` : 'Add exercise'}
          </button>
        </div>
      </div>
    </>
  );
}

Object.assign(window, { AddExerciseSheet });
