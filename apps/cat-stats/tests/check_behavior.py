"""Offline endpoint regression checks for every Cat Stats page.

Run: py -3.14 -B apps/cat-stats/tests/check_behavior.py
This harness adapts only Starlark type names and .elems() for Python execution.
Use GDN validation as well to check the actual Starlark runtime.
"""
from pathlib import Path
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch


ROOT = Path(__file__).resolve().parents[1]
NOW = 1800000000
KEY = "test-only-key"
MANIFEST = ROOT.joinpath("manifest.yaml").read_text(encoding="utf-8")
PAGES = next(line for line in MANIFEST.splitlines() if line.startswith("pages: "))
PAGES = PAGES.split("[", 1)[1].split("]", 1)[0].split(", ")
SCENARIOS = next(line for line in MANIFEST.splitlines() if "choices: [Live," in line)
SCENARIOS = SCENARIOS.split("[", 1)[1].split("]", 1)[0].split(", ")[1:]
TYPE_NAMES = {dict: "dict", list: "list", str: "string", int: "int", float: "float", bool: "bool"}
ns = {"type": lambda value: TYPE_NAMES.get(type(value), type(value).__name__)}
exec(compile(ROOT.joinpath("app.star").read_text(encoding="utf-8").replace(".elems()", ""), "app.star", "exec"), ns)


class Canvas:
    def __init__(self):
        self.texts = []

    def fill(self, *args, **kwargs): pass
    def rect(self, *args, **kwargs): pass
    def line(self, *args, **kwargs): pass
    def image(self, *args, **kwargs): pass
    def text_width(self, value, font): return len(value) * (6 if font == "5x7" else 5)
    def text(self, value, *args, **kwargs): self.texts.append(value)


def context(inputs):
    return SimpleNamespace(inputs=inputs, now=SimpleNamespace(unix=NOW))


def sample_data():
    data = ns["demo_data"](context({"demo": "Demo"}))
    data["demo"] = False
    return data


def render(page, inputs, response=None):
    get = Mock(return_value=response) if response is not None else Mock(side_effect=AssertionError("Unexpected HTTP request"))
    canvas = Canvas()
    with patch.dict(ns, http=SimpleNamespace(get=get)):
        ns[page](canvas, context(inputs))
    return canvas, get


class EndpointBehavior(unittest.TestCase):
    def test_hostname_and_https_render_identically_on_every_page(self):
        response = {"status_code": 200, "json": sample_data()}
        for page in PAGES:
            baseline, _ = render(page, {"endpoint": "https://example.invalid/status", "readkey": KEY}, response)
            for endpoint in ["example.invalid/status", "  example.invalid/status  ", "https://example.invalid/status"]:
                with self.subTest(page=page, endpoint=endpoint):
                    inputs = {"endpoint": endpoint, "readkey": KEY, "demo": "Live"}
                    canvas, get = render(page, inputs, response)
                    self.assertEqual(canvas.texts, baseline.texts)
                    get.assert_called_once_with("https://example.invalid/status", headers={"x-api-key": KEY}, ttl_seconds=300)
                    self.assertEqual(inputs["endpoint"], endpoint)
                    self.assertNotIn(KEY, " ".join(canvas.texts))

    def test_hostname_path_and_query_are_preserved(self):
        endpoint = "your-worker.your-subdomain.workers.dev/status?view=cat"
        _, get = render("summary", {"endpoint": endpoint, "readkey": KEY}, {"status_code": 200, "json": sample_data()})
        get.assert_called_once_with("https://" + endpoint, headers={"x-api-key": KEY}, ttl_seconds=300)

    def test_invalid_endpoints_never_send_credentials(self):
        invalid = ["https", "http://example.invalid/status", "example.invalid:8080/status", "//example.invalid/status", "user@example.invalid/status", "example.invalid\\@other.invalid/status", "example.invalid/status#fragment", "example.invalid/with space", "example.invalid/status?url=https://other.invalid", "example..invalid/status", "-example.invalid/status", "example-.invalid/status", "example%2finvalid/status", 123]
        for page in PAGES:
            for endpoint in invalid:
                with self.subTest(page=page, endpoint=endpoint):
                    canvas, get = render(page, {"endpoint": endpoint, "readkey": KEY})
                    self.assertIn("HTTPS REQUIRED", canvas.texts)
                    get.assert_not_called()

    def test_missing_settings_never_request_data(self):
        for page in PAGES:
            for inputs in [{}, {"endpoint": "example.invalid/status"}, {"readkey": KEY}]:
                with self.subTest(page=page, inputs=list(inputs)):
                    canvas, get = render(page, inputs)
                    self.assertIn("SETUP REQUIRED", canvas.texts)
                    get.assert_not_called()

    def test_all_demo_pages_bypass_endpoint_and_key(self):
        for page in PAGES:
            for scenario in SCENARIOS:
                with self.subTest(page=page, scenario=scenario):
                    canvas, get = render(page, {"demo": scenario, "endpoint": "https"})
                    self.assertNotIn("SETUP REQUIRED", canvas.texts)
                    self.assertNotIn("HTTPS REQUIRED", canvas.texts)
                    self.assertTrue(canvas.texts)
                    get.assert_not_called()

    def test_http_and_schema_errors_still_show_fallback(self):
        responses = [{"status_code": status} for status in [0, 401, 500]]
        responses += [{"status_code": 200, "json": value} for value in [None, [], {"schema_version": 2}]]
        for page in PAGES:
            for response in responses:
                with self.subTest(page=page, response=response):
                    canvas, get = render(page, {"endpoint": "example.invalid/status", "readkey": KEY}, response)
                    self.assertIn("NO CAT DATA", canvas.texts)
                    get.assert_called_once()

    def test_stale_data_still_rejected(self):
        data = sample_data()
        data["generated_at"] = NOW - 901
        for page in PAGES:
            with self.subTest(page=page):
                canvas, _ = render(page, {"endpoint": "example.invalid/status", "readkey": KEY}, {"status_code": 200, "json": data})
                self.assertIn("DATA STALE", canvas.texts)


if __name__ == "__main__":
    unittest.main()
