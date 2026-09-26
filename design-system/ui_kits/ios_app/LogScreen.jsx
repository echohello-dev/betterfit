const { Icon, ContributionHeatmap } = dsPick(['Icon', 'ContributionHeatmap']);

const D = window.BFData;

const GROUP_ICON = {
  Chest: 'arrows-in-line-horizontal', Back: 'arrow-fat-line-down', Shoulders: 'arrows-out-line-horizontal',
  Arms: 'barbell', Core: 'circle-half-tilt', Legs: 'person-simple-run', Cardio: 'heartbeat'
};

const JULY = [
  { date: 26, name: 'Pull B', meta: 'Planned · today', today: true, groups: [['Back', 2], ['Arms', 3], ['Shoulders', 2]] },
  { date: 25, name: 'Push A', meta: '48 min · 8 exercises', volume: '16.2k', groups: [['Chest', 3], ['Shoulders', 3], ['Arms', 2]] },
  { date: 24, name: 'Legs A', meta: '52 min · 9 exercises', volume: '18.4k', groups: [['Legs', 6], ['Core', 3]] },
  { date: 23, name: 'Rest', rest: true },
  { date: 22, name: 'Push A', meta: '46 min · 7 exercises', volume: '15.1k', groups: [['Chest', 4], ['Shoulders', 3]] },
  { date: 20, name: 'Pull A', meta: '41 min · 7 exercises', volume: '14.2k', groups: [['Back', 4], ['Arms', 3]] },
  { date: 19, name: 'Conditioning', meta: '28 min · intervals', groups: [['Cardio', 4], ['Core', 2]] },
  { date: 17, name: 'Legs B', meta: '55 min · 8 exercises', volume: '19.8k', groups: [['Legs', 5], ['Core', 3]] },
  { date: 16, name: 'Rest', rest: true },
  { date: 15, name: 'Push B', meta: '44 min · 7 exercises', volume: '13.9k', groups: [['Chest', 4], ['Arms', 3]] }
];

/** Stacked horizontal badges: one per muscle group trained, overlapping, with its count. */
function GroupBadges({ groups }) {
  return (
    <span style={{ display: 'flex', alignItems: 'center', marginTop: 8 }}>
      {groups.map(([g, n], i) => (
        <span key={g} title={`${g} · ${n} exercises`} style={{
          display: 'inline-flex', alignItems: 'center', gap: 4, height: 26, padding: '0 9px 0 7px',
          borderRadius: 'var(--radius-pill)', background: 'var(--surface-raised)',
          border: '1px solid var(--bg-page)', color: 'var(--text-secondary)',
          marginLeft: i ? -8 : 0, zIndex: groups.length - i, position: 'relative'
        }}>
          <Icon name={GROUP_ICON[g] || 'barbell'} size={13} weight="bold" color="var(--accent-text)" />
          <span className="bf-num" style={{ fontSize: 11, fontWeight: 'var(--weight-bold)' }}>{n}</span>
        </span>
      ))}
    </span>
  );
}

/** One day in the ledger. `streakUp`/`streakDown` draw the hot-streak line through
    the gutter, joining consecutive training days into a single unbroken run. */
