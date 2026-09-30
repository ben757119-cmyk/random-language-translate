# Random Language Translate

**Highlight any text anywhere on Windows → press a hotkey → it becomes a random non-English language.**

Works in Chrome, Discord, Notepad, Word, Slack, games with text fields — anything.

No browser extension. No DLL injection. Just a small system tool.

---

## Quick start (recommended)

### Option A — AutoHotkey (easiest)

1. Install [AutoHotkey v2](https://www.autohotkey.com/)
2. Download [`RandomTranslate.ahk`](RandomTranslate.ahk)
3. Double-click it
4. Highlight text anywhere and press **Ctrl+Shift+Y**

A tray icon appears. Right-click it to exit.

### Option B — Python (no AutoHotkey needed)

```bash
pip install keyboard pyperclip requests
python random_translate.py
```

Same hotkey: **Ctrl+Shift+Y**

---

## How it works

1. You highlight text
2. Press **Ctrl+Shift+Y**
3. Tool copies the selection (Ctrl+C)
4. Translates it to a **random non-English language** via Google’s public translate endpoint
5. Pastes the result back (Ctrl+V)

English is never chosen as the target.

---

## Hotkey

| Action | Keys |
|--------|------|
| Translate selection | `Ctrl + Shift + Y` |

Change it in the script if you want.

---

## Privacy

- Nothing is stored
- Only network call is the one-time translation when you press the hotkey
- No accounts, no tracking

---

## Why not a Chrome extension / DLL injector?

Browser extensions are restricted by each site and by Chrome’s sandbox.  
DLL injectors into Chrome are fragile, break on updates, and get flagged by antivirus.

A system-wide hotkey tool is simpler and actually reliable.

---

## Files

| File | Purpose |
|------|---------|
| `RandomTranslate.ahk` | Main AutoHotkey v2 script |
| `random_translate.py` | Python alternative |
| `languages.json` | Language list (shared) |

---

## License

MIT — do whatever you want.
