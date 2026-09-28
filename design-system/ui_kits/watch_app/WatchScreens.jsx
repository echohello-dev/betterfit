const { Icon, ProgressRing, RecoveryDot } = window.BetterFitDesignSystem_6a70ea;

const SESSION_ICON = (name) => (
  /pull/i.test(name) ? 'arrow-fat-line-down'
    : /push/i.test(name) ? 'arrows-in-line-horizontal'
      : /leg/i.test(name) ? 'person-simple-run'
        : /cond|cardio|interval/i.test(name) ? 'heartbeat'
          : 'barbell'
);

function WatchList({ onStart }) {
  const d = window.BFData;
  return (
    <>
      <WatchBar title="BetterFit" />
      <WatchScroll>
        <div style={{ background: 'var(--bf-yellow)', color: 'var(--bf-black)', borderRadius: 'var(--radius-md)', padding: '10px 12px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
            <Icon name={SESSION_ICON(d.today.name)} size={11} weight="bold" />
            <div style={{ fontSize: 9, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '.1em', opacity: .62 }}>Today</div>
          </div>
          <div className="bf-display" style={{ fontSize: 22, marginTop: 2 }}>{d.today.name}</div>
          <div className="bf-num" style={{ fontSize: 10, fontWeight: 600, marginTop: 4 }}>{d.today.exercises} exercises · {d.today.duration}</div>
          <button type="button" onClick={onStart} style={{
            marginTop: 10, width: '100%', minHeight: 44, border: 'none', cursor: 'pointer',
            background: 'var(--bf-black)', color: 'var(--bf-yellow)', borderRadius: 'var(--radius-md)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
            fontFamily: 'var(--font-ui)', fontSize: 14, fontWeight: 600
          }}><Icon name="play" size={13} />Start</button>
        </div>
        {['Push A', 'Legs A', 'Conditioning'].map((n) => (
          <div key={n} style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 'var(--radius-md)', padding: '10px 12px', display: 'flex', alignItems: 'center', gap: 8 }}>
            <Icon name={SESSION_ICON(n)} size={14} color="var(--accent-text)" />
            <span style={{ fontSize: 13, fontWeight: 600, flex: 1 }}>{n}</span>
            <Icon name="caret-right" size={11} weight="bold" color="var(--text-tertiary)" />
          </div>
        ))}
      </WatchScroll>
    </>
  );
}

function WatchActive({ onFinish }) {
  const d = window.BFData;
  const [set, setSet] = React.useState(1);
  const [paused, setPaused] = React.useState(false);
  return (
    <>
      <WatchBar title={d.today.name} />
      <WatchScroll>
        <div style={{ textAlign: 'center' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 5, color: paused ? 'var(--text-secondary)' : 'var(--accent-text)' }}>
            <Icon name={paused ? 'pause' : 'timer'} size={11} weight="bold" />
            <span style={{ fontSize: 9, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '.1em' }}>{paused ? 'Paused' : 'Elapsed'}</span>
          </div>
          <div className="bf-num" style={{ fontFamily: 'var(--font-mono)', fontSize: 30, fontWeight: 700, marginTop: 2, color: paused ? 'var(--text-secondary)' : 'var(--text-primary)' }}>18:42</div>
        </div>
        <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 'var(--radius-md)', padding: 12, textAlign: 'center' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 5 }}>
            <Icon name="arrow-fat-line-down" size={12} weight="bold" color="var(--accent-text)" />
            <span style={{ fontSize: 12, fontWeight: 600 }}>{d.plan[0].name}</span>
          </div>
          <div className="bf-num" style={{ fontSize: 26, fontWeight: 700, marginTop: 4 }}>245 <span style={{ fontSize: 12, color: 'var(--text-secondary)' }}>lb</span></div>
          <div className="bf-num" style={{ fontSize: 11, color: 'var(--text-secondary)' }}>Set {set} of 4 · 5 reps</div>
        </div>
        <WatchButton icon="check" onClick={() => setSet((s) => Math.min(4, s + 1))}>Log set</WatchButton>
        <WatchButton icon={paused ? 'play' : 'pause'} tone="surface" onClick={() => setPaused((p) => !p)}>{paused ? 'Resume' : 'Pause'}</WatchButton>
        <WatchButton tone="danger" onClick={onFinish}>End workout</WatchButton>
      </WatchScroll>
    </>
  );
}

function WatchSummary({ onDone }) {
  const d = window.BFData;
  return (
    <>
      <WatchBar title="Complete" />
      <WatchScroll>
        <div style={{ display: 'grid', placeItems: 'center', paddingTop: 4 }}>
          <ProgressRing progress={1} size={78} lineWidth={9} tint="var(--accent)">
            <Icon name="check" size={26} weight="bold" color="var(--text-primary)" />
          </ProgressRing>
        </div>
        <div style={{ textAlign: 'center' }}>
          <div className="bf-display" style={{ fontSize: 18 }}>Good work</div>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 5, fontSize: 10, color: 'var(--text-secondary)', marginTop: 2 }}>
            <Icon name={SESSION_ICON(d.today.name)} size={11} weight="bold" color="var(--accent-text)" />
            <span style={{ whiteSpace: 'nowrap' }}>{d.today.name} · 42 min</span>
          </div>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 6 }}>
          {[['14.2k', 'lb lifted', 'scales'], ['18', 'sets', 'stack-simple'], ['13', 'day streak', 'flame'], ['412', 'kcal', 'fire-simple']].map(([v, l, ic]) => (
            <div key={l} style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 'var(--radius-sm)', padding: '8px 10px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                <Icon name={ic} size={11} weight="bold" color="var(--accent-text)" />
                <div className="bf-num" style={{ fontSize: 15, fontWeight: 700 }}>{v}</div>
              </div>
              <div style={{ fontSize: 9, color: 'var(--text-secondary)', marginTop: 1 }}>{l}</div>
            </div>
          ))}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 10, color: 'var(--text-secondary)' }}>
          <RecoveryDot status="fatigued" size={8} /><span>Back is now fatigued</span>
        </div>
        <WatchButton tone="surface" onClick={onDone}>Done</WatchButton>
      </WatchScroll>
    </>
  );
}

Object.assign(window, { WatchList, WatchActive, WatchSummary });
