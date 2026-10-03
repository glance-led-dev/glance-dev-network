#!/usr/bin/env python3
"""Estimate the encoded Glance settings descriptor before submission."""

from argparse import ArgumentParser
from urllib.parse import quote


LIMIT = 255


def main() -> int:
    parser = ArgumentParser()
    parser.add_argument("--state", default="IL")
    parser.add_argument("--city", default="SPRINGFIELD")
    parser.add_argument("--school", default="SACRED-HEART-GRIFFIN-CYCLONES")
    parser.add_argument("--sport", default="F")
    parser.add_argument("--timezone", default="C")
    parser.add_argument("--frequency", default="30")
    parser.add_argument("--encrypted-token-length", type=int, default=132)
    args = parser.parse_args()

    token = "X" * args.encrypted_token_length
    descriptor = (
        "GDN:192:32:gdn_hss:1:300:"
        f"s-{args.sport.upper()}_k-{token}_a-{args.state.upper()}_"
        f"c-{args.city.upper()}_n-{args.school.upper()}_"
        f"z-{args.timezone.upper()}_f-{args.frequency}"
    )
    encoded_length = len(quote(descriptor, safe="-_.~"))
    remaining = LIMIT - encoded_length
    print(f"Encoded descriptor length: {encoded_length}/{LIMIT}")
    print(f"Remaining characters: {remaining}")
    if remaining < 0:
        print("FAIL: settings exceed the device limit")
        return 1
    print("PASS: settings fit within the device limit")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
