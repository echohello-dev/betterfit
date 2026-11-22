import base64
import importlib.util
import json
from pathlib import Path
import plistlib
import struct
import tempfile
import unittest
import zlib

SPEC = importlib.util.spec_from_file_location(
    "testflight_archive", Path(__file__).resolve().parents[1] / "testflight_archive.py"
)
release = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(release)


class TestFlightArchiveTests(unittest.TestCase):
    def test_checked_in_ios_icon_catalog_is_opaque(self):
        root = Path(__file__).resolve().parents[2]
        release.validate_icon_catalog(root / "Apps/iOS/BetterFitApp/Assets.xcassets/AppIcon.appiconset")

    def test_icon_preflight_rejects_alpha_and_transparency(self):
        self.assertEqual(release.validate_icon_png(self.png(2)), (1024, 1024))
        for data in [self.png(6), self.png(2, transparency=True), b"invalid"]:
            with self.assertRaises(ValueError):
                release.validate_icon_png(data)

    def test_compiled_marketing_icon_must_be_present_and_opaque(self):
        icon = {"Name": "AppIcon", "PixelWidth": 1024, "PixelHeight": 1024, "Opaque": True}
        release.validate_compiled_icons([icon])
        for metadata in [[], [{**icon, "Opaque": False}], [{**icon, "PixelWidth": 180}]]:
            with self.assertRaises(ValueError):
                release.validate_compiled_icons(metadata)

    def configuration(self, data):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "public.json"
            path.write_text(json.dumps(data))
            return release.public_configuration("supabase", path)

    def test_guest_never_accepts_cloud_file(self):
        self.assertEqual(release.public_configuration("guest", None), {
            "SUPABASE_URL": "", "SUPABASE_ANON_KEY": ""
        })
        with self.assertRaises(ValueError):
            release.public_configuration("guest", Path("unused.json"))

    def test_rejects_local_or_credential_bearing_endpoints(self):
        for url in [
            "http://project.supabase.co", "https://127.0.0.1", "https://192.168.1.2",
            "https://localhost", "https://api.local", "https://user:password@project.supabase.co",
            "https://project.supabase.co?token=secret", "https://[invalid", "https://example.invalid",
            "https://project.supabase.co:invalid",
        ]:
            with self.subTest(url=url), self.assertRaises(ValueError):
                self.configuration({"SUPABASE_URL": url, "SUPABASE_ANON_KEY": "sb_publishable_fixture"})

    def test_rejects_privileged_or_unrecognised_keys(self):
        for key in ["sb_secret_fixture", "unknown", self.jwt("service_role"), "x\nINJECTED = YES"]:
            with self.subTest(key_type=key.split("_")[0]), self.assertRaises(ValueError):
                self.configuration({"SUPABASE_URL": "https://project.supabase.co", "SUPABASE_ANON_KEY": key})
        with self.assertRaises(ValueError):
            self.configuration({
                "SUPABASE_URL": "https://project.supabase.co",
                "SUPABASE_ANON_KEY": "sb_publishable_fixture", "SUPABASE_SECRET_KEY": "private",
            })

    def test_accepts_only_public_client_key_types(self):
        for key in ["sb_publishable_fixture", self.jwt("anon")]:
            data = {"SUPABASE_URL": "https://project.supabase.co", "SUPABASE_ANON_KEY": key}
            self.assertEqual(self.configuration(data), data)

    def test_build_format_rejects_timestamps_and_injection(self):
        release.validate_versions("1.7.0", "2611.22.1")
        for build in ["20261122", "2026.1122.1", "1.2.100", "0", "1.02.3", "1\nOTHER=YES"]:
            with self.subTest(build=build), self.assertRaises(ValueError):
                release.validate_versions("1.7.0", build)

    def test_export_is_local_and_internal_only(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "release"
            config = release.prepare(output, "1.7.0", "2611.22.1", "ABCDEFGHIJ", "guest", {
                "SUPABASE_URL": "", "SUPABASE_ANON_KEY": ""
            })
            self.assertEqual(config.stat().st_mode & 0o777, 0o600)
            options = plistlib.loads((output / "ExportOptions.plist").read_bytes())
            self.assertEqual(options["destination"], "export")
            self.assertTrue(options["testFlightInternalTestingOnly"])
            self.assertFalse(options["manageAppVersionAndBuildNumber"])

    def test_log_redacts_public_values_and_xcconfig_url_rendering(self):
        config = {"SUPABASE_URL": "https://project.supabase.co", "SUPABASE_ANON_KEY": "sb_publishable_fixture"}
        log = "https://project.supabase.co https:/$()/project.supabase.co sb_publishable_fixture"
        self.assertNotIn("project.supabase.co", release.redact(log, config))
        self.assertNotIn("sb_publishable_fixture", release.redact(log, config))

    def test_archive_requires_matching_metadata_and_no_credential_files(self):
        with tempfile.TemporaryDirectory() as directory:
            archive = Path(directory)
            app = archive / "Products/Applications/BetterFitApp.app"
            app.mkdir(parents=True)
            config = {"SUPABASE_URL": "", "SUPABASE_ANON_KEY": ""}
            info = {
                "CFBundleIdentifier": "dev.echohello.BetterFit", "CFBundleShortVersionString": "1.7.0",
                "CFBundleVersion": "2611.22.1", "BetterFitBackend": "guest", **config,
            }
            (app / "Info.plist").write_bytes(plistlib.dumps(info))
            (app / "PrivacyInfo.xcprivacy").write_bytes(plistlib.dumps({}))
            release.validate_archive(archive, "1.7.0", "2611.22.1", "guest", config)
            with self.assertRaises(ValueError):
                release.validate_archive(archive, "1.7.0", "2611.22.2", "guest", config)
            (app / ".env").write_text("PRIVATE=must-not-ship")
            with self.assertRaises(ValueError):
                release.validate_archive(archive, "1.7.0", "2611.22.1", "guest", config)

    @staticmethod
    def jwt(role):
        payload = base64.urlsafe_b64encode(json.dumps({"role": role}).encode()).decode().rstrip("=")
        return f"header.{payload}.signature"

    @staticmethod
    def png(colour_type, transparency=False):
        def chunk(kind, content):
            return (struct.pack(">I", len(content)) + kind + content
                    + struct.pack(">I", zlib.crc32(kind + content)))
        header = struct.pack(">IIBBBBB", 1024, 1024, 8, colour_type, 0, 0, 0)
        extra = chunk(b"tRNS", b"\x00\x00\x00\x00\x00\x00") if transparency else b""
        return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) + extra + chunk(b"IEND", b"")
