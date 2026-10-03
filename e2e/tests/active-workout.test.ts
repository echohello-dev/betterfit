import { test, expect } from '@mobilewright/test';
import { resetAndLaunch } from './helpers';

// Maps to Figma flow 2 (Log a set) + flow 3 (Rest):
// Plan -> Start workout -> log set 1 -> rest timer appears.
// The demo plan varies by weekday (Push/Pull/Legs/Upper; rest days fall back to
// a Pull Day demo), so match set counters structurally, never by session name.
test('start workout, log a set, rest timer appears', async ({ device, screen }) => {
  await resetAndLaunch(device);

  await screen.getByRole('button', { name: 'Start workout' }).tap();
  await expect(screen.getByRole('button', { name: 'Back to plan' })).toBeVisible();
  await expect(screen.getByText(/^SET 1 OF \d+$/)).toBeVisible();

  // Dock label carries the live target, e.g. "Log 185 × 6".
  await screen.getByRole('button', { name: /Log .*×/ }).tap();

  await expect(screen.getByText(/^SET 2 OF \d+$/)).toBeVisible();
  await expect(screen.getByText('Rest', { exact: true })).toBeVisible();
  await expect(screen.getByRole('button', { name: 'Skip' })).toBeVisible();
  await expect(screen.getByRole('button', { name: '+15s' })).toBeVisible();
});

test('skip rest dismisses the timer', async ({ device, screen }) => {
  await resetAndLaunch(device);

  await screen.getByRole('button', { name: 'Start workout' }).tap();
  await expect(screen.getByText(/^SET 1 OF \d+$/)).toBeVisible();
  await screen.getByRole('button', { name: /Log .*×/ }).tap();
  await expect(screen.getByText('Rest', { exact: true })).toBeVisible();

  await screen.getByRole('button', { name: 'Skip' }).tap();
  await expect(screen.getByText('Rest', { exact: true })).toBeHidden({ timeout: 10_000 });
});
