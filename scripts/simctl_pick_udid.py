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

    args = parser.parse_args()

    try:
        raw = subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "-j"])
    except FileNotFoundError:
        # xcrun not available in environment
        return 0
    except subprocess.CalledProcessError:
        return 0

    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        return 0

    devices = (data.get("devices", {}) or {}).get(args.runtime, []) or []
    udid = pick_udid(devices, args.prefer, args.contains)
    sys.stdout.write(udid)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
