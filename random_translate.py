#!/usr/bin/env python3
"""
Random Language Translate — Python version
Highlight text anywhere on Windows → Ctrl+Shift+Y → random non-English language

Requires:
    pip install keyboard pyperclip requests

Run:
    python random_translate.py
"""

from __future__ import annotations

import json
import random
import sys
import time
import urllib.parse

try:
    import keyboard
    import pyperclip
    import requests
except ImportError:
    print("Install deps first:")
    print("  pip install keyboard pyperclip requests")
    sys.exit(1)

LANGS = [
    {"code": "es", "name": "Spanish", "flag": "\U0001F1EA\U0001F1F8"},
    {"code": "fr", "name": "French", "flag": "\U0001F1EB\U0001F1F7"},
    {"code": "de", "name": "German", "flag": "\U0001F1E9\U0001F1EA"},
    {"code": "it", "name": "Italian", "flag": "\U0001F1EE\U0001F1F9"},
    {"code": "pt", "name": "Portuguese", "flag": "\U0001F1F5\U0001F1F9"},
    {"code": "ru", "name": "Russian", "flag": "\U0001F1F7\U0001F1FA"},
    {"code": "ja", "name": "Japanese", "flag": "\U0001F1EF\U0001F1F5"},
    {"code": "ko", "name": "Korean", "flag": "\U0001F1F0\U0001F1F7"},
    {"code": "zh-CN", "name": "Chinese", "flag": "\U0001F1E8\U0001F1F3"},
    {"code": "ar", "name": "Arabic", "flag": "\U0001F1F8\U0001F1E6"},
    {"code": "hi", "name": "Hindi", "flag": "\U0001F1EE\U0001F1F3"},
    {"code": "tr", "name": "Turkish", "flag": "\U0001F1F9\U0001F1F7"},
    {"code": "pl", "name": "Polish", "flag": "\U0001F1F5\U0001F1F1"},
    {"code": "nl", "name": "Dutch", "flag": "\U0001F1F3\U0001F1F1"},
    {"code": "sv", "name": "Swedish", "flag": "\U0001F1F8\U0001F1EA"},
    {"code": "uk", "name": "Ukrainian", "flag": "\U0001F1FA\U0001F1E6"},
    {"code": "vi", "name": "Vietnamese", "flag": "\U0001F1FB\U0001F1F3"},
    {"code": "th", "name": "Thai", "flag": "\U0001F1F9\U0001F1ED"},
    {"code": "id", "name": "Indonesian", "flag": "\U0001F1EE\U0001F1E9"},
    {"code": "cs", "name": "Czech", "flag": "\U0001F1E8\U0001F1FF"},
    {"code": "ro", "name": "Romanian", "flag": "\U0001F1F7\U0001F1F4"},
    {"code": "el", "name": "Greek", "flag": "\U0001F1EC\U0001F1F7"},
    {"code": "he", "name": "Hebrew", "flag": "\U0001F1EE\U0001F1F1"},
    {"code": "fi", "name": "Finnish", "flag": "\U0001F1EB\U0001F1EE"},
    {"code": "da", "name": "Danish", "flag": "\U0001F1E9\U0001F1F0"},
    {"code": "no", "name": "Norwegian", "flag": "\U0001F1F3\U0001F1F4"},
    {"code": "hu", "name": "Hungarian", "flag": "\U0001F1ED\U0001F1FA"},
    {"code": "sw", "name": "Swahili", "flag": "\U0001F1F0\U0001F1EA"},
]


def translate(text: str, tl: str) -> str:
    url = (
        "https://clients5.google.com/translate_a/t"
        f"?client=dict-chrome-ex&sl=auto&tl={urllib.parse.quote(tl)}"
        f"&q={urllib.parse.quote(text)}"
    )
    r = requests.get(
        url,
        headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0"},
        timeout=10,
    )
    r.raise_for_status()
    data = r.json()
    # [["translated","en"]] or ["translated","en"]
    if isinstance(data, list):
        if data and isinstance(data[0], str):
            return data[0]
        if data and isinstance(data[0], list) and data[0]:
            return data[0][0] if isinstance(data[0][0], str) else str(data[0][0])
    raise RuntimeError(f"Unexpected response: {data!r}")


def do_translate() -> None:
    saved = None
    try:
        saved = pyperclip.paste()
    except Exception:
        pass

    try:
        pyperclip.copy("")
    except Exception:
        pass

    # Copy selection
    keyboard.send("ctrl+c")
    time.sleep(0.15)

    text = ""
    for _ in range(10):
        try:
            text = pyperclip.paste()
            if text and text.strip():
                break
        except Exception:
            pass
        time.sleep(0.05)

    if not text or not text.strip():
        print("[RTL] No text selected")
        if saved is not None:
            try:
                pyperclip.copy(saved)
            except Exception:
                pass
        return

    lang = random.choice(LANGS)
    print(f"[RTL] Translating → {lang['flag']} {lang['name']} …")

    try:
        out = translate(text, lang["code"])
    except Exception as e:
        print(f"[RTL] Error: {e}")
        if saved is not None:
            try:
                pyperclip.copy(saved)
            except Exception:
                pass
        return

    try:
        pyperclip.copy(out)
        time.sleep(0.05)
        keyboard.send("ctrl+v")
        print(f"[RTL] Done — {lang['flag']} {lang['name']}")
    except Exception as e:
        print(f"[RTL] Paste failed: {e}")

    # Restore clipboard shortly after
    if saved is not None:

        def _restore():
            time.sleep(0.6)
            try:
                pyperclip.copy(saved)
            except Exception:
                pass

        import threading

        threading.Thread(target=_restore, daemon=True).start()


def main() -> None:
    print("Random Language Translate")
    print("Hotkey: Ctrl+Shift+Y")
    print("Highlight text anywhere, then press the hotkey.")
    print("Press Ctrl+C in this window to quit.\n")

    keyboard.add_hotkey("ctrl+shift+y", do_translate, suppress=True)

    try:
        keyboard.wait()
    except KeyboardInterrupt:
        print("\nBye.")


if __name__ == "__main__":
    main()
