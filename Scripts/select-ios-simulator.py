#!/usr/bin/env python3

"""Print the destination for the newest available iPhone simulator."""

import json
import re
import sys


def runtime_version(identifier: str) -> tuple[int, ...]:
    return tuple(map(int, re.findall(r"\d+", identifier)))


devices_by_runtime = json.load(sys.stdin).get("devices", {})
for runtime in sorted(devices_by_runtime, key=runtime_version, reverse=True):
    for device in devices_by_runtime[runtime]:
        if device.get("isAvailable") and device.get("name", "").startswith("iPhone"):
            print(f"platform=iOS Simulator,id={device['udid']}")
            raise SystemExit

raise SystemExit("사용 가능한 iPhone 시뮬레이터가 없습니다.")
