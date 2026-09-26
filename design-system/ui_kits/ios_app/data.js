window.BFData = {
  user: { name: 'Johnny', since: 'Member since Jan 2024', plan: 'Pro' },
  today: {
    name: 'Pull B', focus: 'Today · Tue 26 Jul', exercises: 5, duration: '42 min', volume: '14.2k lb',
    muscles: ['Lats', 'Biceps', 'Rear delts']
  },
  muscleSplit: [
    { muscle: 'Lats', percent: 38 }, { muscle: 'Biceps', percent: 27 },
    { muscle: 'Rear delts', percent: 21 }, { muscle: 'Core', percent: 14 }
  ],
  plan: [
    { index: 1, name: 'Trap bar deadlift', prescription: '4 × 5 · 245 lb', muscles: 'Back, Glutes', state: 'planned' },
    { index: 2, name: 'Barbell row', prescription: '4 × 8 · 135 lb', muscles: 'Lats, Rear delts', state: 'planned' },
    { index: 3, name: 'Lat pulldown', prescription: '3 × 10 · 120 lb', muscles: 'Lats', state: 'planned' },
    { index: 4, name: 'EZ curl', prescription: '3 × 12 · 65 lb', muscles: 'Biceps', state: 'planned' },
    { index: 5, name: 'Face pull', prescription: '3 × 15 · 40 lb', muscles: 'Rear delts', state: 'planned' }
  ],
  recovery: {
    overall: 72,
    regions: [
      { region: 'Chest', status: 'sore', percent: 34 },
      { region: 'Back', status: 'recovered', percent: 96 },
      { region: 'Shoulders', status: 'fatigued', percent: 58 },
      { region: 'Arms', status: 'fresh', percent: 81 },
      { region: 'Core', status: 'recovered', percent: 92 },
      { region: 'Legs', status: 'fresh', percent: 77 }
    ]
  },
  streak: { current: 12, best: 21 },
  heatmap: Array.from({ length: 182 }, (_, i) => (i % 7 === 2 || i % 7 === 6) ? 0 : Math.round(Math.abs(Math.sin(i * 0.63)) * 4)),
  prs: [
    { name: 'Trap bar deadlift', value: '345 lb', when: '2 weeks ago' },
    { name: 'Bench press', value: '205 lb', when: 'Last month' },
    { name: 'Back squat', value: '285 lb', when: 'Last month' }
  ],
  targets: [
    { label: 'Workouts', value: 3, target: 5, unit: '' },
    { label: 'Volume', value: 41, target: 60, unit: 'k lb' },
    { label: 'Active minutes', value: 186, target: 250, unit: '' }
  ],
  achievements: [
    { icon: 'medal', title: 'Ten in a row', done: true },
    { icon: 'barbell', title: 'Bodyweight bench', done: true },
    { icon: 'sun-horizon', title: 'Five 6am sessions', done: false },
    { icon: 'mountains', title: '100k lb month', done: false }
  ],
  searchResults: [
    { icon: 'barbell', title: 'Bench press', subtitle: 'Chest · Barbell' },
    { icon: 'barbell', title: 'Incline bench press', subtitle: 'Chest · Barbell' },
    { icon: 'person-simple-run', title: 'Treadmill intervals', subtitle: 'Cardio · Machine' },
    { icon: 'barbell', title: 'Bent-over row', subtitle: 'Back · Barbell' },
    { icon: 'gear-six', title: 'Weight units', subtitle: 'Setting · Preferences' }
  ],
  week: [
    { day: 'Mon', name: 'Push A', done: true },
    { day: 'Tue', name: 'Pull B', done: false, today: true },
    { day: 'Wed', name: 'Rest', done: false },
    { day: 'Thu', name: 'Legs A', done: false },
    { day: 'Fri', name: 'Push B', done: false },
    { day: 'Sat', name: 'Conditioning', done: false },
    { day: 'Sun', name: 'Rest', done: false }
  ]
};
