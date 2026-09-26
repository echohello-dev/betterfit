const { Card, SectionHeader, Divider, SettingsRow, Button, WeightUnitToggle, Icon } = window.BetterFitDesignSystem_6a70ea;

function SettingsScreen({ onBack, scheme, onScheme }) {
  const [reminders, setReminders] = React.useState(true);
  const [health, setHealth] = React.useState(true);
  const [autoTrack, setAutoTrack] = React.useState(false);
  const [unit, setUnit] = React.useState('lb');
  return (
    <>
      <StatusBar />
      <NavBar title="Settings" leading={<Button variant="ghost" size="sm" fullWidth={false} icon="caret-left" onClick={onBack}>Back</Button>} />
      <Scroll>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <SectionHeader title="Appearance" />
            <Card>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <span style={{ fontSize: 'var(--text-body)' }}>Theme</span>
                <WeightUnitToggle value={scheme === 'dark' ? 'Dark' : 'Light'} options={['Light', 'Dark']} onChange={(v) => onScheme(v === 'Dark' ? 'dark' : 'light')} />
              </div>
              <Divider style={{ margin: '12px 0' }} />
              <div style={{ fontSize: 'var(--text-footnote)', color: 'var(--text-secondary)', textWrap: 'pretty' }}>
                BetterFit has one accent. Light and dark mirror the same two colours — there is nothing else to pick.
              </div>
            </Card>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <SectionHeader title="Training" />
            <Card>
              <SettingsRow kind="static" icon="scales" title="Weight units" value={unit === 'lb' ? 'Pounds' : 'Kilograms'} />
              <Divider />
              <SettingsRow kind="toggle" icon="pulse" title="Auto-track sets" subtitle="Detect sets from Apple Watch motion" checked={autoTrack} onChange={setAutoTrack} />
              <Divider />
              <SettingsRow kind="toggle" icon="heartbeat" title="Apple Health" subtitle="Read workouts and resting heart rate" checked={health} onChange={setHealth} />
            </Card>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <SectionHeader title="Notifications" />
            <Card>
              <SettingsRow kind="toggle" icon="bell" title="Workout reminders" subtitle="Weekdays, 6:30 pm" checked={reminders} onChange={setReminders} />
              <Divider />
              <SettingsRow kind="static" icon="timer" title="Default rest" value="90s" />
            </Card>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <SectionHeader title="About" />
            <Card>
              <SettingsRow kind="static" title="Version" value="1.8.2" />
              <Divider />
              <SettingsRow kind="link" title="Privacy policy" />
              <Divider />
              <SettingsRow kind="link" title="Licences" />
            </Card>
          </div>

          <Button variant="destructive">Sign out</Button>
        </div>
      </Scroll>
    </>
  );
}

Object.assign(window, { SettingsScreen });
