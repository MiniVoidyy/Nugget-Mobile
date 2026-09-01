"""Export daemon definitions from GoldenNugget's daemons_tweak.py into
Nugget/Files/daemons.json for the on-device daemon disabler.

Keeps the iOS fork's catalog in sync with the desktop app. Point
GOLDENNUGGET_SRC at the GoldenNugget checkout root (the directory whose
`src` package contains src/tweaks/daemons_tweak.py), e.g.:

    GOLDENNUGGET_SRC=~/GoldenNugget python Scripts/export_daemons_json.py
"""
import json
import os
import sys

SRC = os.environ.get("GOLDENNUGGET_SRC")
if not SRC:
    raise SystemExit("Set GOLDENNUGGET_SRC to the GoldenNugget repo root")
sys.path.insert(0, SRC)

from src.tweaks.daemons_tweak import (  # noqa: E402
    Daemon,
    DAEMON_CATEGORY,
    DAEMON_TITLES,
    DAEMON_DESCRIPTIONS,
    RECOMMENDED_ANALYTICS,
    DaemonCategory,
)


def main():
    out = []
    for daemon in Daemon:
        category = DAEMON_CATEGORY.get(daemon, DaemonCategory.OTHER)
        out.append({
            "name": daemon.name,
            "labels": list(daemon.value),
            "category": category.name,
            "title": DAEMON_TITLES.get(daemon, daemon.name),
            "description": DAEMON_DESCRIPTIONS.get(daemon.name, ""),
        })

    payload = {
        "generated_from": "src/tweaks/daemons_tweak.py",
        "recommended": [d.name for d in RECOMMENDED_ANALYTICS],
        "daemons": out,
    }

    dest = os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        "..", "Nugget", "Files", "daemons.json",
    )
    with open(dest, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    print(f"Wrote {len(out)} daemons to {dest}")


if __name__ == "__main__":
    main()