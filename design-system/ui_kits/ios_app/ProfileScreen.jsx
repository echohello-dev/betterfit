const {
  Card, SectionHeader, Divider, Icon, StatTile, ContributionHeatmap, MetricPill,
  ListRow, Button, IconButton, Logo
} = window.BetterFitDesignSystem_6a70ea;

function ProfileScreen({ onSettings }) {
  const d = window.BFData;
  return (
    <>
      <StatusBar />
      <NavBar title="Me" trailing={<IconButton icon="gear-six" label="Settings" size={44} variant="quiet" onClick={onSettings} />} />
      <Scroll>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
            <Logo variant="combo" height={58} assetBase="../../assets" style={{ borderRadius: 16 }} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div className="bf-display" style={{ fontSize: 'var(--text-title-2)' }}>{d.user.name}</div>
              <div style={{ fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)' }}>{d.user.since}</div>
            </div>
            <MetricPill label={d.user.plan} tone="accent" icon="star" />
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 10 }}>
            <StatTile icon="fire-simple" value={d.streak.current} label="Day streak" />
            <StatTile icon="barbell" value="41k" label="Volume (lb)" />
            <StatTile icon="heartbeat" value={d.recovery.overall + '%'} label="Recovery" />
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <SectionHeader title="Weekly targets" action={<Button variant="ghost" size="sm" fullWidth={false}>Edit</Button>} />
            <Card>
              {d.targets.map((t, i) => (
                <div key={t.label} style={{ marginTop: i ? 14 : 0 }}>
                  <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
                    <span style={{ fontSize: 'var(--text-subheadline)' }}>{t.label}</span>
                    <span className="bf-num" style={{ fontSize: 'var(--text-subheadline)', fontWeight: 600, whiteSpace: 'nowrap' }}>{t.value}<span style={{ color: 'var(--text-tertiary)', fontWeight: 400 }}>&nbsp;/&nbsp;{t.target}{t.unit}</span></span>
                  </div>
                  <div style={{ height: 6, borderRadius: 3, background: 'var(--surface-raised)', marginTop: 8, overflow: 'hidden' }}>
                    <div style={{ width: Math.min(100, (t.value / t.target) * 100) + '%', height: '100%', background: 'var(--accent)' }} />
                  </div>
                </div>
              ))}
            </Card>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <SectionHeader title="Personal records" action={<Button variant="ghost" size="sm" fullWidth={false}>View all</Button>} />
            <Card padding={12}>
              {d.prs.map((p, i) => (
                <div key={p.name}>
                  {i > 0 && <Divider inset={56} />}
                  <ListRow icon="trophy" title={p.name} subtitle={p.when} iconTint="var(--accent-text)"
                    trailing={<span className="bf-num" style={{ fontSize: 'var(--text-subheadline)', fontWeight: 600 }}>{p.value}</span>} />
                </div>
              ))}
            </Card>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <SectionHeader title="Achievements" action={<span className="bf-num" style={{ fontSize: 'var(--text-caption)', color: 'var(--text-tertiary)' }}>2/4</span>} />
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
              {d.achievements.map((a) => (
                <Card key={a.title} padding={14} style={{ opacity: a.done ? 1 : 0.45 }}>
                  <Icon name={a.icon} size={20} color={a.done ? 'var(--accent-text)' : 'var(--text-tertiary)'} />
                  <div style={{ fontSize: 'var(--text-footnote)', fontWeight: 600, marginTop: 8 }}>{a.title}</div>
                  <div style={{ fontSize: 'var(--text-caption)', color: 'var(--text-secondary)', marginTop: 2 }}>{a.done ? 'Earned' : 'Locked'}</div>
                </Card>
              ))}
            </div>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <SectionHeader title="Your year" />
            <Card>
              <ContributionHeatmap values={d.heatmap} weeks={22} cell={9} gap={3} />
              <div style={{ fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)', marginTop: 12 }}>
                <span className="bf-num" style={{ color: 'var(--text-primary)', fontWeight: 600 }}>112</span> workouts logged. Twelve weeks unbroken.
              </div>
            </Card>
          </div>
        </div>
      </Scroll>
    </>
  );
}

Object.assign(window, { ProfileScreen });
