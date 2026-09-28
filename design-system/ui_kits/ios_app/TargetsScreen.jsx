const { Icon } = dsPick(['Icon']);

const D = window.BFData;
const SESSION_ICON = (name) => (
  /pull/i.test(name) ? 'arrow-fat-line-down'
    : /push/i.test(name) ? 'arrows-in-line-horizontal'
      : /leg/i.test(name) ? 'person-simple-run'
        : /cond|cardio|interval/i.test(name) ? 'heartbeat'
          : /rest/i.test(name) ? 'moon'
            : 'barbell'
);

function TargetRow({ t }) {
  const pct = Math.round((t.value / t.target) * 100);
  return (
    <div style={{ padding: '14px 0', borderTop: '1px solid var(--separator)' }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 12 }}>
        <span style={{ flex: 1, fontSize: 'var(--text-body)', fontWeight: 'var(--weight-semibold)' }}>{t.label}</span>
        <span className="bf-num" style={{ fontSize: 'var(--text-subheadline)', fontWeight: 'var(--weight-semibold)' }}>{t.value}{t.unit}</span>
        <span className="bf-num" style={{ fontSize: 'var(--text-footnote)', color: 'var(--text-tertiary)' }}>/ {t.target}{t.unit}</span>
      </div>
      <Bar pct={pct} style={{ marginTop: 10 }} />
      <div className="bf-num" style={{ fontSize: 'var(--text-caption)', color: 'var(--text-secondary)', marginTop: 7 }}>{pct}% of the week</div>
    </div>
  );
}

function TargetsScreen() {
  const w = D.targets[0];
  const left = w.target - w.value;
  return (
    <>
      <StatusBar />
      <LedgerHead title="Targets" right={
        <button type="button" aria-label="Edit targets" style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--accent-text)', minWidth: 44, height: 44, fontFamily: 'var(--font-ui)', fontSize: 'var(--text-subheadline)', fontWeight: 'var(--weight-semibold)' }}>Edit</button>
      } />

      <div style={{ flex: 1, overflowY: 'auto', overflowX: 'hidden', scrollbarWidth: 'none', msOverflowStyle: 'none' }}>
        <Slab>
          <Eyebrow style={{ opacity: 0.6 }}>This week</Eyebrow>
          <div className="bf-num" style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginTop: 10, whiteSpace: 'nowrap' }}>
            <span style={{ fontSize: 68, fontWeight: 'var(--weight-bold)', lineHeight: 0.86, letterSpacing: '-0.03em' }}>{w.value}</span>
            <span style={{ fontSize: 26, fontWeight: 'var(--weight-bold)', opacity: 0.5 }}>/&nbsp;{w.target}</span>
          </div>
          <div style={{ fontSize: 'var(--text-body)', fontWeight: 'var(--weight-semibold)', marginTop: 14, maxWidth: 280, textWrap: 'pretty' }}>
            Workouts done. {left === 1 ? 'One more reaches your goal.' : `${left} more reach your goal.`}
          </div>
          <div style={{ display: 'flex', gap: 5, marginTop: 18 }}>
            {Array.from({ length: w.target }).map((_, i) => (
              <span key={i} style={{ flex: 1, height: 8, background: i < w.value ? 'var(--bf-black)' : 'rgba(0,0,0,.22)' }} />
            ))}
          </div>
        </Slab>

        <div style={{ padding: '0 20px 110px' }}>
          <SectionRule label="Weekly targets" trailing={`${D.targets.length} set`} />
          {D.targets.map((t) => <TargetRow key={t.label} t={t} />)}

          <SectionRule label="The week" trailing="Mon–Sun" />
          {D.week.map((d) => (
            <LedgerRow key={d.day} gutter={d.day.slice(0, 2).toUpperCase()} gutterAccent={d.today}
              title={d.name} titleIcon={SESSION_ICON(d.name)}
              meta={d.today ? 'Today' : d.done ? 'Completed' : d.name === 'Rest' ? 'Scheduled rest' : 'Scheduled'}
              dim={d.name === 'Rest'}
              trailing={d.done ? <Icon name="check" size={16} weight="bold" color="var(--accent-text)" /> : null} />
          ))}

          <SectionRule label="Streak" />
          <LedgerRow gutter={<Icon name="flame" size={15} weight="bold" />} title="Current streak" meta={`Best is ${D.streak.best} days`} trailing={`${D.streak.current} days`} />

          <SectionRule label="Records this month" trailing={`${D.prs.length}`} />
          {D.prs.map((p) => (
            <LedgerRow key={p.name} gutter={<Icon name="medal" size={15} weight="bold" />} title={p.name} meta={p.when} trailing={p.value} />
          ))}
        </div>
      </div>
    </>
  );
}

Object.assign(window, { TargetsScreen });
