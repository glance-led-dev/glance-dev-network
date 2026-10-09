"""Exercise the real Starlark app against deterministic SIRI responses.

No credentials, no network. Run from the SDK root:
  .venv/bin/python -m unittest discover -s apps/civic-center-muni/tests -v
"""
import copy
import datetime as dt
from pathlib import Path
import unittest
from unittest.mock import patch

from gdn.fonts import font_height, text_width
from gdn.scene import render_scene
from gdn.starhost import run_star_app

APP = Path(__file__).resolve().parents[1]
NOW = dt.datetime(2026, 10, 9, 21, 0, tzinfo=dt.timezone.utc)


def iso(minutes=0):
    return (NOW + dt.timedelta(minutes=minutes)).isoformat()


def visit(route="N", minutes=3, stop="16997", trip="train-1", **call_overrides):
    call = {"StopPointRef": stop, "ExpectedArrivalTime": iso(minutes)}
    call.update(call_overrides)
    return {
        "RecordedAtTime": iso(), "MonitoringRef": stop,
        "MonitoredVehicleJourney": {
            "PublishedLineName": route, "OperatorRef": "SF", "Monitored": True,
            "DestinationName": "Ocean Beach" if route == "N" else "Balboa Park",
            "FramedVehicleJourneyRef": {"DatedVehicleJourneyRef": trip},
            "MonitoredCall": call,
        },
    }


def feed(visits):
    return {"Siri": {"ServiceDelivery": {
        "Status": True, "ResponseTimestamp": iso(),
        "StopMonitoringDelivery": {
            "ResponseTimestamp": iso(), "MonitoredStopVisit": visits,
        },
    }}}


def run(payload=None, status=200, page=1, inputs=None):
    response = {"status_code": status, "json": payload, "body": ""}
    with patch("gdn.starhost.executor.HttpHost.get", return_value=response) as request:
        scene = run_star_app(APP, inputs=inputs or {"apikey": "test-token"}, now=NOW, only_page=page)
    return scene, request


def text(scene):
    return [op["text"] for op in scene["pages"][0]["ops"] if op["op"] == "text"]


class ArrivalsTests(unittest.TestCase):
    def test_sample_preview_has_eight_arrivals_and_never_fetches(self):
        for page in [1, 2]:
            scene, request = run(inputs={"apikey": ""}, page=page)
            self.assertIn("WESTBOUND" if page == 1 else "EASTBOUND", text(scene))
            self.assertNotIn("DEMO", " ".join(text(scene)))
            self.assertEqual(len(text(scene)), 17)  # Heading plus eight pairs.
            request.assert_not_called()

    def test_real_arrivals_sort_and_deduplicate_trips(self):
        near = visit()
        visits = [visit("L", 12, trip="train-3"), visit("K", 8, trip="train-2"), near, copy.deepcopy(near)]
        scene, request = run(feed(visits))
        self.assertEqual(text(scene)[1:3], ["N", "3"])
        self.assertEqual(text(scene)[1:], ["N", "3", "K", "8", "L", "12"])
        params = request.call_args.kwargs["params"]
        self.assertEqual((params["agency"], params["stopcode"]), ("SF", "16997"))

    def test_platforms_and_bus_services_never_mix(self):
        payload = feed([visit("14", 1), visit("N", 2), visit("M", 4, "15727", "inbound")])
        scene, request = run(payload, page=2)
        self.assertEqual(text(scene)[1:3], ["M", "4"])
        self.assertEqual(request.call_args.kwargs["params"]["stopcode"], "15727")

    def test_offsets_and_fractional_seconds(self):
        for timestamp in ["2026-10-09T14:03:00-07:00", "2026-10-09T21:03:00Z", "2026-10-09T21:03:00.123Z"]:
            scene, _ = run(feed(visit(ExpectedArrivalTime=timestamp)))
            self.assertEqual(text(scene)[1:3], ["N", "3"])

    def test_past_cancelled_scheduled_and_stale_predictions_are_excluded(self):
        scheduled = visit(trip="scheduled", ExpectedArrivalTime="", AimedArrivalTime=iso(4))
        stale = visit(trip="stale")
        stale["RecordedAtTime"] = iso(-11)
        visits = [visit(minutes=-1), visit(trip="cancelled", ArrivalStatus="cancelled"), scheduled, stale]
        scene, _ = run(feed(visits))
        self.assertIn("NO TRAINS", text(scene))
        self.assertIn("PREDICTED", text(scene))

    def test_stale_feed_and_http_failures_have_actionable_screens(self):
        payload = feed([visit()])
        payload["Siri"]["ServiceDelivery"]["StopMonitoringDelivery"]["ResponseTimestamp"] = iso(-11)
        scene, _ = run(payload)
        self.assertIn("STALE FEED", text(scene))
        for status, expected in [(0, "OFFLINE"), (401, "CHECK KEY"), (403, "CHECK KEY"), (429, "RATE LIMIT"), (500, "OFFLINE")]:
            scene, _ = run(status=status)
            self.assertIn(expected, text(scene))
            self.assertNotIn("DEMO", text(scene))

    def test_malformed_responses_and_timestamps_do_not_crash(self):
        for payload in [None, [], {}, {"Siri": []}, feed([]), feed([None]), feed([visit(ExpectedArrivalTime="broken")])]:
            scene, _ = run(payload)
            render_scene(scene, asset_dir=APP)
        payload = feed([])
        payload["Siri"]["ServiceDelivery"]["StopMonitoringDelivery"] = [None]
        self.assertIn("BAD FEED", text(run(payload)[0]))

    def test_text_stays_on_the_panel_and_does_not_overlap(self):
        cases = [feed([visit(minutes=m)] + [visit("K", 90, trip="next-%d" % i) for i in range(n-1)]) for m in [0, 1, 12, 90] for n in [1, 8, 16]]
        cases += [feed([]), None]
        for payload in cases:
            scene, _ = run(payload)
            boxes = []
            for op in scene["pages"][0]["ops"]:
                if op["op"] != "text" or not op["text"]:
                    continue
                w, h = text_width(op["font"], op["text"]), font_height(op["font"])
                x = op["x"] - (w if op.get("align") == "right" else w // 2 if op.get("align") == "center" else 0)
                y = op["y"]
                self.assertTrue(0 <= x and x+w <= 64 and 0 <= y and y+h <= 32, (op, x, w, h))
                box = (x, y, x+w, y+h)
                for other in boxes:
                    self.assertFalse(box[0] < other[2] and other[0] < box[2] and box[1] < other[3] and other[1] < box[3], (box, other))
                boxes.append(box)


if __name__ == "__main__":
    unittest.main()
