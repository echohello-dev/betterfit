#!/usr/bin/env python3
"""Prepare and archive an explicitly configured iOS beta without uploading it."""

import argparse
import base64
import ipaddress
import json
import os
from pathlib import Path
import plistlib
import re
import subprocess
from urllib.parse import urlsplit


def validate_versions(version, build):
    if not re.fullmatch(r"(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)", version):
        raise ValueError("Version must contain three period-separated integers.")
    if not re.fullmatch(r"[1-9][0-9]{0,3}(?:\.(?:0|[1-9][0-9]?)){0,2}", build):
        raise ValueError("Build must use up to three integers, limited to 4, 2 and 2 digits.")


def public_configuration(backend, config_path):
    if backend == "guest":
        if config_path is not None:
            raise ValueError("Guest archives must not receive a cloud configuration file.")
        return {"SUPABASE_URL": "", "SUPABASE_ANON_KEY": ""}
    if config_path is None:
        raise ValueError("Cloud archives require an explicit public configuration JSON file.")
    try:
        data = json.loads(Path(config_path).read_text())
    except (OSError, ValueError):
        raise ValueError("Unable to read public configuration JSON.") from None
    if not isinstance(data, dict) or set(data) != {"SUPABASE_URL", "SUPABASE_ANON_KEY"}:
        raise ValueError("Configuration must contain only SUPABASE_URL and SUPABASE_ANON_KEY.")
    if any(not isinstance(value, str) or not value for value in data.values()):
        raise ValueError("Both public configuration values must be non-empty strings.")
    try:
        url = urlsplit(data["SUPABASE_URL"])
        host = (url.hostname or "").lower().rstrip(".")
        _ = url.port
    except ValueError:
        raise ValueError("The cloud endpoint is invalid.") from None
    try:
        address = ipaddress.ip_address(host)
    except ValueError:
        address = None
    valid = (
        url.scheme == "https" and bool(host) and not url.username and not url.password
        and not url.query and not url.fragment
        and not host.endswith((".localhost", ".local", ".internal", ".test", ".invalid", ".example"))
        and host != "localhost" and "." in host
        and (address is None or address.is_global)
        and bool(re.fullmatch(r"https://[A-Za-z0-9.:/_-]+", data["SUPABASE_URL"]))
    )
    if not valid:
        raise ValueError("Cloud archives require a public HTTPS endpoint without credentials or query parameters.")
    key = data["SUPABASE_ANON_KEY"]
    if re.fullmatch(r"sb_publishable_[A-Za-z0-9_-]+", key):
        return data
    if re.fullmatch(r"[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+", key):
        try:
            payload = json.loads(base64.urlsafe_b64decode(key.split(".")[1] + "==="))
            if isinstance(payload, dict) and payload.get("role") == "anon":
                return data
        except (ValueError, UnicodeDecodeError):
            pass
    raise ValueError("Cloud archives require a publishable key or anon-role JWT, never a secret/service-role key.")


def prepare(output, version, build, team, backend, configuration):
    validate_versions(version, build)
    if not re.fullmatch(r"[A-Z0-9]{10}", team):
        raise ValueError("A ten-character Apple Developer team ID is required.")
    output.mkdir(parents=True, exist_ok=False)
    settings = {
        "MARKETING_VERSION": version, "CURRENT_PROJECT_VERSION": build,
        "DEVELOPMENT_TEAM": team, "BETTERFIT_BACKEND": backend,
        "BETTERFIT_SUPABASE_URL": configuration["SUPABASE_URL"].replace("://", ":/$()/"),
        "BETTERFIT_SUPABASE_ANON_KEY": configuration["SUPABASE_ANON_KEY"],
    }
    config = output / "Release.xcconfig"
    config.write_text("".join(f"{key} = {value}\n" for key, value in settings.items()))
    config.chmod(0o600)
    (output / "ExportOptions.plist").write_bytes(plistlib.dumps({
        "method": "app-store-connect", "destination": "export", "teamID": team,
        "signingStyle": "automatic", "manageAppVersionAndBuildNumber": False,
        "testFlightInternalTestingOnly": True, "uploadSymbols": True,
    }))
    return config


def validate_archive(archive, version, build, backend, configuration):
    apps = list((archive / "Products/Applications").glob("*.app"))
    if len(apps) != 1:
        raise ValueError("Archive must contain exactly one iOS app.")
    app = apps[0]
    info = plistlib.loads((app / "Info.plist").read_bytes())
    expected = {
        "CFBundleIdentifier": "dev.echohello.BetterFit", "CFBundleShortVersionString": version,
        "CFBundleVersion": build, "BetterFitBackend": backend, **configuration,
    }
    if any(info.get(key, "") != value for key, value in expected.items()):
        raise ValueError("Archived app identity, version or backend differs from the requested configuration.")
    if not (app / "PrivacyInfo.xcprivacy").is_file():
        raise ValueError("The app privacy manifest is missing from the archive.")
    if any(p.suffix in {".p8", ".p12"} or p.name.startswith(".env") for p in app.rglob("*")):
        raise ValueError("The archive contains a credential file.")


def redact(log, configuration):
    for value in configuration.values():
        if value:
            for rendered in [value, value.replace("://", ":/$()/")]:
                log = log.replace(rendered, "<redacted-public-config>")
    return log


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--backend", choices=["guest", "supabase"], required=True)
    parser.add_argument("--public-config", type=Path)
    parser.add_argument("--version", required=True)
    parser.add_argument("--build", required=True)
    parser.add_argument("--team", required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--prepare-only", action="store_true")
    args = parser.parse_args()
    try:
        configuration = public_configuration(args.backend, args.public_config)
        output = args.output.resolve()
        config = prepare(output, args.version, args.build, args.team, args.backend, configuration)
        if args.prepare_only:
            print("Prepared validated configuration and internal-only export options. Nothing built or uploaded.")
            return
        root = Path(__file__).resolve().parent.parent
        environment = {**os.environ, "DEVELOPMENT_TEAM": args.team}
        generation = subprocess.run(
            ["mise", "run", "ios:gen"], cwd=root, env=environment, capture_output=True
        )
        if generation.returncode:
            # The development scheme script can print .env values. Never relay its output.
            raise ValueError("Project generation failed; inspect the mise generation setup locally.")
        print("Archiving Release for iOS devices with automatic provisioning. Nothing will be uploaded.", flush=True)
        archive = output / "BetterFit.xcarchive"
        result = subprocess.run([
            "xcodebuild", "-project", "Apps/iOS/BetterFit.xcodeproj", "-scheme", "BetterFit",
            "-configuration", "Release", "-destination", "generic/platform=iOS",
            "-xcconfig", str(config), "-archivePath", str(archive),
            "-allowProvisioningUpdates", "archive",
        ], cwd=root, env=environment, capture_output=True, text=True)
        log = redact(result.stdout + result.stderr, configuration)
        (output / "archive.log").write_text(log)
        if result.returncode:
            raise ValueError("Archive failed; inspect archive.log in the output directory.")
        validate_archive(archive, args.version, args.build, args.backend, configuration)
        print(f"Validated dev.echohello.BetterFit {args.version} ({args.build}), backend {args.backend}.")
        print("Archive and internal-only export options are ready. Nothing has been exported or uploaded.")
    except (ValueError, OSError, plistlib.InvalidFileException) as error:
        parser.exit(1, f"Release preparation failed: {error}\n")


if __name__ == "__main__":
    main()
