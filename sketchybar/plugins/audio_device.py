#!/usr/bin/env python3
"""Classifies the current default audio output device.

Prints: <category> <TAB> <device name>

Categories: airpods | headphones | display | speakers

`SwitchAudioSource` reports the device name but not how it is connected, so the
transport comes from `system_profiler SPAudioDataType`, which carries
`coreaudio_device_transport` and flags the default output in the same call.
"""
import json
import re
import subprocess
import sys

# Bluetooth speakers exist, so a Bluetooth transport alone does not mean
# headphones. Names win over transport when they are unambiguous.
AIRPODS = re.compile(r"airpod", re.I)
HEADPHONE_WORDS = re.compile(
    r"headphone|headset|earbud|earphone|beats|wh-\d|wf-\d|quietcomfort|momentum", re.I
)
SPEAKER_WORDS = re.compile(r"speaker|soundbar|sound bar|homepod|boom|flip|charge", re.I)


def default_output():
    """(name, transport) for the default output device, or (None, None)."""
    try:
        raw = subprocess.run(
            ["system_profiler", "SPAudioDataType", "-json"],
            capture_output=True, text=True, timeout=10,
        ).stdout
        data = json.loads(raw)
    except Exception:
        return None, None

    for block in data.get("SPAudioDataType", []):
        for dev in block.get("_items", []):
            if dev.get("coreaudio_default_audio_output_device") == "spaudio_yes":
                return dev.get("_name"), dev.get("coreaudio_device_transport", "")
    return None, None


def classify(name, transport):
    name = name or ""
    transport = transport or ""

    if AIRPODS.search(name):
        return "airpods"
    if HEADPHONE_WORDS.search(name):
        return "headphones"
    if SPEAKER_WORDS.search(name):
        return "speakers"

    if "bluetooth" in transport:
        # Unrecognised Bluetooth audio is far more often headphones than a speaker.
        return "headphones"
    if "hdmi" in transport or "displayport" in transport:
        return "display"
    # builtin / usb / virtual / unknown
    return "speakers"


def main():
    name, transport = default_output()
    if name is None:
        # Fall back to the name alone; better a correct name than nothing.
        try:
            name = subprocess.run(
                ["SwitchAudioSource", "-c", "-t", "output"],
                capture_output=True, text=True, timeout=5,
            ).stdout.strip()
        except Exception:
            name = ""
        if not name:
            return 1
        transport = ""
    print(f"{classify(name, transport)}\t{name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
