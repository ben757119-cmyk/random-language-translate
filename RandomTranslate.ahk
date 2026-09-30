; Random Language Translate — AutoHotkey v2
; Highlight text anywhere → Ctrl+Shift+Y → random non-English language
;
; Requires: AutoHotkey v2  https://www.autohotkey.com/

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ── Config ──────────────────────────────────────────────────
HOTKEY := "^+y"   ; Ctrl+Shift+Y

; Language list: code | name | flag
LANGS := [
    Map("code", "es", "name", "Spanish", "flag", "🇪🇸"),
    Map("code", "fr", "name", "French", "flag", "🇫🇷"),
    Map("code", "de", "name", "German", "flag", "🇩🇪"),
    Map("code", "it", "name", "Italian", "flag", "🇮🇹"),
    Map("code", "pt", "name", "Portuguese", "flag", "🇵🇹"),
    Map("code", "ru", "name", "Russian", "flag", "🇷🇺"),
    Map("code", "ja", "name", "Japanese", "flag", "🇯🇵"),
    Map("code", "ko", "name", "Korean", "flag", "🇰🇷"),
    Map("code", "zh-CN", "name", "Chinese", "flag", "🇨🇳"),
    Map("code", "ar", "name", "Arabic", "flag", "🇸🇦"),
    Map("code", "hi", "name", "Hindi", "flag", "🇮🇳"),
    Map("code", "tr", "name", "Turkish", "flag", "🇹🇷"),
    Map("code", "pl", "name", "Polish", "flag", "🇵🇱"),
    Map("code", "nl", "name", "Dutch", "flag", "🇳🇱"),
    Map("code", "sv", "name", "Swedish", "flag", "🇸🇪"),
    Map("code", "uk", "name", "Ukrainian", "flag", "🇺🇦"),
    Map("code", "vi", "name", "Vietnamese", "flag", "🇻🇳"),
    Map("code", "th", "name", "Thai", "flag", "🇹🇭"),
    Map("code", "id", "name", "Indonesian", "flag", "🇮🇩"),
    Map("code", "cs", "name", "Czech", "flag", "🇨🇿"),
    Map("code", "ro", "name", "Romanian", "flag", "🇷🇴"),
    Map("code", "el", "name", "Greek", "flag", "🇬🇷"),
    Map("code", "he", "name", "Hebrew", "flag", "🇮🇱"),
    Map("code", "fi", "name", "Finnish", "flag", "🇫🇮"),
    Map("code", "da", "name", "Danish", "flag", "🇩🇰"),
    Map("code", "no", "name", "Norwegian", "flag", "🇳🇴"),
    Map("code", "hu", "name", "Hungarian", "flag", "🇭🇺"),
    Map("code", "sw", "name", "Swahili", "flag", "🇰🇪"),
    Map("code", "bn", "name", "Bengali", "flag", "🇧🇩"),
    Map("code", "fa", "name", "Persian", "flag", "🇮🇷")
]

; ── Tray ───────────────────────────────────────────────────
A_IconTip := "Random Translate  |  Ctrl+Shift+Y"
Tray := A_TrayMenu
Tray.Delete()
Tray.Add("Random Translate", (*) => 0)
Tray.Disable("Random Translate")
Tray.Add()
Tray.Add("Translate selection`tCtrl+Shift+Y", (*) => DoTranslate())
Tray.Add()
Tray.Add("Exit", (*) => ExitApp())

; ── Hotkey ──────────────────────────────────────────────
Hotkey HOTKEY, DoTranslate

; ── Core ──────────────────────────────────────────────────
DoTranslate(*) {
    ; Save clipboard
    saved := ClipboardAll()
    A_Clipboard := ""

    ; Copy selection
    Send "^c"
    if !ClipWait(0.8) {
        ShowTip("No text selected", true)
        A_Clipboard := saved
        return
    }

    text := A_Clipboard
    if !Trim(text) {
        ShowTip("No text selected", true)
        A_Clipboard := saved
        return
    }

    ShowTip("Translating…")

    lang := LANGS[Random(1, LANGS.Length)]
    try {
        translated := TranslateText(text, lang["code"])
    } catch as err {
        ShowTip("Error: " err.Message, true)
        A_Clipboard := saved
        return
    }

    if !translated {
        ShowTip("Translation failed", true)
        A_Clipboard := saved
        return
    }

    ; Paste result
    A_Clipboard := translated
    Sleep 40
    Send "^v"
    Sleep 80

    ; Restore original clipboard after a moment
    SetTimer(() => (A_Clipboard := saved), -500)

    ShowTip(lang["flag"] "  " lang["name"])
}

TranslateText(text, tl) {
    ; Google Chrome dictionary translate endpoint (reliable, no API key)
    url := "https://clients5.google.com/translate_a/t?client=dict-chrome-ex"
        . "&sl=auto&tl=" . UriEncode(tl)
        . "&q=" . UriEncode(text)

    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    whr.Open("GET", url, false)
    whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0")
    whr.Send()

    if whr.Status != 200
        throw Error("HTTP " whr.Status)

    body := whr.ResponseText
    ; Response shapes:
    ;   [["translated","en"]]
    ;   ["translated","en"]
    if RegExMatch(body, "^\s*\[\s*\[\s*\"(.*?)\"", &m)
        return UnescapeJson(m[1])
    if RegExMatch(body, "^\s*\[\s*\"(.*?)\"", &m)
        return UnescapeJson(m[1])

    throw Error("Unexpected response")
}

UnescapeJson(s) {
    s := StrReplace(s, "\\\"", "\"")
    s := StrReplace(s, "\\n", "`n")
    s := StrReplace(s, "\\r", "`r")
    s := StrReplace(s, "\\t", "`t")
    s := StrReplace(s, "\\\\", "\")
    return s
}

UriEncode(str) {
    out := ""
    buf := Buffer(StrPut(str, "UTF-8") - 1)
    StrPut(str, buf, "UTF-8")
    loop buf.Size {
        b := NumGet(buf, A_Index - 1, "UChar")
        if (b >= 0x41 && b <= 0x5A)  ; A-Z
            || (b >= 0x61 && b <= 0x7A)  ; a-z
            || (b >= 0x30 && b <= 0x39)  ; 0-9
            || b == 0x2D || b == 0x5F || b == 0x2E || b == 0x7E
            out .= Chr(b)
        else
            out .= Format("%{:02X}", b)
    }
    return out
}

; ── Simple on-screen tip ───────────────────────────────
ShowTip(msg, isError := false) {
    static tipGui := 0
    if tipGui {
        try tipGui.Destroy()
    }
    tipGui := Gui("+AlwaysOnTop -Caption +ToolWindow +Border")
    tipGui.BackColor := isError ? "C0392B" : "1A1A2E"
    tipGui.SetFont("s11 cWhite", "Segoe UI")
    tipGui.Add("Text", "w260 Center", msg)
    tipGui.Show("NoActivate AutoSize")
    ; position bottom-center
    tipGui.GetPos(, , &w, &h)
    x := (A_ScreenWidth - w) // 2
    y := A_ScreenHeight - h - 80
    tipGui.Show("x" x " y" y " NoActivate")
    SetTimer(() => (tipGui ? (tipGui.Destroy(), tipGui := 0) : 0), -2200)
}

; Startup notice
ShowTip("Random Translate ready`nCtrl+Shift+Y")
