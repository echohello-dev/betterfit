Rows for the settings and preferences surfaces.

```jsx
<SettingsRow kind="toggle" icon="bell" title="Workout reminders" checked onChange={setOn} />
<SettingsRow kind="radio" title="Pounds" checked />
<SettingsRow kind="static" title="Version" value="1.8.2" />
<SettingsRow kind="link" title="Privacy policy" />
```

Group rows inside a `Card` with `Divider`s between them; use a `SectionHeader` above each group.