function DayRow({ s, streakUp, streakDown, onClick }) {
  const hot = streakUp || streakDown;
  return (
    <div style={{ position: 'relative' }}>
      {hot && <span aria-hidden="true" style={{
        position: 'absolute', left: 15, top: streakUp ? 0 : '50%', bottom: streakDown ? 0 : '50%',
        width: 2, background: 'var(--accent)', zIndex: 0
      }} />}
      <button type="button" onClick={onClick} disabled={!onClick} style={{
        display: 'flex', alignItems: 'flex-start', gap: 14, width: '100%', textAlign: 'left',
        padding: 'var(--l-row-py, 14px) 0', borderTop: '1px solid var(--separator)',
        background: 'none', border: 'none', borderTopWidth: 1, borderTopStyle: 'solid', borderTopColor: 'var(--separator)',
        color: 'inherit', font: 'inherit', fontFamily: 'var(--font-ui)',
        cursor: onClick ? 'pointer' : 'default', opacity: s.rest ? 0.45 : 1, position: 'relative'
      }}>
        <span style={{ flex: '0 0 var(--l-gutter, 32px)', display: 'flex', justifyContent: 'flex-start', position: 'relative', zIndex: 1 }}>
          <span className="bf-num" style={{
            width: 32, height: 32, marginLeft: -1, borderRadius: 'var(--radius-pill)',
            display: 'grid', placeItems: 'center', fontSize: 14, fontWeight: 'var(--weight-bold)',
            background: hot ? 'var(--accent)' : 'transparent',
            color: hot ? 'var(--text-on-accent)' : s.today ? 'var(--accent-text)' : 'var(--text-tertiary)'
          }}>{s.date}</span>
        </span>
        <span style={{ flex: 1, minWidth: 0 }}>
          <span style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
            <span style={{ flex: 1, fontSize: 'var(--l-title, var(--text-body))', fontWeight: 'var(--weight-semibold)' }}>{s.name}</span>
            {s.volume && <span className="bf-num" style={{ fontSize: 'var(--text-subheadline)', fontWeight: 'var(--weight-semibold)' }}>{s.volume}<span style={{ color: 'var(--text-tertiary)', fontSize: 'var(--text-caption)' }}>&nbsp;kg</span></span>}
          </span>
          {s.meta && <span style={{ display: 'block', fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)', marginTop: 'var(--l-meta-gap, 3px)' }}>{s.meta}</span>}
          {s.groups && <GroupBadges groups={s.groups} />}
        </span>
      </button>
    </div>
  );
}

function LogScreen({ onOpenSummary, onAddExercise }) {
  const trained = (i) => JULY[i] && !JULY[i].rest;
  const joined = (a, b) => trained(a) && trained(b) && JULY[a].date - JULY[b].date === 1;
  const runs = JULY.filter((s) => !s.rest).length;

  return (
    <>
      <StatusBar />
      <LedgerHead title="Log" right={
        <button type="button" aria-label="Jump to date" style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-secondary)', width: 44, height: 44, display: 'grid', placeItems: 'center' }}>
          <Icon name="calendar-blank" size={20} weight="bold" />
        </button>
      } />

      <div style={{ flex: 1, overflowY: 'auto', overflowX: 'hidden', scrollbarWidth: 'none', msOverflowStyle: 'none', padding: '0 20px 110px' }}>
        <Readout label="Current streak" value={D.streak.current} unit="days"
          note={`Three days back to back this week. Your best run is ${D.streak.best} days — keep Thursday and you match it.`} />

        <SectionRule label="Consistency" trailing="26 weeks" />
        <div style={{ padding: '4px 0 2px' }}>
          <ContributionHeatmap values={D.heatmap} cell={9} gap={3} />
        </div>

        <SectionRule label="July" trailing={`${runs} sessions · 97.6k kg`} />
        {JULY.map((s, i) => (
          <DayRow key={s.date} s={s}
            streakUp={joined(i - 1, i)} streakDown={joined(i, i + 1)}
            onClick={!s.rest && !s.today ? onOpenSummary : undefined} />
        ))}
        <AddRow onClick={onAddExercise} label="Log a past workout" />

        <SectionRule label="All time" />
        <LedgerRow gutter={<Icon name="barbell" size={15} weight="bold" />} title="Sessions" trailing="184" />
        <LedgerRow gutter={<Icon name="scales" size={15} weight="bold" />} title="Volume lifted" trailing="2.41M" trailingMeta="kg" />
        <LedgerRow gutter={<Icon name="clock" size={15} weight="bold" />} title="Time training" trailing="142" trailingMeta="hours" />
      </div>
    </>
  );
}

Object.assign(window, { LogScreen });
