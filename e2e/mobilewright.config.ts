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
  timeout: 60_000,
  expect: { timeout: 8_000 },
  retries: 1,
  workers: 1,
  reporter: [['list'], ['html', { open: 'never' }]],
  captureGitInfo: { commit: true },
});
