const { Card, Divider, Chip, Icon, ListRow, EmptyState, Button } = window.BetterFitDesignSystem_6a70ea;

function SearchScreen() {
  const d = window.BFData;
  const [q, setQ] = React.useState('');
  const results = d.searchResults.filter((r) => r.title.toLowerCase().includes(q.toLowerCase()));
  return (
    <>
      <StatusBar />
      <NavBar title="Search" />
      <div style={{ flex: '0 0 auto', padding: '0 20px 12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, background: 'var(--surface-raised)', border: '1px solid var(--border)', borderRadius: 'var(--radius-md)', padding: '0 12px', height: 44 }}>
          <Icon name="magnifying-glass" size={16} color="var(--text-tertiary)" />
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Exercises, plans, settings"
            style={{ flex: 1, alignSelf: 'stretch', background: 'transparent', border: 'none', outline: 'none', color: 'var(--text-primary)', fontSize: 'var(--text-body)', fontFamily: 'var(--font-ui)' }} />
          {q && <button type="button" onClick={() => setQ('')} aria-label="Clear" style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-tertiary)', width: 'var(--tap-min)', height: 'var(--tap-min)', display: 'grid', placeItems: 'center' }}><Icon name="x-circle" size={16} /></button>}
        </div>
      </div>
      <div style={{ flex: '0 0 auto', display: 'flex', gap: 8, padding: '0 20px 16px', overflowX: 'auto', scrollbarWidth: 'none', msOverflowStyle: 'none' }}>
        <Chip label="All" selected />
        <Chip label="Exercises" icon="barbell" />
        <Chip label="Muscles" />
        <Chip label="Settings" icon="gear-six" />
      </div>
      <Scroll>
        {results.length === 0 ? (
          <EmptyState icon="magnifying-glass" title={`Nothing matches "${q}"`} message="Try a muscle group, a piece of equipment, or a setting name."
            action={<Button size="sm" fullWidth={false} variant="secondary" onClick={() => setQ('')}>Clear search</Button>} />
        ) : (
          <Card padding={12}>
            {results.map((r, i) => (
              <div key={r.title}>
                {i > 0 && <Divider inset={56} />}
                <ListRow icon={r.icon} title={r.title} subtitle={r.subtitle} onClick={() => {}}
                  trailing={<Icon name="caret-right" size={13} weight="bold" color="var(--text-tertiary)" />} />
              </div>
            ))}
          </Card>
        )}
      </Scroll>
    </>
  );
}

Object.assign(window, { SearchScreen });
