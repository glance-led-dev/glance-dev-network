import os
import sqlite3
import tempfile
import unittest
from contextlib import closing

from app import create_app


class Clock:
    def __init__(self, value=1_800_000_000):
        self.value = value

    def __call__(self):
        return self.value


class PixelPilgrimServiceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.clock = Clock()
        self.calls = []
        places = {"10001": ("NEW YORK", "NY"), "33602": ("TAMPA", "FL")}

        def geocoder(zip_code):
            self.calls.append(zip_code)
            return places.get(zip_code)

        os.environ["PILGRIM_HASH_KEY"] = "test-only-key"
        self.db_path = os.path.join(self.temp.name, "test.db")
        self.app = create_app(
            database_path=self.db_path,
            geocoder=geocoder,
            clock=self.clock,
        )
        self.client = self.app.test_client()

    def tearDown(self):
        self.temp.cleanup()

    def test_rejects_invalid_zip(self):
        response = self.client.get("/v1/journey?zip=ABC")
        self.assertEqual(response.status_code, 400)

    def test_registers_city_without_returning_zip_or_token(self):
        response = self.client.get("/v1/journey?zip=10001")
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data["current"], {"city": "NEW YORK", "state": "NY"})
        self.assertTrue(data["is_here"])
        self.assertNotIn("zip", str(data).lower())
        self.assertNotIn("token", data)

    def test_duplicate_zip_is_idempotent(self):
        self.client.get("/v1/journey?zip=10001")
        self.client.get("/v1/journey?zip=10001")
        self.assertEqual(self.calls.count("10001"), 1)

    def test_database_stores_token_and_city_but_not_raw_zip(self):
        self.client.get("/v1/journey?zip=10001")
        with closing(sqlite3.connect(self.db_path)) as conn:
            token, city, state = conn.execute(
                "SELECT token, city, state FROM stops"
            ).fetchone()
        self.assertEqual((city, state), ("NEW YORK", "NY"))
        self.assertNotEqual(token, "10001")
        self.assertNotIn("10001", token)

    def test_pilgrim_advances_to_next_city_after_six_hours(self):
        self.client.get("/v1/journey?zip=10001")
        before = self.client.get("/v1/journey?zip=33602").get_json()
        self.assertEqual(before["current"]["city"], "NEW YORK")
        self.assertEqual(before["local"]["city"], "TAMPA")
        self.assertFalse(before["is_here"])

        self.clock.value += 6 * 60 * 60 + 1
        after = self.client.get("/v1/journey?zip=33602").get_json()
        self.assertEqual(after["current"]["city"], "TAMPA")
        self.assertEqual(after["previous"]["city"], "NEW YORK")
        self.assertTrue(after["is_here"])


if __name__ == "__main__":
    unittest.main()
