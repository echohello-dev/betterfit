import { defineConfig } from 'mobilewright';

export default defineConfig({
  platform: 'ios',
  deviceType: 'simulator',
  deviceName: /iPhone/,
  bundleId: 'dev.echohello.BetterFit',
  // Launch args (UI_TESTING / DEMO_MODE) are passed by tests/helpers.ts via
  // simctl — mobilewright's LaunchOptions only supports locales.
  autoAppLaunch: false,
  viewTree: 'on-failure',
  // Per-test budget: resetAndLaunch (uninstall -> install -> launch) counts
  // against the test, and CI runners are 2-3x slower than local.
  timeout: 120_000,
  expect: { timeout: 8_000 },
  retries: 1,
  workers: 1,
  reporter: [['list'], ['html', { open: 'never' }]],
  captureGitInfo: { commit: true },
});
