"""Offline checks through the native GDN Starlark runtime.

From a checkout with the SDK dependencies installed:
    python -B apps/commute/tests/check_behavior.py
No test accesses the network or uses real credentials.
"""
import copy
import datetime
from pathlib import Path
import unittest
from unittest.mock import patch

from gdn.fonts import get_glyphs, text_width
from gdn.runner import load_manifest
from gdn.starhost import executor

APP = Path(__file__).resolve().parents[1]
NOW = datetime.datetime(2026, 9, 27, 11, 24, tzinfo=datetime.timezone.utc)
UNIX = int(NOW.timestamp())
KEY = "test-only-key"


def fixture():
    return {
        "schema": 1, "state": "ok", "updatedAt": UNIX, "stale": False,
        "checkedTime": "7:24A", "arriveBy": "08:00", "stopEnabled": True,
        "stopName": "STARBUCKS", "stopState": "ok",
        "direct": {"road": {"kind": "interstate", "number": "675", "label": "I-675"},
                   "minutes": 24, "leaveAt": UNIX + 720, "leaveBy": "7:36A"},
        "stop": {"road": {"kind": "interstate", "number": "675", "label": "I-675"},
                 "minutes": 34, "leaveAt": UNIX + 120, "leaveBy": "7:26A"},
        "weather": {"kind": "sun", "temperatureF": 68, "description": "SUNNY"},
        "sources": {"weatherAlerts": {"state": "ok"}, "roads": {"state": "ok"}},
        "alerts": {"direct": [], "stop": []},
    }


def texts(scene, page="main"):
    return [op["text"] for item in scene["pages"] if item["name"] == page
            for op in item["ops"] if op["op"] == "text"]


