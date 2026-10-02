import { test, expect } from '@mobilewright/test';
import { resetAndLaunch } from './helpers';

test('plan tab renders the work list and start CTA', async ({ device, screen }) => {
  await resetAndLaunch(device);

  await expect(screen.getByRole('button', { name: 'Workout', exact: true })).toBeVisible();
  await expect(screen.getByText('The work')).toBeVisible();
  // Meta line varies by session (e.g. "Focus exercise · Quads") — substring match.
  await expect(screen.getByText('Focus exercise', { exact: false })).toBeVisible();
  await expect(screen.getByRole('button', { name: 'Start workout' })).toBeVisible();
});

test('all four tabs are reachable and show distinct content', async ({ device, screen }) => {
  await resetAndLaunch(device);

  await screen.getByRole('button', { name: 'Body', exact: true }).tap();
  await expect(screen.getByText('Overall recovery')).toBeVisible();
  await expect(screen.getByText('By muscle group')).toBeVisible();

  await screen.getByRole('button', { name: 'Targets', exact: true }).tap();
  await expect(screen.getByText('This week')).toBeVisible();
  await expect(screen.getByText('Weekly targets')).toBeVisible();

  await screen.getByRole('button', { name: 'Log', exact: true }).tap();
  await expect(screen.getByText('Current streak')).toBeVisible();
  await expect(screen.getByText('Consistency')).toBeVisible();

  await screen.getByRole('button', { name: 'Workout', exact: true }).tap();
  await expect(screen.getByText('The work')).toBeVisible();
});
