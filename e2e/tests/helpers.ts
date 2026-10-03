import { execFileSync, execSync } from 'node:child_process';
import { existsSync, readdirSync, statSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';
import type { Device } from '@mobilewright/core';

export const BUNDLE_ID = 'dev.echohello.BetterFit';
export const LAUNCH_ARGS = ['UI_TESTING', 'DEMO_MODE'];

/**
 * Newest built BetterFitApp.app across DerivedData folders.
 * Build it first: `mise run ios:build:dev`.
 */
export function findBuiltApp(): string {
  const root = join(homedir(), 'Library/Developer/Xcode/DerivedData');
  if (!existsSync(root)) throw new Error('No DerivedData — run `mise run ios:build:dev` first.');
  let newest: { path: string; mtime: number } | undefined;
  for (const dir of readdirSync(root)) {
    if (!dir.startsWith('BetterFit')) continue;
    const app = join(root, dir, 'Build/Products/Debug-iphonesimulator/BetterFitApp.app');
    if (!existsSync(app)) continue;
    const mtime = statSync(app).mtimeMs;
    if (!newest || mtime > newest.mtime) newest = { path: app, mtime };
  }
  if (!newest) throw new Error('No built BetterFitApp.app found — run `mise run ios:build:dev` first.');
  return newest.path;
}

function foregroundApp(deviceId: string): string {
  try {
    const out = execFileSync('mobilecli', ['apps', 'foreground', '--device', deviceId], {
      encoding: 'utf8',
    });
    return JSON.parse(out)?.data?.packageName ?? '';
  } catch {
    return '';
  }
}

/**
 * Fresh app instance per test: uninstall (pristine demo data), install the
 * current build, launch with the same args the XCUITest suite uses.
 */
export async function resetAndLaunch(device: Device): Promise<void> {
  const app = findBuiltApp();
  const udid = device.id;

  execSync(`xcrun simctl uninstall "${udid}" ${BUNDLE_ID} || true`, { stdio: 'ignore' });
  execSync(`xcrun simctl install "${udid}" "${app}"`, { stdio: 'ignore' });
  execSync(`xcrun simctl launch "${udid}" ${BUNDLE_ID} ${LAUNCH_ARGS.join(' ')}`, {
    stdio: 'ignore',
  });

  // expect.poll() is not available in @mobilewright/test's expect — poll manually.
  // First launch after a fresh install can be slow on a loaded simulator.
  const deadline = Date.now() + 60_000;
  for (;;) {
    if (foregroundApp(udid) === BUNDLE_ID) return;
    if (Date.now() > deadline) {
      throw new Error(`app did not come to foreground on ${udid}`);
    }
    await new Promise((resolve) => setTimeout(resolve, 500));
  }
}