class Compatibility(unittest.TestCase):
    def render(self, settings=None, data=None, status=200):
        calls = []
        payload = fixture() if data is None else data

        def get(_host, url, headers=None, params=None, ttl_seconds=300):
            calls.append({"url": url, "headers": headers, "params": params, "ttl": ttl_seconds})
            return {"status_code": status, "json": copy.deepcopy(payload), "body": "", "error": None}

        with patch.object(executor.HttpHost, "get", get):
            scene = executor.run_star_app(APP, settings or {}, now=NOW)
        return scene, calls

    def live(self, **settings):
        return {"endpoint": "example.invalid/status", "readkey": KEY, **settings}

    def test_endpoint_forms_preserve_authenticated_request_and_scene(self):
        expected_scene = None
        for endpoint in ["example.invalid/status", "  example.invalid/status  ", "https://example.invalid/status"]:
            with self.subTest(endpoint=endpoint):
                scene, calls = self.render(self.live(endpoint=endpoint))
                self.assertEqual(calls, [{"url": "https://example.invalid/status",
                                         "headers": {"Authorization": "Bearer " + KEY},
                                         "params": {"arriveby": "Configured"}, "ttl": 60}] * 2)
                if expected_scene is not None:
                    self.assertEqual(scene, expected_scene)
                expected_scene = scene
                self.assertIn("LEAVE BY 7:36A", texts(scene))

    def test_invalid_endpoints_never_send_credentials(self):
        for endpoint in ["https", "http://example.invalid/status", "example", "//example.invalid/status",
                         "user@example.invalid/status", "example.invalid:443/status", "bad host.invalid/status",
                         "example.invalid/status?key=x", "https://example.invalid/status#fragment",
                         "-bad.invalid/status", "bad..invalid/status"]:
            with self.subTest(endpoint=endpoint):
                scene, calls = self.render(self.live(endpoint=endpoint))
                self.assertIn("INVALID URL", texts(scene))
                self.assertEqual(calls, [])

    def test_missing_setup_never_fetches(self):
        for settings in [{}, {"endpoint": "example.invalid/status"}, {"readkey": KEY}]:
            scene, calls = self.render(settings)
            self.assertIn("SETUP REQUIRED", texts(scene))
            self.assertEqual(calls, [])

    def test_arrival_presets_and_legacy_values_preserve_worker_contract(self):
        for supplied, expected in [("8 AM", "08:00"), ("8.15 AM", "08:15"), ("8.30 AM", "08:30"),
                                   ("08:00", "08:00"), ("08:15", "08:15"), ("08:30", "08:30"),
                                   ("Configured", "Configured"), ("08", "Configured")]:
            with self.subTest(arrivetime=supplied):
                _, calls = self.render(self.live(arrivetime=supplied))
                self.assertEqual([call["params"] for call in calls], [{"arriveby": expected}] * 2)

    def test_new_and_legacy_arrival_choices_have_identical_demo_scenes(self):
        for current, legacy in [("8 AM", "08:00"), ("8.15 AM", "08:15"), ("8.30 AM", "08:30")]:
            for scenario in ["Interstate", "Leave now", "Late", "Stop too late"]:
                newer, calls = self.render({"demo": scenario, "arrivetime": current})
                older, old_calls = self.render({"demo": scenario, "arrivetime": legacy})
                self.assertEqual(newer, older)
                self.assertEqual(calls + old_calls, [])

    def test_absolute_deadlines_and_urgency_fit_in_display(self):
        for offset, label, color in [(720, "LEAVE BY 7:36A", "#55F3A6"),
                                     (299, "LEAVE BY 7:36A", "#FFC54A"),
                                     (0, "LEAVE BY 7:36A", "#FFC54A"),
                                     (-1, "LATE / BY 7:36A", "#FF5964")]:
            data = fixture()
            data["direct"]["leaveAt"] = UNIX + offset
            scene, _ = self.render(self.live(), data)
            headline = next(op for op in scene["pages"][0]["ops"] if op.get("text") == label)
            self.assertEqual(headline["color"], color)
            self.assertLessEqual(headline["x"] + text_width(headline["font"], label), 151)
            self.assertTrue(all(char in get_glyphs(headline["font"]) for char in label))
            self.assertFalse(any("LEAVE IN" in text or "MIN LATE" in text for text in texts(scene)))

    def test_stop_deadline_and_missing_time(self):
        scene, _ = self.render(self.live(trip="Stopover"))
        self.assertIn("LEAVE BY 7:26A", texts(scene))
        self.assertIn("DIRECT: BY 7:36A", texts(scene))
        data = fixture()
        data["direct"].pop("leaveBy")
        scene, _ = self.render(self.live(), data)
        self.assertIn("CHECK LEAVE TIME", texts(scene))

    def test_long_stop_name_preserves_complete_upcoming_or_missed_deadline(self):
        for offset, suffix in [(120, ": BY 7:26A"), (-1, ": MISSED 7:26A")]:
            data = fixture()
            data["stopName"] = "NEIGHBORHOOD COFFEE SHOP WITH A LONG NAME"
            data["stop"]["leaveAt"] = UNIX + offset
            scene, _ = self.render(self.live(), data)
            footer = next(op for op in scene["pages"][0]["ops"]
                          if op["op"] == "text" and op["y"] == 25)
            self.assertTrue(footer["text"].endswith(suffix), footer["text"])
            self.assertIn("..", footer["text"])
            self.assertLessEqual(footer["x"] + text_width(footer["font"], footer["text"]), 181)

    def test_three_minute_freshness_cutoff_is_unchanged(self):
        for age, stale in [(180, False), (181, True), (-31, True)]:
            data = fixture()
            data["updatedAt"] = UNIX - age
            scene, _ = self.render(self.live(), data)
            self.assertEqual("TRAFFIC STALE" in texts(scene), stale)

    def test_weather_warning_still_overrides_stale_traffic(self):
        data = fixture()
        data["stale"] = True
        data["alerts"]["direct"] = [{"kind": "weather", "severity": "Extreme",
                                      "title": "TORNADO WARNING", "detail": "TAKE SHELTER NOW"}]
        scene, _ = self.render(self.live(), data)
        self.assertIn("TORNADO WARNING", texts(scene))
        self.assertIn("TORNADO WARNING", texts(scene, "routeweather"))

    def test_failed_request_keeps_error_state(self):
        for status in [0, 401, 500]:
            scene, _ = self.render(self.live(), status=status)
            self.assertIn("NO LIVE DATA", texts(scene))

    def test_all_demos_and_views_render_without_network(self):
        manifest = load_manifest(APP)
        demos = next(item["choices"] for item in manifest["inputs"] if item["key"] == "demo")
        for scenario in demos:
            if scenario == "Live":
                continue
            for mode in ["Departure", "Routes", "Conditions"]:
                with self.subTest(demo=scenario, viewmode=mode):
                    scene, calls = self.render({"demo": scenario, "viewmode": mode})
                    self.assertEqual(len(scene["pages"]), 2)
                    self.assertEqual(calls, [])


if __name__ == "__main__":
    unittest.main(verbosity=2)
