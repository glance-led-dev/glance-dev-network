"""Offline input/transport regression tests using the native GDN Starlark host.

Run from the repository root with the SDK dependencies installed:
    python -B -m unittest discover -s apps/xbox-companion/tests -v
"""

import copy
import datetime
from pathlib import Path
import unittest
from unittest.mock import patch

import yaml
from gdn.starhost import executor


APP = Path(__file__).resolve().parents[1]
NOW = datetime.datetime(2026, 9, 27, tzinfo=datetime.timezone.utc)
EPOCH = int(NOW.timestamp())
SNAPSHOT = {
    "schema": 1,
    "state": "ready",
    "updated": EPOCH,
    "profile": {"gamertag": "PLAYER ONE", "score": 84720},
    "presence": {"state": "online", "title": "FORZA HORIZON"},
}


class InputCompatibilityTests(unittest.TestCase):
    def setUp(self):
        self.calls = []
        self.status = 200
        self.snapshot = copy.deepcopy(SNAPSHOT)

        def fake_get(_host, url, headers=None, params=None, ttl_seconds=300):
            self.calls.append((url, headers, params, ttl_seconds))
            return {
                "status_code": self.status,
                "json": self.snapshot if self.status == 200 else None,
                "body": "",
                "error": None,
            }

        self.http = patch.object(executor.HttpHost, "get", fake_get)
        self.http.start()
        self.addCleanup(self.http.stop)

    def render(self, endpoint="xbox.example.invalid/status", **inputs):
        settings = {"endpoint": endpoint, "readkey": "test-only-key", **inputs}
        return executor.run_star_app(APP, settings, now=NOW)

    @staticmethod
    def text(scene):
        return [op["text"] for page in scene["pages"] for op in page["ops"] if op["op"] == "text"]

    def test_host_path_matches_legacy_scene_and_transport(self):
        legacy = self.render("https://xbox.example.invalid/status")
        for endpoint in ["xbox.example.invalid/status", "  xbox.example.invalid/status  "]:
            with self.subTest(endpoint=endpoint):
                self.calls.clear()
                self.assertEqual(legacy, self.render(endpoint))
                self.assertEqual(self.calls, [(
                    "https://xbox.example.invalid/status",
                    {"Authorization": "Bearer test-only-key"}, None, 60,
                )])

    def test_path_and_query_are_preserved(self):
        self.render("xbox.example.invalid/companion/status?view=profile")
        self.assertEqual(self.calls[0][0], "https://xbox.example.invalid/companion/status?view=profile")

    def test_legacy_https_input_is_preserved(self):
        endpoint = "https://xbox.example.invalid:8443/status?view=profile"
        self.render(endpoint)
        self.assertEqual(self.calls[0][0], endpoint)

    def test_invalid_host_inputs_do_not_fetch(self):
        for endpoint in [
            "https", "http://xbox.example.invalid/status", "localhost/status",
            "xbox.example.invalid:8443/status", "xbox.example.invalid/a:b",
            "user@xbox.example.invalid/status", "xbox.example.invalid/status#part",
            "xbox.example.invalid\\status", "xbox.example.invalid/a b",
            "xbox.example.invalid/a\nb", "xbox.example.invalid/a\tb",
            ".example.invalid/status", "example.invalid./status",
            "bad..example.invalid/status", "-bad.example.invalid/status",
            "bad-.example.invalid/status", "bad_name.example.invalid/status",
        ]:
            with self.subTest(endpoint=endpoint):
                self.calls.clear()
                self.assertIn("CHECK STATUS HOST", self.text(self.render(endpoint)))
                self.assertEqual(self.calls, [])

    def test_missing_settings_do_not_fetch(self):
        for settings in [{}, {"endpoint": ""}, {"readkey": ""}, {"endpoint": "   "}]:
            with self.subTest(settings=settings):
                self.calls.clear()
                scene = executor.run_star_app(APP, settings, now=NOW)
                self.assertIn("CONNECT ACCOUNT", self.text(scene))
                self.assertEqual(self.calls, [])

    def test_all_demos_bypass_network(self):
        manifest = yaml.safe_load((APP / "manifest.yaml").read_text(encoding="utf-8"))
        modes = next(item["choices"] for item in manifest["inputs"] if item["key"] == "demo")
        for mode in modes:
            if mode == "Live":
                continue
            with self.subTest(mode=mode):
                self.calls.clear()
                self.render("https", demo=mode, readkey="")
                self.assertEqual(self.calls, [])

    def test_http_failures_keep_existing_states(self):
        for status, message in [(401, "RECONNECT ACCOUNT"), (403, "RECONNECT ACCOUNT"), (503, "SERVICE UNAVAILABLE"), (0, "SERVICE UNAVAILABLE")]:
            with self.subTest(status=status):
                self.status = status
                self.assertIn(message, self.text(self.render()))

    def test_schema_and_freshness_boundaries_are_preserved(self):
        self.snapshot["schema"] = 2
        self.assertIn("NO XBOX DATA", self.text(self.render()))
        self.snapshot["schema"] = 1
        for age, stale in [(300, False), (301, True), (-60, False), (-61, True)]:
            with self.subTest(age=age):
                self.snapshot["updated"] = EPOCH - age
                self.assertEqual("LAST UPDATE IS OLD" in self.text(self.render()), stale)

    def test_manifest_keeps_settings_contract_and_allowed_refresh(self):
        manifest = yaml.safe_load((APP / "manifest.yaml").read_text(encoding="utf-8"))
        self.assertEqual(manifest["refresh"], 300)
        settings = {item["key"]: item for item in manifest["inputs"]}
        self.assertEqual(list(settings), [
            "endpoint", "readkey", "viewmode", "showfriends", "showpic",
            "showart", "showscore", "showgame", "showachievements", "demo",
        ])
        self.assertEqual(settings["endpoint"]["app_input_type"], "free-text")
        self.assertEqual(settings["readkey"]["app_input_type"], "api-key")
        self.assertEqual(settings["endpoint"]["default"], "")
        self.assertEqual(settings["readkey"]["default"], "")
        self.assertEqual(settings["demo"]["default"], "Live")
        self.assertEqual(settings["viewmode"]["default"], "Auto")
        self.assertEqual(self.render()["app"]["refresh"], 300)


if __name__ == "__main__":
    unittest.main()
