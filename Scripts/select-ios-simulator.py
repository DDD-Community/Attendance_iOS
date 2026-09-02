#!/usr/bin/env python3

"""Print the destination for the newest available iPhone simulator."""

import json
import re
import subprocess
import sys


def runtime_version(identifier: str) -> tuple[int, ...]:
    return tuple(map(int, re.findall(r"\d+", identifier)))


def load_simulators() -> dict:
    if not sys.stdin.isatty():
        stdin = sys.stdin.read().strip()
        if stdin:
            return json.loads(stdin)

    output = subprocess.check_output(
        ["xcrun", "simctl", "list", "devices", "available", "--json"],
        text=True,
    )
    return json.loads(output)


devices_by_runtime = load_simulators().get("devices", {})
for runtime in sorted(devices_by_runtime, key=runtime_version, reverse=True):
    available_iphones = [
        device
        for device in devices_by_runtime[runtime]
        if device.get("isAvailable", True)
        and device.get("name", "").startswith("iPhone")
    ]

    # 개발자가 사용 중인 Booted 기기를 CI가 가져가지 않도록 유휴 기기를 우선한다.
    available_iphones.sort(key=lambda device: device.get("state") != "Shutdown")
    if available_iphones:
        print(f"platform=iOS Simulator,id={available_iphones[0]['udid']}")
        raise SystemExit

raise SystemExit("사용 가능한 iPhone 시뮬레이터가 없습니다.")
