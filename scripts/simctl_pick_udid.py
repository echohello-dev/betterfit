#!/usr/bin/env python3

import argparse
import json
import subprocess
import sys
from typing import Iterable, Optional


def pick_udid(devices: list[dict], preferred_names: Iterable[str], contains: Optional[str]) -> str:
    for name in preferred_names:
        for device in devices:
            if device.get("name") == name:
                return device.get("udid") or ""

    if contains:
        for device in devices:
            if contains in (device.get("name") or ""):
                return device.get("udid") or ""

    return (devices[0].get("udid") or "") if devices else ""


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Pick a preferred simulator device UDID from `xcrun simctl list devices available -j`."
    )
    parser.add_argument(
        "--runtime",
        required=True,
        help='Simulator runtime identifier (e.g. "com.apple.CoreSimulator.SimRuntime.iOS-26-2")',
    )
    parser.add_argument(
        "--prefer",
        action="append",
        default=[],
        help="Preferred device name (can be passed multiple times).",
    )
    parser.add_argument(
        "--contains",
        default=None,
        help='Fallback substring match for device name (e.g. "iPhone" or "Apple Watch").',
    )
    parser.add_argument(
        "--timeout-seconds",
        type=float,
        default=15.0,
        help="Timeout for the underlying `xcrun simctl list` call (default: 15s).",
    )

    args = parser.parse_args()

    try:
        result = subprocess.run(
            ["xcrun", "simctl", "list", "devices", "available", "-j"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=args.timeout_seconds,
        )
        raw = result.stdout
    except FileNotFoundError:
        sys.stderr.write("simctl_pick_udid.py: `xcrun` not found (install Xcode CLT / select Xcode).\n")
        return 1
    except subprocess.TimeoutExpired:
        sys.stderr.write(
            "simctl_pick_udid.py: timed out running `xcrun simctl list ...`.\n"
            "CoreSimulator may be hung. Try: `mise run ios:sim:reset` then retry.\n"
        )
        return 2
    except subprocess.CalledProcessError as e:
        sys.stderr.write("simctl_pick_udid.py: `xcrun simctl list` failed.\n")
        if e.stderr:
            try:
                sys.stderr.write(e.stderr.decode("utf-8", errors="replace"))
                if not e.stderr.endswith(b"\n"):
                    sys.stderr.write("\n")
            except Exception:
                pass
        return 3

    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        sys.stderr.write("simctl_pick_udid.py: failed to parse JSON output from `xcrun simctl list`.\n")
        return 4

    devices = (data.get("devices", {}) or {}).get(args.runtime, []) or []
    udid = pick_udid(devices, args.prefer, args.contains)
    sys.stdout.write(udid)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
