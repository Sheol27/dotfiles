#!/usr/bin/env python3
import json
import subprocess
import sys

ICONS = {"Playing": "", "Paused": ""}
FMT = "{{status}}\t{{playerName}}\t{{artist}}\t{{title}}"


def emit(status, player="", artist="", title=""):
    if status not in ICONS:
        print(json.dumps({"text": "", "class": "stopped"}), flush=True)
        return
    track = " — ".join(x for x in (artist, title) if x) or "Unknown"
    print(json.dumps({
        "text": ICONS[status],
        "tooltip": f"{track}\n<small>{player}</small>",
        "class": status.lower(),
    }), flush=True)


proc = subprocess.Popen(
    ["playerctl", "--follow", "metadata", "--format", FMT],
    stdout=subprocess.PIPE, text=True,
)
emit("")
for line in proc.stdout:
    emit(*line.rstrip("\n").split("\t", 3))
sys.exit(proc.wait())
